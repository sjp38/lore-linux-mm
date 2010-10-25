Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D00328D0002
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 03:26:24 -0400 (EDT)
Date: Mon, 25 Oct 2010 15:26:17 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
Message-ID: <20101025072616.GA5452@localhost>
References: <AANLkTimVu+5gTDs8przJVP2EbWC=FX-zWW7aH08BtrHC@mail.gmail.com>
 <20101020055717.GA12752@localhost>
 <20101020150346.1832.A69D9226@jp.fujitsu.com>
 <20101020092739.GA23869@localhost>
 <4CBEE888.2090606@kernel.dk>
 <20101022053755.GB16804@localhost>
 <20101022080725.GA22594@localhost>
 <4CC146B1.8060906@kernel.dk>
 <20101024165234.GA23508@localhost>
 <20101025174051.31a00481@notabene>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101025174051.31a00481@notabene>
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>
Cc: Jens Axboe <axboe@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Torsten Kaiser <just.for.lkml@googlemail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 25, 2010 at 02:40:51PM +0800, Neil Brown wrote:
> On Mon, 25 Oct 2010 00:52:34 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > On Fri, Oct 22, 2010 at 04:09:21PM +0800, Jens Axboe wrote:
> > > On 2010-10-22 10:07, Wu Fengguang wrote:
> > > >>> We surely need 1 set aside for each level of that stack that will
> > > >>> potentially consume one. 1 should be enough for the generic pool, and
> > > >>> then clones will use a separate pool. So md and friends should really
> > > >>> have a pool per device, so that stacking will always work properly.
> > > >>
> > > >> Agreed for the deadlock problem.
> > > >>
> > > >>> There should be no throughput concerns, it should purely be a safe guard
> > > >>> measure to prevent us deadlocking when doing IO for reclaim.
> > > >>
> > > >> It's easy to verify whether the minimal size will have negative
> > > >> impacts on IO throughput. In Torsten's case, increase BIO_POOL_SIZE
> > > >> by one and check how it performs.
> > > > 
> > > > Sorry it seems simply increasing BIO_POOL_SIZE is not enough to fix
> > > > possible deadlocks. We need adding new mempool(s). Because when there
> > > > BIO_POOL_SIZE=2 and there are two concurrent reclaimers each take 1
> > > > reservation, they will deadlock each other when trying to take the
> > > > next bio at the raid1 level.
> > > 
> > > Yes, plus it's not a practical solution since you don't know how deep
> > > the stack is. As I wrote in the initial email, each consumer needs it's
> > > own private mempool (and just 1 entry should suffice).
> > 
> > You are right. The below scratch patch adds minimal mempool code for raid1.
> > It passed simple stress test of resync + 3 dd writers. Although write
> > throughput is rather slow in my qemu, I don't observe any
> > temporary/permanent stuck ups.
> 
> Hi,
>   thanks for the patch.  I'll make a few changes to what I finally apply -
>   for example we don't really need mempools in r1buf_poll_alloc as that isn't
>   on the writeout path - so I'll tidy that up first.

OK. That change is not absolutely necessary for the deadlock fix.

It's done just in hope of improving things a bit under memory
pressure: r1buf_poll_alloc() allocates N bios at one time, which might
temporarily exhaust BIO_POOL_SIZE. Since that path is independent of
the normal write path, so I simply reuse the r1_bio_set.

>   Also I'll avoid making changes to fs/bio.c at first.  It may still be a
>   good idea to have a bio_clone_bioset, but that should be a separate patch -
>   there are at least 3 places that would use it.

Fair enough. I did the

        fs_bio_set->bio_destructor = bio_fs_destructor;

hack for the same reason: it's better to pass the destructor func as
a parameter to bioset_create(), however that requires changing more
places.

> Thanks - I'll try to get this into the current merge window.

Thank you!

Thanks,
Fengguang

> > 
> >  drivers/md/raid1.c  |   32 ++++++++++++++++++++++++++++----
> >  drivers/md/raid1.h  |    2 ++
> >  fs/bio.c            |   31 +++++++++++++++++++++----------
> >  include/linux/bio.h |    2 ++
> >  4 files changed, 53 insertions(+), 14 deletions(-)
> > 
> > --- linux-next.orig/drivers/md/raid1.c	2010-10-25 00:02:40.000000000 +0800
> > +++ linux-next/drivers/md/raid1.c	2010-10-25 00:28:16.000000000 +0800
> > @@ -76,6 +76,14 @@ static void r1bio_pool_free(void *r1_bio
> >  	kfree(r1_bio);
> >  }
> >  
> > +static void r1_bio_destructor(struct bio *bio)
> > +{
> > +	r1bio_t *r1_bio = bio->bi_private;
> > +	conf_t *conf = r1_bio->mddev->private;
> > +
> > +	bio_free(bio, conf->r1_bio_set);
> > +}
> > +
> >  #define RESYNC_BLOCK_SIZE (64*1024)
> >  //#define RESYNC_BLOCK_SIZE PAGE_SIZE
> >  #define RESYNC_SECTORS (RESYNC_BLOCK_SIZE >> 9)
> > @@ -85,6 +93,7 @@ static void r1bio_pool_free(void *r1_bio
> >  static void * r1buf_pool_alloc(gfp_t gfp_flags, void *data)
> >  {
> >  	struct pool_info *pi = data;
> > +	conf_t *conf = pi->mddev->private;
> >  	struct page *page;
> >  	r1bio_t *r1_bio;
> >  	struct bio *bio;
> > @@ -100,7 +109,8 @@ static void * r1buf_pool_alloc(gfp_t gfp
> >  	 * Allocate bios : 1 for reading, n-1 for writing
> >  	 */
> >  	for (j = pi->raid_disks ; j-- ; ) {
> > -		bio = bio_alloc(gfp_flags, RESYNC_PAGES);
> > +		bio = bio_alloc_bioset(gfp_flags, RESYNC_PAGES,
> > +				       conf->r1_bio_set);
> >  		if (!bio)
> >  			goto out_free_bio;
> >  		r1_bio->bios[j] = bio;
> > @@ -386,6 +396,10 @@ static void raid1_end_write_request(stru
> >  				!test_bit(R1BIO_Degraded, &r1_bio->state),
> >  				behind);
> >  		md_write_end(r1_bio->mddev);
> > +		if (to_put) {
> > +			bio_put(to_put);
> > +			to_put = NULL;
> > +		}
> >  		raid_end_bio_io(r1_bio);
> >  	}
> >  
> > @@ -851,7 +865,7 @@ static int make_request(mddev_t *mddev, 
> >  		}
> >  		r1_bio->read_disk = rdisk;
> >  
> > -		read_bio = bio_clone(bio, GFP_NOIO);
> > +		read_bio = bio_clone_bioset(bio, GFP_NOIO, conf->r1_bio_set);
> >  
> >  		r1_bio->bios[rdisk] = read_bio;
> >  
> > @@ -946,7 +960,7 @@ static int make_request(mddev_t *mddev, 
> >  		if (!r1_bio->bios[i])
> >  			continue;
> >  
> > -		mbio = bio_clone(bio, GFP_NOIO);
> > +		mbio = bio_clone_bioset(bio, GFP_NOIO, conf->r1_bio_set);
> >  		r1_bio->bios[i] = mbio;
> >  
> >  		mbio->bi_sector	= r1_bio->sector + conf->mirrors[i].rdev->data_offset;
> > @@ -1646,7 +1660,9 @@ static void raid1d(mddev_t *mddev)
> >  					mddev->ro ? IO_BLOCKED : NULL;
> >  				r1_bio->read_disk = disk;
> >  				bio_put(bio);
> > -				bio = bio_clone(r1_bio->master_bio, GFP_NOIO);
> > +				bio = bio_clone_bioset(r1_bio->master_bio,
> > +						       GFP_NOIO,
> > +						       conf->r1_bio_set);
> >  				r1_bio->bios[r1_bio->read_disk] = bio;
> >  				rdev = conf->mirrors[disk].rdev;
> >  				if (printk_ratelimit())
> > @@ -1948,6 +1964,10 @@ static conf_t *setup_conf(mddev_t *mddev
> >  					  conf->poolinfo);
> >  	if (!conf->r1bio_pool)
> >  		goto abort;
> > +	conf->r1_bio_set = bioset_create(mddev->raid_disks * 2, 0);
> > +	if (!conf->r1_bio_set)
> > +		goto abort;
> > +	conf->r1_bio_set->bio_destructor = r1_bio_destructor;
> >  
> >  	conf->poolinfo->mddev = mddev;
> >  
> > @@ -2012,6 +2032,8 @@ static conf_t *setup_conf(mddev_t *mddev
> >  	if (conf) {
> >  		if (conf->r1bio_pool)
> >  			mempool_destroy(conf->r1bio_pool);
> > +		if (conf->r1_bio_set)
> > +			bioset_free(conf->r1_bio_set);
> >  		kfree(conf->mirrors);
> >  		safe_put_page(conf->tmppage);
> >  		kfree(conf->poolinfo);
> > @@ -2121,6 +2143,8 @@ static int stop(mddev_t *mddev)
> >  	blk_sync_queue(mddev->queue); /* the unplug fn references 'conf'*/
> >  	if (conf->r1bio_pool)
> >  		mempool_destroy(conf->r1bio_pool);
> > +	if (conf->r1_bio_set)
> > +		bioset_free(conf->r1_bio_set);
> >  	kfree(conf->mirrors);
> >  	kfree(conf->poolinfo);
> >  	kfree(conf);
> > --- linux-next.orig/fs/bio.c	2010-10-25 00:02:39.000000000 +0800
> > +++ linux-next/fs/bio.c	2010-10-25 00:03:37.000000000 +0800
> > @@ -306,6 +306,7 @@ out_set:
> >  	bio->bi_flags |= idx << BIO_POOL_OFFSET;
> >  	bio->bi_max_vecs = nr_iovecs;
> >  	bio->bi_io_vec = bvl;
> > +	bio->bi_destructor = bs->bio_destructor;
> >  	return bio;
> >  
> >  err_free:
> > @@ -340,12 +341,7 @@ static void bio_fs_destructor(struct bio
> >   */
> >  struct bio *bio_alloc(gfp_t gfp_mask, int nr_iovecs)
> >  {
> > -	struct bio *bio = bio_alloc_bioset(gfp_mask, nr_iovecs, fs_bio_set);
> > -
> > -	if (bio)
> > -		bio->bi_destructor = bio_fs_destructor;
> > -
> > -	return bio;
> > +	return bio_alloc_bioset(gfp_mask, nr_iovecs, fs_bio_set);
> >  }
> >  EXPORT_SYMBOL(bio_alloc);
> >  
> > @@ -460,20 +456,21 @@ void __bio_clone(struct bio *bio, struct
> >  EXPORT_SYMBOL(__bio_clone);
> >  
> >  /**
> > - *	bio_clone	-	clone a bio
> > + *	bio_clone_bioset	-	clone a bio
> >   *	@bio: bio to clone
> >   *	@gfp_mask: allocation priority
> > + *	@bs: bio_set to allocate from
> >   *
> >   * 	Like __bio_clone, only also allocates the returned bio
> >   */
> > -struct bio *bio_clone(struct bio *bio, gfp_t gfp_mask)
> > +struct bio *
> > +bio_clone_bioset(struct bio *bio, gfp_t gfp_mask, struct bio_set *bs)
> >  {
> > -	struct bio *b = bio_alloc_bioset(gfp_mask, bio->bi_max_vecs, fs_bio_set);
> > +	struct bio *b = bio_alloc_bioset(gfp_mask, bio->bi_max_vecs, bs);
> >  
> >  	if (!b)
> >  		return NULL;
> >  
> > -	b->bi_destructor = bio_fs_destructor;
> >  	__bio_clone(b, bio);
> >  
> >  	if (bio_integrity(bio)) {
> > @@ -489,6 +486,19 @@ struct bio *bio_clone(struct bio *bio, g
> >  
> >  	return b;
> >  }
> > +EXPORT_SYMBOL(bio_clone_bioset);
> > +
> > +/**
> > + *	bio_clone	-	clone a bio
> > + *	@bio: bio to clone
> > + *	@gfp_mask: allocation priority
> > + *
> > + *	Like __bio_clone, only also allocates the returned bio
> > + */
> > +struct bio *bio_clone(struct bio *bio, gfp_t gfp_mask)
> > +{
> > +	return bio_clone_bioset(bio, gfp_mask, fs_bio_set);
> > +}
> >  EXPORT_SYMBOL(bio_clone);
> >  
> >  /**
> > @@ -1664,6 +1674,7 @@ static int __init init_bio(void)
> >  	fs_bio_set = bioset_create(BIO_POOL_SIZE, 0);
> >  	if (!fs_bio_set)
> >  		panic("bio: can't allocate bios\n");
> > +	fs_bio_set->bio_destructor = bio_fs_destructor;
> >  
> >  	bio_split_pool = mempool_create_kmalloc_pool(BIO_SPLIT_ENTRIES,
> >  						     sizeof(struct bio_pair));
> > --- linux-next.orig/include/linux/bio.h	2010-10-25 00:02:40.000000000 +0800
> > +++ linux-next/include/linux/bio.h	2010-10-25 00:03:37.000000000 +0800
> > @@ -227,6 +227,7 @@ extern int bio_phys_segments(struct requ
> >  
> >  extern void __bio_clone(struct bio *, struct bio *);
> >  extern struct bio *bio_clone(struct bio *, gfp_t);
> > +extern struct bio *bio_clone_bioset(struct bio *, gfp_t, struct bio_set *);
> >  
> >  extern void bio_init(struct bio *);
> >  
> > @@ -299,6 +300,7 @@ struct bio_set {
> >  	mempool_t *bio_integrity_pool;
> >  #endif
> >  	mempool_t *bvec_pool;
> > +	bio_destructor_t	*bio_destructor;
> >  };
> >  
> >  struct biovec_slab {
> > --- linux-next.orig/drivers/md/raid1.h	2010-10-25 00:02:40.000000000 +0800
> > +++ linux-next/drivers/md/raid1.h	2010-10-25 00:03:37.000000000 +0800
> > @@ -60,6 +60,8 @@ struct r1_private_data_s {
> >  	mempool_t *r1bio_pool;
> >  	mempool_t *r1buf_pool;
> >  
> > +	struct bio_set *r1_bio_set;
> > +
> >  	/* When taking over an array from a different personality, we store
> >  	 * the new thread here until we fully activate the array.
> >  	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

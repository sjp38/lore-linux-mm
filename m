Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 586316B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 10:34:52 -0400 (EDT)
Date: Mon, 13 May 2013 11:34:41 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [RFC 2/2] virtio_balloon: auto-ballooning support
Message-ID: <20130513143441.GA13910@optiplex.redhat.com>
References: <1368111229-29847-1-git-send-email-lcapitulino@redhat.com>
 <1368111229-29847-3-git-send-email-lcapitulino@redhat.com>
 <20130509211516.GC16446@optiplex.redhat.com>
 <20130510092046.17be9bbb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130510092046.17be9bbb@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, riel@redhat.com, mst@redhat.com, amit.shah@redhat.com, anton@enomsg.org

On Fri, May 10, 2013 at 09:20:46AM -0400, Luiz Capitulino wrote:
> On Thu, 9 May 2013 18:15:19 -0300
> Rafael Aquini <aquini@redhat.com> wrote:
> 
> > Since your shrinker
> > doesn't change the balloon target size,
> 
> Which target size are you referring to? The one in the host (member num_pages
> of VirtIOBalloon in QEMU)?
>

Yes, I'm referring to the struct virtio_balloon_config->num_pages element,
which basically is the balloon size target. Guest's struct
virtio_balloon->num_pages is just a book keeping element to allow the guest
balloon thread to track how far it is from achieving the target set by the host,
IIUC.
 
> If it the one in the host, then my understanding is that that member is only
> used to communicate the new balloon target to the guest. The guest driver
> will only read it when told (by the host) to do so, and when it does the
> target value will be correct.
>
> Am I right?
> 

You're right, and the host's member is used to communicate the configured size
to guest's balloon device, however, by not changing it when the shrinker causes 
the balloon to deflate will make the balloon thread to be woken up again 
in order to chase the balloon size target again, won't it? Check
towards_target() and balloon() and you will see from where my concern arises.

Cheers!
-- Rafael

 
> > as soon as the shrink round finishes the
> > balloon will re-inflate again, won't it? Doesn't this cause a sort of "balloon
> > thrashing" scenario, if both guest and host are suffering from memory pressure?
> > 
> > 
> > The rest I have for the moment, are only nitpicks :)
> > 
> > 
> > >  drivers/virtio/virtio_balloon.c     | 55 +++++++++++++++++++++++++++++++++++++
> > >  include/uapi/linux/virtio_balloon.h |  1 +
> > >  2 files changed, 56 insertions(+)
> > > 
> > > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > > index 9d5fe2b..f9dcae8 100644
> > > --- a/drivers/virtio/virtio_balloon.c
> > > +++ b/drivers/virtio/virtio_balloon.c
> > > @@ -71,6 +71,9 @@ struct virtio_balloon
> > >  	/* Memory statistics */
> > >  	int need_stats_update;
> > >  	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
> > > +
> > > +	/* Memory shrinker */
> > > +	struct shrinker shrinker;
> > >  };
> > >  
> > >  static struct virtio_device_id id_table[] = {
> > > @@ -126,6 +129,7 @@ static void set_page_pfns(u32 pfns[], struct page *page)
> > >  		pfns[i] = page_to_balloon_pfn(page) + i;
> > >  }
> > >  
> > > +/* This function should be called with vb->balloon_mutex held */
> > >  static void fill_balloon(struct virtio_balloon *vb, size_t num)
> > >  {
> > >  	struct balloon_dev_info *vb_dev_info = vb->vb_dev_info;
> > > @@ -166,6 +170,7 @@ static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
> > >  	}
> > >  }
> > >  
> > > +/* This function should be called with vb->balloon_mutex held */
> > >  static void leak_balloon(struct virtio_balloon *vb, size_t num)
> > >  {
> > >  	struct page *page;
> > > @@ -285,6 +290,45 @@ static void update_balloon_size(struct virtio_balloon *vb)
> > >  			      &actual, sizeof(actual));
> > >  }
> > >  
> > > +static unsigned long balloon_get_nr_pages(const struct virtio_balloon *vb)
> > > +{
> > > +	return vb->num_pages / VIRTIO_BALLOON_PAGES_PER_PAGE;
> > > +}
> > > +
> > > +static int balloon_shrinker(struct shrinker *shrinker,struct shrink_control *sc)
> > > +{
> > > +	unsigned int nr_pages, new_target;
> > > +	struct virtio_balloon *vb;
> > > +
> > > +	vb = container_of(shrinker, struct virtio_balloon, shrinker);
> > > +	if (!mutex_trylock(&vb->balloon_lock)) {
> > > +		return -1;
> > > +	}
> > > +
> > > +	nr_pages = balloon_get_nr_pages(vb);
> > > +	if (!sc->nr_to_scan || !nr_pages) {
> > > +		goto out;
> > > +	}
> > > +
> > > +	/*
> > > +	 * If the current balloon size is greater than the number of
> > > +	 * pages being reclaimed by the kernel, deflate only the needed
> > > +	 * amount. Otherwise deflate everything we have.
> > > +	 */
> > > +	new_target = 0;
> > > +	if (nr_pages > sc->nr_to_scan) {
> > > +		new_target = nr_pages - sc->nr_to_scan;
> > > +	}
> > > +
> > 
> > CodingStyle: you don't need the curly-braces for all these single staments above
> 
> Oh, this comes from QEMU coding style. Fixed.
> 
> > > +	leak_balloon(vb, new_target);
> > > +	update_balloon_size(vb);
> > > +	nr_pages = balloon_get_nr_pages(vb);
> > > +
> > > +out:
> > > +	mutex_unlock(&vb->balloon_lock);
> > > +	return nr_pages;
> > > +}
> > > +
> > >  static int balloon(void *_vballoon)
> > >  {
> > >  	struct virtio_balloon *vb = _vballoon;
> > > @@ -471,6 +515,13 @@ static int virtballoon_probe(struct virtio_device *vdev)
> > >  		goto out_del_vqs;
> > >  	}
> > >  
> > > +	memset(&vb->shrinker, 0, sizeof(vb->shrinker));
> > > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_AUTO_BALLOON)) {
> > > +		vb->shrinker.shrink = balloon_shrinker;
> > > +		vb->shrinker.seeks = DEFAULT_SEEKS;
> > > +		register_shrinker(&vb->shrinker);
> > > +	}
> > > +
> > >  	return 0;
> > >  
> > >  out_del_vqs:
> > > @@ -487,6 +538,9 @@ out:
> > >  
> > >  static void remove_common(struct virtio_balloon *vb)
> > >  {
> > > +	if (vb->shrinker.shrink)
> > > +		unregister_shrinker(&vb->shrinker);
> > > +
> > >  	/* There might be pages left in the balloon: free them. */
> > >  	mutex_lock(&vb->balloon_lock);
> > >  	while (vb->num_pages)
> > > @@ -543,6 +597,7 @@ static int virtballoon_restore(struct virtio_device *vdev)
> > >  static unsigned int features[] = {
> > >  	VIRTIO_BALLOON_F_MUST_TELL_HOST,
> > >  	VIRTIO_BALLOON_F_STATS_VQ,
> > > +	VIRTIO_BALLOON_F_AUTO_BALLOON,
> > >  };
> > >  
> > >  static struct virtio_driver virtio_balloon_driver = {
> > > diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> > > index 5e26f61..bd378a4 100644
> > > --- a/include/uapi/linux/virtio_balloon.h
> > > +++ b/include/uapi/linux/virtio_balloon.h
> > > @@ -31,6 +31,7 @@
> > >  /* The feature bitmap for virtio balloon */
> > >  #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
> > >  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
> > > +#define VIRTIO_BALLOON_F_AUTO_BALLOON	2 /* Automatic ballooning */
> > >  
> > >  /* Size of a PFN in the balloon interface. */
> > >  #define VIRTIO_BALLOON_PFN_SHIFT 12
> > > -- 
> > > 1.8.1.4
> > > 
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

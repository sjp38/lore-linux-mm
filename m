Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AD9CD6B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 12:34:53 -0500 (EST)
Date: Fri, 13 Nov 2009 17:34:46 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] make crypto unplug fix V3
Message-ID: <20091113173446.GL29804@csn.ul.ie>
References: <1258054211-2854-1-git-send-email-mel@csn.ul.ie> <20091112202748.GC2811@think> <20091112220005.GD2811@think> <20091113024642.GA7771@think> <20091113125812.GB7891@think>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091113125812.GB7891@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 07:58:12AM -0500, Chris Mason wrote:
> This is still likely to set your dm data on fire.  It is only meant for
> testers that start with mkfs and don't have any valuable dm data.
> 

The good news is that my room remains fire-free. Despite swap also
running from dm-crypt, I had no corruption or instability issues.

Here is an updated set of results for fake-gitk running.

X86
2.6.30-0000000-force-highorder           Elapsed:12:08.908    Failures:0
2.6.31-0000000-force-highorder           Elapsed:10:56.283    Failures:0
2.6.31-0000006-dm-crypt-unplug           Elapsed:11:51.653    Failures:0
2.6.31-0000012-pgalloc-2.6.30            Elapsed:12:26.587    Failures:0
2.6.31-0000123-congestion-both           Elapsed:10:55.298    Failures:0
2.6.31-0001234-kswapd-quick-recheck      Elapsed:18:01.523    Failures:0
2.6.31-0123456-dm-crypt-unplug           Elapsed:10:45.720    Failures:0
2.6.31-revert-8aa7e847                   Elapsed:15:08.020    Failures:0
2.6.32-rc6-0000000-force-highorder       Elapsed:16:20.765    Failures:4
2.6.32-rc6-0000006-dm-crypt-unplug       Elapsed:13:42.920    Failures:0
2.6.32-rc6-0000012-pgalloc-2.6.30        Elapsed:16:13.380    Failures:1
2.6.32-rc6-0000123-congestion-both       Elapsed:18:39.118    Failures:0
2.6.32-rc6-0001234-kswapd-quick-recheck  Elapsed:15:04.398    Failures:0
2.6.32-rc6-0123456-dm-crypt-unplug       Elapsed:12:50.438    Failures:0
2.6.32-rc6-revert-8aa7e847               Elapsed:20:50.888    Failures:0

X86-64
2.6.30-0000000-force-highorder           Elapsed:10:37.300    Failures:0
2.6.31-0000000-force-highorder           Elapsed:08:49.338    Failures:0
2.6.31-0000006-dm-crypt-unplug           Elapsed:09:37.840    Failures:0
2.6.31-0000012-pgalloc-2.6.30            Elapsed:15:49.690    Failures:0
2.6.31-0000123-congestion-both           Elapsed:09:18.790    Failures:0
2.6.31-0001234-kswapd-quick-recheck      Elapsed:08:39.268    Failures:0
2.6.31-0123456-dm-crypt-unplug           Elapsed:08:20.965    Failures:0
2.6.31-revert-8aa7e847                   Elapsed:08:07.457    Failures:0
2.6.32-rc6-0000000-force-highorder       Elapsed:18:29.103    Failures:1
2.6.32-rc6-0000006-dm-crypt-unplug       Elapsed:25:53.515    Failures:3
2.6.32-rc6-0000012-pgalloc-2.6.30        Elapsed:19:55.570    Failures:6
2.6.32-rc6-0000123-congestion-both       Elapsed:17:29.255    Failures:2
2.6.32-rc6-0001234-kswapd-quick-recheck  Elapsed:14:41.068    Failures:0
2.6.32-rc6-0123456-dm-crypt-unplug       Elapsed:15:48.028    Failures:1
2.6.32-rc6-revert-8aa7e847               Elapsed:14:48.647    Failures:0

The numbering in the kernel indicates what patches are applied. I tested
the dm-crypt patch both in isolation and in combination with the patches
in this series.

Basically, the dm-crypt-unplug makes a small difference in performance
overall, mostly slight gains and losses. There was one massive regression
with the dm-crypt patch applied to 2.6.32-rc6 but at the moment, I don't
know what that is.

In general, the patch reduces the amount of time direct reclaimers are
spending on congestion_wait.

> It includes my patch from last night, along with changes to force dm to
> unplug when its IO queues empty.
> 
> The problem goes like this:
> 
> Process: submit read bio
> dm: put bio onto work queue
> process: unplug
> dm: work queue finds bio, does a generic_make_request
> 
> The end result is that we miss the unplug completely.  dm-crypt needs to
> unplug for sync bios.  This patch also changes it to unplug whenever the
> queue is empty, which is far from ideal but better than missing the
> unplugs.
> 
> This doesn't completely fix io stalls I'm seeing with dm-crypt, but its
> my best guess.  If it works, I'll break it up and submit for real to
> the dm people.
> 

Out of curiousity, how are you measuring IO stalls? In the tests I'm doing,
the worker processes output their progress and it should be at a steady
rate. I considered a stall to be an excessive delay between updates which
is a pretty indirect measure.

> -chris
> 
> diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
> index ed10381..729ae01 100644
> --- a/drivers/md/dm-crypt.c
> +++ b/drivers/md/dm-crypt.c
> @@ -94,8 +94,12 @@ struct crypt_config {
>  	struct bio_set *bs;
>  
>  	struct workqueue_struct *io_queue;
> +	struct workqueue_struct *async_io_queue;
>  	struct workqueue_struct *crypt_queue;
>  
> +	atomic_t sync_bios_in_queue;
> +	atomic_t async_bios_in_queue;
> +
>  	/*
>  	 * crypto related data
>  	 */
> @@ -679,11 +683,29 @@ static void kcryptd_io_write(struct dm_crypt_io *io)
>  static void kcryptd_io(struct work_struct *work)
>  {
>  	struct dm_crypt_io *io = container_of(work, struct dm_crypt_io, work);
> +	struct crypt_config *cc = io->target->private;
> +	int zero_sync = 0;
> +	int zero_async = 0;
> +	int was_sync = 0;
> +
> +	if (io->base_bio->bi_rw & (1 << BIO_RW_SYNCIO)) {
> +		zero_sync = atomic_dec_and_test(&cc->sync_bios_in_queue);
> +		was_sync = 1;
> +	} else
> +		zero_async = atomic_dec_and_test(&cc->async_bios_in_queue);
>  
>  	if (bio_data_dir(io->base_bio) == READ)
>  		kcryptd_io_read(io);
>  	else
>  		kcryptd_io_write(io);
> +
> +	if ((was_sync && zero_sync) ||
> +	    (!was_sync && zero_async &&
> +	     atomic_read(&cc->sync_bios_in_queue) == 0)) {
> +		struct backing_dev_info *bdi;
> +		bdi = blk_get_backing_dev_info(io->base_bio->bi_bdev);
> +		blk_run_backing_dev(bdi, NULL);
> +	}
>  }
>  
>  static void kcryptd_queue_io(struct dm_crypt_io *io)
> @@ -691,7 +713,13 @@ static void kcryptd_queue_io(struct dm_crypt_io *io)
>  	struct crypt_config *cc = io->target->private;
>  
>  	INIT_WORK(&io->work, kcryptd_io);
> -	queue_work(cc->io_queue, &io->work);
> +	if (io->base_bio->bi_rw & (1 << BIO_RW_SYNCIO)) {
> +		atomic_inc(&cc->sync_bios_in_queue);
> +		queue_work(cc->io_queue, &io->work);
> +	} else {
> +		atomic_inc(&cc->async_bios_in_queue);
> +		queue_work(cc->async_io_queue, &io->work);
> +	}
>  }
>  
>  static void kcryptd_crypt_write_io_submit(struct dm_crypt_io *io,
> @@ -759,8 +787,7 @@ static void kcryptd_crypt_write_convert(struct dm_crypt_io *io)
>  
>  		/* Encryption was already finished, submit io now */
>  		if (crypt_finished) {
> -			kcryptd_crypt_write_io_submit(io, r, 0);
> -
> +			kcryptd_crypt_write_io_submit(io, r, 1);
>  			/*
>  			 * If there was an error, do not try next fragments.
>  			 * For async, error is processed in async handler.
> @@ -1120,6 +1147,15 @@ static int crypt_ctr(struct dm_target *ti, unsigned int argc, char **argv)
>  	} else
>  		cc->iv_mode = NULL;
>  
> +	atomic_set(&cc->sync_bios_in_queue, 0);
> +	atomic_set(&cc->async_bios_in_queue, 0);
> +
> +	cc->async_io_queue = create_singlethread_workqueue("kcryptd_async_io");
> +	if (!cc->async_io_queue) {
> +		ti->error = "Couldn't create kcryptd io queue";
> +		goto bad_async_io_queue;
> +	}
> +
>  	cc->io_queue = create_singlethread_workqueue("kcryptd_io");
>  	if (!cc->io_queue) {
>  		ti->error = "Couldn't create kcryptd io queue";
> @@ -1139,6 +1175,8 @@ static int crypt_ctr(struct dm_target *ti, unsigned int argc, char **argv)
>  bad_crypt_queue:
>  	destroy_workqueue(cc->io_queue);
>  bad_io_queue:
> +	destroy_workqueue(cc->async_io_queue);
> +bad_async_io_queue:
>  	kfree(cc->iv_mode);
>  bad_ivmode_string:
>  	dm_put_device(ti, cc->dev);
> @@ -1166,6 +1204,7 @@ static void crypt_dtr(struct dm_target *ti)
>  	struct crypt_config *cc = (struct crypt_config *) ti->private;
>  
>  	destroy_workqueue(cc->io_queue);
> +	destroy_workqueue(cc->async_io_queue);
>  	destroy_workqueue(cc->crypt_queue);
>  
>  	if (cc->req)
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

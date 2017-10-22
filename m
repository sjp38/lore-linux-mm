Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B93606B0253
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 07:50:54 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x7so14264400pfa.19
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 04:50:54 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k190si3461494pgc.648.2017.10.22.04.50.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Oct 2017 04:50:52 -0700 (PDT)
Subject: Re: [PATCH v1 1/3] virtio-balloon: replace the coarse-grained balloon_lock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>
	<1508500466-21165-2-git-send-email-wei.w.wang@intel.com>
	<201710221420.FHG17654.OOMFQSFJVFHLtO@I-love.SAKURA.ne.jp>
	<59EC7FF5.6070906@intel.com>
In-Reply-To: <59EC7FF5.6070906@intel.com>
Message-Id: <201710222050.GIF35945.FHOMQFOVSFLtOJ@I-love.SAKURA.ne.jp>
Date: Sun, 22 Oct 2017 20:50:44 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, mst@redhat.com
Cc: mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

Wei Wang wrote:
> >> @@ -162,20 +160,20 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
> >>   			msleep(200);
> >>   			break;
> >>   		}
> >> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> >> -		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
> >> +		set_page_pfns(vb, pfns + num_pfns, page);
> >>   		if (!virtio_has_feature(vb->vdev,
> >>   					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> >>   			adjust_managed_page_count(page, -1);
> >>   	}
> >>   
> >> -	num_allocated_pages = vb->num_pfns;
> >> +	mutex_lock(&vb->inflate_lock);
> >>   	/* Did we get any? */
> >> -	if (vb->num_pfns != 0)
> >> -		tell_host(vb, vb->inflate_vq);
> >> -	mutex_unlock(&vb->balloon_lock);
> >> +	if (num_pfns != 0)
> >> +		tell_host(vb, vb->inflate_vq, pfns, num_pfns);
> >> +	mutex_unlock(&vb->inflate_lock);
> >> +	atomic64_add(num_pfns, &vb->num_pages);
> > Isn't this addition too late? If leak_balloon() is called due to
> > out_of_memory(), it will fail to find up to dated vb->num_pages value.
> 
> Not really. I think the old way of implementation above:
> "vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE"
> isn't quite accurate, because "vb->num_page" should reflect the number of
> pages that have already been inflated, which means those pages have
> already been given to the host via "tell_host()".
> 
> If we update "vb->num_page" earlier before tell_host(), then it will 
> include the pages
> that haven't been given to the host, which I think shouldn't be counted 
> as inflated pages.
> 
> On the other hand, OOM will use leak_balloon() to release the pages that 
> should
> have already been inflated.

But leak_balloon() finds max inflated pages from vb->num_pages, doesn't it?

> 
> >>   
> >>   	/* We can only do one array worth at a time. */
> >> -	num = min(num, ARRAY_SIZE(vb->pfns));
> >> +	num = min_t(size_t, num, VIRTIO_BALLOON_ARRAY_PFNS_MAX);
> >>   
> >> -	mutex_lock(&vb->balloon_lock);
> >>   	/* We can't release more pages than taken */
> >> -	num = min(num, (size_t)vb->num_pages);
> >> -	for (vb->num_pfns = 0; vb->num_pfns < num;
> >> -	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> >> +	num = min_t(size_t, num, atomic64_read(&vb->num_pages));
> >> +	for (num_pfns = 0; num_pfns < num;
> >> +	     num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> >>   		page = balloon_page_dequeue(vb_dev_info);
> > If balloon_page_dequeue() can be concurrently called by both host's request
> > and guest's OOM event, is (!dequeued_page) test in balloon_page_dequeue() safe?
> 
> 
> I'm not sure about the question. The "dequeue_page" is a local variable
> in the function, why would it be unsafe for two invocations (the shared
> b_dev_info->pages are operated under a lock)?

I'm not MM person nor virtio person. I'm commenting from point of view of
safe programming. My question is, isn't there possibility of hitting

	if (unlikely(list_empty(&b_dev_info->pages) &&
		     !b_dev_info->isolated_pages))
		BUG();

when things run concurrently.

Wei Wang wrote:
> On 10/22/2017 12:11 PM, Tetsuo Handa wrote:
> > Michael S. Tsirkin wrote:
> >>> -	num_freed_pages = leak_balloon(vb, oom_pages);
> >>> +
> >>> +	/* Don't deflate more than the number of inflated pages */
> >>> +	while (npages && atomic64_read(&vb->num_pages))
> >>> +		npages -= leak_balloon(vb, npages);
> > don't we need to abort if leak_balloon() returned 0 for some reason?
> 
> I don't think so. Returning 0 should be a normal case when the host tries
> to give back some pages to the guest, but there is no pages that have ever
> been inflated. For example, right after booting the guest, the host sends a
> deflating request to give the guest 1G memory, leak_balloon should return 0,
> and guest wouldn't get 1 more G memory.
> 
My question is, isn't there possibility of leak_balloon() returning 0 for
reasons other than vb->num_pages == 0 ? If yes, this can cause infinite loop
(i.e. lockups) when things run concurrently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C76266B0069
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 07:22:33 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p87so14217211pfj.21
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 04:22:33 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j13si3407475pgf.700.2017.10.22.04.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Oct 2017 04:22:32 -0700 (PDT)
Message-ID: <59EC7FF5.6070906@intel.com>
Date: Sun, 22 Oct 2017 19:24:37 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v1 1/3] virtio-balloon: replace the coarse-grained balloon_lock
References: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>	<1508500466-21165-2-git-send-email-wei.w.wang@intel.com> <201710221420.FHG17654.OOMFQSFJVFHLtO@I-love.SAKURA.ne.jp>
In-Reply-To: <201710221420.FHG17654.OOMFQSFJVFHLtO@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mst@redhat.com
Cc: mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

On 10/22/2017 01:20 PM, Tetsuo Handa wrote:
> Wei Wang wrote:
>> The balloon_lock was used to synchronize the access demand to elements
>> of struct virtio_balloon and its queue operations (please see commit
>> e22504296d). This prevents the concurrent run of the leak_balloon and
>> fill_balloon functions, thereby resulting in a deadlock issue on OOM:
>>
>> fill_balloon: take balloon_lock and wait for OOM to get some memory;
>> oom_notify: release some inflated memory via leak_balloon();
>> leak_balloon: wait for balloon_lock to be released by fill_balloon.
>>
>> This patch breaks the lock into two fine-grained inflate_lock and
>> deflate_lock, and eliminates the unnecessary use of the shared data
>> (i.e. vb->pnfs, vb->num_pfns). This enables leak_balloon and
>> fill_balloon to run concurrently and solves the deadlock issue.
>>
>> @@ -162,20 +160,20 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>>   			msleep(200);
>>   			break;
>>   		}
>> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
>> -		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
>> +		set_page_pfns(vb, pfns + num_pfns, page);
>>   		if (!virtio_has_feature(vb->vdev,
>>   					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>>   			adjust_managed_page_count(page, -1);
>>   	}
>>   
>> -	num_allocated_pages = vb->num_pfns;
>> +	mutex_lock(&vb->inflate_lock);
>>   	/* Did we get any? */
>> -	if (vb->num_pfns != 0)
>> -		tell_host(vb, vb->inflate_vq);
>> -	mutex_unlock(&vb->balloon_lock);
>> +	if (num_pfns != 0)
>> +		tell_host(vb, vb->inflate_vq, pfns, num_pfns);
>> +	mutex_unlock(&vb->inflate_lock);
>> +	atomic64_add(num_pfns, &vb->num_pages);
> Isn't this addition too late? If leak_balloon() is called due to
> out_of_memory(), it will fail to find up to dated vb->num_pages value.

Not really. I think the old way of implementation above:
"vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE"
isn't quite accurate, because "vb->num_page" should reflect the number of
pages that have already been inflated, which means those pages have
already been given to the host via "tell_host()".

If we update "vb->num_page" earlier before tell_host(), then it will 
include the pages
that haven't been given to the host, which I think shouldn't be counted 
as inflated pages.

On the other hand, OOM will use leak_balloon() to release the pages that 
should
have already been inflated.

In addition, I think we would also need to move balloon_page_insert(), 
which puts the
page onto the inflated page list, after tell_host().



>>   
>> -	return num_allocated_pages;
>> +	return num_pfns;
>>   }
>>   
>>   static void release_pages_balloon(struct virtio_balloon *vb,
>> @@ -194,38 +192,39 @@ static void release_pages_balloon(struct virtio_balloon *vb,
>>   
>>   static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>>   {
>> -	unsigned num_freed_pages;
>>   	struct page *page;
>>   	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
>>   	LIST_HEAD(pages);
>> +	unsigned int num_pfns;
>> +	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
> This array consumes 1024 bytes of kernel stack, doesn't it?
> leak_balloon() might be called from out_of_memory() where kernel stack
> is already largely consumed before entering __alloc_pages_nodemask().
> For reducing possibility of stack overflow, since out_of_memory() is
> serialized by oom_lock, I suggest using static (maybe kmalloc()ed as
> vb->oom_pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX]) buffer when called from
> out_of_memory().

In that case, we might as well to use
vb->inflate_pfns = kmalloc(VIRTIO_BALLOON_ARRAY_PFNS_MAX..);
vb->deflate_pfns = kmalloc(VIRTIO_BALLOON_ARRAY_PFNS_MAX..);
which are allocated in probe().

>>   
>>   	/* We can only do one array worth at a time. */
>> -	num = min(num, ARRAY_SIZE(vb->pfns));
>> +	num = min_t(size_t, num, VIRTIO_BALLOON_ARRAY_PFNS_MAX);
>>   
>> -	mutex_lock(&vb->balloon_lock);
>>   	/* We can't release more pages than taken */
>> -	num = min(num, (size_t)vb->num_pages);
>> -	for (vb->num_pfns = 0; vb->num_pfns < num;
>> -	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
>> +	num = min_t(size_t, num, atomic64_read(&vb->num_pages));
>> +	for (num_pfns = 0; num_pfns < num;
>> +	     num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
>>   		page = balloon_page_dequeue(vb_dev_info);
> If balloon_page_dequeue() can be concurrently called by both host's request
> and guest's OOM event, is (!dequeued_page) test in balloon_page_dequeue() safe?


I'm not sure about the question. The "dequeue_page" is a local variable
in the function, why would it be unsafe for two invocations (the shared
b_dev_info->pages are operated under a lock)?



> Is such concurrency needed?

Thanks for this question, it triggers another optimization, which I want to
introduce if this direction could be accepted:

I think it is not quite necessary to deflate pages in OOM-->leak_balloon()
when the host request leak_ballon() is running. In that case, I think OOM
can just count the pages that are deflated by the host request.

The implementation logic will be simple, here is the major part:

1) Introduce a "vb->deflating" flag, to tell whether deflating is in 
progress

2) At the beginning of leak_balloon():
     if (READ_ONCE(vb->deflating)) {
            npages = atomic64_read(&vb->num_pages);
            /* Wait till the other run of leak_balloon() returns */
            while (READ_ONCE(vb->deflating));
            npages = npages - atomic64_read(&vb->num_pages)
     } else {
         WRITE_ONCE(vb->deflating, true);
     }
     ...

3) At the end of leak_balloon():
     WRITE_ONCE(vb->deflating, false);

(The above vb->deflating doesn't have to be in vb though, it can be a 
static variable inside leak_balloon(). we can
discuss more about the implementation when reaching that step)


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

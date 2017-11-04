Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E00B46B0033
	for <linux-mm@kvack.org>; Sat,  4 Nov 2017 07:07:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x7so5388539pfa.19
        for <linux-mm@kvack.org>; Sat, 04 Nov 2017 04:07:16 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id r17si8244616pgd.673.2017.11.04.04.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Nov 2017 04:07:13 -0700 (PDT)
Message-ID: <59FD9FE3.5090409@intel.com>
Date: Sat, 04 Nov 2017 19:09:23 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v17 4/6] virtio-balloon: VIRTIO_BALLOON_F_SG
References: <1509696786-1597-1-git-send-email-wei.w.wang@intel.com>	<1509696786-1597-5-git-send-email-wei.w.wang@intel.com> <201711032025.HJC78622.SFFOMLOtFQHVJO@I-love.SAKURA.ne.jp>
In-Reply-To: <201711032025.HJC78622.SFFOMLOtFQHVJO@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 11/03/2017 07:25 PM, Tetsuo Handa wrote:
> Wei Wang wrote:
>> @@ -164,6 +284,8 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>>   			break;
>>   		}
>>   
>> +		if (use_sg && xb_set_page(vb, page, &pfn_min, &pfn_max) < 0)
> Isn't this leaking "page" ?


Right, thanks, will add __free_page(page) here.

>> @@ -184,8 +307,12 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>>   
>>   	num_allocated_pages = vb->num_pfns;
>>   	/* Did we get any? */
>> -	if (vb->num_pfns != 0)
>> -		tell_host(vb, vb->inflate_vq);
>> +	if (vb->num_pfns) {
>> +		if (use_sg)
>> +			tell_host_sgs(vb, vb->inflate_vq, pfn_min, pfn_max);
> Please describe why tell_host_sgs() can work without __GFP_DIRECT_RECLAIM allocation,
> for tell_host_sgs() is called with vb->balloon_lock mutex held.

Essentially, 
tell_host_sgs()-->send_balloon_page_sg()-->add_one_sg()-->virtqueue_add_inbuf( 
, , num=1 ,,GFP_KERNEL)
won't need any memory allocation, because we always add one sg (i.e. 
num=1) each time. That memory
allocation option is only used when multiple sgs are added (i.e. num > 
1) and the implementation inside virtqueue_add_inbuf
need allocation of indirect descriptor table.

We could also add some comments above the function to explain a little 
about this if necessary.

>
>
>> @@ -223,7 +353,13 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>>   		page = balloon_page_dequeue(vb_dev_info);
>>   		if (!page)
>>   			break;
>> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
>> +		if (use_sg) {
>> +			if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0)
> Isn't this leaking "page" ?

Yes, will make it:

     if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0) {
         balloon_page_enqueue(..., page);
         break;
     }

>
> If this is inside vb->balloon_lock mutex (isn't this?), xb_set_page() must not
> use __GFP_DIRECT_RECLAIM allocation, for leak_balloon_sg_oom() will be blocked
> on vb->balloon_lock mutex.

OK. Since the preload() doesn't need too much memory (< 4K in total), 
how about GFP_NOWAIT here?


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

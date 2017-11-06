Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76C0F6B025F
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:19:11 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 76so10441359pfr.3
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:19:11 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i13si10924122pgp.62.2017.11.06.00.19.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 00:19:10 -0800 (PST)
Message-ID: <5A001B72.1010204@intel.com>
Date: Mon, 06 Nov 2017 16:21:06 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v17 4/6] virtio-balloon: VIRTIO_BALLOON_F_SG
References: <1509696786-1597-1-git-send-email-wei.w.wang@intel.com>	<1509696786-1597-5-git-send-email-wei.w.wang@intel.com>	<201711032025.HJC78622.SFFOMLOtFQHVJO@I-love.SAKURA.ne.jp>	<59FD9FE3.5090409@intel.com> <201711042028.EGB64074.FOLMHtFJVQOOFS@I-love.SAKURA.ne.jp>
In-Reply-To: <201711042028.EGB64074.FOLMHtFJVQOOFS@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 11/04/2017 07:28 PM, Tetsuo Handa wrote:
> Wei Wang wrote:
>> On 11/03/2017 07:25 PM, Tetsuo Handa wrote:
>>
>> If this is inside vb->balloon_lock mutex (isn't this?), xb_set_page() must not
>> use __GFP_DIRECT_RECLAIM allocation, for leak_balloon_sg_oom() will be blocked
>> on vb->balloon_lock mutex.
>> OK. Since the preload() doesn't need too much memory (< 4K in total),
>> how about GFP_NOWAIT here?
> Maybe GFP_NOWAIT | __GFP_NOWARN ?

Sounds good to me. I also plan to move "xb_set_page()" under mutex_lock, 
that is,

     fill_balloon()
     {
         ...
         mutex_lock(&vb->balloon_lock);

         vb->num_pfns = 0;
         while ((page = balloon_page_pop(&pages))) {
==>        xb_set_page(..,page,..);
                 balloon_page_enqueue(&vb->vb_dev_info, page);
         ...
     }

As explained in the xbitmap patch, we need the lock to avoid concurrent 
access to the bitmap.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

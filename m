Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF9C6B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 21:43:41 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so8345218pad.13
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 18:43:40 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id x7si6725414pdj.176.2014.07.08.18.43.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jul 2014 18:43:39 -0700 (PDT)
Message-ID: <53BC9E48.7040809@codeaurora.org>
Date: Tue, 08 Jul 2014 18:43:36 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: arm64 flushing 255GB of vmalloc space takes too long
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi,

I have an arm64 target which has been observed hanging in __purge_vmap_area_lazy
in vmalloc.c The root cause of this 'hang' is that flush_tlb_kernel_range is
attempting to flush 255GB of virtual address space. This takes ~2 seconds and
preemption is disabled at this time thanks to the purge lock. Disabling
preemption for that time is long enough to trigger a watchdog we have setup.

Triggering this is fairly easy:
1) Early in bootup, vmalloc > lazy_max_pages. This gives an address near the
start of the vmalloc range.
2) load a module
3) vfree the vmalloc region from step 1
4) unload the module

The arm64 virtual address layout looks like
vmalloc : 0xffffff8000000000 - 0xffffffbbffff0000   (245759 MB)
vmemmap : 0xffffffbc02400000 - 0xffffffbc03600000   (    18 MB)
modules : 0xffffffbffc000000 - 0xffffffc000000000   (    64 MB)

and the algorithm in __purge_vmap_area_lazy flushes between the lowest address.
Essentially, if we are using a reasonable amount of vmalloc space and a module
unload triggers a vmalloc purge, we will end up triggering our watchdog.

A couple of options I thought of:
1) Increase the timeout of our watchdog to allow the flush to occur. Nobody
I suggested this to likes the idea as the watchdog firing generally catches
behavior that results in poor system performance and disabling preemption
for that long does seem like a problem.
2) Change __purge_vmap_area_lazy to do less work under a spinlock. This would
certainly have a performance impact and I don't even know if it is plausible.
3) Allow module unloading to trigger a vmalloc purge beforehand to help avoid
this case. This would still be racy if another vfree came in during the time
between the purge and the vfree but it might be good enough.
4) Add 'if size > threshold flush entire tlb' (I haven't profiled this yet)


Any other thoughts?

Thanks,
Laura
-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id D20326B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 13:37:20 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id gc3so170506241obb.3
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 10:37:20 -0800 (PST)
Received: from rcdn-iport-6.cisco.com (rcdn-iport-6.cisco.com. [173.37.86.77])
        by mx.google.com with ESMTPS id g6si16638555oel.75.2016.02.16.10.37.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 10:37:19 -0800 (PST)
Date: Tue, 16 Feb 2016 10:37:06 -0800 (PST)
From: Nag Avadhanam <nag@cisco.com>
Subject: Re: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
In-Reply-To: <20160216084346.GA8511@esperanza>
Message-ID: <alpine.LRH.2.00.1602160950310.14077@mcp-bld-lnx-277.cisco.com>
References: <1455308080-27238-1-git-send-email-danielwa@cisco.com> <20160214211856.GT19486@dastard> <56C216CA.7000703@cisco.com> <20160215230511.GU19486@dastard> <56C264BF.3090100@cisco.com> <20160216004531.GA28260@thunk.org> <D2E7B337.D5404%nag@cisco.com>
 <20160216084346.GA8511@esperanza>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Theodore Ts'o <tytso@mit.edu>, "Daniel Walker (danielwa)" <danielwa@cisco.com>, Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Jonathan Corbet <corbet@lwn.net>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 16 Feb 2016, Vladimir Davydov wrote:

> On Tue, Feb 16, 2016 at 02:58:04AM +0000, Nag Avadhanam (nag) wrote:
>> We have a class of platforms that are essentially swap-less embedded
>> systems that have limited memory resources (2GB and less).
>>
>> There is a need to implement early alerts (before the OOM killer kicks in)
>> based on the current memory usage so admins can take appropriate steps (do
>> not initiate provisioning operations but support existing services,
>> de-provision certain services, etc. based on the extent of memory usage in
>> the system) .
>>
>> There is also a general need to let end users know the available memory so
>> they can determine if they can enable new services (helps in planning).
>>
>> These two depend upon knowing approximate (accurate within few 10s of MB)
>> memory usage within the system. We want to alert admins before system
>> exhibits any thrashing behaviors.
>
> Have you considered using /proc/kpageflags for counting such pages? It
> should already export all information about memory pages you might need,
> e.g. which pages are mapped, which are anonymous, which are inactive,
> basically all page flags and even more. Moreover, you can even determine
> the set of pages that are really read/written by processes - see
> /sys/kernel/mm/page_idle/bitmap. On such a small machine scanning the
> whole pfn range should be pretty cheap, so you might find this API
> acceptable.

Thanks Vladimir. I came across the pagmemap interface sometime ago. I
was not sure if its mainstream. I think this should allow userspace 
VM scan (scans might take a bit longer). Will try it.

We could avoid the scans altogether.

The need plainly put is, inform the admins of these swapless embedded systems 
of the available memory.

If we can reliably and efficiently maintain counts of file pages 
(inactive and active) mapped into the address spaces of active user space 
processes, this need can be met. "Mapped" of /proc/meminfo does not seem 
to be a direct fit for this purpose (I need to understand this better). 
If I know for sure "Mapped" does not count device and the kernel pages 
mapped into the user space, then I can employ it gainfully for this need.

(Cached - Shmem - <mapped file/binary pages of active processes>) gives me
reclaimable file pages. If I can determine that then I can add that to MemFree 
and determine the available memory.

Thanks,
nag

>
> Thanks,
> Vladimir
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

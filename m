Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D0D576B0253
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 03:17:54 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id k126so687164wmd.5
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 00:17:54 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y22sor5382931edm.12.2018.01.19.00.17.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 00:17:53 -0800 (PST)
Reply-To: christian.koenig@amd.com
Subject: Re: [RFC] Per file OOM badness
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <DM5PR1201MB012142B041369BF6911C5818FDEF0@DM5PR1201MB0121.namprd12.prod.outlook.com>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <ckoenig.leichtzumerken@gmail.com>
Message-ID: <78121ca2-3693-d43e-5a5f-989380fb3667@gmail.com>
Date: Fri, 19 Jan 2018 09:17:51 +0100
MIME-Version: 1.0
In-Reply-To: <DM5PR1201MB012142B041369BF6911C5818FDEF0@DM5PR1201MB0121.namprd12.prod.outlook.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "He, Roger" <Hongbo.He@amd.com>, "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Cc: "Koenig, Christian" <Christian.Koenig@amd.com>

Am 19.01.2018 um 06:39 schrieb He, Roger:
> Basically the idea is right to me.
>
> 1. But we need smaller granularity to control the contribution to OOM badness.
>       Because when the TTM buffer resides in VRAM rather than evict to system memory, we should not take this account into badness.
>       But I think it is not easy to implement.

I was considering that as well when I wrote the original patch set, but 
then decided against it at least for now.

Basically all VRAM buffers can be swapped to system memory, so they 
potentially need system memory as well. That is especially important 
during suspend/resume.

>
> 2. If the TTM buffer(GTT here) is mapped to user for CPU access, not quite sure the buffer size is already taken into account for kernel.
>       If yes, at last the size will be counted again by your patches.

No that isn't accounted for as far as I know.

>
> So, I am thinking if we can counted the TTM buffer size into:
> struct mm_rss_stat {
> 	atomic_long_t count[NR_MM_COUNTERS];
> };
> Which is done by kernel based on CPU VM (page table).
>
> Something like that:
> When GTT allocate suceess:
> add_mm_counter(vma->vm_mm, MM_ANONPAGES, buffer_size);
>
> When GTT swapped out:
> dec_mm_counter from MM_ANONPAGES frist, then
> add_mm_counter(vma->vm_mm, MM_SWAPENTS, buffer_size);  // or MM_SHMEMPAGES or add new item.
>
> Update the corresponding item in mm_rss_stat always.
> If that, we can control the status update accurately.
> What do you think about that?
> And is there any side-effect for this approach?

I already tried this when I originally worked on the issue and that 
approach didn't worked because allocated buffers are not associated to 
the process where they are created.

E.g. most display surfaces are created by the X server, but used by 
processes. So if you account the BO to the process who created it we 
would start to kill X again and that is exactly what we try to avoid.

Regards,
Christian.

>
>
> Thanks
> Roger(Hongbo.He)
>
> -----Original Message-----
> From: dri-devel [mailto:dri-devel-bounces@lists.freedesktop.org] On Behalf Of Andrey Grodzovsky
> Sent: Friday, January 19, 2018 12:48 AM
> To: linux-kernel@vger.kernel.org; linux-mm@kvack.org; dri-devel@lists.freedesktop.org; amd-gfx@lists.freedesktop.org
> Cc: Koenig, Christian <Christian.Koenig@amd.com>
> Subject: [RFC] Per file OOM badness
>
> Hi, this series is a revised version of an RFC sent by Christian KA?nig a few years ago. The original RFC can be found at https://lists.freedesktop.org/archives/dri-devel/2015-September/089778.html
>
> This is the same idea and I've just adressed his concern from the original RFC and switched to a callback into file_ops instead of a new member in struct file.
>
> Thanks,
> Andrey
>
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel
> _______________________________________________
> amd-gfx mailing list
> amd-gfx@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/amd-gfx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

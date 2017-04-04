Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 13E3A6B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 05:36:59 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v44so27784826wrc.9
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 02:36:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c26si16595950wrb.192.2017.04.04.02.36.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 02:36:57 -0700 (PDT)
Date: Tue, 4 Apr 2017 11:36:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm/vmalloc: allow to call vfree() in atomic context
Message-ID: <20170404093653.GG15132@dhcp22.suse.cz>
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
 <20170330152229.f2108e718114ed77acae7405@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170330152229.f2108e718114ed77acae7405@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de, thellstrom@vmware.com, stable@vger.kernel.org

On Thu 30-03-17 15:22:29, Andrew Morton wrote:
> On Thu, 30 Mar 2017 13:27:16 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
[...]
> > This can be fixed in vmgfx, but it would be better to make vfree()
> > non-sleeping again because we may have other bugs like this one.
> 
> I tend to disagree: adding yet another schedule_work() introduces
> additional overhead and adds some risk of ENOMEM errors which wouldn't
> occur with a synchronous free.

I do not think ENOMEM would be a problem. We are talking about lazy
handling already. Besides that the allocation path also does this lazy
free AFAICS.

> > __purge_vmap_area_lazy() is the only function in the vfree() path that
> > wants to be able to sleep. So it make sense to schedule
> > __purge_vmap_area_lazy() via schedule_work() so it runs only in sleepable
> > context.
> 
> vfree() already does
> 
> 	if (unlikely(in_interrupt()))
> 		__vfree_deferred(addr);
> 
> so it seems silly to introduce another defer-to-kernel-thread thing
> when we already have one.

But this only cares about the IRQ context and this patch aims at atomic
context in general. I agree it would have been better to reduce this
deferred behavior to only _atomic_ context but we not have a reliable
way to detect that on non-preemptive kernels AFAIR.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

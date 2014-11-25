Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id CAAE56B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 06:39:56 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id tr6so326423ieb.21
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 03:39:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i1si575244iod.64.2014.11.25.03.39.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Nov 2014 03:39:55 -0800 (PST)
Date: Tue, 25 Nov 2014 03:40:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: add parameter to disable faultaround
Message-Id: <20141125034016.5638d5e4.akpm@linux-foundation.org>
In-Reply-To: <547465d2.6561420a.04ed.0514SMTPIN_ADDED_BROKEN@mx.google.com>
References: <1416898318-17409-1-git-send-email-chanho.min@lge.com>
	<20141124230502.30f9b6f0.akpm@linux-foundation.org>
	<547465d2.6561420a.04ed.0514SMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chanho Min <chanho.min@lge.com>
Cc: "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Hugh Dickins' <hughd@google.com>, 'Michal Hocko' <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'HyoJun Im' <hyojun.im@lge.com>, 'Gunho Lee' <gunho.lee@lge.com>, 'Wonhong Kwon' <wonhong.kwon@lge.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Tue, 25 Nov 2014 20:19:40 +0900 "Chanho Min" <chanho.min@lge.com> wrote:

> > > The faultaround improves the file read performance, whereas pages which
> > > can be dropped by drop_caches are reduced. On some systems, The amount of
> > > freeable pages under memory pressure is more important than read
> > > performance.
> > 
> > The faultaround pages *are* freeable.  Perhaps you meant "free" here.
> > 
> > Please tell us a great deal about the problem which you are trying to
> > solve.  What sort of system, what sort of workload, what is bad about
> > the behaviour which you are observing, etc.
> 
> We are trying to solve two issues.
> 
> We drop page caches by writing to /proc/sys/vm/drop_caches at specific point
> and make suspend-to-disk image. The size of this image is increased if faultaround
> is worked.

OK.

These pages are clean (mostly) and are mapped into process pagetables. 
Obviously mm/vmscan.c:shrink_all_memory() is not freeing these pages
prior to hibernating.

I forget what the policy/tuning is in this area.  IIRC, the intent of
shrink_all_memory() is to free up enough memory so that hibernation can
perform its function, rather than to explicitly reduce the size of the
image.

What I suggest you do is to take a look at how hibernation is calling
shrink_all_memory() and retune it so it shrinks a lot harder.  You may
want to disable swapping, or perhaps reduce it by performing one
shrink_all_memory() in the same way as at present, then perform a
second shrink_all_memory() more aggressively, but with
scan_control.may_swap=0.  The overall effect will be to make
hibernation tear down the process pagetable mappings and free these
pagecache pages before preparing the disk image.

If we can get this working then your hibernation image will be
significantly smaller than it is with this patch, because more pages
will be unmapped and freed.  There will of course be a lot of major
pagefaults after resume.  If that's a problem then perhaps we can tune
the second shrink_all_memory() pass to only unmap ptes for unreferenced
pages.

> Under memory pressure, we want to drop many page caches as possible.
> But, The number of dropped pages are reduced compared to non-faultaround kernel.

Again, why do you want to do this?  What problem is it solving?  I
assume you're using drop_caches for this as well?

Generally, any use of drop_caches is wrong, and indicates there's some
shortcoming in MM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

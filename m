Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBAF2802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 04:47:01 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c81so6130076wmd.10
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 01:47:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si10405437wmp.150.2017.06.30.01.46.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 01:46:59 -0700 (PDT)
Date: Fri, 30 Jun 2017 10:46:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Regarding your thread on LKML - drm_radeon spamming
 alloc_contig_range [WAS: Re: PROBLEM-PERSISTS: dmesg spam:
 alloc_contig_range: [XX, YY) PFNs busy]
Message-ID: <20170630084653.GC22917@dhcp22.suse.cz>
References: <CADK6UNEQ+WuKDRyUVPQ1RwOWCkvcU95OBh4obKj4dv62Kf5ipA@mail.gmail.com>
 <20170629174705.GN23586@orbis-terrarum.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170629174705.GN23586@orbis-terrarum.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Robin H. Johnson" <robbat2@gentoo.org>
Cc: Kumar Abhishek <kumar.abhishek.kakkar@gmail.com>, robbat2@orbis-terrarum.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mina86@mina86.com, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>

[CC Vlastimil, Joonsoo]

On Thu 29-06-17 17:47:05, Robin H. Johnson wrote:
> CC'd back to LKML.
> 
> On Thu, Jun 29, 2017 at 06:11:00PM +0530, Kumar Abhishek wrote:
> > Hi Robin,
> > 
> > I am an independent developer who stumbled upon your thread on the LKML
> > after facing a similar issue - my kernel log being spammed by
> > alloc_contig_range messages. I am running Linux on an ARM system
> > (specifically the BeagleBoard-X15) and am on kernel version 4.9.33 with TI
> > patches on top of it.
> > 
> > I am running Debian Stretch (9.0) on the system.
> > 
> > Here's what my stack trace looks like:
> ..
> > 
> > It's somewhat similar to your stack trace, but this here happens on an
> > etnaviv GPU (Vivante GCxx).
> > 
> > In my case if I do 'sudo service lightdm stop', these messages stop too.
> > This seems to suggest that the problem may be in the X server rather than
> > the kernel? I seem to think this because I replicated this on an entirely
> > different set of hardware than yours.
> > 
> > I just wanted to bring this to your notice, and also ask you if you managed
> > to solve it for yourself.
> > 
> > One solution could be to demote the pr_info in alloc_contig_range to
> > pr_debug or to do away with the message altogether, but this would be
> > suppressing the issue instead of really knowing what it is about.
> > 
> > Let me know how I could further investigate this.
> The problem, as far as I got diagnosed on LKML, is that some of the GPUs
> have a bunch of non-fatal contiguous memory allocation requests: they
> have a meaningful fallback path on the allocation, so 'PFNs busy' is a
> false busy for their case.

Well, later on we found out that a change to the compaction has changed
a picture and 424f6c4818bb ("mm: alloc_contig: re-allow CMA to compact
FS pages") fixed that issue. It went to 4.10 and I do not see it in 4.9
stable tree. Maybe it can help in this case as well.

> However, if there was a another consumer that does NOT have a fallback,
> the output would still be crucially useful.
> 
> Attached is the patch that I unsuccessfully proposed on LKML to
> rate-limit the messages, with the last revision to only dump_stack() if
> CONFIG_CMA_DEBUG was set.

The patch makes some sense to me in general. Try to repost it.
 
> The path that LKML wanted was to add a new parameter to suppress or at
> least demote the failure message, and update all of the callers: but it
> means that many of the indirect callers need that added parameter as
> well.
> 
> mm/cma.c:cma_alloc this call can suppress the error, you can see it retry.
> mm/hugetlb.c: These callers should get the error message.
> 
> The error message DOES still have a good general use in notifying you
> that something is going wrong. There was noticeable performance slowdown
> in my case when it was trying hard to allocate.
> 
> -- 
> Robin Hugh Johnson
> E-Mail     : robbat2@orbis-terrarum.net
> Home Page  : http://www.orbis-terrarum.net/?l=people.robbat2
> ICQ#       : 30269588 or 41961639
> GnuPG FP   : 11ACBA4F 4778E3F6 E4EDF38E B27B944E 34884E85

> commit 808c209dc82ce79147122ca78e7047bc74a16149
> Author: Robin H. Johnson <robbat2@gentoo.org>
> Date:   Wed Nov 30 10:32:57 2016 -0800
> 
>     mm: ratelimit & trace PFNs busy.
>     
>     Signed-off-by: Robin H. Johnson <robbat2@gentoo.org>
> 	Acked-by: Michal Nazarewicz <mina86@mina86.com>
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6de9440e3ae2..3c28ec3d18f8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7289,8 +7289,16 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  
>  	/* Make sure the range is really isolated. */
>  	if (test_pages_isolated(outer_start, end, false)) {
> -		pr_info("%s: [%lx, %lx) PFNs busy\n",
> -			__func__, outer_start, end);
> +		static DEFINE_RATELIMIT_STATE(ratelimit_pfn_busy,
> +					DEFAULT_RATELIMIT_INTERVAL,
> +					DEFAULT_RATELIMIT_BURST);
> +		if (__ratelimit(&ratelimit_pfn_busy)) {
> +			pr_info("%s: [%lx, %lx) PFNs busy\n",
> +				__func__, outer_start, end);
> +			if (IS_ENABLED(CONFIG_CMA_DEBUG))
> +				dump_stack();
> +		}
> +
>  		ret = -EBUSY;
>  		goto done;
>  	}




-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 443076B028B
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 04:56:36 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r144so8221299wme.0
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 01:56:36 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id p80si23492328wmd.122.2017.01.19.01.56.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 01:56:35 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 968301C2101
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 09:56:34 +0000 (GMT)
Date: Thu, 19 Jan 2017 09:56:33 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH -next] init/main: Init jump_labels before they are used
 to build zonelists
Message-ID: <20170119095633.x32yyhkohh5tii4z@techsingularity.net>
References: <20170117125624.8535-1-shorne@gmail.com>
 <cc2486a7-4a95-8014-acfa-0eedf485d935@suse.cz>
 <20170117134454.GB6515@twins.programming.kicks-ass.net>
 <20170117143043.GA7836@lianli.shorne-pla.net>
 <8c4e1c37-1a8e-9e5e-c276-f7bd3cfb248b@suse.cz>
 <20170117123416.6d0caf7544a3508d368ecea1@linux-foundation.org>
 <e8d8db10-ff33-0dd9-f954-8bc069b239a6@suse.cz>
 <7554ba8c-3ac0-8d1b-eb9f-548ef6c45693@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <7554ba8c-3ac0-8d1b-eb9f-548ef6c45693@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stafford Horne <shorne@gmail.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Kees Cook <keescook@chromium.org>, Jessica Yu <jeyu@redhat.com>, Petr Mladek <pmladek@suse.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Yang Shi <yang.shi@linaro.org>, Tejun Heo <tj@kernel.org>, Prarit Bhargava <prarit@redhat.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm <linux-mm@kvack.org>

On Thu, Jan 19, 2017 at 09:28:28AM +0100, Vlastimil Babka wrote:
> On 01/17/2017 09:49 PM, Vlastimil Babka wrote:
> > On 17.1.2017 21:34, Andrew Morton wrote:
> >>>>
> >>>> Will you be able to look into that? Openrisc doesnt have jump_label
> >>>> support, so its no issue at the moment.
> >>>>
> >>>> Archs that do have it:
> >>>>
> >>>> arch/arm64/Kconfig:     select HAVE_ARCH_JUMP_LABEL
> >>>> arch/mips/Kconfig:      select HAVE_ARCH_JUMP_LABEL
> >>>> arch/s390/Kconfig:      select HAVE_ARCH_JUMP_LABEL
> >>>> arch/sparc/Kconfig:     select HAVE_ARCH_JUMP_LABEL if SPARC64
> >>>> arch/tile/Kconfig:      select HAVE_ARCH_JUMP_LABEL
> >>>> arch/x86/Kconfig:       select HAVE_ARCH_JUMP_LABEL
> >>>> arch/arm/Kconfig:       select HAVE_ARCH_JUMP_LABEL if !XIP_KERNEL && !CPU_ENDIAN_BE32 && MMU
> >>>> arch/powerpc/Kconfig:   select HAVE_ARCH_JUMP_LABEL
> >>>>
> >>>> I looked at a few (arm, tile) and I dont see their arch_jump_label_transform*
> >>>> implementations depending on global state like ideal_nops from x86. They
> >>>> should be ok.
> >>>
> >>> Thanks, I'll try.
> >>>
> >>>> If no time, Should you change your patch to not use static keys for
> >>>> build_all_zonelists at least?
> >>>
> >>> Yes that would be uglier but possible if I find issues or I'm not
> >>> confident enough with the auditing...
> >>
> >> We could just revert f5adbdff6a1c40e19 ("mm, page_alloc: convert
> >> page_group_by_mobility_disable to static key")?
> > 
> > That's a -next commit id, as the patch is in mmotm. I'll ask for removal if I
> > don't have a fix soon, but if you or somebody else prefers to do that ASAP, it
> > can be re-added later with a fix.
> 
> OK I think that we just drop the patch [1] from mmotm. Mel told me the
> benefit was marginal, and also the last move of jump_label_init() caused
> problems for several releases.
> 

Note that it's not guaranteed to cause any problems this time. If
jump_label_init can go ahead without the page allocator being fully up
and running then it may be ok.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

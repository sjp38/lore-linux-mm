Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 68A066B0038
	for <linux-mm@kvack.org>; Sun, 13 Dec 2015 22:01:46 -0500 (EST)
Received: by igbxm8 with SMTP id xm8so74541224igb.1
        for <linux-mm@kvack.org>; Sun, 13 Dec 2015 19:01:46 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id j15si14757665iod.139.2015.12.13.19.01.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 13 Dec 2015 19:01:45 -0800 (PST)
Date: Mon, 14 Dec 2015 12:03:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 1/3] mm, printk: introduce new format string for flags
Message-ID: <20151214030317.GA3781@js1304-P5Q-DELUXE>
References: <87io4hi06n.fsf@rasmusvillemoes.dk>
 <1449242195-16374-1-git-send-email-vbabka@suse.cz>
 <20151210025944.GB17967@js1304-P5Q-DELUXE>
 <20151210040456.GC7814@home.goodmis.org>
 <56694DF6.70600@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56694DF6.70600@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On Thu, Dec 10, 2015 at 11:03:34AM +0100, Vlastimil Babka wrote:
> On 12/10/2015 05:04 AM, Steven Rostedt wrote:
> >On Thu, Dec 10, 2015 at 11:59:44AM +0900, Joonsoo Kim wrote:
> >>Ccing, Steven to ask trace-cmd problem.
> >>
> >>I'd like to use %pgp in tracepoint output. It works well when I do
> >>'cat /sys/kernel/debug/tracing/trace' but not works well when I do
> >>'./trace-cmd report'. It prints following error log.
> >>
> >>   [page_ref:page_ref_unfreeze] bad op token &
> >>   [page_ref:page_ref_set] bad op token &
> >>   [page_ref:page_ref_mod_unless] bad op token &
> >>   [page_ref:page_ref_mod_and_test] bad op token &
> >>   [page_ref:page_ref_mod_and_return] bad op token &
> >>   [page_ref:page_ref_mod] bad op token &
> >>   [page_ref:page_ref_freeze] bad op token &
> >>
> >>Following is the format I used.
> >>
> >>TP_printk("pfn=0x%lx flags=%pgp count=%d mapcount=%d mapping=%p mt=%d val=%d ret=%d",
> >>                 __entry->pfn, &__entry->flags, __entry->count,
> >>                 __entry->mapcount, __entry->mapping, __entry->mt,
> >>                 __entry->val, __entry->ret)
> >>
> >>Could it be solved by 'trace-cmd' itself?
> 
> You mean that trace-cmd/parse-events.c would interpret the raw value
> of flags by itself? That would mean the flags became fixed ABI, not
> a good idea...
> 
> >>Or it's better to pass flags by value?
> 
> If it's value (as opposed to a pointer in %pgp), that doesn't change
> much wrt. having to intepret them?
> 
> >>Or should I use something like show_gfp_flags()?
> 
> Sounds like least pain to me, at least for now. We just need to have
> the translation tables available as #define with __print_flags() in
> some trace/events header, like the existing trace/events/gfpflags.h
> for gfp flags. These tables can still be reused within mm/debug.c or
> printk code without copy/paste, like I did in "[PATCH v2 6/9] mm,
> debug: introduce dump_gfpflag_names() for symbolic printing of
> gfp_flags" [1]. Maybe it's not the most elegant solution, but works
> without changing parse-events.c using the existing format export.
> 
> So if you agree, I can do this in the next spin.
> 

Okay. I'm okay with this approach.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

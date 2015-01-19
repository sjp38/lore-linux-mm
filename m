Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD546B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 09:38:40 -0500 (EST)
Received: by mail-la0-f49.google.com with SMTP id hs14so29242570lab.8
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 06:38:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o5si13264210lae.100.2015.01.19.06.38.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 06:38:38 -0800 (PST)
Message-ID: <54BD16EA.9050007@suse.cz>
Date: Mon, 19 Jan 2015 15:38:34 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: compaction tracepoint broken with CONFIG_COMPACTION enabled
References: <54b9a3ce.lQ94nh84G4XJawsQ%akpm@linux-foundation.org> <20150119124210.GC21052@dhcp22.suse.cz>
In-Reply-To: <20150119124210.GC21052@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au

On 01/19/2015 01:42 PM, Michal Hocko wrote:
> Hi,
> compaction trace points seem to be broken without CONFIG_COMPACTION
> enabled after
> mm-compaction-more-trace-to-understand-when-why-compaction-start-finish.patch.
> 
> My config is
> # CONFIG_COMPACTION is not set
> CONFIG_CMA=y

Joonsoo posted a V4 that should be fixed at least according to description -
unfortunately it wasn't just fixes on top of what's in mmotm, though.

> which might be a bit unusual but I am getting
>   CC      mm/compaction.o
> In file included from include/trace/define_trace.h:90:0,
>                  from include/trace/events/compaction.h:298,
>                  from mm/compaction.c:49:
> include/trace/events/compaction.h: In function a??ftrace_raw_output_mm_compaction_enda??:
> include/trace/events/compaction.h:164:3: error: a??compaction_status_stringa?? undeclared (first use in this function)
>    compaction_status_string[__entry->status])
>    ^
> [...]
> include/trace/events/compaction.h: In function a??ftrace_raw_output_mm_compaction_suitable_templatea??:
> include/trace/events/compaction.h:220:3: error: a??compaction_status_stringa?? undeclared (first use in this function)
>    compaction_status_string[__entry->ret])
> [...]
> scripts/Makefile.build:257: recipe for target 'mm/compaction.o' failed
> make[1]: *** [mm/compaction.o] Error 1
> Makefile:1528: recipe for target 'mm/compaction.o' failed
> make: *** [mm/compaction.o] Error 2
> 
> Moving compaction_status_string outside of CONFIG_COMPACTION doesn't
> help much because of other failures:
> include/trace/events/compaction.h:261:30: error: a??struct zonea?? has no member named a??compact_defer_shifta??
>    __entry->defer_shift = zone->compact_defer_shift;
> 
> So I guess the tracepoint need a better fix.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

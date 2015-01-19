Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 842FA6B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 07:42:14 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id l15so6633995wiw.0
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 04:42:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gh7si21172677wib.71.2015.01.19.04.42.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 04:42:11 -0800 (PST)
Date: Mon, 19 Jan 2015 13:42:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: compaction tracepoint broken with CONFIG_COMPACTION enabled (was:
 mmotm 2015-01-16-15-50 uploaded)
Message-ID: <20150119124210.GC21052@dhcp22.suse.cz>
References: <54b9a3ce.lQ94nh84G4XJawsQ%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <54b9a3ce.lQ94nh84G4XJawsQ%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au

Hi,
compaction trace points seem to be broken without CONFIG_COMPACTION
enabled after
mm-compaction-more-trace-to-understand-when-why-compaction-start-finish.patch.

My config is
# CONFIG_COMPACTION is not set
CONFIG_CMA=y

which might be a bit unusual but I am getting
  CC      mm/compaction.o
In file included from include/trace/define_trace.h:90:0,
                 from include/trace/events/compaction.h:298,
                 from mm/compaction.c:49:
include/trace/events/compaction.h: In function a??ftrace_raw_output_mm_compaction_enda??:
include/trace/events/compaction.h:164:3: error: a??compaction_status_stringa?? undeclared (first use in this function)
   compaction_status_string[__entry->status])
   ^
[...]
include/trace/events/compaction.h: In function a??ftrace_raw_output_mm_compaction_suitable_templatea??:
include/trace/events/compaction.h:220:3: error: a??compaction_status_stringa?? undeclared (first use in this function)
   compaction_status_string[__entry->ret])
[...]
scripts/Makefile.build:257: recipe for target 'mm/compaction.o' failed
make[1]: *** [mm/compaction.o] Error 1
Makefile:1528: recipe for target 'mm/compaction.o' failed
make: *** [mm/compaction.o] Error 2

Moving compaction_status_string outside of CONFIG_COMPACTION doesn't
help much because of other failures:
include/trace/events/compaction.h:261:30: error: a??struct zonea?? has no member named a??compact_defer_shifta??
   __entry->defer_shift = zone->compact_defer_shift;

So I guess the tracepoint need a better fix.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

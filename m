Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 266BE6B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 02:28:47 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id hb5so114333059wjc.2
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 23:28:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qa4si80369186wjc.238.2017.01.03.23.28.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 23:28:46 -0800 (PST)
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-3-mhocko@kernel.org> <20161229053359.GA1815@bbox>
 <20161229075243.GA29208@dhcp22.suse.cz> <20161230014853.GA4184@bbox>
 <20161230092636.GA13301@dhcp22.suse.cz> <20161230160456.GA7267@bbox>
 <20161230163742.GK13301@dhcp22.suse.cz> <20170103050328.GA15700@bbox>
 <20170103082122.GA30111@dhcp22.suse.cz> <20170104050722.GA17166@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9f77c4d2-dddf-8fc6-0982-edf02a58b15f@suse.cz>
Date: Wed, 4 Jan 2017 08:28:43 +0100
MIME-Version: 1.0
In-Reply-To: <20170104050722.GA17166@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 01/04/2017 06:07 AM, Minchan Kim wrote:
> With this,
> ./scripts/bloat-o-meter vmlinux.old vmlinux.new.new
> add/remove: 1/1 grow/shrink: 0/9 up/down: 1394/-1636 (-242)
> function                                     old     new   delta
> isolate_lru_pages                              -    1394   +1394
> print_fmt_mm_vmscan_lru_shrink_inactive      359     355      -4
> vermagic                                      64      58      -6
> perf_trace_mm_vmscan_lru_shrink_active       264     256      -8
> trace_raw_output_mm_vmscan_lru_shrink_active     203     193     -10
> trace_event_raw_event_mm_vmscan_lru_shrink_active     241     225     -16
> print_fmt_mm_vmscan_lru_shrink_active        458     426     -32
> trace_event_define_fields_mm_vmscan_lru_shrink_active     384     336     -48
> shrink_inactive_list                        1430    1271    -159
> shrink_active_list                          1265    1082    -183
> isolate_lru_pages.isra                      1170       -   -1170
> Total: Before=26268743, After=26268501, chg -0.00%
> 
> We can save 242 bytes.
> 
> If we consider binary size, 424 bytes save.
> 
> #> ls -l vmlinux.old vmlinux.new.new
> 194092840  vmlinux.old
> 194092416  vmlinux.new.new

Which is roughly 0.0002%. Not that I'm against fighting bloat, but let's
not forget that it's not the only factor. For example the following part
from above:

> isolate_lru_pages                              -    1394   +1394
> isolate_lru_pages.isra                      1170       -   -1170

shows that your change has prevented a -fipa-src gcc optimisation, which
is "interprocedural scalar replacement of aggregates, removal of unused
parameters and replacement of parameters passed by reference by
parameters passed by value." Well, I'm no gcc expert :) but it might be
that the change is not a simple win-win.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

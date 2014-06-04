Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id EA0066B0031
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 07:04:17 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id r20so1206666wiv.3
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 04:04:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d16si33682302wiv.38.2014.06.04.04.04.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 04:04:16 -0700 (PDT)
Date: Wed, 4 Jun 2014 12:04:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch -mm 3/3] mm, compaction: avoid compacting memory for thp
 if pageblock cannot become free
Message-ID: <20140604110411.GK10819@suse.de>
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz>
 <1400233673-11477-1-git-send-email-vbabka@suse.cz>
 <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com>
 <537DB0E5.40602@suse.cz>
 <alpine.DEB.2.02.1405220127320.13630@chino.kir.corp.google.com>
 <537DE799.3040400@suse.cz>
 <alpine.DEB.2.02.1406031728390.5312@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1406031729410.5312@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1406031729410.5312@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

On Tue, Jun 03, 2014 at 05:30:01PM -0700, David Rientjes wrote:
> It's pointless to migrate pages within a pageblock if the entire pageblock will 
> not become free for a thp allocation.
> 
> If we encounter a page that cannot be migrated and a direct compactor other than 
> khugepaged is trying to allocate a hugepage for thp, then skip the entire 
> pageblock and avoid migrating pages needlessly.
> 

It's not completely pointless. A movable page may be placed within an
unmovable pageblock due to insufficient free memory or a pageblock changed
type. When this happens then partial migration moves the movable page
of out of the unmovable block. Future unmovable allocations can then be
placed with other unmovable pages instead of falling back to other blocks
and degrading fragmentation over time.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

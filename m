Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADE1A6B03E7
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:25:07 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x23so30042368wrb.6
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:25:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p89si12696963wma.78.2017.06.21.05.25.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 05:25:06 -0700 (PDT)
Subject: Re: [PATCH] mm: avoid taking zone lock in pagetypeinfo_showmixed
References: <1498045643-12257-1-git-send-email-vinmenon@codeaurora.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d2ca6001-2d1f-f258-ca4b-72f9e9275853@suse.cz>
Date: Wed, 21 Jun 2017 14:24:22 +0200
MIME-Version: 1.0
In-Reply-To: <1498045643-12257-1-git-send-email-vinmenon@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, zhongjiang@huawei.com, sergey.senozhatsky@gmail.com, sudipm.mukherjee@gmail.com, hannes@cmpxchg.org, mgorman@techsingularity.net, mhocko@suse.com, bigeasy@linutronix.de, rientjes@google.com, minchan@kernel.org
Cc: linux-mm@kvack.org

On 06/21/2017 01:47 PM, Vinayak Menon wrote:
> pagetypeinfo_showmixedcount_print is found to take a lot of
> time to complete and it does this holding the zone lock and
> disabling interrupts. In some cases it is found to take more
> than a second (On a 2.4GHz,8Gb RAM,arm64 cpu). Avoid taking
> the zone lock similar to what is done by read_page_owner,
> which means possibility of inaccurate results.
> 
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

walk_zones_in_node() becomes quite ugly though, multiple bool params are
not nice, and both are there for single special cases. Wonder if
replacing this with a new for_each_zone_node() helper would make this
better. OTOH it's now isolated only to vmstat.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

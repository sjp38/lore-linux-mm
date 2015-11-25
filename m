Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 876336B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:28:59 -0500 (EST)
Received: by wmuu63 with SMTP id u63so133798590wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:28:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id us2si33919908wjc.196.2015.11.25.03.28.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 03:28:58 -0800 (PST)
Date: Wed, 25 Nov 2015 11:28:51 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: vmscan: Obey indeed proportional scanning for kswapd
 and memcg
Message-ID: <20151125112851.GP19677@suse.de>
References: <1448426900-2907-1-git-send-email-baiyaowei@cmss.chinamobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1448426900-2907-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, jslaby@suse.cz, Valdis.Kletnieks@vt.edu, zcalusic@bitsync.net, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 25, 2015 at 12:48:20PM +0800, Yaowei Bai wrote:
> Commit e82e0561dae9f3ae5 ("mm: vmscan: obey proportional scanning
> requirements for kswapd") intended to preserve the proportional scanning
> and reclaim what was requested by get_scan_count() for kswapd and memcg
> by stopping reclaiming one type(anon or file) LRU and reducing the other's
> amount of scanning proportional to the original scan target.
> 
> So the way to determine which LRU should be stopped reclaiming should be
> comparing scanned/unscanned percentages to the original scan target of two
> lru types instead of absolute values what implemented currently, because
> larger absolute value doesn't mean larger percentage, there shall be
> chance that larger absolute value with smaller percentage, for instance:
> 
> 	target_file = 1000
> 	target_anon = 500
> 	nr_file = 500
> 	nr_anon = 400
> 
> in this case, because nr_file > nr_anon, according to current implement,
> we will stop scanning anon lru and shrink file lru. This breaks
> proportional scanning intent and makes more unproportional.
> 
> This patch changes to compare percentage to the original scan target to
> determine which lru should be shrunk.
> 
> Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>

This one has gone back and forth a few times in the past. It really was
deliberate that the scanning was proportional to the scan target. While
I see what your concern is, it's unclear what the actual impact is. Have
you done any testing to check if the proposed new behaviour is actually
better?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

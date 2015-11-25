Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 109226B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:43:42 -0500 (EST)
Received: by wmww144 with SMTP id w144so69877085wmw.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:43:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f81si5976426wmh.9.2015.11.25.05.43.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 05:43:40 -0800 (PST)
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20151125120021.GA27342@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5655BB0A.90000@suse.cz>
Date: Wed, 25 Nov 2015 14:43:38 +0100
MIME-Version: 1.0
In-Reply-To: <20151125120021.GA27342@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 11/25/2015 01:00 PM, Michal Hocko wrote:
> On Tue 24-11-15 15:22:03, Joonsoo Kim wrote:
>> When I tested compaction in low memory condition, I found that
>> my benchmark is stuck in congestion_wait() at shrink_inactive_list().
>> This stuck last for 1 sec and after then it can escape. More investigation
>> shows that it is due to stale vmstat value. vmstat is updated every 1 sec
>> so it is stuck for 1 sec.
> 
> Wouldn't it be sufficient to use zone_page_state_snapshot in
> too_many_isolated?

That sounds better than the ad-hoc half-solution, yeah.
I don't know how performance sensitive the callers are, but maybe it could do a
non-snapshot check first, and only repeat with _snapshot when it's about to wait
(the result is true), just to make sure?

OTOH, how big issue is this? I suspect the system has been genuinely
too_many_isolated(), or very close, in order to hit the condition in the first
place, and the inaccuracy just delays the recovery a bit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB8E6B02E1
	for <linux-mm@kvack.org>; Tue,  2 May 2017 04:06:06 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d46so6712888wrd.17
        for <linux-mm@kvack.org>; Tue, 02 May 2017 01:06:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n126si1793703wmd.33.2017.05.02.01.06.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 01:06:04 -0700 (PDT)
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170411181519.GC21171@dhcp22.suse.cz>
 <20170412013503.GA8448@js1304-desktop>
 <20170413115615.GB11795@dhcp22.suse.cz>
 <20170417020210.GA1351@js1304-desktop> <20170424130936.GB1746@dhcp22.suse.cz>
 <20170425034255.GB32583@js1304-desktop>
 <20170427150636.GM4706@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <32ac1107-14a3-fdff-ad48-0e246fec704f@suse.cz>
Date: Tue, 2 May 2017 10:06:01 +0200
MIME-Version: 1.0
In-Reply-To: <20170427150636.GM4706@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On 04/27/2017 05:06 PM, Michal Hocko wrote:
> On Tue 25-04-17 12:42:57, Joonsoo Kim wrote:
>> On Mon, Apr 24, 2017 at 03:09:36PM +0200, Michal Hocko wrote:
>>> On Mon 17-04-17 11:02:12, Joonsoo Kim wrote:
>>>> On Thu, Apr 13, 2017 at 01:56:15PM +0200, Michal Hocko wrote:
>>>>> On Wed 12-04-17 10:35:06, Joonsoo Kim wrote:
> [...]
>>> not for free. For most common configurations where we have ZONE_DMA,
>>> ZONE_DMA32, ZONE_NORMAL and ZONE_MOVABLE all the 3 bits are already
>>> consumed so a new zone will need a new one AFAICS.
>>
>> Yes, it requires one more bit for a new zone and it's handled by the patch.
> 
> I am pretty sure that you are aware that consuming new page flag bits
> is usually a no-go and something we try to avoid as much as possible
> because we are in a great shortage there. So there really have to be a
> _strong_ reason if we go that way. My current understanding that the
> whole zone concept is more about a more convenient implementation rather
> than a fundamental change which will solve unsolvable problems with the
> current approach. More on that below.

I don't see it as such a big issue. It's behind a CONFIG option (so we
also don't need the jump labels you suggest later) and enabling it
reduces the number of possible NUMA nodes (not page flags). So either
you are building a kernel for android phone that needs CMA but will have
a single NUMA node, or for a large server with many nodes that won't
have CMA. As long as there won't be large servers that need CMA, we
should be fine (yes, I know some HW vendors can be very creative, but
then it's their problem?).

> [...]
>> MOVABLE allocation will fallback as following sequence.
>>
>> ZONE_CMA -> ZONE_MOVABLE -> ZONE_HIGHMEM -> ZONE_NORMAL -> ...

Hmm, so this in effect resembles some of the aggressive CMA utilization
efforts that were never merged due to issues. Joonsoo, could you
summarize/expand the cover letter part on what were the issues with
aggressive CMA utilization, and why they no longer apply with ZONE_CMA,
especially given the current node-lru reclaim? Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

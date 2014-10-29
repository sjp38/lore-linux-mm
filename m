Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9278E900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 09:51:19 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id l4so2482835lbv.4
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 06:51:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xv1si7259862lbb.119.2014.10.29.06.51.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 06:51:16 -0700 (PDT)
Message-ID: <5450F0CF.3030504@suse.cz>
Date: Wed, 29 Oct 2014 14:51:11 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] mm, compaction: pass classzone_idx and alloc_flags
 to watermark checking
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz> <1412696019-21761-2-git-send-email-vbabka@suse.cz> <20141027064651.GA23379@js1304-P5Q-DELUXE> <544E0C43.3030009@suse.cz> <20141028071625.GB27813@js1304-P5Q-DELUXE>
In-Reply-To: <20141028071625.GB27813@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 10/28/2014 08:16 AM, Joonsoo Kim wrote:> On Mon, Oct 27, 2014 at 
10:11:31AM +0100, Vlastimil Babka wrote:
 >> On 10/27/2014 07:46 AM, Joonsoo Kim wrote:
 >>> On Tue, Oct 07, 2014 at 05:33:35PM +0200, Vlastimil Babka wrote:
 >>>
 >>> Hello,
 >>>
 >>> compaction_suitable() has one more zone_watermark_ok(). Why is it
 >>> unchanged?
 >>
 >> Hi,
 >>
 >> it's a check whether there are enough free pages to perform compaction,
 >> which means enough migration targets and temporary copies during
 >> migration. These allocations are not affected by the flags of the
 >> process that makes the high-order allocation.
 >
 > Hmm...
 >
 > To check whether enough free page is there or not needs zone index and
 > alloc flag. What we need to ignore is just order information, IMO.
 > If there is not enough free page in that zone, compaction progress
 > doesn't have any meaning. It will fail due to shortage of free page
 > after successful compaction.

I thought that the second check in compaction_suitable() makes sure of 
this, but now I see it's in fact not.
But i'm not sure if we should just put the flags in the first check, as 
IMHO the flags should only affect the final high-order allocation, not 
also the temporary pages needed for migration?

BTW now I'm not even sure that the 2UL << order part makes sense 
anymore. The number of pages migrated at once is always restricted by 
COMPACT_CLUSTER_MAX, so why would we need more than that to cover migration?
Also the order of checks seems wrong. It should return COMPACT_PARTIAL 
"If the allocation would succeed without compaction" but that only can 
happen after passing the check if the zone has the extra 1UL << order 
for migration. Do you agree?

 > I guess that __isolate_free_page() is also good candidate to need this
 > information in order to prevent compaction from isolating too many
 > freepage in low memory condition.

I don't see how it would help here. It's temporary allocations for page 
migration. How would passing classzone_idx and alloc_flags prevent 
isolating too many?

 > Thanks.
 >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

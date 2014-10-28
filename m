Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 68AD5900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 03:15:09 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so101158pab.10
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 00:15:09 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id tw4si635192pab.24.2014.10.28.00.15.07
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 00:15:08 -0700 (PDT)
Date: Tue, 28 Oct 2014 16:16:25 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/5] mm, compaction: pass classzone_idx and alloc_flags
 to watermark checking
Message-ID: <20141028071625.GB27813@js1304-P5Q-DELUXE>
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
 <1412696019-21761-2-git-send-email-vbabka@suse.cz>
 <20141027064651.GA23379@js1304-P5Q-DELUXE>
 <544E0C43.3030009@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <544E0C43.3030009@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Mon, Oct 27, 2014 at 10:11:31AM +0100, Vlastimil Babka wrote:
> On 10/27/2014 07:46 AM, Joonsoo Kim wrote:
> > On Tue, Oct 07, 2014 at 05:33:35PM +0200, Vlastimil Babka wrote:
> > 
> > Hello,
> > 
> > compaction_suitable() has one more zone_watermark_ok(). Why is it
> > unchanged?
> 
> Hi,
> 
> it's a check whether there are enough free pages to perform compaction,
> which means enough migration targets and temporary copies during
> migration. These allocations are not affected by the flags of the
> process that makes the high-order allocation.

Hmm...

To check whether enough free page is there or not needs zone index and
alloc flag. What we need to ignore is just order information, IMO.
If there is not enough free page in that zone, compaction progress
doesn't have any meaning. It will fail due to shortage of free page
after successful compaction.

I guess that __isolate_free_page() is also good candidate to need this
information in order to prevent compaction from isolating too many
freepage in low memory condition.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFCEA6B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 21:42:40 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id r4so62086216oib.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 18:42:40 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z67si13322257itf.88.2016.06.06.18.42.39
        for <linux-mm@kvack.org>;
        Mon, 06 Jun 2016 18:42:40 -0700 (PDT)
Date: Tue, 7 Jun 2016 10:43:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: add NR_ZSMALLOC to vmstat
Message-ID: <20160607014340.GB26230@bbox>
References: <1464919731-13255-1-git-send-email-minchan@kernel.org>
 <20160603080141.GA490@swordfish>
 <20160603082336.GA18488@bbox>
 <20160603102432.GB586@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160603102432.GB586@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Chanho Min <chanho.min@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>

Hi Sergey,

On Fri, Jun 03, 2016 at 07:24:32PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (06/03/16 17:23), Minchan Kim wrote:
> > On Fri, Jun 03, 2016 at 05:01:41PM +0900, Sergey Senozhatsky wrote:
> > > On (06/03/16 11:08), Minchan Kim wrote:
> > > > Now, zram is very popular for some of embedded world(e.g., TV, mobile
> > > > phone). On those system, zsmalloc consumed memory size is never trivial
> > > > (one of example from real product system, total memory: 800M, zsmalloc
> > > > consumed: 150M), so we have used this out of tree patch to monitor system
> > > > memory behavior via /proc/vmstat.
> > > > 
> > > > With zsmalloc in vmstat, it helps tracking down system behavior by
> > > > memory usage.
> > > 
> > > Hello,
> > > 
> > > may be use zsmalloc stats file instead? as far as I know, you keep
> > > zsmalloc stats enabled in production anyway.
> > 
> > It doesn't support per-zone stat which is important to show
> > the fragmentation of the zone, for exmaple.
> 
> Ah, I see.
> 
> *just an idea*
> 
> may be zbud and z3fold folks will be interested as well, so may

First motivation of stat came from fragmentation problem from zsmalloc
which caused by storing many thin zpages in a pageframe and across two
pageframes while zswap limits the limitation by design.

Second motivation is zsmalloc can allocate page from HIGH/movable zones
so I want to know how distribution zsmalloced pages is.
However, zbud doesn't.

Lastly, zswap is designed for short-lived with backed storage so I guess
it shouldn't be a problem.

http://marc.info/?l=linux-mm&m=136570894925571&w=2
http://marc.info/?l=linux-kernel&m=136571103026450&w=2

Quote from Seth
"
> Compaction - compaction would basically involve creating a virtual address
> space of sorts, which zsmalloc is capable of through its API with handles,
> not pointer. However, as Dan points out this requires a structure the maintain
> the mappings and adds to complexity. Additionally, the need for compaction
> diminishes as the allocations are short-lived with frontswap backends doing
> writeback and cleancache backends shrinking.

Of course I say this, but for zram, this can be important as the allocations
can't be moved out of memory and, therefore, are long lived. I was speaking
from the zswap perspective.
"


> be more generic name and define... um, my head doesn't work toay..
> ZALLOC... ZPOOLALLOC... hm.. I think you got the idea.

Having said that, generic name is better rather than zsmalloc. Thanks.
I want to use *zspage* which is term from the beginning of zprojects. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

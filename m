Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 11D306B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 21:47:13 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so7592598pde.21
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 18:47:12 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id m1si22673198pbe.268.2014.02.03.18.47.10
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 18:47:11 -0800 (PST)
Date: Tue, 4 Feb 2014 11:47:07 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/zswap: add writethrough option
Message-ID: <20140204024707.GC3481@bbox>
References: <1387459407-29342-1-git-send-email-ddstreet@ieee.org>
 <1390831279-5525-1-git-send-email-ddstreet@ieee.org>
 <20140203150835.f55fd427d0ebb0c2943f266b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140203150835.f55fd427d0ebb0c2943f266b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Weijie Yang <weijie.yang@samsung.com>, Shirish Pargaonkar <spargaonkar@suse.com>, Mel Gorman <mgorman@suse.de>

Hello Andrew,

On Mon, Feb 03, 2014 at 03:08:35PM -0800, Andrew Morton wrote:
> On Mon, 27 Jan 2014 09:01:19 -0500 Dan Streetman <ddstreet@ieee.org> wrote:
> 
> > Currently, zswap is writeback cache; stored pages are not sent
> > to swap disk, and when zswap wants to evict old pages it must
> > first write them back to swap cache/disk manually.  This avoids
> > swap out disk I/O up front, but only moves that disk I/O to
> > the writeback case (for pages that are evicted), and adds the
> > overhead of having to uncompress the evicted pages and the
> > need for an additional free page (to store the uncompressed page).
> > 
> > This optionally changes zswap to writethrough cache by enabling
> > frontswap_writethrough() before registering, so that any
> > successful page store will also be written to swap disk.  The
> > default remains writeback.  To enable writethrough, the param
> > zswap.writethrough=1 must be used at boot.
> > 
> > Whether writeback or writethrough will provide better performance
> > depends on many factors including disk I/O speed/throughput,
> > CPU speed(s), system load, etc.  In most cases it is likely
> > that writeback has better performance than writethrough before
> > zswap is full, but after zswap fills up writethrough has
> > better performance than writeback.
> > 
> > The reason to add this option now is, first to allow any zswap
> > user to be able to test using writethrough to determine if they
> > get better performance than using writeback, and second to allow
> > future updates to zswap, such as the possibility of dynamically
> > switching between writeback and writethrough.
> > 
> > ...
> >
> > Based on specjbb testing on my laptop, the results for both writeback
> > and writethrough are better than not using zswap at all, but writeback
> > does seem to be better than writethrough while zswap isn't full.  Once
> > it fills up, performance for writethrough is essentially close to not
> > using zswap, while writeback seems to be worse than not using zswap.
> > However, I think more testing on a wider span of systems and conditions
> > is needed.  Additionally, I'm not sure that specjbb is measuring true
> > performance under fully loaded cpu conditions, so additional cpu load
> > might need to be added or specjbb parameters modified (I took the
> > values from the 4 "warehouses" test run).
> > 
> > In any case though, I think having writethrough as an option is still
> > useful.  More changes could be made, such as changing from writeback
> > to writethrough based on the zswap % full.  And the patch doesn't
> > change default behavior - writethrough must be specifically enabled.
> > 
> > The %-ized numbers I got from specjbb on average, using the default
> > 20% max_pool_percent and varying the amount of heap used as shown:
> > 
> > ram | no zswap | writeback | writethrough
> > 75     93.08     100         96.90
> > 87     96.58     95.58       96.72
> > 100    92.29     89.73       86.75
> > 112    63.80     38.66       19.66
> > 125    4.79      29.90       15.75
> > 137    4.99      4.50        4.75
> > 150    4.28      4.62        5.01
> > 162    5.20      2.94        4.66
> > 175    5.71      2.11        4.84
> 
> Changelog is very useful, thanks for taking the time.
> 
> It does sound like the feature is of marginal benefit.  Is "zswap
> filled up" an interesting or useful case to optimize?
> 
> otoh the addition is pretty simple and we can later withdraw the whole
> thing without breaking anyone's systems.
> 
> What do people think?

IMHO, Using overcommiting memory and swap, it's really thing
we shold optimize once we decided to use writeback of zswap.

But I don't think writethrough isn't ideal solution for
that case where zswap is full. Sometime, just dynamic disabling
of zswap might be better due to reducing unnecessary
comp/decomp overhead.

Dan said that it's good to have because someuser might find
right example we didn't find in future. Although I'm not a
huge fan of such justification for merging the patch(I tempted
my patches several time with such claim), I don't object it
(Actually, I have an idea to make zswap's writethough useful but
it isn't related to this topic) any more if we could withdraw
easily if it turns out a obstacle for future enhace.

Thanks.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3DF886B0088
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 04:11:54 -0400 (EDT)
Date: Fri, 10 Jul 2009 16:34:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class
	citizen  (with test cases)
Message-ID: <20090710083429.GC24168@localhost>
References: <20090608091044.880249722@intel.com> <ab418ea90907100024xe95ab44pb0809d262e616565@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ab418ea90907100024xe95ab44pb0809d262e616565@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Nai Xia <nai.xia@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 10, 2009 at 03:24:29PM +0800, Nai Xia wrote:
> Hi,
> 
> I was able to launch some tests with SPEC cpu2006.
> The benchmark was based on mmotm
> commit 0b7292956dbdfb212abf6e3c9cfb41e9471e1081 on a intel  Q6600 box with
> 4G ram. The kernel cmdline mem=500M was used to see how good exec-prot can
> be under memory stress.

Thank you for the testings, Nai!

> Following are the results:
> 
>                                   Estimated
>                 Base     Base       Base
> Benchmarks      Ref.   Run Time     Ratio
> 
> mmotm with 500M
> 400.perlbench    9770        671      14.6  *
> 401.bzip2        9650       1011       9.55 *
> 403.gcc          8050        774      10.4  *
> 462.libquantum  20720       1213      17.1  *
> 
> 
> mmot-prot with 500M
> 400.perlbench    9770        658      14.8  *
> 401.bzip2        9650       1007       9.58 *
> 403.gcc          8050        749      10.8  *
> 462.libquantum  20720       1116      18.6  *
> 
> mmotm with 4G ( allowing the full working sets)
> 400.perlbench    9770        594      16.5  *
> 401.bzip2        9650        828      11.7  *
> 403.gcc          8050        523      15.4  *
> 462.libquantum  20720       1121      18.5  *

mmotm    mmotm-prot  mmotm-4G    mmotm-prot   mmotm-4G
14.6     14.8        16.5        +1.4%        +13.0%  
 9.55     9.58       11.7        +0.3%        +22.5%  
10.4     10.8        15.4        +3.8%        +48.1%  
17.1     18.6        18.5        +8.8%         +8.2%  

So it's mostly small improvements.

> It's worth noting that SPEC documented "The CPU2006 benchmarks
> (code + workload) have been designed to fit within about 1GB of
> physical memory",
> and the exec vm sizes of these programs are as below:
> perlbench  956KB
> bzip2         56KB
> gcc          3008KB
> libquantum  36KB
> 
> 
> Are we expecting to see more good results for cpu-bound programs (e.g.
> scientific ones)
> with large number of exec pages ?

Not likely. Scientific computing is typically equipped with lots of
memory and the footprint of the program itself is relatively small.

The exec-mmap protection mainly helps when some exec pages/programs
have been inactive for some minutes and then go active. That's the
typically desktop use pattern.

Thanks,
Fengguang

> On Mon, Jun 8, 2009 at 5:10 PM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> > Andrew,
> >
> > I managed to back this patchset with two test cases :)
> >
> > They demonstrated that
> > - X desktop responsiveness can be *doubled* under high memory/swap pressure
> > - it can almost stop major faults when the active file list is slowly scanned
> > A because of undergoing partially cache hot streaming IO
> >
> > The details are included in the changelog.
> >
> > Thanks,
> > Fengguang
> > --
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org. A For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

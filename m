Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 81E306B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 06:14:45 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so1455271pbc.13
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 03:14:45 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id eb3si444263pbd.77.2014.01.08.03.14.43
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 03:14:44 -0800 (PST)
Date: Wed, 8 Jan 2014 19:14:40 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [numa shrinker] 9b17c62382: -36.6% regression on sparse file copy
Message-ID: <20140108111440.GA10467@localhost>
References: <20140106082048.GA567@localhost>
 <20140106131042.GA5145@destitution>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140106131042.GA5145@destitution>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@parallels.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, lkp@linux.intel.com

On Tue, Jan 07, 2014 at 12:10:42AM +1100, Dave Chinner wrote:
> On Mon, Jan 06, 2014 at 04:20:48PM +0800, fengguang.wu@intel.com wrote:
> > Hi Dave,
> > 
> > We noticed throughput drop in test case
> > 
> >         vm-scalability/300s-lru-file-readtwice (*)
> > 
> > between v3.11 and v3.12, and it's still low as of v3.13-rc6:
> > 
> >           v3.11                      v3.12                  v3.13-rc6
> > ---------------  -------------------------  -------------------------
> >   14934707 ~ 0%     -48.8%    7647311 ~ 0%     -47.6%    7829487 ~ 0%  vm-scalability.throughput
> >              ^^     ^^^^^^
> >         stddev%    change%
> 
> What does this vm-scalability.throughput number mean?

It's the total throughput reported by all the 240 dd:

8781176832 bytes (8.8 GB) copied, 299.97 s, 29.3 MB/s
2124931+0 records in
2124930+0 records out
8703713280 bytes (8.7 GB) copied, 299.97 s, 29.0 MB/s
2174078+0 records in
2174077+0 records out
...

> > (*) The test case basically does
> > 
> >         truncate -s 135080058880 /tmp/vm-scalability.img
> >         mkfs.xfs -q /tmp/vm-scalability.img
> >         mount -o loop /tmp/vm-scalability.img /tmp/vm-scalability 
> > 
> >         nr_cpu=120
> >         for i in $(seq 1 $nr_cpu)
> >         do     
> >                 sparse_file=/tmp/vm-scalability/sparse-lru-file-readtwice-$i
> >                 truncate $sparse_file -s 36650387592
> >                 dd if=$sparse_file of=/dev/null &
> >                 dd if=$sparse_file of=/dev/null &
> >         done
> 
> So a page cache load of reading 120x36GB files twice concurrently?

Yes.

> There's no increase in system time, so it can't be that the
> shrinkers are running wild.
> 
> FWIW, I'm at LCA right now, so it's going to be a week before I can
> look at this, so if you can find any behavioural difference in the
> shrinkers (e.g. from perf profiles, on different filesystems, etc)
> I'd appreciate it...

OK, enjoy your time! I'll try different parameters and check if that
makes any difference.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

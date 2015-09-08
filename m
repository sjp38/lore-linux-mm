Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 88F106B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 20:21:37 -0400 (EDT)
Received: by iofb144 with SMTP id b144so100838750iof.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 17:21:37 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id fm4si2345377pab.148.2015.09.07.17.21.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 17:21:36 -0700 (PDT)
Received: by padhk3 with SMTP id hk3so22483359pad.3
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 17:21:36 -0700 (PDT)
Date: Tue, 8 Sep 2015 09:22:20 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150908002220.GC6896@swordfish>
References: <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
 <20150903060247.GV1933@devil.localdomain>
 <20150903122949.78ee3c94@redhat.com>
 <20150904063528.GA29320@swordfish>
 <CA+55aFxOR06BiyH9nfFXzidFGr77R_BGp_xypjFQJSnv5c+_-g@mail.gmail.com>
 <20150904075945.GA31503@swordfish>
 <CA+55aFzs78Y0LS2FJG7Mrh6KBFxVnsBGSAySoi7SpR+EmmGpLg@mail.gmail.com>
 <20150905020907.GA1431@swordfish>
 <CA+55aFw609MpnZPdecjxHxLRQsHp2fM+vUj0KtHPC9sTm78FRw@mail.gmail.com>
 <20150907084437.GA27956@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150907084437.GA27956@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Dave Chinner <dchinner@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (09/07/15 17:44), Sergey Senozhatsky wrote:
[...]
> Oh, that's a good idea. I didn't use tools/testing/ktest/, it's a bit too
> massive for my toy script. I have some modifications to slabinfo and a rather
> ugly script to parse files and feed them to gnuplot (and yes, I use gnuplot
> for plotting). slabinfo patches are not entirely dumb and close to being ready
> (well.. except that I need to clean up all those %6s sprintfs that worked fine
> for dynamically scalled sizes and do not work so nicely for sizes in bytes). I
> can send them out later. Less sure about the script (bash) tho. In a nutshell
> it's just a number of
>      grep | awk > FOO; gnuplot ... FOO
> 
> So I'll finish some plotting improvements first (not ready yet) and then
> I'll take a look how quickly I can land it (rewrite in perl) in
> tools/testing/ktest/.

Hi,

uploaded my scripts to
https://github.com/sergey-senozhatsky/slabinfo

A set of very simple bash scripts. The README file contains
some sort of documentation and a 'tutorial'.

==================================================================
To start collecting samples, record file name is NOMERGE, note sudo

sudo ./slabinfo-plotter.sh -r NOMERGE

#^C or reboot

pre-process records file for gnuplot

./slabinfo-plotter.sh -p NOMERGE -b gnuplot
File gnuplot_slabs-by-loss-NOMERGE
File gnuplot_slabs-by-size-NOMERGE
File gnuplot_totals-NOMERGE

generate grphs from 'slabinfo totals'

./gnuplot-totals.sh -f gnuplot_totals-NOMERGE


Graph file name -- gnuplot_totals-NOMERGE.png
...

==================================================================


Two things:
-- it wants a patched version of slabinfo (some sort of patches are in
   kernel_patches/ dir)
-- it wants slabinfo to be in PATH


For now on it does what it does -- captures numbers and picks only ones
that are interesting to me and generates plots.


I'm doing this in my spare time, but I'm surely accepting improvement
requests/ideas, pull requests, and everything that follows.


Will play around with the scripts for some time to make sure they
are usable and then we can decide if there is a place for something
like this in the kernel or it's better be done somehow differently.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id A72EF6B5028
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 03:29:43 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id o4-v6so1573400lfg.11
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 00:29:43 -0700 (PDT)
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id p22-v6si4587937ljj.46.2018.08.30.00.29.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 00:29:42 -0700 (PDT)
Date: Thu, 30 Aug 2018 09:29:40 +0200
From: Vincent Whitchurch <vincent.whitchurch@axis.com>
Subject: Re: [PATCH 2/2] scripts: add kmemleak2pprof.py for slab usage
 analysis
Message-ID: <20180830072939.i33m43mj7uslhvmz@axis.com>
References: <20180828103914.30434-1-vincent.whitchurch@axis.com>
 <20180828103914.30434-2-vincent.whitchurch@axis.com>
 <20180828162804.4ee225124cbde3f39f53fd80@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828162804.4ee225124cbde3f39f53fd80@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: catalin.marinas@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Aug 28, 2018 at 04:28:04PM -0700, Andrew Morton wrote:
> On Tue, 28 Aug 2018 12:39:14 +0200 Vincent Whitchurch <vincent.whitchurch@axis.com> wrote:
> 
> > Add a script which converts /sys/kernel/debug/kmemleak_all to the pprof
> > format, which can be used for analysing memory usage.  See
> > https://github.com/google/pprof.
> 
> Why is this better than /proc/slabinfo?

slabinfo just tells you how much memory is being used in a particular
slab, it doesn't give you a breakdown of who allocated all that memory.
slabinfo can't also tell you how much memory a particular subsystem is
using.

For example, here we can see that tracer_init_tracefs() and its callers
are using ~12% of the total tracked memory:

 $ pprof -top -compact_labels -cum prof 
 Showing nodes accounting for 13418.95kB, 92.07% of 14575.28kB total
 Dropped 4069 nodes (cum <= 72.88kB)
       flat  flat%   sum%        cum   cum%
       ...
          0     0% 56.71%  1832.15kB 12.57%  tracer_init_tracefs+0x74/0x1cc

 
And that tracefs' dentrys use 500 KiB and its inodes use 1+ MiB:
 	
 $ pprof -text -compact_labels -focus tracer_init_tracefs -nodecount 2 prof
 Main binary filename not available.
 Showing nodes accounting for 1794.85kB, 12.31% of 14575.28kB total
 Dropped 1912 nodes (cum <= 72.88kB)
 Showing top 2 nodes out of 32
       flat  flat%   sum%        cum   cum%
  1294.56kB  8.88%  8.88%  1294.56kB  8.88%  new_inode_pseudo+0x8/0x4c
   500.29kB  3.43% 12.31%   500.29kB  3.43%  d_alloc+0x10/0x78
   ...

> 
> >  $ ./kmemleak2pprof.py kmemleak_all
> >  $ pprof -text -ignore free_area_init_node -compact_labels -nodecount 10 prof
> 
> Are we missing an argument here?  s/prof/kmemleak_all/?

No, the default output filename of this script is called "prof".

Date: Thu, 1 Jun 2006 20:04:05 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: NCQ performance (was Re: [rfc][patch] remove racy sync_page?)
Message-ID: <20060601180405.GP4400@suse.de>
References: <20060601131921.GH4400@suse.de> <447F0023.8090206@argo.co.il> <20060601150320.GO4400@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060601150320.GO4400@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@argo.co.il>
Cc: Mark Lord <lkml@rtr.ca>, Linus Torvalds <torvalds@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 01 2006, Jens Axboe wrote:
> On Thu, Jun 01 2006, Avi Kivity wrote:
> > Jens Axboe wrote:
> > >
> > >Ok, I decided to rerun a simple random read work load (with fio), using
> > >depths 1 and 32. The test is simple - it does random reads all over the
> > >drive size with 4kb block sizes. The reads are O_DIRECT. The test
> > >pattern was set to repeatable, so it's going through the same workload.
> > >The test spans the first 32G of the drive and runtime is capped at 20
> > >seconds.
> > >
> > 
> > Did you modify the iodepth given to the test program, or to the drive? 
> > If the former, then some of the performance increase came from the Linux 
> > elevator.
> > 
> > Ideally exactly the same test would be run with the just the drive 
> > parameters changed.
> 
> Just from the program. Since the software depth matched the software
> depth, I'd be surprised if it made much of a difference here.  I can
> rerun the same test tomorrow with the drive depth modified the and
> software depth fixed at 32. Then the io scheduler can at least help the
> drive without NCQ out somewhat.

Same test, but with iodepth=48 for both ncq depth 1 and ncq depth 31.
This gives the io scheduler something to work with for both cases.

sda:    Maxtor 7B300S0
sdb:    Maxtor 7L320S0
sdc:    SAMSUNG HD160JJ
sdd:    HDS725050KLA360 (Hitachi 500GB drive)

drive           depth           KiB/sec         diff    diff 1/1
----------------------------------------------------------------
sda              1/1            397
sda              1              513             +29%
sda             31              673             +31+    +69%

sdb              1/1            397
sdb              1              535             +35%
sdb             31              741             +38%    +87%

sdc              1/1            372
sdc              1              449             +21%
sdc             31              507             +13%    +36%

sdd              1/1            489
sdd              1              650             +33%
sdd             31              941             +45%    +92%

Conclusions: the io scheduler helps, NCQ help - both combined helps a
lot. The Samsung firmware looks bad. Additional requests in io scheduler
when using NCQ doesn't help, except for the new firmware Maxtor.
Suspect. NCQ still helps a lot, > 30% for all drives except the Samsung.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

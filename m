Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7533F6B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 12:40:09 -0500 (EST)
Subject: Re: [PATCH 03/11] readahead: bump up the default readahead size
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20100211234249.GE407@shareable.org>
References: <20100207041013.891441102@intel.com>
	 <20100207041043.147345346@intel.com> <4B6FBB3F.4010701@linux.vnet.ibm.com>
	 <20100208134634.GA3024@localhost> <1265924254.15603.79.camel@calx>
	 <20100211234249.GE407@shareable.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 11 Feb 2010 18:04:31 -0600
Message-ID: <1265933071.15603.129.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jamie Lokier <jamie@shareable.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, David Woodhouse <dwmw2@infradead.org>, linux-embedded@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-02-11 at 23:42 +0000, Jamie Lokier wrote:
> Matt Mackall wrote:
> > On Mon, 2010-02-08 at 21:46 +0800, Wu Fengguang wrote:
> > > Chris,
> > > 
> > > Firstly inform the linux-embedded maintainers :)
> > > 
> > > I think it's a good suggestion to add a config option
> > > (CONFIG_READAHEAD_SIZE). Will update the patch..
> > 
> > I don't have a strong opinion here beyond the nagging feeling that we
> > should be using a per-bdev scaling window scheme rather than something
> > static.
> 
> I agree with both.  100Mb/s isn't typical on little devices, even if a
> fast ATA disk is attached.  I've got something here where the ATA
> interface itself (on a SoC) gets about 10MB/s max when doing nothing
> else, or 4MB/s when talking to the network at the same time.
> It's not a modern design, but you know, it's junk we try to use :-)
> 
> It sounds like a calculation based on throughput and seek time or IOP
> rate, and maybe clamped if memory is small, would be good.
> 
> Is the window size something that could be meaningfully adjusted
> according to live measurements?

I think so. You've basically got a few different things you want to
balance: throughput, latency, and memory pressure. Successful readaheads
expand the window, as do empty request queues, while long request queues
and memory reclaim events collapse it. With any luck, we'll then
automatically do the right thing with fast/slow devices on big/small
boxes with varying load. And, like TCP, we don't need to 'know' anything
about the hardware, except to watch what happens when we use it.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

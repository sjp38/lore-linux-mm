Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 7B43D6B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 18:29:39 -0500 (EST)
Date: Tue, 19 Feb 2013 15:29:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] add extra free kbytes tunable
Message-Id: <20130219152936.f079c971.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1302171546120.10836@dflat>
References: <alpine.DEB.2.02.1302111734090.13090@dflat>
	<A5ED84D3BB3A384992CBB9C77DEDA4D414A98EBF@USINDEM103.corp.hds.com>
	<511EB5CB.2060602@redhat.com>
	<alpine.DEB.2.02.1302171546120.10836@dflat>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dormando <dormando@rydia.net>
Cc: Rik van Riel <riel@redhat.com>, Seiji Aguchi <seiji.aguchi@hds.com>, Satoru Moriya <satoru.moriya@hds.com>, Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "hughd@google.com" <hughd@google.com>

On Sun, 17 Feb 2013 15:48:31 -0800 (PST)
dormando <dormando@rydia.net> wrote:

> Add a userspace visible knob to tell the VM to keep an extra amount
> of memory free, by increasing the gap between each zone's min and
> low watermarks.

The problem is that adding this tunable will constrain future VM
implementations.  We will forever need to at least retain the
pseudo-file.  We will also need to make some effort to retain its
behaviour.

It would of course be better to fix things so you don't need to tweak
VM internals to get acceptable behaviour.

You said:

: We have a server workload wherein machines with 100G+ of "free" memory
: (used by page cache), scattered but frequent random io reads from 12+
: SSD's, and 5gbps+ of internet traffic, will frequently hit direct reclaim
: in a few different ways.
: 
: 1) It'll run into small amounts of reclaim randomly (a few hundred
: thousand).
: 
: 2) A burst of reads or traffic can cause extra pressure, which kswapd
: occasionally responds to by freeing up 40g+ of the pagecache all at once
: (!) while pausing the system (Argh).
: 
: 3) A blip in an upstream provider or failover from a peer causes the
: kernel to allocate massive amounts of memory for retransmission
: queues/etc, potentially along with buffered IO reads and (some, but not
: often a ton) of new allocations from an application. This paired with 2)
: can cause the box to stall for 15+ seconds.

Can we prioritise these?  2) looks just awful - kswapd shouldn't just
go off and free 40G of pagecache.  Do you know what's actually in that
pagecache?  Large number of small files or small number of (very) large
files?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

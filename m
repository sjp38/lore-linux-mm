Date: Wed, 12 Sep 2007 18:44:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 16 of 24] avoid some lock operation in vm fast path
Message-Id: <20070912184415.a781f4fc.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0709121832130.4981@schroedinger.engr.sgi.com>
References: <patchbomb.1187786927@v2.random>
	<b343d1056f356d60de86.1187786943@v2.random>
	<20070912055952.bd5c99d6.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0709121746240.4489@schroedinger.engr.sgi.com>
	<20070912181636.8e807295.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0709121832130.4981@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007 18:33:48 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> > We should be able to directly decrease lock contention in there by chewing
> > on larger hunks: make scan_control.swap_cluster_max larger.  Did anyone try
> > that?
> > 
> > I guess we should stop calling that thing swap_cluster_max, really. 
> > swap_cluster_max is amount-of-stuff-to-write-to-swap for IO clustering. 
> > That's unrelated to amount-of-stuff-to-batch-in-page-reclaim for lock
> > contention reduction.  My fault.
> 
> So we need it configurable? Something like this?
> 
> 
> 
> 
> Add /proc/sys/vm/reclaim_batch to configure the reclaim_batch size
> 
> Add a new proc variable to configure the reclaim batch size.

That's a suitable start for someone to do a bit of performance testing.  If
it turns out to be worthwhile then perhaps we might decide to make it a
per-zone ratio based on present_pages or something, and to make the initial
defaults something more appropriate than SWAP_CLUSTER_MAX.

Also there might be tradeoffs between the size of this thing and the number
of cpus (per node?).

Dunno.  It all depends whether there's significant benefit to be had here. 
If there is, some additional testing and tuning would be needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

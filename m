Date: Wed, 9 Mar 2005 06:14:35 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: Is there a way to do an architecture specific shake of memory?
Message-ID: <20050309121435.GA29630@lnx-holt.americas.sgi.com>
References: <20050308211535.GB16061@lnx-holt.americas.sgi.com> <Pine.LNX.4.58.0503081833430.10095@server.graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0503081833430.10095@server.graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 08, 2005 at 06:35:07PM -0800, Christoph Lameter wrote:
> On Tue, 8 Mar 2005, Robin Holt wrote:
> 
> > Any suggestions are welcome.
> 
> Check when you free items how long the list of free items is and if its
> too long free some of them.

That is done as well as a check from cpu_idle.  The amount of free is
being changed from a boot-time very large number computed from total
memory to a per-node percentage of free memory.  A concern was raised
for the eventuality of a process constantly running on a cpu so the idle
calls never happen, a memory hog application begins to consume memory on
the node, and nothing ever shakes the memory free from the quicklists.
This led to the suggestion of a timer based shaker.  I would rather put
it into the blocked allocation path than have it timer based and hope
we pick the correct resolution of timer.  The problem is the quicklists
are per-cpu so we need to try flushing the quicklists for the cpus on
the affected node.

Thanks,
Robin Holt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Avoid allocating interleave from almost full nodes
Date: Fri, 27 Oct 2006 21:12:11 -0700
References: <Pine.LNX.4.64.0610271943540.10933@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610271943540.10933@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200610272112.12118.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 27 October 2006 19:46, Christoph Lameter wrote:
> Interleave allocation often go over large sets of nodes. Some of the nodes
> may have tasks on them that heavily use memory. Overallocating those nodes
> may reduce performance of those tasks. It is better if we try to avoid
> nodes that have most of its memory used.
>
> This patch checks for the amount of free pages on a node. If it is lower
> than a predefined limit (in /proc/sys/kernel/min_interleave_ratio) then
> we avoid allocating from that node. We keep a bitmap of full nodes
> that is cleared every 2 seconds when the drain the pagesets for
> node 0.
>
> Should we find that all nodes are marked as full then we disregard
> the limit and allocate from the next node without any checks.

And when only one node is not full the interleaved allocations will
all go to that node? I'm not sure that's a good idea.

I suspect it will need some threshold like ">50% of all nodes full"
then disregard.

In general I think it's a bad hack: Who says the allocations
of the process who filled a node is more important than the interleaving
process? I think it would be better to keep them being equal citizens
and allocate interleaving everywhere.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ECFA06B0245
	for <linux-mm@kvack.org>; Mon, 10 May 2010 00:35:53 -0400 (EDT)
Subject: numa aware lmb and sparc stuff
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 May 2010 14:35:26 +1000
Message-ID: <1273466126.23699.23.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Dave !

So I'm looking at properly sorting out the interactions between LMB and
NUMA, among other in order to use that stuff on powerpc (and others) as
well but also to try to sort out some of that NO_BOOTMEM stuff from
Yinghai.

Currently, my understanding of how things work on sparc is that you
construct an array of "struct node_mem_mask" at boot, one for each
node, which are used to define the base and size of nodes as powers of
two.

You then pass to lmb_alloc_nid() a pointer to a nid_range() function
which walks that array to provide node information back to lmb (which in
my current patch series, I replaced with an arch callback
lmb_nid_range()).

Now, I'm trying to figure out whether I can replace that later part with
generic code in lmb.c which would use the early_node_map[] instead.

>From what I can see, your only callsite of lmb_alloc_nid() is in
allocate_node_data() which is called in your three bootmem init
variants.

In all three cases, you proceed to call add_node_ranges() which calls
add_active_range() for the intersection of all lmb and nodes before you
call allocate_node_data(). This early_node_map[] should be properly
initialized by the time you get there.

So unless i'm missing something, I should be able to completely remove
lmb's reliance on that nid_range() callback and instead have lmb itself
use the various early_node_map[] accessors such as
for_each_active_range_index_in_nid() or similar.

What do you think ? Am I missing an important part of the picture on
sparc64 ?

If not, then I should be able to easily make that whole LMB numa thing
completely arch neutral.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

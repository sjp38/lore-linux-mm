Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C77726B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 20:32:20 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o231WIN9030478
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Mar 2010 10:32:18 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1966D45DE50
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 10:32:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E262B45DE4E
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 10:32:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C87161DB8037
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 10:32:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 700B81DB803B
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 10:32:17 +0900 (JST)
Date: Wed, 3 Mar 2010 10:28:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] slab: add memory hotplug support
Message-Id: <20100303102844.fe740203.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003021419020.30059@router.home>
References: <20100215105253.GE21783@one.firstfloor.org>
	<20100215110135.GN5723@laptop>
	<alpine.DEB.2.00.1002191222320.26567@router.home>
	<20100220090154.GB11287@basil.fritz.box>
	<alpine.DEB.2.00.1002240949140.26771@router.home>
	<4B862623.5090608@cs.helsinki.fi>
	<alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002251228140.18861@router.home>
	<20100226114136.GA16335@basil.fritz.box>
	<alpine.DEB.2.00.1002260904311.6641@router.home>
	<20100226155755.GE16335@basil.fritz.box>
	<alpine.DEB.2.00.1002261123520.7719@router.home>
	<alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>
	<4B8CA7F5.1030802@cs.helsinki.fi>
	<alpine.DEB.2.00.1003021419020.30059@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 2 Mar 2010 14:20:06 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> 
> Not sure how this would sync with slab use during node bootstrap and
> shutdown. Kame-san?
> 
> Otherwise
> 
> Acked-by: Christoph Lameter <cl@linux-foundation.org>
> 

What this patch fixes ? Maybe I miss something...

At node hot-add

 * pgdat is allocated from other node (because we have no memory for "nid")
 * memmap for the first section (and possiby others) will be allocated from
   other nodes.
 * Once a section for the node is onlined, any memory can be allocated localy.

   (Allocating memory from local node requires some new implementation as
    bootmem allocater, we didn't that.)

 Before this patch, slab's control layer is allocated by cpuhotplug.
 So, at least keeping this order,
    memory online -> cpu online
 slab's control layer is allocated from local node.

 When node-hotadd is done in this order
    cpu online -> memory online
 kmalloc_node() will allocate memory from other node via fallback.

 After this patch, slab's control layer is allocated by memory hotplug.
 Then, in any order, slab's control will be allocated via fallback routine.

If this patch is an alternative fix for Andi's this logic
==
Index: linux-2.6.32-memhotadd/mm/slab.c
===================================================================
--- linux-2.6.32-memhotadd.orig/mm/slab.c
+++ linux-2.6.32-memhotadd/mm/slab.c
@@ -4093,6 +4093,9 @@ static void cache_reap(struct work_struc
 		 * we can do some work if the lock was obtained.
 		 */
 		l3 = searchp->nodelists[node];
+		/* Note node yet set up */
+		if (!l3)
+			break;
==
I'm not sure this really happens.

cache_reap() is for checking local node. The caller is set up by
CPU_ONLINE. searchp->nodelists[] is filled by CPU_PREPARE.

Then, cpu for the node should be onlined. (and it's done under proper mutex.)

I'm sorry if I miss something important. But how anyone cause this ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

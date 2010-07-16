Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0552A6B02A3
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 05:02:45 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o6G92i1x031268
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 02:02:44 -0700
Received: from pzk10 (pzk10.prod.google.com [10.243.19.138])
	by wpaz21.hot.corp.google.com with ESMTP id o6G92f0u018157
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 02:02:43 -0700
Received: by pzk10 with SMTP id 10so538256pzk.32
        for <linux-mm@kvack.org>; Fri, 16 Jul 2010 02:02:41 -0700 (PDT)
Date: Fri, 16 Jul 2010 02:02:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q2 00/19] SLUB with queueing (V2) beats SLAB netperf TCP_RR
In-Reply-To: <4C4016FD.9080207@cs.helsinki.fi>
Message-ID: <alpine.DEB.2.00.1007160158540.18388@chino.kir.corp.google.com>
References: <20100709190706.938177313@quilx.com> <alpine.DEB.2.00.1007141650110.29110@chino.kir.corp.google.com> <4C4016FD.9080207@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jul 2010, Pekka Enberg wrote:

> > I'd also consider patch 7 for 2.6.35-rc6 (and -stable).
> 
> It's an obvious bug fix but is it triggered in practice? Is there a bugzilla
> report for that?
> 

Let's ask Benjamin who initially reported the problem with arch_initcall 
whether or not this is rc (and stable) material.

For reference, we're talking about the sysfs_slab_remove() check on 
slab_state to prevent the WARN in the kobject code you hit with its fix 
below:


From: Christoph Lameter <cl@linux-foundation.org>

slub: Allow removal of slab caches during boot

If a slab cache is removed before we have setup sysfs then simply skip over
the sysfs handling.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Roland Dreier <rdreier@cisco.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-06 15:13:48.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-07-06 15:15:27.000000000 -0500
@@ -4507,6 +4507,13 @@ static int sysfs_slab_add(struct kmem_ca
 
 static void sysfs_slab_remove(struct kmem_cache *s)
 {
+	if (slab_state < SYSFS)
+		/*
+		 * Sysfs has not been setup yet so no need to remove the
+		 * cache from sysfs.
+		 */
+		return;
+
 	kobject_uevent(&s->kobj, KOBJ_REMOVE);
 	kobject_del(&s->kobj);
 	kobject_put(&s->kobj);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

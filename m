Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id EEFB96B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 10:50:22 -0500 (EST)
Received: by mail-bk0-f49.google.com with SMTP id v15so1237422bkz.36
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 07:50:22 -0800 (PST)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id qd4si3328674bkb.293.2014.01.24.07.50.20
        for <linux-mm@kvack.org>;
        Fri, 24 Jan 2014 07:50:21 -0800 (PST)
Date: Fri, 24 Jan 2014 09:50:17 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
In-Reply-To: <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com>
Message-ID: <alpine.DEB.2.10.1401240946530.12886@nuc>
References: <20140107132100.5b5ad198@kryten> <20140107074136.GA4011@lge.com> <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401201612340.28048@nuc> <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
 <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, benh@kernel.crashing.org, paulus@samba.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Han Pingtian <hanpt@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>

On Fri, 24 Jan 2014, Wanpeng Li wrote:

> >
> >diff --git a/mm/slub.c b/mm/slub.c
> >index 545a170..a1c6040 100644
> >--- a/mm/slub.c
> >+++ b/mm/slub.c
> >@@ -1700,6 +1700,9 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
> > 	void *object;
> >	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;

This needs to be numa_mem_id() and numa_mem_id would need to be
consistently used.

> >
> >+	if (!node_present_pages(searchnode))
> >+		searchnode = numa_mem_id();

Probably wont need that?

> >+
> >	object = get_partial_node(s, get_node(s, searchnode), c, flags);
> >	if (object || node != NUMA_NO_NODE)
> >		return object;
> >
>
> The bug still can't be fixed w/ this patch.

Some more detail would be good. If memory is requested from a particular
node then it would be best to use one that has memory. Callers also may
have used numa_node_id() and that also would need to be fixed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A849E6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 09:14:02 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id z3so6133172pln.6
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 06:14:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e3si2053916plk.542.2018.01.16.06.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Jan 2018 06:13:58 -0800 (PST)
Date: Tue, 16 Jan 2018 06:13:54 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: [LSF/MM TOPIC] Matthew's minor MM topics
Message-ID: <20180116141354.GB30073@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

(trying again with the right MM mailing list address.  Sorry.)

I have a number of things I'd like to discuss that are purely MM related.
I don't know if any of them rise to the level of an entire session,
but maybe lightning talks, or maybe we can dispose of them on the list
before the summit.

1. GFP_DMA / GFP_HIGHMEM / GFP_DMA32

The documentation is clear that only one of these three bits is allowed
to be set.  Indeed, we have code that checks that only one of these
three bits is set.  So why do we have three bits?  Surely this encoding
works better:

00b (normal)
01b GFP_DMA
10b GFP_DMA32
11b GFP_HIGHMEM
(or some other clever encoding that maps well to the zone_type index)

2. kvzalloc_ab_c()

We could bikeshed on this name all summit long, but the idea is to provide
an equivalent of kvmalloc_array() which works for array-plus-header.
These allocations are legion throughout the kernel.  Here's the first
one I found with a grep:

drivers/vhost/vhost.c:  newmem = kvzalloc(size + mem.nregions * sizeof(*m->regions), GFP_KERNEL);

... and, yep, that one's a security hole.

The implementation is not hard, viz:

+static inline void *kvzalloc_ab_c(size_t n, size_t size, size_t c, gfp_t flags)
+{
+       if (size != 0 && n > (SIZE_MAX - c) / size)
+               return NULL;
+
+       return kvmalloc(n * size + c, flags);
+}

but the name will tie us in knots and getting people to actually use
it will be worse.  (I actually stole the name from another project,
but I can't find it now).

We also need to go through and convert dozens of callers that are
doing kvzalloc(a * b) into kvzalloc_array(a, b).  Maybe we can ask for
some coccinelle / smatch / checkpatch help here.

3. Maybe we could rename kvfree() to just free()?  Please?  There's
nothing special about it.  One fewer thing for somebody to learn when
coming fresh to kernel programming.

4. vmf_insert_(page|pfn|mixed|...)

vm_insert_foo are invariably called from fault handlers, usually as
the last thing we do before returning a VM_FAULT code.  As such, why do
they return an errno that has to be translated?  We would be better off
returning VM_FAULT codes from these functions.

Related, I'd like to introduce a new vm_fault_t typedef for unsigned
int that indicates that the function returns VM_FAULT flags rather than
an errno.  We've had so many mistakes in this area.


----- End forwarded message -----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

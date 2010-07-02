Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 11F396B01AC
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 19:18:32 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <bac5bd58-6d57-4c40-a6d7-7414128185b7@default>
Date: Fri, 2 Jul 2010 16:17:05 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [SCSI/FS/MM] LSF10/MM topic proposal: PAM: Page-accessible memory
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: lsf10-pc@lists.linuxfoundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently the kernel uses and manages two data storage
abstractions, RAM and device (i.e. disk).  RAM, as the name
implies, is randomly accessible at a byte level, very fast,
and as intended by Von Neumann, is interchangeably used by the
kernel for kernel code or kernel data or user code or user data.
Device storage is generally relatively slow, batched and
asynchronous, modeled to the kernel like rotating media.

In recent years, a number of new storage technologies --
both hardware- and software-based -- have appeared in the
middle between "true RAM" and "disk" including:

- hypervisor RAM
- compressed RAM
- SSDs
- phase change RAM
- far-far NUMA RAM
- (others?)

Each has unique performance and/or byte-accessibility and/or
reliability idiosyncrasies that hinder it from being treated
as "true RAM".  But each is also too fast and too expensive
to be treated as a "disk".  As a result, there have been
many attempts to shoehorn these odd memory types, along with
their idiosyncrasies, into various parts of the kernel
to serve various specific needs.  The result has not been
particularly aesthetic or maintainable.  Nor has this fractured
approach come close to achieving the new technologies'
full capabilities, thus pigeonholing their use and stunting
their potential growth.

To address (pun intended) these new "memory types", I propose
the addition of a new kernel memory abstraction which we will
call PAM, for page-accessible memory.  (Don't laugh at the
seeming audacity, overwhelming complexity, and low cost-benefit
of such an addition yet... please read on.)

As its name implies, PAM is accessed only by the page, not by
the byte (where pagesize must be specified but need not be 4K).
Like a device, data in PAM must be copied/DMA'ed into RAM for
the data to be directly used and/or byte-addressed by the kernel
or by userland.  Because many of the new memory types are dynamic
in nature, the kernel does not know a priori the size of PAM,
so the kernel addresses each page with a non-linear
object-oriented "handle" and accesses the data through a generic
synchronous API of get_page, put_page, and flush_page.  The
idiosyncrasies of each new memory type are then entirely hidden
in "PAM drivers" behind the API.

There are at least two types of PAM: ephemeral PAM (EPAM) and
persistent PAM (PPAM).  A put to EPAM is always successful, but
a get of the same page may fail; so EPAM is not guaranteed
to hold all of the pages put to it.  A put to PPAM may fail but,
once a put is successful, a get of the same page will always
be successful.  A PAM driver supporting EPAM and/or PPAM must
ensure certain additional coherency and concurrency semantics
that are beyond the scope of this brief discussion.  There
also may be other useful types of PAM.

There is existence proof that this kind of API has value.  The
proposed cleancache and frontswap patchsets demonstrate how
EPAM can be used as an "overflow" for page cache and how PPAM
can be used as a "fronting store" for swap devices; a shim
to Xen's Transcendent Memory ("tmem") demonstrates one PAM driver,
and Nitin Gupta's zcache work plans to demonstrate another.  Both
presume a synchronous API and that the pages of data put into
PAM are infrequently accessed by the kernel (and not at all
by userland); these semantics are critical to the cleancache and
frontswap patchsets but other semantics might possibly be
specified by flag parameters provided to a more generic PAM API.

While I firmly believe that cleancache/frontswap/tmem/zcache
can stand on their own merit and should be accepted into the
kernel,  I wonder if the generic PAM concept might serve nicely
as an API to other new RAM-like fast storage, such as SSDs and
phase change RAM.  I would like to discuss PAM concepts with
experts in these areas.  And I wonder if there might be other
kernel data storage needs obvious to kernel MM/FS experts
that might utilize such an API.  If so, maybe it is finally time
to free the kernel from the chains of Von Neumann and open
the kernel doors to other new types of RAM?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

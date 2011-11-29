Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 95D0C6B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 10:06:03 -0500 (EST)
Message-ID: <1322579127.2921.240.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 4/30] uprobes: Define hooks for mmap/munmap.
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 29 Nov 2011 16:05:27 +0100
In-Reply-To: <1322567326.2921.226.camel@twins>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
	 <1322071812.14799.87.camel@twins>
	 <20111124134742.GH28065@linux.vnet.ibm.com>
	 <1322492384.2921.143.camel@twins>
	 <20111129083322.GD13445@linux.vnet.ibm.com>
	 <1322567326.2921.226.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, tulasidhard@gmail.com

On Tue, 2011-11-29 at 12:48 +0100, Peter Zijlstra wrote:
> There's 2 main cases,=20
>         A) vma_adjust() vs unregister_uprobe() and=20
>         B) mmap() vs unregister_uprobe().
>=20
> The result of A should be -1 reference in total, since we're removing
> the one probe.

This might not be correct for A[23], please double check.

>  The result of B should be 0 since we're removing the
> probe and we shouldn't be installing new ones.
>=20
> A1)
>         vma_adjust()
>           munmap_uprobe()
>                                 unregister_uprobe()
>           mmap_uprobe()
>                                   delete_uprobe()
>=20
>=20
>         munmap will to -1, mmap will do +1, __unregister_uprobe() which i=
s
> serialized against vma_adjust() will do -1 on either the old or new vma,
> resulting in a grand total of: -1+1-1=3D-1, OK
>=20
> A2) breakpoint is in old, not in new, again two cases:
>=20
> A2a) __unregister_uprobe() sees old
>=20
>         munmap -1, __unregister_uprobe -1, mmap 0: -2 FAIL
>=20
> A2b) __unregister_uprobe() sees new
>=20
>         munmap -1, __unregister_uprobe 0, mmap 0: -1 OK
>=20
> A3) breakpoint is in new, not in old, again two cases:
>=20
> A3a) __unregister_uprobe() sees old
>=20
>         munmap 0, __unregister_uprobe 0, mmap: 1: 1 FAIL
>=20
> A3b) __unregister_uprobe() seed new
>=20
>         munmap 0, __unregister_uprobe -1, mmap: 1: 0 FAIL

There's more cases, I forgot the details of how the prio_tree stuff
works, so please consider if its possible to also have:

  __unregister_uprobe() will observe neither old nor new

This could happen if we first munmap, __unregister_uprobe() will iterate
past where mmap() will insert the new vma, mmap will insert the new vma,
and __unregister_uprobe() will now not observe it.

and

  __unregister_uprobe() will observe both old _and_ new

This latter could happen by favourably interleaving the prio_tree
iteration with the munmap and mmap operations, so that we first observe
the old vma, do the munmap, do the mmap, and then have the
find_next_vma_info() thing find the new vma.

> B1)
>                                 unregister_uprobe()
>         mmap()
>           mmap_uprobe()
>                                   __unregister_uprobe()
>                                   delete_uprobe()
>=20
>         mmap +1, __unregister_uprobe() -1: 0 OK
>=20
> B2)
>                                 unregister_uprobe()
>         mmap()
>                                   __unregister_uprobe()
>           mmap_uprobe()
>                                   delete_uprobe()
>=20
>         mmap +1, __unregister_uprobe() 0: +1 FAIL=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 305AA6B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 09:24:01 -0500 (EST)
Message-ID: <1322490213.2921.133.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 5/30] uprobes: copy of the original
 instruction.
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 28 Nov 2011 15:23:33 +0100
In-Reply-To: <20111118110733.10512.11835.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110733.10512.11835.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Fri, 2011-11-18 at 16:37 +0530, Srikar Dronamraju wrote:
> +static int __copy_insn(struct address_space *mapping,
> +                       struct vm_area_struct *vma, char *insn,
> +                       unsigned long nbytes, unsigned long offset)
> +{
> +       struct file *filp =3D vma->vm_file;
> +       struct page *page;
> +       void *vaddr;
> +       unsigned long off1;
> +       unsigned long idx;
> +
> +       if (!filp)
> +               return -EINVAL;
> +
> +       idx =3D (unsigned long)(offset >> PAGE_CACHE_SHIFT);
> +       off1 =3D offset &=3D ~PAGE_MASK;
> +
> +       /*
> +        * Ensure that the page that has the original instruction is
> +        * populated and in page-cache.
> +        */
> +       page =3D read_mapping_page(mapping, idx, filp);
> +       if (IS_ERR(page))
> +               return -ENOMEM;
> +
> +       vaddr =3D kmap_atomic(page);
> +       memcpy(insn, vaddr + off1, nbytes);
> +       kunmap_atomic(vaddr);
> +       page_cache_release(page);
> +       return 0;
> +}
> +
> +static int copy_insn(struct uprobe *uprobe, struct vm_area_struct *vma,
> +                                       unsigned long addr)
> +{
> +       struct address_space *mapping;
> +       int bytes;
> +       unsigned long nbytes;
> +
> +       addr &=3D ~PAGE_MASK;
> +       nbytes =3D PAGE_SIZE - addr;
> +       mapping =3D uprobe->inode->i_mapping;
> +
> +       /* Instruction at end of binary; copy only available bytes */
> +       if (uprobe->offset + MAX_UINSN_BYTES > uprobe->inode->i_size)
> +               bytes =3D uprobe->inode->i_size - uprobe->offset;
> +       else
> +               bytes =3D MAX_UINSN_BYTES;
> +
> +       /* Instruction at the page-boundary; copy bytes in second page */
> +       if (nbytes < bytes) {
> +               if (__copy_insn(mapping, vma, uprobe->insn + nbytes,
> +                               bytes - nbytes, uprobe->offset + nbytes))
> +                       return -ENOMEM;

You just lost your possible -EINVAL return value.

> +
> +               bytes =3D nbytes;
> +       }
> +       return __copy_insn(mapping, vma, uprobe->insn, bytes, uprobe->off=
set);
> +}=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

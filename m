Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7E48D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:39:55 -0400 (EDT)
Subject: Re: [PATCH v3 2.6.39-rc1-tip 15/26] 15: uprobes: Handing int3 and
 singlestep exception.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110401143527.15455.32854.sendpatchset@localhost6.localdomain6>
References: 
	 <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	 <20110401143527.15455.32854.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 19 Apr 2011 15:39:19 +0200
Message-ID: <1303220359.8345.1.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-04-01 at 20:05 +0530, Srikar Dronamraju wrote:
> +               probept =3D uprobes_get_bkpt_addr(regs);
> +               down_read(&mm->mmap_sem);
> +               for (vma =3D mm->mmap; vma; vma =3D vma->vm_next) {
> +                       if (!valid_vma(vma))
> +                               continue;
> +                       if (probept < vma->vm_start || probept > vma->vm_=
end)
> +                               continue;
> +                       u =3D find_uprobe(vma->vm_file->f_mapping->host,
> +                                       probept - vma->vm_start);
> +                       break;
> +               }

Why the linear vma walk? Surely the find_vma() suffices since there can
only be one vma that matches a particular vaddr.

> +               up_read(&mm->mmap_sem);=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

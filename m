Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8555B9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 08:56:16 -0400 (EDT)
Subject: Re: [PATCH v5 3.1.0-rc4-tip 18/26]   uprobes: slot allocation.
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 27 Sep 2011 14:55:23 +0200
In-Reply-To: <20110920120335.25326.50673.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20110920120335.25326.50673.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317128124.15383.56.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-09-20 at 17:33 +0530, Srikar Dronamraju wrote:
> +static unsigned long xol_take_insn_slot(struct uprobes_xol_area *area)
> +{
> +       unsigned long slot_addr, flags;
> +       int slot_nr;
> +
> +       do {
> +               spin_lock_irqsave(&area->slot_lock, flags);
> +               slot_nr =3D find_first_zero_bit(area->bitmap, UINSNS_PER_=
PAGE);
> +               if (slot_nr < UINSNS_PER_PAGE) {
> +                       __set_bit(slot_nr, area->bitmap);
> +                       slot_addr =3D area->vaddr +
> +                                       (slot_nr * UPROBES_XOL_SLOT_BYTES=
);
> +                       atomic_inc(&area->slot_count);
> +               }
> +               spin_unlock_irqrestore(&area->slot_lock, flags);
> +               if (slot_nr >=3D UINSNS_PER_PAGE)
> +                       xol_wait_event(area);
> +
> +       } while (slot_nr >=3D UINSNS_PER_PAGE);
> +
> +       return slot_addr;
> +}

> +static void xol_free_insn_slot(struct task_struct *tsk)
> +{
> +       struct uprobes_xol_area *area;
> +       unsigned long vma_end;
> +       unsigned long slot_addr;
> +
> +       if (!tsk->mm || !tsk->mm->uprobes_xol_area || !tsk->utask)
> +               return;
> +
> +       slot_addr =3D tsk->utask->xol_vaddr;
> +
> +       if (unlikely(!slot_addr || IS_ERR_VALUE(slot_addr)))
> +               return;
> +
> +       area =3D tsk->mm->uprobes_xol_area;
> +       vma_end =3D area->vaddr + PAGE_SIZE;
> +       if (area->vaddr <=3D slot_addr && slot_addr < vma_end) {
> +               int slot_nr;
> +               unsigned long offset =3D slot_addr - area->vaddr;
> +               unsigned long flags;
> +
> +               slot_nr =3D offset / UPROBES_XOL_SLOT_BYTES;
> +               if (slot_nr >=3D UINSNS_PER_PAGE)
> +                       return;
> +
> +               spin_lock_irqsave(&area->slot_lock, flags);
> +               __clear_bit(slot_nr, area->bitmap);
> +               spin_unlock_irqrestore(&area->slot_lock, flags);
> +               atomic_dec(&area->slot_count);
> +               if (waitqueue_active(&area->wq))
> +                       wake_up(&area->wq);
> +               tsk->utask->xol_vaddr =3D 0;
> +       }
> +}=20

So if you want to keep that slot_lock, you might as well make
->slot_count a normal integer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

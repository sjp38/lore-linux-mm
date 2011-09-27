Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C98459000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 08:38:42 -0400 (EDT)
Subject: Re: [PATCH v5 3.1.0-rc4-tip 18/26]   uprobes: slot allocation.
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 27 Sep 2011 14:37:59 +0200
In-Reply-To: <20110920120335.25326.50673.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20110920120335.25326.50673.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317127079.15383.52.camel@twins>
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
> +}=20

Why isn't a find_first_bit() + set_and_test_bit() not sufficient? That
is, what do you need that lock for?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

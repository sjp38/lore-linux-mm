Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8FB9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 08:19:35 -0400 (EDT)
Subject: Re: [PATCH v5 3.1.0-rc4-tip 18/26]   uprobes: slot allocation.
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 27 Sep 2011 14:18:52 +0200
In-Reply-To: <20110920120335.25326.50673.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20110920120335.25326.50673.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317125932.15383.49.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-09-20 at 17:33 +0530, Srikar Dronamraju wrote:
> +static struct uprobes_xol_area *xol_alloc_area(void)
> +{
> +       struct uprobes_xol_area *area =3D NULL;
> +
> +       area =3D kzalloc(sizeof(*area), GFP_KERNEL);
> +       if (unlikely(!area))
> +               return NULL;
> +
> +       area->bitmap =3D kzalloc(BITS_TO_LONGS(UINSNS_PER_PAGE) * sizeof(=
long),
> +                                                               GFP_KERNE=
L);
> +
> +       if (!area->bitmap)
> +               goto fail;
> +
> +       init_waitqueue_head(&area->wq);
> +       spin_lock_init(&area->slot_lock);
> +       if (!xol_add_vma(area) && !current->mm->uprobes_xol_area) {

So what happens if xol_add_vma() succeeds, but we find
->uprobes_xol_area set?

> +               task_lock(current);
> +               if (!current->mm->uprobes_xol_area) {

Having to re-test it under this lock seems to suggest it could.

> +                       current->mm->uprobes_xol_area =3D area;
> +                       task_unlock(current);
> +                       return area;

This function would be so much easier to read if the success case (this
here I presume) would not be nested 2 deep.

> +               }
> +               task_unlock(current);
> +       }

at which point you could end up with two extra vmas? Because there's no
freeing of the result of xol_add_vma().

> +fail:
> +       kfree(area->bitmap);
> +       kfree(area);
> +       return current->mm->uprobes_xol_area;
> +}=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

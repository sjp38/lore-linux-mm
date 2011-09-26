Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB7F9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 08:30:16 -0400 (EDT)
Subject: Re: [PATCH v5 3.1.0-rc4-tip 2/26]   Uprobes: Allow multiple
 consumers for an uprobe.
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 26 Sep 2011 14:29:26 +0200
In-Reply-To: <20110920120006.25326.81787.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20110920120006.25326.81787.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317040166.9084.90.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-09-20 at 17:30 +0530, Srikar Dronamraju wrote:
> +       con =3D uprobe->consumers;
> +       if (consumer =3D=3D con) {
> +               uprobe->consumers =3D con->next;
> +               ret =3D true;
> +       } else {
> +               for (; con; con =3D con->next) {
> +                       if (con->next =3D=3D consumer) {
> +                               con->next =3D consumer->next;
> +                               ret =3D true;
> +                               break;
> +                       }
> +               }
> +       }=20

	struct uprobe_consumer **next =3D &uprobe->consumers;

	for (; *next; next =3D &(*next)->next) {
		if (*next =3D=3D consumer) {
			*next =3D (*next)->next;
			ret =3D true;
			break;
		}
	}

Wouldn't something like that work?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

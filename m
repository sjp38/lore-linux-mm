Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id CF90C6B004D
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 06:08:43 -0400 (EDT)
Message-ID: <1334657287.28150.77.camel@twins>
Subject: Re: [PATCH 2/6] uprobes: introduce is_swbp_at_addr_fast()
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 17 Apr 2012 12:08:07 +0200
In-Reply-To: <20120416153408.GA8852@redhat.com>
References: <20120405222024.GA19154@redhat.com>
	 <20120405222106.GB19166@redhat.com> <1334570935.28150.25.camel@twins>
	 <20120416144457.GA7018@redhat.com> <1334588109.28150.59.camel@twins>
	 <20120416153408.GA8852@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Mon, 2012-04-16 at 17:34 +0200, Oleg Nesterov wrote:
> On 04/16, Peter Zijlstra wrote:
> >
> > Can't we 'optimize' read_opcode() by doing the pagefault_disable() +
> > __copy_from_user_inatomic() optimistically before going down the whole
> > gup()+lock+kmap path?
>=20
> Unlikely, the task is not current.

Easy enough to test that though.. and that should make the regular path
fast enough, no?


---
 kernel/events/uprobes.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 985be4d..7f5d8c5 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -312,6 +312,15 @@ static int read_opcode(struct mm_struct *mm, unsigned =
long vaddr, uprobe_opcode_
 	void *vaddr_new;
 	int ret;
=20
+	if (mm =3D=3D current->mm) {
+		pagefault_disable();
+		ret =3D __copy_from_user_inatomic(opcode, (void __user *)vaddr,=20
+						sizeof(*opcode));
+		pagefault_enable();
+		if (!ret)
+			return 0;
+	}
+
 	ret =3D get_user_pages(NULL, mm, vaddr, 1, 0, 0, &page, NULL);
 	if (ret <=3D 0)
 		return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

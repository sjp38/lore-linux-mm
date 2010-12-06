Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9D33D6B0088
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 02:46:20 -0500 (EST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [thisops uV3 14/18] lguest: Use this_cpu_ops
Date: Mon, 6 Dec 2010 18:16:07 +1030
References: <20101130190707.457099608@linux.com> <20101130190849.422541374@linux.com>
In-Reply-To: <20101130190849.422541374@linux.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201012061816.07860.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Dec 2010 05:37:21 am Christoph Lameter wrote:
> Use this_cpu_ops in a couple of places in lguest.
>=20
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Signed-off-by: Christoph Lameter <cl@linux.com>

This doesn't even compile :(

I've applied it, and applied the following fixes, too:

lguest: compile fixes

arch/x86/lguest/boot.c: In function =E2=80=98lguest_init_IRQ=E2=80=99:
arch/x86/lguest/boot.c:824: error: macro "__this_cpu_write" requires 2 argu=
ments, but only 1 given
arch/x86/lguest/boot.c:824: error: =E2=80=98__this_cpu_write=E2=80=99 undec=
lared (first use in this function)
arch/x86/lguest/boot.c:824: error: (Each undeclared identifier is reported =
only once
arch/x86/lguest/boot.c:824: error: for each function it appears in.)

drivers/lguest/x86/core.c: In function =E2=80=98copy_in_guest_info=E2=80=99:
drivers/lguest/x86/core.c:94: error: lvalue required as left operand of ass=
ignment

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/arch/x86/lguest/boot.c b/arch/x86/lguest/boot.c
=2D-- a/arch/x86/lguest/boot.c
+++ b/arch/x86/lguest/boot.c
@@ -821,7 +821,7 @@ static void __init lguest_init_IRQ(void)
=20
 	for (i =3D FIRST_EXTERNAL_VECTOR; i < NR_VECTORS; i++) {
 		/* Some systems map "vectors" to interrupts weirdly.  Not us! */
=2D		__this_cpu_write(vector_irq[i]) =3D i - FIRST_EXTERNAL_VECTOR;
+		__this_cpu_write(vector_irq[i], i - FIRST_EXTERNAL_VECTOR);
 		if (i !=3D SYSCALL_VECTOR)
 			set_intr_gate(i, interrupt[i - FIRST_EXTERNAL_VECTOR]);
 	}
diff --git a/drivers/lguest/x86/core.c b/drivers/lguest/x86/core.c
=2D-- a/drivers/lguest/x86/core.c
+++ b/drivers/lguest/x86/core.c
@@ -91,7 +91,7 @@ static void copy_in_guest_info(struct lg
 	 * Guest has changed.
 	 */
 	if (__this_cpu_read(lg_last_cpu) !=3D cpu || cpu->last_pages !=3D pages) {
=2D		__this_cpu_read(lg_last_cpu) =3D cpu;
+		__this_cpu_write(lg_last_cpu, cpu);
 		cpu->last_pages =3D pages;
 		cpu->changed =3D CHANGED_ALL;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

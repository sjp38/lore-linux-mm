Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 976E66B0010
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 17:38:33 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id s15-v6so941308wrn.16
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 14:38:33 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id o6-v6si7198301wrw.329.2018.07.23.14.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 14:38:32 -0700 (PDT)
Date: Mon, 23 Jul 2018 23:38:30 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes and Updates
Message-ID: <20180723213830.GA4632@amd>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
 <20180723140925.GA4285@amd>
 <CA+55aFynT9Sp7CbnB=GqLbns7GFZbv3pDSQm_h0jFvJpz3ES+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Kj7319i9nmIyA2yE"
Content-Disposition: inline
In-Reply-To: <CA+55aFynT9Sp7CbnB=GqLbns7GFZbv3pDSQm_h0jFvJpz3ES+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?iso-8859-1?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-07-23 12:00:08, Linus Torvalds wrote:
> On Mon, Jul 23, 2018 at 7:09 AM Pavel Machek <pavel@ucw.cz> wrote:
> >
> > Meanwhile... it looks like gcc is not slowed down significantly, but
> > other stuff sees 30% .. 40% slowdowns... which is rather
> > significant.
>=20
> That is more or less expected.
>=20
> Gcc spends about 90+% of its time in user space, and the system calls
> it *does* do tend to be "real work" (open/read/etc). And modern gcc's
> no longer have the pipe between cpp and cc1, so they don't have that
> issue either (which would have sjhown the PTI slowdown a lot more)
>=20
> Some other loads will do a lot more time traversing the user/kernel
> boundary, and in 32-bit mode you won't be able to take advantage of
> the address space ID's, so you really get the full effect.

Understood. Just -- bzip2 should include quite a lot of time in
userspace, too.=20

> > Would it be possible to have per-process control of kpti? I have
> > some processes where trading of speed for security would make sense.
>=20
> That was pretty extensively discussed, and no sane model for it was
> ever agreed upon.  Some people wanted it per-thread, others per-mm,
> and it wasn't clear how to set it either and how it should inherit
> across fork/exec, and what the namespace rules etc should be.
>=20
> You absolutely need to inherit it (so that you can say "I trust this
> session" or whatever), but at the same time you *don't* want to
> inherit if you have a server you trust that then spawns user processes
> (think "I want systemd to not have the overhead, but the user
> processes it spawns obviously do need protection").
>=20
> It was just a morass. Nothing came out of it.  I guess people can
> discuss it again, but it's not simple.

I agree it is not easy. OTOH -- 30% of user-visible performance is a
_lot_. That is worth spending man-years on...  Ok, problem is not as
severe on modern CPUs with address space ID's, but...

What I want is "if A can ptrace B, and B has pti disabled, A can have
pti disabled as well". Now.. I see someone may want to have it
per-thread, because for stuff like javascript JIT, thread may have
rights to call ptrace, but is unable to call ptrace because JIT
removed that ability... hmm...

But for now I'd like at least "global" option of turning pti on/off
during runtime for benchmarking. Let me see...

Something like this, or is it going to be way more complex? Does
anyone have patch by chance?

									Pavel

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index dfb975b..719e39a 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -162,6 +162,9 @@
 .macro SWITCH_TO_USER_CR3 scratch_reg:req
 	ALTERNATIVE "jmp .Lend_\@", "", X86_FEATURE_PTI
=20
+	cmpl	$1, PER_CPU_VAR(pti_enabled)
+	jne	.Lend_\@
+=09
 	movl	%cr3, \scratch_reg
 	orl	$PTI_SWITCH_MASK, \scratch_reg
 	movl	\scratch_reg, %cr3
@@ -176,6 +179,8 @@
 	testl	$SEGMENT_RPL_MASK, PT_CS(%esp)
 	jz	.Lend_\@
 	.endif
+	cmpl	$1, PER_CPU_VAR(pti_enabled)
+	jne	.Lend_\@
 	/* On user-cr3? */
 	movl	%cr3, %eax
 	testl	$PTI_SWITCH_MASK, %eax
@@ -192,6 +197,10 @@
  */
 .macro SWITCH_TO_KERNEL_CR3 scratch_reg:req
 	ALTERNATIVE "jmp .Lend_\@", "", X86_FEATURE_PTI
+
+	cmpl	$1, PER_CPU_VAR(pti_enabled)
+	jne	.Lend_\@
+
 	movl	%cr3, \scratch_reg
 	/* Test if we are already on kernel CR3 */
 	testl	$PTI_SWITCH_MASK, \scratch_reg
@@ -302,6 +311,9 @@
 	 */
 	ALTERNATIVE "jmp .Lswitched_\@", "", X86_FEATURE_PTI
=20
+	cmpl	$1, PER_CPU_VAR(pti_enabled)
+	jne	.Lswitched_\@
+
 	testl	$PTI_SWITCH_MASK, \cr3_reg
 	jz	.Lswitched_\@
=20
diff --git a/arch/x86/include/asm/cpu_entry_area.h b/arch/x86/include/asm/c=
pu_entry_area.h
index 4a7884b..8c92ae2 100644
--- a/arch/x86/include/asm/cpu_entry_area.h
+++ b/arch/x86/include/asm/cpu_entry_area.h
@@ -59,6 +59,7 @@ struct cpu_entry_area {
 #define CPU_ENTRY_AREA_TOT_SIZE	(CPU_ENTRY_AREA_SIZE * NR_CPUS)
=20
 DECLARE_PER_CPU(struct cpu_entry_area *, cpu_entry_area);
+DECLARE_PER_CPU(int, pti_enabled);
=20
 extern void setup_cpu_entry_areas(void);
 extern void cea_set_pte(void *cea_vaddr, phys_addr_t pa, pgprot_t flags);
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index f73fa6f..da34a21 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -507,6 +507,9 @@ void load_percpu_segment(int cpu)
 DEFINE_PER_CPU(struct cpu_entry_area *, cpu_entry_area);
 #endif
=20
+DEFINE_PER_CPU(int, pti_enabled);
+
+
 #ifdef CONFIG_X86_64
 /*
  * Special IST stacks which the CPU switches to when it calls

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--Kj7319i9nmIyA2yE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAltWStYACgkQMOfwapXb+vJQqACdFk1xGh2+ut+ydTcCmbQ59Aqd
sdQAn1X97V8a9pK+pZ+oPvZkrvwiKNxz
=Ln9o
-----END PGP SIGNATURE-----

--Kj7319i9nmIyA2yE--

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 494956B6C27
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 20:43:16 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id d23so11391506plj.22
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 17:43:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e40sor20442705plb.21.2018.12.03.17.43.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 17:43:14 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20181128000754.18056-2-rick.p.edgecombe@intel.com>
Date: Mon, 3 Dec 2018 17:43:11 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
 <20181128000754.18056-2-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, naveen.n.rao@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, David Miller <davem@davemloft.net>, Masami Hiramatsu <mhiramat@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, ast@kernel.org, Daniel Borkmann <daniel@iogearbox.net>, jeyu@kernel.org, netdev@vger.kernel.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jann Horn <jannh@google.com>, kristen@linux.intel.com, Dave Hansen <dave.hansen@intel.com>, deneen.t.dock@intel.com, Peter Zijlstra <peterz@infradead.org>

> On Nov 27, 2018, at 4:07 PM, Rick Edgecombe =
<rick.p.edgecombe@intel.com> wrote:
>=20
> Since vfree will lazily flush the TLB, but not lazily free the =
underlying pages,
> it often leaves stale TLB entries to freed pages that could get =
re-used. This is
> undesirable for cases where the memory being freed has special =
permissions such
> as executable.

So I am trying to finish my patch-set for preventing transient W+X =
mappings
from taking space, by handling kprobes & ftrace that I missed (thanks =
again for
pointing it out).

But all of the sudden, I don=E2=80=99t understand why we have the =
problem that this
(your) patch-set deals with at all. We already change the mappings to =
make
the memory writable before freeing the memory, so why can=E2=80=99t we =
make it
non-executable at the same time? Actually, why do we make the module =
memory,
including its data executable before freeing it???

In other words: disable_ro_nx() is called by free_module() before =
freeing
the memory. Wouldn=E2=80=99t inverting the logic makes much more sense? =
I am
confused.

-- >8 --

From: Nadav Amit <namit@vmware.com>
Subject: [PATCH] modules: disable_ro_nx() should enable nx=20

---
 kernel/module.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/kernel/module.c b/kernel/module.c
index 7cb207249437..e12d760ea3b0 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -2029,14 +2029,13 @@ void set_all_modules_text_ro(void)
=20
 static void disable_ro_nx(const struct module_layout *layout)
 {
+	frob_text(layout, set_memory_nx);
+
 	if (rodata_enabled) {
 		frob_text(layout, set_memory_rw);
 		frob_rodata(layout, set_memory_rw);
 		frob_ro_after_init(layout, set_memory_rw);
 	}
-	frob_rodata(layout, set_memory_x);
-	frob_ro_after_init(layout, set_memory_x);
-	frob_writable_data(layout, set_memory_x);
 }
=20
 #else
--=20
2.17.1

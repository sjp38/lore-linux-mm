Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 529566B006C
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 00:29:59 -0500 (EST)
From: Josh Triplett <josh@joshtriplett.org>
Subject: [PATCH 23/58] mm: Avoid defining set_iounmap_nonlazy on non-x86
Date: Sun, 18 Nov 2012 21:28:02 -0800
Message-Id: <1353302917-13995-24-git-send-email-josh@joshtriplett.org>
In-Reply-To: <1353302917-13995-1-git-send-email-josh@joshtriplett.org>
References: <1353302917-13995-1-git-send-email-josh@joshtriplett.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Kautuk Consul <consul.kautuk@gmail.com>, Cong Wang <amwang@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Josh Triplett <josh@joshtriplett.org>

Commit 3ee48b6af49cf534ca2f481ecc484b156a41451d added the
set_iounmap_nonlazy function for use on x86, but actually defined it on
all architectures.  Only x86 prototypes this function (in asm/io.h), and
only x86 uses it (in arch/x86/kernel/crash_dump_64.c), so avoid defining
it on non-x86.

Meanwhile, include the appropriate header with the prototype, to
eliminate a warning from gcc (-Wmissing-prototypes) and from Sparse
(-Wdecl).

mm/vmalloc.c:563:6: warning: no previous prototype for =E2=80=98set_iounm=
ap_nonlazy=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
 mm/vmalloc.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 78e0830..fc32a0a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -27,6 +27,7 @@
 #include <linux/pfn.h>
 #include <linux/kmemleak.h>
 #include <linux/atomic.h>
+#include <linux/io.h>
 #include <asm/uaccess.h>
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
@@ -556,6 +557,7 @@ static atomic_t vmap_lazy_nr =3D ATOMIC_INIT(0);
 /* for per-CPU blocks */
 static void purge_fragmented_blocks_allcpus(void);
=20
+#ifdef CONFIG_X86
 /*
  * called before a call to iounmap() if the caller wants vm_area_struct'=
s
  * immediately freed.
@@ -564,6 +566,7 @@ void set_iounmap_nonlazy(void)
 {
 	atomic_set(&vmap_lazy_nr, lazy_max_pages()+1);
 }
+#endif
=20
 /*
  * Purges all lazily-freed vmap areas.
--=20
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

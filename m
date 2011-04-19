Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1F264900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 20:19:42 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E72C73EE0C1
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:19:38 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C4D6345DE88
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:19:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A84D845DE93
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:19:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A8CDE38001
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:19:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 679FAE08001
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:19:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm: convert mm->cpu_vm_cpumask into cpumask_var_t
In-Reply-To: <20110418211950.9365.A69D9226@jp.fujitsu.com>
References: <20110418211455.9359.A69D9226@jp.fujitsu.com> <20110418211950.9365.A69D9226@jp.fujitsu.com>
Message-Id: <20110419091947.936D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 19 Apr 2011 09:19:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  Documentation/cachetlb.txt |    2 +-
>  include/linux/mm_types.h   |    9 ++++++---
>  include/linux/sched.h      |    1 +
>  init/main.c                |    2 ++
>  kernel/fork.c              |   37 ++++++++++++++++++++++++++++++++++---
>  mm/init-mm.c               |    1 -
>  6 files changed, 44 insertions(+), 8 deletions(-)
>=20
> This patch don't touch x86/kerrnel/tboot.c. because it can't be compiled.

My bad. I confounded CONFIG_HAVE_INTEL_TXT with CONFIG_INTEL_TXT. Proper
fixing (and incremental) patch is here.



=46rom 0b443d8dbdf7ce97f92e6622840585ca41abca83 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 19 Apr 2011 08:38:01 +0900
Subject: [PATCH 4/4] fix tboot

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 arch/x86/kernel/tboot.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kernel/tboot.c b/arch/x86/kernel/tboot.c
index 998e972..0f0d1a3 100644
--- a/arch/x86/kernel/tboot.c
+++ b/arch/x86/kernel/tboot.c
@@ -110,7 +110,6 @@ static struct mm_struct tboot_mm =3D {
 	.mmap_sem       =3D __RWSEM_INITIALIZER(init_mm.mmap_sem),
 	.page_table_lock =3D  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist         =3D LIST_HEAD_INIT(init_mm.mmlist),
-	.cpu_vm_mask    =3D CPU_MASK_ALL,
 };
=20
 static inline void switch_to_tboot_pt(void)
@@ -337,9 +336,18 @@ static struct notifier_block tboot_cpu_notifier __cpui=
nitdata =3D
=20
 static __init int tboot_late_init(void)
 {
+	int ret;
+
 	if (!tboot_enabled())
 		return 0;
=20
+	ret =3D mm_init_cpumask(&tboot_mm, 0);
+	if (ret) {
+		pr_warning("tboot: Allocation failure, disable tboot.\n");
+		tboot =3D NULL;
+		return ret;
+	}
+
 	tboot_create_trampoline();
=20
 	atomic_set(&ap_wfs_count, 0);
--=20
1.7.3.1




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

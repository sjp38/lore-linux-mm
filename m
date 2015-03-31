Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id EDFA46B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 21:48:04 -0400 (EDT)
Received: by pddn5 with SMTP id n5so3950256pdd.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 18:48:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id qa5si17042153pbc.238.2015.03.30.18.48.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 18:48:04 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t2V1m0Cm004262
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 10:48:00 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm: numa: disable change protection for vma(VM_HUGETLB)
Date: Tue, 31 Mar 2015 01:45:55 +0000
Message-ID: <20150331014554.GA8128@hori1.linux.bs1.fc.nec.co.jp>
References: <1427708426-31610-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150330102802.GQ4701@suse.de> <55192885.5010608@gmail.com>
 <20150330115901.GR4701@suse.de>
In-Reply-To: <20150330115901.GR4701@suse.de>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E43A9941B7A00E438D9A51526CBEF50F@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Naoya Horiguchi <nao.horiguchi@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Mar 30, 2015 at 12:59:01PM +0100, Mel Gorman wrote:
> On Mon, Mar 30, 2015 at 07:42:13PM +0900, Naoya Horiguchi wrote:
...
>=20
> I note now that the patch was too hasty. By rights, that check
> should be covered by vma_migratable() but it's only checked if
> CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION which means it's x86-only. If you
> are seeing this problem on any other arch then a more correct fix might b=
e
> to remove the CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION check in vma_migratab=
le.

Changing vma_migratable() affects other usecases of hugepage migration like
mbind(), so simply removing the ifdef doesn't work for such usecases.
I didn't test other archs, but I guess that this problem could happen on al=
l
archs enabling numa balancing, whether it supports CONFIG_ARCH_ENABLE_HUGEP=
AGE_MIGRATION.

So I'd like pick/push your first suggestion. It passed my testing.

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm: numa: disable change protection for vma(VM_HUGETLB)

Currently when a process accesses to hugetlb range protected with PROTNONE,
unexpected COWs are triggered, which finally put hugetlb subsystem into
broken/uncontrollable state, where for example h->resv_huge_pages is subtra=
cted
too much and wrapped around to a very large number, and free hugepage pool
is no longer maintainable.

This patch simply stops changing protection for vma(VM_HUGETLB) to fix the
problem. And this also allows us to avoid useless overhead of minor faults.

Suggested-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 kernel/sched/fair.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7ce18f3c097a..6ad0d570f38e 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2161,8 +2161,10 @@ void task_numa_work(struct callback_head *work)
 		vma =3D mm->mmap;
 	}
 	for (; vma; vma =3D vma->vm_next) {
-		if (!vma_migratable(vma) || !vma_policy_mof(vma))
+		if (!vma_migratable(vma) || !vma_policy_mof(vma) ||
+			is_vm_hugetlb_page(vma)) {
 			continue;
+		}
=20
 		/*
 		 * Shared library pages mapped by multiple processes are not
--=20
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 402FC6B0005
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 23:56:27 -0500 (EST)
From: Tony Lu <zlu@tilera.com>
Subject: [PATCH v2] mm/hugetlb: Set PTE as huge in hugetlb_change_protection
 and remove_migration_pte
Date: Wed, 23 Jan 2013 04:56:15 +0000
Message-ID: <BAB94DBB0E89D8409949BC28AC95914C47B12CCE@USMAExch1.tad.internal.tilera.com>
References: <BAB94DBB0E89D8409949BC28AC95914C47B123D2@USMAExch1.tad.internal.tilera.com>
	<20130121100410.GE7798@dhcp22.suse.cz>
	<BAB94DBB0E89D8409949BC28AC95914C47B12789@USMAExch1.tad.internal.tilera.com>
 <CAJd=RBD-C5dUJL-S8aRk-yQ2-7+GUdQRGJuyxsnymG8k9P8ppw@mail.gmail.com>
In-Reply-To: <CAJd=RBD-C5dUJL-S8aRk-yQ2-7+GUdQRGJuyxsnymG8k9P8ppw@mail.gmail.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Metcalf <cmetcalf@tilera.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, Tony Lu <zlu@tilera.com>

When setting a huge PTE, besides calling pte_mkhuge(), we also need
to call arch_make_huge_pte(), which we indeed do in make_huge_pte(),
but we forget to do in hugetlb_change_protection() and
remove_migration_pte().

Signed-off-by: Zhigang Lu <zlu@tilera.com>
Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Hillf Danton <dhillf@gmail.com>
Cc: stable@vger.kernel.org
---
Changelog v2:
Missed adding arch_make_huge_pte() in remove_migration_pte() with previous =
patch, so sending v2 after adding that.

 mm/hugetlb.c |    1 +
 mm/migrate.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4f3ea0b..546db81 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3033,6 +3033,7 @@ unsigned long hugetlb_change_protection(struct vm_are=
a_struct *vma,
                if (!huge_pte_none(huge_ptep_get(ptep))) {
                        pte =3D huge_ptep_get_and_clear(mm, address, ptep);
                        pte =3D pte_mkhuge(pte_modify(pte, newprot));
+                       pte =3D arch_make_huge_pte(pte, vma, NULL, 0);
                        set_huge_pte_at(mm, address, ptep, pte);
                        pages++;
                }
diff --git a/mm/migrate.c b/mm/migrate.c
index c387786..2fd8b4a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -160,8 +160,10 @@ static int remove_migration_pte(struct page *new, stru=
ct vm_area_struct *vma,
        if (is_write_migration_entry(entry))
                pte =3D pte_mkwrite(pte);
 #ifdef CONFIG_HUGETLB_PAGE
-       if (PageHuge(new))
+       if (PageHuge(new)) {
                pte =3D pte_mkhuge(pte);
+               pte =3D arch_make_huge_pte(pte, vma, new, 0);
+       }
 #endif
        flush_cache_page(vma, addr, pte_pfn(pte));
        set_pte_at(mm, addr, ptep, pte);
--=20
1.7.10.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

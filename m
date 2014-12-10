Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 206D56B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 02:22:36 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so2235097pac.25
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 23:22:35 -0800 (PST)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id z1si5240111pdk.226.2014.12.09.23.22.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 23:22:34 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 10 Dec 2014 15:22:21 +0800
Subject: [RFC] mm:fix zero_page huge_zero_page rss/pss statistic
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B31403@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
 <CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net>
 <20141205143134.37139da2208c654a0d3cd942@linux-foundation.org>
 <35FD53F367049845BC99AC72306C23D103E688B313F4@CNBJMBX05.corpusers.net>
 <20141208114601.GA28846@node.dhcp.inet.fi>
 <35FD53F367049845BC99AC72306C23D103E688B313FB@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313FB@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Kirill A. Shutemov'" <kirill@shutemov.name>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Konstantin Khlebnikov' <koct9i@gmail.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'n-horiguchi@ah.jp.nec.com'" <n-horiguchi@ah.jp.nec.com>, "'oleg@redhat.com'" <oleg@redhat.com>, "'gorcunov@openvz.org'" <gorcunov@openvz.org>, "'pfeiner@google.com'" <pfeiner@google.com>

smaps_pte_entry() doesn't ignore zero_huge_page,
but it ignore zero_page, because vm_normal_page() will
ignore it. We remove vm_normal_page() call, because walk_page_range()
have ignore VM_PFNMAP vma maps, it's safe to just use pfn_valid(),
so that we can also consider zero_page to be a valid page.

Another change is that we only add map_count >=3D 2 or mapcount =3D=3D 1
pages into pss, because zero_page and huge_zero_page's _mapcount is
zero, this means pss will consider evey zero page as a PAGE_SIZE for
every process, this is not correct for pss statistic. We ignore
zero page for pss, just add zero page into rss statistic.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 fs/proc/task_mmu.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 4e0388c..ce503d3 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -458,7 +458,9 @@ static void smaps_pte_entry(pte_t ptent, unsigned long =
addr,
 	int mapcount;
=20
 	if (pte_present(ptent)) {
-		page =3D vm_normal_page(vma, addr, ptent);
+		if (!pte_special(ptent) && pfn_valid(pte_pfn(ptent)))
+			page =3D pfn_to_page(pte_pfn(ptent));
+
 	} else if (is_swap_pte(ptent)) {
 		swp_entry_t swpent =3D pte_to_swp_entry(ptent);
=20
@@ -491,7 +493,7 @@ static void smaps_pte_entry(pte_t ptent, unsigned long =
addr,
 		else
 			mss->shared_clean +=3D ptent_size;
 		mss->pss +=3D (ptent_size << PSS_SHIFT) / mapcount;
-	} else {
+	} else if (mapcount =3D=3D 1){
 		if (pte_dirty(ptent) || PageDirty(page))
 			mss->private_dirty +=3D ptent_size;
 		else
--=20
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

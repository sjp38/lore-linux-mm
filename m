Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 258626B0003
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 20:33:30 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id w22-v6so11430372ioc.5
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 17:33:30 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id b12si3223008ita.118.2018.11.12.17.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 17:33:28 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC][PATCH v1 10/11] mm: clear PageHWPoison in memory hotremove
Date: Tue, 13 Nov 2018 01:32:15 +0000
Message-ID: <20181113013214.GA14528@hori1.linux.bs1.fc.nec.co.jp>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1541746035-13408-11-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1541746035-13408-11-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <DA34DA41D102784C949AFD4B4E0EBFD8@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>

On Fri, Nov 09, 2018 at 03:47:14PM +0900, Naoya Horiguchi wrote:
> One hopeful usecase of memory hotplug is to replace half-broken DIMMs
> with new ones, so it makes sense to clear hwpoison info at the time of
> memory hotremove.
>=20
> I hope that this patch covers the topic discussed in
> https://lkml.org/lkml/2018/1/17/1228
>=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/page_alloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git v4.19-mmotm-2018-10-30-16-08/mm/page_alloc.c v4.19-mmotm-2018-=
10-30-16-08_patched/mm/page_alloc.c
> index 970d6ff..27826b3 100644
> --- v4.19-mmotm-2018-10-30-16-08/mm/page_alloc.c
> +++ v4.19-mmotm-2018-10-30-16-08_patched/mm/page_alloc.c
> @@ -8139,8 +8139,9 @@ __offline_isolated_pages(unsigned long start_pfn, u=
nsigned long end_pfn)
>  		 * The HWPoisoned page may be not in buddy system, and
>  		 * page_count() is not 0.
>  		 */
> -		if (unlikely(!PageBuddy(page) && PageHWPoison(page))) {
> +		if (unlikely(!PageBuddy(page) && TestClearPageHWPoison(page))) {
>  			pfn++;
> +			num_poisoned_pages_dec();
>  			SetPageReserved(page);
>  			continue;
>  		}

Kbuild test robot shows that this patch causes build errors on
!CONFIG_MEMORY_FAILURE, which should be fixed by the following changes.

Thanks,
Naoya Horiguchi
---
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6c496dab246d..559092915fe6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2785,6 +2785,10 @@ static inline void num_poisoned_pages_dec(void)
 {
 	atomic_long_dec(&num_poisoned_pages);
 }
+#else
+static inline void num_poisoned_pages_dec(void)
+{
+}
 #endif
=20
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index ab0bde073050..1461384aa1a3 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -385,6 +385,7 @@ extern bool set_hwpoison_free_buddy_page(struct page *p=
age);
 extern bool clear_hwpoison_free_buddy_page(struct page *page);
 #else
 PAGEFLAG_FALSE(HWPoison)
+TESTCLEARFLAG_FALSE(HWPoison)
 static inline bool set_hwpoison_free_buddy_page(struct page *page)
 {
 	return false;=

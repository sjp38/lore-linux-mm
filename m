Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87E00C5AE59
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 16:39:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D05321670
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 16:39:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D05321670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A68B06B026C; Tue, 10 Sep 2019 12:39:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A19CA6B0271; Tue, 10 Sep 2019 12:39:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9300B6B0272; Tue, 10 Sep 2019 12:39:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id 71F086B026C
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:39:40 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0B70B180AD801
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 16:39:40 +0000 (UTC)
X-FDA: 75919572120.18.force87_545a2a4ecb836
X-HE-Tag: force87_545a2a4ecb836
X-Filterd-Recvd-Size: 10634
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 16:39:39 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A6DA837E79;
	Tue, 10 Sep 2019 16:39:38 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-108.ams2.redhat.com [10.36.116.108])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6855060BF3;
	Tue, 10 Sep 2019 16:39:33 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	linuxppc-dev@lists.ozlabs.org,
	David Hildenbrand <david@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Arun KS <arunks@codeaurora.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v1] powerpc/pseries: CMM: Drop page array
Date: Tue, 10 Sep 2019 18:39:32 +0200
Message-Id: <20190910163932.13160-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 10 Sep 2019 16:39:38 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We can simply store the pages in a list (page->lru), no need for a
separate data structure (+ complicated handling). This is how most
other balloon drivers store allocated pages without additional tracking
data.

For the notifiers, use page_to_pfn() to check if a page is in the
applicable range. plpar_page_set_loaned()/plpar_page_set_active() were
called with __pa(page_address()) for now, I assume we can simply switch
to page_to_phys() here. The pfn_to_kaddr() handling is now mostly gone.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: David Hildenbrand <david@redhat.com>
---

Only compile-tested. I hope the page_to_phys() thingy is correct and I
didn't mess up something else / ignoring something important why the arra=
y
is needed.

I stumbled over this while looking at how the memory isolation notifier i=
s
used - and wondered why the additional array is necessary. Also, I think
by switching to the generic balloon compaction mechanism, we could get
rid of the memory hotplug notifier and the memory isolation notifier in
this code, as the migration capability of the inflated pages is the real
requirement:
	commit 14b8a76b9d53346f2871bf419da2aaf219940c50
	Author: Robert Jennings <rcj@linux.vnet.ibm.com>
	Date:   Thu Dec 17 14:44:52 2009 +0000
=09
	    powerpc: Make the CMM memory hotplug aware
=09
	    The Collaborative Memory Manager (CMM) module allocates individual p=
ages
	    over time that are not migratable.  On a long running system this ca=
n
	    severely impact the ability to find enough pages to support a hotplu=
g
	    memory remove operation.
	[...]

Thoughts?

---
 arch/powerpc/platforms/pseries/cmm.c | 155 ++++++---------------------
 1 file changed, 31 insertions(+), 124 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/cmm.c b/arch/powerpc/platform=
s/pseries/cmm.c
index b33251d75927..9cab34a667bf 100644
--- a/arch/powerpc/platforms/pseries/cmm.c
+++ b/arch/powerpc/platforms/pseries/cmm.c
@@ -75,21 +75,13 @@ module_param_named(debug, cmm_debug, uint, 0644);
 MODULE_PARM_DESC(debug, "Enable module debugging logging. Set to 1 to en=
able. "
 		 "[Default=3D" __stringify(CMM_DEBUG) "]");
=20
-#define CMM_NR_PAGES ((PAGE_SIZE - sizeof(void *) - sizeof(unsigned long=
)) / sizeof(unsigned long))
-
 #define cmm_dbg(...) if (cmm_debug) { printk(KERN_INFO "cmm: "__VA_ARGS_=
_); }
=20
-struct cmm_page_array {
-	struct cmm_page_array *next;
-	unsigned long index;
-	unsigned long page[CMM_NR_PAGES];
-};
-
 static unsigned long loaned_pages;
 static unsigned long loaned_pages_target;
 static unsigned long oom_freed_pages;
=20
-static struct cmm_page_array *cmm_page_list;
+static LIST_HEAD(cmm_page_list);
 static DEFINE_SPINLOCK(cmm_lock);
=20
 static DEFINE_MUTEX(hotplug_mutex);
@@ -138,8 +130,7 @@ static long plpar_page_set_active(unsigned long vpa)
  **/
 static long cmm_alloc_pages(long nr)
 {
-	struct cmm_page_array *pa, *npa;
-	unsigned long addr;
+	struct page *page;
 	long rc;
=20
 	cmm_dbg("Begin request for %ld pages\n", nr);
@@ -156,43 +147,20 @@ static long cmm_alloc_pages(long nr)
 			break;
 		}
=20
-		addr =3D __get_free_page(GFP_NOIO | __GFP_NOWARN |
-				       __GFP_NORETRY | __GFP_NOMEMALLOC);
-		if (!addr)
+		page =3D alloc_page(GFP_NOIO | __GFP_NOWARN | __GFP_NORETRY |
+				  __GFP_NOMEMALLOC);
+		if (!page)
 			break;
 		spin_lock(&cmm_lock);
-		pa =3D cmm_page_list;
-		if (!pa || pa->index >=3D CMM_NR_PAGES) {
-			/* Need a new page for the page list. */
-			spin_unlock(&cmm_lock);
-			npa =3D (struct cmm_page_array *)__get_free_page(
-					GFP_NOIO | __GFP_NOWARN |
-					__GFP_NORETRY | __GFP_NOMEMALLOC);
-			if (!npa) {
-				pr_info("%s: Can not allocate new page list\n", __func__);
-				free_page(addr);
-				break;
-			}
-			spin_lock(&cmm_lock);
-			pa =3D cmm_page_list;
-
-			if (!pa || pa->index >=3D CMM_NR_PAGES) {
-				npa->next =3D pa;
-				npa->index =3D 0;
-				pa =3D npa;
-				cmm_page_list =3D pa;
-			} else
-				free_page((unsigned long) npa);
-		}
-
-		if ((rc =3D plpar_page_set_loaned(__pa(addr)))) {
+		rc =3D plpar_page_set_loaned(page_to_phys(page));
+		if (rc) {
 			pr_err("%s: Can not set page to loaned. rc=3D%ld\n", __func__, rc);
 			spin_unlock(&cmm_lock);
-			free_page(addr);
+			__free_page(page);
 			break;
 		}
=20
-		pa->page[pa->index++] =3D addr;
+		list_add(&page->lru, &cmm_page_list);
 		loaned_pages++;
 		totalram_pages_dec();
 		spin_unlock(&cmm_lock);
@@ -212,25 +180,16 @@ static long cmm_alloc_pages(long nr)
  **/
 static long cmm_free_pages(long nr)
 {
-	struct cmm_page_array *pa;
-	unsigned long addr;
+	struct page *page, *tmp;
=20
 	cmm_dbg("Begin free of %ld pages.\n", nr);
 	spin_lock(&cmm_lock);
-	pa =3D cmm_page_list;
-	while (nr) {
-		if (!pa || pa->index <=3D 0)
+	list_for_each_entry_safe(page, tmp, &cmm_page_list, lru) {
+		if (!nr)
 			break;
-		addr =3D pa->page[--pa->index];
-
-		if (pa->index =3D=3D 0) {
-			pa =3D pa->next;
-			free_page((unsigned long) cmm_page_list);
-			cmm_page_list =3D pa;
-		}
-
-		plpar_page_set_active(__pa(addr));
-		free_page(addr);
+		plpar_page_set_active(page_to_phys(page));
+		list_del(&page->lru);
+		__free_page(page);
 		loaned_pages--;
 		nr--;
 		totalram_pages_inc();
@@ -491,20 +450,13 @@ static struct notifier_block cmm_reboot_nb =3D {
 static unsigned long cmm_count_pages(void *arg)
 {
 	struct memory_isolate_notify *marg =3D arg;
-	struct cmm_page_array *pa;
-	unsigned long start =3D (unsigned long)pfn_to_kaddr(marg->start_pfn);
-	unsigned long end =3D start + (marg->nr_pages << PAGE_SHIFT);
-	unsigned long idx;
+	struct page *page;
=20
 	spin_lock(&cmm_lock);
-	pa =3D cmm_page_list;
-	while (pa) {
-		if ((unsigned long)pa >=3D start && (unsigned long)pa < end)
+	list_for_each_entry(page, &cmm_page_list, lru) {
+		if (page_to_pfn(page) >=3D marg->start_pfn &&
+		    page_to_pfn(page) < marg->start_pfn + marg->nr_pages)
 			marg->pages_found++;
-		for (idx =3D 0; idx < pa->index; idx++)
-			if (pa->page[idx] >=3D start && pa->page[idx] < end)
-				marg->pages_found++;
-		pa =3D pa->next;
 	}
 	spin_unlock(&cmm_lock);
 	return 0;
@@ -545,69 +497,24 @@ static struct notifier_block cmm_mem_isolate_nb =3D=
 {
 static int cmm_mem_going_offline(void *arg)
 {
 	struct memory_notify *marg =3D arg;
-	unsigned long start_page =3D (unsigned long)pfn_to_kaddr(marg->start_pf=
n);
-	unsigned long end_page =3D start_page + (marg->nr_pages << PAGE_SHIFT);
-	struct cmm_page_array *pa_curr, *pa_last, *npa;
-	unsigned long idx;
+	struct page *page, *tmp;
 	unsigned long freed =3D 0;
=20
 	cmm_dbg("Memory going offline, searching 0x%lx (%ld pages).\n",
-			start_page, marg->nr_pages);
+		(unsigned long)pfn_to_kaddr(marg->start_pfn), marg->nr_pages);
 	spin_lock(&cmm_lock);
=20
 	/* Search the page list for pages in the range to be offlined */
-	pa_last =3D pa_curr =3D cmm_page_list;
-	while (pa_curr) {
-		for (idx =3D (pa_curr->index - 1); (idx + 1) > 0; idx--) {
-			if ((pa_curr->page[idx] < start_page) ||
-			    (pa_curr->page[idx] >=3D end_page))
-				continue;
-
-			plpar_page_set_active(__pa(pa_curr->page[idx]));
-			free_page(pa_curr->page[idx]);
-			freed++;
-			loaned_pages--;
-			totalram_pages_inc();
-			pa_curr->page[idx] =3D pa_last->page[--pa_last->index];
-			if (pa_last->index =3D=3D 0) {
-				if (pa_curr =3D=3D pa_last)
-					pa_curr =3D pa_last->next;
-				pa_last =3D pa_last->next;
-				free_page((unsigned long)cmm_page_list);
-				cmm_page_list =3D pa_last;
-			}
-		}
-		pa_curr =3D pa_curr->next;
-	}
-
-	/* Search for page list structures in the range to be offlined */
-	pa_last =3D NULL;
-	pa_curr =3D cmm_page_list;
-	while (pa_curr) {
-		if (((unsigned long)pa_curr >=3D start_page) &&
-				((unsigned long)pa_curr < end_page)) {
-			npa =3D (struct cmm_page_array *)__get_free_page(
-					GFP_NOIO | __GFP_NOWARN |
-					__GFP_NORETRY | __GFP_NOMEMALLOC);
-			if (!npa) {
-				spin_unlock(&cmm_lock);
-				cmm_dbg("Failed to allocate memory for list "
-						"management. Memory hotplug "
-						"failed.\n");
-				return -ENOMEM;
-			}
-			memcpy(npa, pa_curr, PAGE_SIZE);
-			if (pa_curr =3D=3D cmm_page_list)
-				cmm_page_list =3D npa;
-			if (pa_last)
-				pa_last->next =3D npa;
-			free_page((unsigned long) pa_curr);
-			freed++;
-			pa_curr =3D npa;
-		}
-
-		pa_last =3D pa_curr;
-		pa_curr =3D pa_curr->next;
+	list_for_each_entry_safe(page, tmp, &cmm_page_list, lru) {
+		if (page_to_pfn(page) < marg->start_pfn ||
+		    page_to_pfn(page) >=3D marg->start_pfn + marg->nr_pages)
+			continue;
+		plpar_page_set_active(page_to_phys(page));
+		list_del(&page->lru);
+		__free_page(page);
+		freed++;
+		loaned_pages--;
+		totalram_pages_inc();
 	}
=20
 	spin_unlock(&cmm_lock);
--=20
2.21.0



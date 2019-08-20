Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 302D3C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:18:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E085722DA7
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:18:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E085722DA7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EDD26B000D; Tue, 20 Aug 2019 09:18:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 157346B000A; Tue, 20 Aug 2019 09:18:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E24686B000E; Tue, 20 Aug 2019 09:18:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0106.hostedemail.com [216.40.44.106])
	by kanga.kvack.org (Postfix) with ESMTP id 95CEC6B0269
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:18:41 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3EB4F68AE
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:18:41 +0000 (UTC)
X-FDA: 75842860842.11.wood49_11920db8c6824
X-HE-Tag: wood49_11920db8c6824
X-Filterd-Recvd-Size: 7646
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:18:40 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 13C3DADEC;
	Tue, 20 Aug 2019 13:18:39 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Matthew Wilcox <willy@infradead.org>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 4/4] mm, page_owner, debug_pagealloc: save and dump freeing stack trace
Date: Tue, 20 Aug 2019 15:18:28 +0200
Message-Id: <20190820131828.22684-5-vbabka@suse.cz>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190820131828.22684-1-vbabka@suse.cz>
References: <20190820131828.22684-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The debug_pagealloc functionality is useful to catch buggy page allocator=
 users
that cause e.g. use after free or double free. When page inconsistency is
detected, debugging is often simpler by knowing the call stack of process=
 that
last allocated and freed the page. When page_owner is also enabled, we re=
cord
the allocation stack trace, but not freeing.

This patch therefore adds recording of freeing process stack trace to pag=
e
owner info, if both page_owner and debug_pagealloc are configured and ena=
bled.
With only page_owner enabled, this info is not useful for the memory leak
debugging use case. dump_page() is adjusted to print the info. An example
result of calling __free_pages() twice may look like this (note the page =
last free
stack trace):

BUG: Bad page state in process bash  pfn:13d8f8
page:ffffc31984f63e00 refcount:-1 mapcount:0 mapping:0000000000000000 ind=
ex:0x0
flags: 0x1affff800000000()
raw: 01affff800000000 dead000000000100 dead000000000122 0000000000000000
raw: 0000000000000000 0000000000000000 ffffffffffffffff 0000000000000000
page dumped because: nonzero _refcount
page_owner tracks the page as freed
page last allocated via order 0, migratetype Unmovable, gfp_mask 0xcc0(GF=
P_KERNEL)
 prep_new_page+0x143/0x150
 get_page_from_freelist+0x289/0x380
 __alloc_pages_nodemask+0x13c/0x2d0
 khugepaged+0x6e/0xc10
 kthread+0xf9/0x130
 ret_from_fork+0x3a/0x50
page last free stack trace:
 free_pcp_prepare+0x134/0x1e0
 free_unref_page+0x18/0x90
 khugepaged+0x7b/0xc10
 kthread+0xf9/0x130
 ret_from_fork+0x3a/0x50
Modules linked in:
CPU: 3 PID: 271 Comm: bash Not tainted 5.3.0-rc4-2.g07a1a73-default+ #57
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.12.1-0-=
ga5cab58-prebuilt.qemu.org 04/01/2014
Call Trace:
 dump_stack+0x85/0xc0
 bad_page.cold+0xba/0xbf
 rmqueue_pcplist.isra.0+0x6c5/0x6d0
 rmqueue+0x2d/0x810
 get_page_from_freelist+0x191/0x380
 __alloc_pages_nodemask+0x13c/0x2d0
 __get_free_pages+0xd/0x30
 __pud_alloc+0x2c/0x110
 copy_page_range+0x4f9/0x630
 dup_mmap+0x362/0x480
 dup_mm+0x68/0x110
 copy_process+0x19e1/0x1b40
 _do_fork+0x73/0x310
 __x64_sys_clone+0x75/0x80
 do_syscall_64+0x6e/0x1e0
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x7f10af854a10
...

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 .../admin-guide/kernel-parameters.txt         |  2 +
 mm/Kconfig.debug                              |  4 +-
 mm/page_owner.c                               | 53 ++++++++++++++-----
 3 files changed, 45 insertions(+), 14 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentat=
ion/admin-guide/kernel-parameters.txt
index 47d981a86e2f..e813a17d622e 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -809,6 +809,8 @@
 			enables the feature at boot time. By default, it is
 			disabled and the system will work mostly the same as a
 			kernel built without CONFIG_DEBUG_PAGEALLOC.
+			Note: to get most of debug_pagealloc error reports, it's
+			useful to also enable the page_owner functionality.
 			on: enable the feature
=20
 	debugpat	[X86] Enable PAT debugging
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 82b6a20898bd..327b3ebf23bf 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -21,7 +21,9 @@ config DEBUG_PAGEALLOC
 	  Also, the state of page tracking structures is checked more often as
 	  pages are being allocated and freed, as unexpected state changes
 	  often happen for same reasons as memory corruption (e.g. double free,
-	  use-after-free).
+	  use-after-free). The error reports for these checks can be augmented
+	  with stack traces of last allocation and freeing of the page, when
+	  PAGE_OWNER is also selected and enabled on boot.
=20
 	  For architectures which don't enable ARCH_SUPPORTS_DEBUG_PAGEALLOC,
 	  fill the pages with poison patterns after free_pages() and verify
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 4a48e018dbdf..dee931184788 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -24,6 +24,9 @@ struct page_owner {
 	short last_migrate_reason;
 	gfp_t gfp_mask;
 	depot_stack_handle_t handle;
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	depot_stack_handle_t free_handle;
+#endif
 };
=20
 static bool page_owner_disabled =3D true;
@@ -102,19 +105,6 @@ static inline struct page_owner *get_page_owner(stru=
ct page_ext *page_ext)
 	return (void *)page_ext + page_owner_ops.offset;
 }
=20
-void __reset_page_owner(struct page *page, unsigned int order)
-{
-	int i;
-	struct page_ext *page_ext;
-
-	for (i =3D 0; i < (1 << order); i++) {
-		page_ext =3D lookup_page_ext(page + i);
-		if (unlikely(!page_ext))
-			continue;
-		__clear_bit(PAGE_EXT_OWNER_ACTIVE, &page_ext->flags);
-	}
-}
-
 static inline bool check_recursive_alloc(unsigned long *entries,
 					 unsigned int nr_entries,
 					 unsigned long ip)
@@ -154,6 +144,32 @@ static noinline depot_stack_handle_t save_stack(gfp_=
t flags)
 	return handle;
 }
=20
+void __reset_page_owner(struct page *page, unsigned int order)
+{
+	int i;
+	struct page_ext *page_ext;
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	depot_stack_handle_t handle =3D 0;
+	struct page_owner *page_owner;
+
+	if (debug_pagealloc_enabled())
+		handle =3D save_stack(GFP_NOWAIT | __GFP_NOWARN);
+#endif
+
+	for (i =3D 0; i < (1 << order); i++) {
+		page_ext =3D lookup_page_ext(page + i);
+		if (unlikely(!page_ext))
+			continue;
+		__clear_bit(PAGE_EXT_OWNER_ACTIVE, &page_ext->flags);
+#ifdef CONFIG_DEBUG_PAGEALLOC
+		if (debug_pagealloc_enabled()) {
+			page_owner =3D get_page_owner(page_ext);
+			page_owner->free_handle =3D handle;
+		}
+#endif
+	}
+}
+
 static inline void __set_page_owner_handle(struct page *page,
 	struct page_ext *page_ext, depot_stack_handle_t handle,
 	unsigned int order, gfp_t gfp_mask)
@@ -435,6 +451,17 @@ void __dump_page_owner(struct page *page)
 		stack_trace_print(entries, nr_entries, 0);
 	}
=20
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	handle =3D READ_ONCE(page_owner->free_handle);
+	if (!handle) {
+		pr_alert("page_owner free stack trace missing\n");
+	} else {
+		nr_entries =3D stack_depot_fetch(handle, &entries);
+		pr_alert("page last free stack trace:\n");
+		stack_trace_print(entries, nr_entries, 0);
+	}
+#endif
+
 	if (page_owner->last_migrate_reason !=3D -1)
 		pr_alert("page has been migrated, last migrate reason: %s\n",
 			migrate_reason_names[page_owner->last_migrate_reason]);
--=20
2.22.0



Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E60136B0620
	for <linux-mm@kvack.org>; Thu, 10 May 2018 16:48:27 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id bd7-v6so1808304plb.20
        for <linux-mm@kvack.org>; Thu, 10 May 2018 13:48:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c6-v6si1567325plo.88.2018.05.10.13.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 13:48:26 -0700 (PDT)
Date: Thu, 10 May 2018 13:48:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: Tree for May 10 (mm/ksm.c)
Message-Id: <20180510134825.372f4a7ec17ce3e945640ac2@linux-foundation.org>
In-Reply-To: <e55fad49-6c19-7c43-ef37-eb148bd3d55d@infradead.org>
References: <20180510172842.2619e058@canb.auug.org.au>
	<e55fad49-6c19-7c43-ef37-eb148bd3d55d@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Linux-Next Mailing List <linux-next@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

On Thu, 10 May 2018 09:37:51 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:

> On 05/10/2018 12:28 AM, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Changes since 20180509:
> > 
> 
> on i386:
> 
> ../mm/ksm.c: In function 'try_to_merge_one_page':
> ../mm/ksm.c:1244:4: error: implicit declaration of function 'set_page_stable_node' [-Werror=implicit-function-declaration]
>     set_page_stable_node(page, NULL);

Thanks.

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-ksm-move-page_stable_node-from-ksmh-to-ksmc-fix

fix SYSFS=n build

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/ksm.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff -puN include/linux/ksm.h~mm-ksm-move-page_stable_node-from-ksmh-to-ksmc-fix include/linux/ksm.h
diff -puN mm/ksm.c~mm-ksm-move-page_stable_node-from-ksmh-to-ksmc-fix mm/ksm.c
--- a/mm/ksm.c~mm-ksm-move-page_stable_node-from-ksmh-to-ksmc-fix
+++ a/mm/ksm.c
@@ -823,11 +823,6 @@ static int unmerge_ksm_pages(struct vm_a
 	return err;
 }
 
-#ifdef CONFIG_SYSFS
-/*
- * Only called through the sysfs control interface:
- */
-
 static inline struct stable_node *page_stable_node(struct page *page)
 {
 	return PageKsm(page) ? page_rmapping(page) : NULL;
@@ -839,6 +834,10 @@ static inline void set_page_stable_node(
 	page->mapping = (void *)((unsigned long)stable_node | PAGE_MAPPING_KSM);
 }
 
+#ifdef CONFIG_SYSFS
+/*
+ * Only called through the sysfs control interface:
+ */
 static int remove_stable_node(struct stable_node *stable_node)
 {
 	struct page *page;
_

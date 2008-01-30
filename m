Date: Wed, 30 Jan 2008 12:02:07 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
Message-ID: <20080130180207.GU26420@sgi.com>
References: <20080130022909.677301714@sgi.com> <20080130022944.236370194@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080130022944.236370194@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Back to one of Andrea's points from a couple days ago, I think we still
have a problem with the PageExternalRmap page flag.

If I had two drivers with external rmap implementations, there is no way
I can think of for a simple flag to coordinate a single page being
exported and maintained by the two.

Since the intended use seems to point in the direction of the external
rmap must be maintained consistent with the all pages the driver has
exported and the driver will already need to handle cases where the page
does not appear in its rmap, I would propose the setting and clearing
should be handled in the mmu_notifier code.

This is the first of two patches.  This one is intended as an addition
to patch 1/6.  I will post the other shortly under the patch 3/6 thread.


Index: git-linus/include/linux/mmu_notifier.h
===================================================================
--- git-linus.orig/include/linux/mmu_notifier.h	2008-01-30 11:43:45.000000000 -0600
+++ git-linus/include/linux/mmu_notifier.h	2008-01-30 11:44:35.000000000 -0600
@@ -146,6 +146,7 @@ static inline void mmu_notifier_head_ini
 
 extern void mmu_rmap_notifier_register(struct mmu_rmap_notifier *mrn);
 extern void mmu_rmap_notifier_unregister(struct mmu_rmap_notifier *mrn);
+extern void mmu_rmap_export_page(struct page *page);
 
 extern struct hlist_head mmu_rmap_notifier_list;
 
Index: git-linus/mm/mmu_notifier.c
===================================================================
--- git-linus.orig/mm/mmu_notifier.c	2008-01-30 11:43:45.000000000 -0600
+++ git-linus/mm/mmu_notifier.c	2008-01-30 11:56:08.000000000 -0600
@@ -99,3 +99,8 @@ void mmu_rmap_notifier_unregister(struct
 }
 EXPORT_SYMBOL(mmu_rmap_notifier_unregister);
 
+void mmu_rmap_export_page(struct page *page)
+{
+	SetPageExternalRmap(page);
+}
+EXPORT_SYMBOL(mmu_rmap_export_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

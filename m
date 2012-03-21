Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 7AA3D6B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 18:47:23 -0400 (EDT)
Date: Wed, 21 Mar 2012 15:47:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/3] thp: add HPAGE_PMD_* definitions for
 !CONFIG_TRANSPARENT_HUGEPAGE
Message-Id: <20120321154721.3b8884bd.akpm@linux-foundation.org>
In-Reply-To: <CAP=VYLoGSckJH+2GytZN0V0P3Uuv-PiVneKbFsVb5kQa3kcTCQ@mail.gmail.com>
References: <1331591456-20769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1331591456-20769-2-git-send-email-n-horiguchi@ah.jp.nec.com>
	<CAP=VYLoGSckJH+2GytZN0V0P3Uuv-PiVneKbFsVb5kQa3kcTCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org

On Wed, 21 Mar 2012 18:07:41 -0400
Paul Gortmaker <paul.gortmaker@windriver.com> wrote:

> On Mon, Mar 12, 2012 at 6:30 PM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > These macros will be used in later patch, where all usage are expected
> > to be optimized away without #ifdef CONFIG_TRANSPARENT_HUGEPAGE.
> > But to detect unexpected usages, we convert existing BUG() to BUILD_BUG().
> 
> Just a heads up that this showed up in linux-next today as the
> cause of a new build failure for an ARM board:
> 
> http://kisskb.ellerman.id.au/kisskb/buildresult/5930053/

The internet started working again.

mm/pgtable-generic.c: In function 'pmdp_clear_flush_young':
mm/pgtable-generic.c:76: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed

I guess we shouldn't be evaluating HPAGE_PMD_MASK at all if
!CONFIG_TRANSPARENT_HUGEPAGE, so...

--- a/mm/pgtable-generic.c~thp-add-hpage_pmd_-definitions-for-config_transparent_hugepage-fix
+++ a/mm/pgtable-generic.c
@@ -70,10 +70,11 @@ int pmdp_clear_flush_young(struct vm_are
 			   unsigned long address, pmd_t *pmdp)
 {
 	int young;
-#ifndef CONFIG_TRANSPARENT_HUGEPAGE
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+#else
 	BUG();
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	young = pmdp_test_and_clear_young(vma, address, pmdp);
 	if (young)
 		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

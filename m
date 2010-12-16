Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 49F5E6B0098
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 21:36:34 -0500 (EST)
Date: Thu, 16 Dec 2010 03:35:21 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: kvm mmu transparent hugepage support for linux-next
Message-ID: <20101216023521.GE5638@random.random>
References: <20101215051540.GP5638@random.random>
 <20101215155545.303ca2c2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101215155545.303ca2c2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Miklos Szeredi <miklos@szeredi.hu>, Gleb Natapov <gleb@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Wed, Dec 15, 2010 at 03:55:45PM -0800, Andrew Morton wrote:
> On Wed, 15 Dec 2010 06:15:40 +0100
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > Some of some relevant user of the project:
> > 
> > KVM Virtualization
> > GCC (kernel build included, requires a few liner patch to enable)
> > JVM
> > VMware Workstation
> > HPC
> > 
> > It would be great if it could go in -mm.
> 
> That all merged pretty easily on top of the current mm pile.  Except
> for kvm-mmu-transparent-hugepage-support.patch which needs some thought
> and testing to get it merged into the KVM changes in linux-next.  I
> simply omitted kvm-mmu-transparent-hugepage-support.patch so please
> take a look?

Ok, I've an untested patch as full replacement of the
5Akvm-mmu-transparent-hugepage-support.patch, for linux-next. It's
untested because I didn't even try to boot linux-next after reading
your last mail about it. In the meantime I'd appreciate review from
Marcelo.

For Marcelo: before we were calling gup and checking if the pfn was
part of a compound page, and we were returning the right "level" from
inside mapping_level(). Now mapping_level is only left to detect
hugetlbfs. So if hugetlbfs isn't detected, _after_ gfn_to_pfn runs, we
check if the pfn is part of a trans compound page. If it is, we adjust
pfn/gfn after the fact before invoking spte establishment. It should
be functionally equivalent to the previous version and it eliminates
one unnecessary gfn_to_pfn/gup invocation compared to the previous
code. I had to rewrite it to adjust after the fact (async page fault)
to avoid invalidating async page faults (or to avoid handling async
page faults inside mapping_level itself which would litter its
interface and make it a lot more complex). If we're allowed to adjust
after the fact, this is simpler more efficient and it'll live happily
with the async page faults. Note: I didn't adjust the guest virtual
address as I don't think it needs adjustment. Let me know if you see
something wrong with this, thanks! (good thing is, if something's
wrong we'll notice it very quick as soon as we can test it :)

=========
Subject: kvm mmu transparent hugepage support

From: Andrea Arcangeli <aarcange@redhat.com>

This should work for both hugetlbfs and transparent hugepages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index bdb9fa9..22062b2 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2286,6 +2286,18 @@ static int kvm_handle_bad_page(struct kvm *kvm, gfn_t gfn, pfn_t pfn)
 	return 1;
 }
 
+static void transparent_hugepage_adjust(gfn_t *gfn, pfn_t *pfn, int * level)
+{
+	/* check if it's a transparent hugepage */
+	if (!is_error_pfn(*pfn) && !kvm_is_mmio_pfn(*pfn) &&
+	    *level == PT_PAGE_TABLE_LEVEL &&
+	    PageTransCompound(pfn_to_page(*pfn))) {
+		*level = PT_DIRECTORY_LEVEL;
+		*gfn = *gfn & ~(KVM_PAGES_PER_HPAGE(*level) - 1);
+		*pfn = *pfn & ~(KVM_PAGES_PER_HPAGE(*level) - 1);
+	}
+}
+
 static bool try_async_pf(struct kvm_vcpu *vcpu, bool no_apf, gfn_t gfn,
 			 gva_t gva, pfn_t *pfn, bool write, bool *writable);
 
@@ -2314,6 +2326,7 @@ static int nonpaging_map(struct kvm_vcpu *vcpu, gva_t v, int write, gfn_t gfn,
 
 	if (try_async_pf(vcpu, no_apf, gfn, v, &pfn, write, &map_writable))
 		return 0;
+	transparent_hugepage_adjust(&gfn, &pfn, &level);
 
 	/* mmio */
 	if (is_error_pfn(pfn))
@@ -2676,6 +2689,7 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa, u32 error_code,
 
 	if (try_async_pf(vcpu, no_apf, gfn, gpa, &pfn, write, &map_writable))
 		return 0;
+	transparent_hugepage_adjust(&gfn, &pfn, &level);
 
 	/* mmio */
 	if (is_error_pfn(pfn))
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
index 590bf12..bc91891 100644
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -575,6 +575,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr, u32 error_code,
 	if (try_async_pf(vcpu, no_apf, walker.gfn, addr, &pfn, write_fault,
 			 &map_writable))
 		return 0;
+	transparent_hugepage_adjust(&walker.gfn, &pfn, &level);
 
 	/* mmio */
 	if (is_error_pfn(pfn))
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index fb93ff9..4fa0121 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -103,8 +103,36 @@ static pfn_t fault_pfn;
 inline int kvm_is_mmio_pfn(pfn_t pfn)
 {
 	if (pfn_valid(pfn)) {
-		struct page *page = compound_head(pfn_to_page(pfn));
-		return PageReserved(page);
+		struct page *head;
+		struct page *tail = pfn_to_page(pfn);
+		head = compound_head(tail);
+		if (head != tail) {
+			smp_rmb();
+			/*
+			 * head may be a dangling pointer.
+			 * __split_huge_page_refcount clears PageTail
+			 * before overwriting first_page, so if
+			 * PageTail is still there it means the head
+			 * pointer isn't dangling.
+			 */
+			if (PageTail(tail)) {
+				/*
+				 * the "head" is not a dangling
+				 * pointer but the hugepage may have
+				 * been splitted from under us (and we
+				 * may not hold a reference count on
+				 * the head page so it can be reused
+				 * before we run PageReferenced), so
+				 * we've to recheck PageTail before
+				 * returning what we just read.
+				 */
+				int reserved = PageReserved(head);
+				smp_rmb();
+				if (PageTail(tail))
+					return reserved;
+			}
+		}
+		return PageReserved(tail);
 	}
 
 	return true;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8C51B6B004A
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 12:11:20 -0500 (EST)
Date: Thu, 25 Nov 2010 18:10:30 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 16 of 66] special pmd_trans_* functions
Message-ID: <20101125171030.GQ6118@random.random>
References: <patchbomb.1288798055@v2.random>
 <522a9ff792e43eb0ec6a.1288798071@v2.random>
 <20101118125112.GM8135@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118125112.GM8135@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 12:51:12PM +0000, Mel Gorman wrote:
> Usually it is insisted upon that this looks like
> 
> static inline int pmd_trans_huge(pmd) {
> 	return 0;
> }
> 
> I understand it's to avoid any possibility of side-effets though to have type
> checking and I am 99% certain the compiler still does the right thing. Still,
> with no obvious side-effects here;
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>

It doesn't seem to fail build on x86-64 and x86, so it should build
for all other archs too. I'm keeping this incremental at the end just
in case.

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -471,10 +471,20 @@ extern void untrack_pfn_vma(struct vm_ar
 #endif
 
 #ifndef CONFIG_TRANSPARENT_HUGEPAGE
-#define pmd_trans_huge(pmd) 0
-#define pmd_trans_splitting(pmd) 0
+static inline int pmd_trans_huge(pmd_t pmd)
+{
+	return 0;
+}
+static inline int pmd_trans_splitting(pmd_t pmd)
+{
+	return 0;
+}
 #ifndef __HAVE_ARCH_PMD_WRITE
-#define pmd_write(pmd)	({ BUG(); 0; })
+static inline int pmd_write(pmd_t pmd)
+{
+	BUG();
+	return 0;
+}
 #endif /* __HAVE_ARCH_PMD_WRITE */
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

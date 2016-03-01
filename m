Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 00CC16B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 08:31:08 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id n186so36941637wmn.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 05:31:07 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id cl14si37373747wjb.42.2016.03.01.05.31.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Mar 2016 05:31:06 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id DD58398F28
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 13:31:03 +0000 (UTC)
Date: Tue, 1 Mar 2016 13:31:02 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/1] mm: thp: Set THP defrag by default to madvise and
 add a stall-free defrag option
Message-ID: <20160301133102.GG2854@techsingularity.net>
References: <1456503359-4910-1-git-send-email-mgorman@techsingularity.net>
 <56D58E1E.5090708@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <56D58E1E.5090708@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 01, 2016 at 01:42:06PM +0100, Vlastimil Babka wrote:
> >Lastly, it removes a check from the page allocator slowpath that is related
> >to __GFP_THISNODE to allow "defer" to work. The callers that really cares are
> >slub/slab and they are updated accordingly. The slab one may be surprising
> >because it also corrects a comment as kswapd was never woken up by that path.
> 
> It would be also nice if we could remove the is_thp_gfp_mask() checks one
> day. They try to make direct reclaim/compaction for THP less intrusive, but
> maybe could be removed now that the stalls are limited otherwise. But that's
> out of scope here.
> 

Maybe a rename would be appropriate but it's marginal at best.

> [...]
> 
> >diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> >index 8a282687ee06..a19b173cbc57 100644
> >--- a/Documentation/vm/transhuge.txt
> >+++ b/Documentation/vm/transhuge.txt
> >@@ -113,9 +113,26 @@ guaranteed, but it may be more likely in case the allocation is for a
> >  MADV_HUGEPAGE region.
> >
> >  echo always >/sys/kernel/mm/transparent_hugepage/defrag
> >+echo defer >/sys/kernel/mm/transparent_hugepage/defrag
> >  echo madvise >/sys/kernel/mm/transparent_hugepage/defrag
> >  echo never >/sys/kernel/mm/transparent_hugepage/defrag
> >
> >+"always" means that an application requesting THP will stall on allocation
> >+failure and directly reclaim pages and compact memory in an effort to
> >+allocate a THP immediately. This may be desirable for virtual machines
> >+that benefit heavily from THP use and are willing to delay the VM start
> >+to utilise them.
> >+
> >+"defer" means that an application will wake kswapd in the background
> >+to reclaim pages and wake kcompact to compact memory so that THP is
> >+available in the near future. It's the responsibility of khugepaged
> >+to then install the THP pages later.
> >+
> >+"madvise" will enter direct reclaim like "always" but only for regions
> >+that are have used madvise(). This is the default behaviour.
> 
> "madvise(MADV_HUGEPAGE)" perhaps?
> 

Fixed.

> [...]
> 
> >@@ -277,17 +273,23 @@ static ssize_t double_flag_store(struct kobject *kobj,
> >  static ssize_t enabled_show(struct kobject *kobj,
> >  			    struct kobj_attribute *attr, char *buf)
> >  {
> >-	return double_flag_show(kobj, attr, buf,
> >-				TRANSPARENT_HUGEPAGE_FLAG,
> >-				TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);
> >+	if (test_bit(TRANSPARENT_HUGEPAGE_FLAG, &transparent_hugepage_flags)) {
> >+		VM_BUG_ON(test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags));
> >+		return sprintf(buf, "[always] madvise never\n");
> >+	} else if (test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags))
> >+		return sprintf(buf, "always [madvise] never\n");
> >+	else
> >+		return sprintf(buf, "always madvise [never]\n");
> 
> Somewhat ugly wrt consistent usage of { }, due to the VM_BUG_ON(), which I
> would just drop.

Fixed.

> Also I wonder if some racy read vs write of the file can
> trigger the BUG_ON? Or are the kobject accesses synchronized at a higher
> level?
> 

Even if such a bug was to occur, it should be relatively harmless due to
the order of the checks in alloc_hugepage_direct_gfpmask()

> >  }
> >+
> >  static ssize_t enabled_store(struct kobject *kobj,
> >  			     struct kobj_attribute *attr,
> >  			     const char *buf, size_t count)
> >  {
> >  	ssize_t ret;
> >
> >-	ret = double_flag_store(kobj, attr, buf, count,
> >+	ret = triple_flag_store(kobj, attr, buf, count,
> >+				TRANSPARENT_HUGEPAGE_FLAG,
> >  				TRANSPARENT_HUGEPAGE_FLAG,
> >  				TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);
> 
> So this makes "echo defer > enabled" behave just like "echo always"? For
> userspace interface that becomes a fixed ABI, I would prefer to be more
> careful with unintended aliases like this. Maybe pass something like "-1"
> that triple_flag_store() would check in the "defer" case and return -EINVAL?
> 

Fair point.

> >@@ -784,9 +793,30 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
> >  	return 0;
> >  }
> >
> >-static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
> >+/*
> >+ * If THP is set to always then directly reclaim/compact as necessary
> >+ * If set to defer then do no reclaim and defer to khugepaged
> >+ * If set to madvise and the VMA is flagged then directly reclaim/compact
> >+ */
> >+static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
> >+{
> >+	gfp_t reclaim_flags = 0;
> >+
> >+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags) &&
> >+	    (vma->vm_flags & VM_HUGEPAGE))
> >+		reclaim_flags = __GFP_DIRECT_RECLAIM;
> >+	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
> >+		reclaim_flags = __GFP_KSWAPD_RECLAIM;
> >+	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
> >+		reclaim_flags = __GFP_DIRECT_RECLAIM;
> 
> Hmm, here's a trick question. What if I wanted direct reclaim for madvise()
> vma's and kswapd/kcompactd for others? Right now there's no such option,
> right? And expressing that with different values for a single tunable
> becomes ugly...
> 

It does become ugly and I'm not aware of anyone complaining about the
behaviour of madvise() regions. The intent was to avoid stalls for people
that are not necessarily expecting them due to the current defaults.
Hence, at this point I don't think it's worth expanding the interface
further. 

This?

---8<---
mm: thp: Set THP defrag by default to madvise and add a stall-free defrag option -fix

The following is a fix to the patch
mm-thp-set-thp-defrag-by-default-to-madvise-and-add-a-stall-free-defrag-option.patch
based on feedback from Vlastimil Babka. It removes an unnecessary VM_BUG_ON for tidyness,
clarifies documentation and adds a check forbidding someone writing "defer" to the enable
knob for transparent huge pages.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 Documentation/vm/transhuge.txt | 2 +-
 mm/huge_memory.c               | 7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index a19b173cbc57..1943fe051a36 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -129,7 +129,7 @@ available in the near future. It's the responsibility of khugepaged
 to then install the THP pages later.
 
 "madvise" will enter direct reclaim like "always" but only for regions
-that are have used madvise(). This is the default behaviour.
+that are have used madvise(MADV_HUGEPAGE). This is the default behaviour.
 
 "never" should be self-explanatory.
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 206f35f06d83..9161b3a83720 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -246,6 +246,8 @@ static ssize_t triple_flag_store(struct kobject *kobj,
 {
 	if (!memcmp("defer", buf,
 		    min(sizeof("defer")-1, count))) {
+		if (enabled == deferred)
+			return -EINVAL;
 		clear_bit(enabled, &transparent_hugepage_flags);
 		clear_bit(req_madv, &transparent_hugepage_flags);
 		set_bit(deferred, &transparent_hugepage_flags);
@@ -273,10 +275,9 @@ static ssize_t triple_flag_store(struct kobject *kobj,
 static ssize_t enabled_show(struct kobject *kobj,
 			    struct kobj_attribute *attr, char *buf)
 {
-	if (test_bit(TRANSPARENT_HUGEPAGE_FLAG, &transparent_hugepage_flags)) {
-		VM_BUG_ON(test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags));
+	if (test_bit(TRANSPARENT_HUGEPAGE_FLAG, &transparent_hugepage_flags))
 		return sprintf(buf, "[always] madvise never\n");
-	} else if (test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags))
+	else if (test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags))
 		return sprintf(buf, "always [madvise] never\n");
 	else
 		return sprintf(buf, "always madvise [never]\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

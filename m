Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C9B2A6B0038
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 04:02:17 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so49651418wmu.1
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 01:02:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bf6si45340967wjb.201.2016.12.26.01.02.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Dec 2016 01:02:16 -0800 (PST)
Date: Mon, 26 Dec 2016 10:02:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20161226090211.GA11455@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
 <20161222100009.GA6055@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
 <20161223085150.GA23109@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612230154450.88514@chino.kir.corp.google.com>
 <20161223111817.GC23109@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612231428030.88276@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1612231428030.88276@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 23-12-16 14:46:43, David Rientjes wrote:
[...]
> You want defrag=madvise to start doing background compaction for 
> everybody, which was never done before for existing users of 
> defrag=madvise?  That might be possible, I don't really care, I just think 
> it's riskier because there are existing users of defrag=madvise who are 
> opting in to new behavior because of the kernel change.  This patch 
> changes defrag=defer because it's the new option and people setting the 
> mode know what they are getting.

But my primary argument is that if you tweak "defer" value behavior
then you lose the only "stall free yet allow background compaction"
option. That option is really important. You seem to think that it
is the application which is under the control. And I am not all that
surprised because you are under control of the whole userspace in your
deployments. But there are others where the administrator is not under
the control of what application asks for yet he is responsible for the
overal "experience" if you will. Long stalls during the page faults are
often seen as bugs and users might not really care whether the
application writer really wanted THP or not...

[...]

> This is obviously fine for Kirill, and I have users who remap their .text 
> segment and do madvise(MADV_DONTNEED) because they really want hugepages 
> when they are exec'd, so I'd kindly ask you to consider the real-world use 
> cases that require background compaction to make hugepages available for 
> everybody but allow apps to opt-in to take the expense of compaction on 
> themselves rather than your own theory of what users want.

I definitely _agree_ that this is a very important usecase! I am just
trying to think long term and a more sophisticated background compaction
is something that we definitely lack and _want_ longterm. There are more
high order users than THP. I believe we really want to teach kcompactd
to maintain configurable amount of highorder pages.

If there is really a need for an immediate solution^Wworkaround then I
think that tweaking the madvise option should be reasonably safe. Admins
are really prepared for stalls because they are explicitly opting in for
madvise behavior and they will get a background compaction on top. This
is a new behavior but I do not see how it would be harmful. If an
excessive compaction is a problem then THP can be reduced to madvise
only vmas.

But, I really _do_ care about having a stall free option which is not a
complete disable of the background compaction for THP.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f3c2040edbb1..3679c47faef4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -622,8 +622,8 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 	bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
 
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
-				&transparent_hugepage_flags) && vma_madvised)
-		return GFP_TRANSHUGE;
+				&transparent_hugepage_flags))
+		return (vma_madvise) ? GFP_TRANSHUGE : GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
 	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
 						&transparent_hugepage_flags))
 		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

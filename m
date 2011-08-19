Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DD88B6B0171
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 03:49:00 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p7J7mwfO031008
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:58 -0700
Received: from yxl31 (yxl31.prod.google.com [10.190.3.223])
	by hpaq2.eem.corp.google.com with ESMTP id p7J7muT5017336
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:57 -0700
Received: by yxl31 with SMTP id 31so1950633yxl.23
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:56 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 5/9] kvm: use get_page instead of get_page_unless_zero
Date: Fri, 19 Aug 2011 00:48:27 -0700
Message-Id: <1313740111-27446-6-git-send-email-walken@google.com>
In-Reply-To: <1313740111-27446-1-git-send-email-walken@google.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

In transparent_hugepage_adjust(), we can use get_page instead of
get_page_unless_zero and an assertion that the count was not zero.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 arch/x86/kvm/mmu.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index aee3862..d9b7f0c 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2353,8 +2353,7 @@ static void transparent_hugepage_adjust(struct kvm_vcpu *vcpu,
 			*gfnp = gfn;
 			kvm_release_pfn_clean(pfn);
 			pfn &= ~mask;
-			if (!get_page_unless_zero(pfn_to_page(pfn)))
-				BUG();
+			get_page(pfn_to_page(pfn));
 			*pfnp = pfn;
 		}
 	}
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

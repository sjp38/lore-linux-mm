Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 12B8B2806EE
	for <linux-mm@kvack.org>; Fri, 19 May 2017 12:58:32 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o85so29479526qkh.15
        for <linux-mm@kvack.org>; Fri, 19 May 2017 09:58:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b145si9074326qkc.241.2017.05.19.09.58.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 09:58:31 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH] x86/mm: pgds getting out of sync after memory hot remove
Date: Fri, 19 May 2017 14:01:26 -0400
Message-Id: <1495216887-3175-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>

After memory hot remove it seems we do not synchronize pgds for kernel
virtual memory range (on vmemmap_free()). This seems bogus to me as it
means we are left with stall entry for process with mm != mm_init

Yet i am puzzle by the fact that i am only now hitting this issue. It
never was an issue with 4.12 or before ie HMM never triggered following
BUG_ON inside sync_global_pgds():

if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
   BUG_ON(p4d_page_vaddr(*p4d) != p4d_page_vaddr(*p4d_ref));


It seems that Kirill 5 level page table changes play a role in this
behavior change. I could not bisect because HMM is painfull to rebase
for each bisection step so that is just my best guess.


Am i missing something here ? Am i wrong in assuming that should sync
pgd on vmemmap_free() ? If so anyone have a good guess on why i am now
seeing the above BUG_ON ?

Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@suse.de>

JA(C)rA'me Glisse (1):
  x86/mm: synchronize pgd in vmemmap_free()

 arch/x86/mm/init_64.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3356B00B6
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 18:31:21 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so4626061pdb.2
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 15:31:21 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cj15si11912739pdb.1.2015.02.18.15.31.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Feb 2015 15:31:20 -0800 (PST)
Date: Wed, 18 Feb 2015 15:31:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: incorporate zero pages into transparent huge
 pages
Message-Id: <20150218153119.0bcd0bf8b4e7d30d99f00a3b@linux-foundation.org>
In-Reply-To: <1423688635-4306-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1423688635-4306-1-git-send-email-ebru.akagunduz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com

On Wed, 11 Feb 2015 23:03:55 +0200 Ebru Akagunduz <ebru.akagunduz@gmail.com> wrote:

> This patch improves THP collapse rates, by allowing zero pages.
> 
> Currently THP can collapse 4kB pages into a THP when there
> are up to khugepaged_max_ptes_none pte_none ptes in a 2MB
> range.  This patch counts pte none and mapped zero pages
> with the same variable.

So if I'm understanding this correctly, with the default value of
khugepaged_max_ptes_none (HPAGE_PMD_NR-1), if an application creates a
2MB area which contains 511 mappings of the zero page and one real
page, the kernel will proceed to turn that area into a real, physical
huge page.  So it consumes 2MB of memory which would not have
previously been allocated?

If so, this might be rather undesirable behaviour in some situations
(and ditto the current behaviour for pte_none ptes)?

This can be tuned by adjusting khugepaged_max_ptes_none, but not many
people are likely to do that because we didn't document the damn thing.
 At all.  Can we please rectify this, and update it for the is_zero_pfn
feature?  The documentation should include an explanation telling
people how to decide what setting to use, how to observe its effects,
etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

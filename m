Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3CDC8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 18:02:28 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id e8-v6so12091695plt.4
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 15:02:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w18-v6sor2631084pga.312.2018.09.11.15.02.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Sep 2018 15:02:27 -0700 (PDT)
Date: Wed, 12 Sep 2018 01:02:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, thp: Fix mlocking THP page with migration enabled
Message-ID: <20180911220219.y6qahrzgkf3ut23d@kshutemo-mobl1>
References: <20180911103403.38086-1-kirill.shutemov@linux.intel.com>
 <5E196C27-3D56-4D76-B361-0665CB3790BF@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5E196C27-3D56-4D76-B361-0665CB3790BF@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vegard Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, Sep 11, 2018 at 04:30:02PM -0400, Zi Yan wrote:
> I want to understand the Anon THP part of the problem more clearly. For Anon THPs,
> you said, PTEs for the page will always come after mlocked PMD. I just wonder that if
> a process forks a child1 which forks its own child2 and the child1 mlocks a subpage causing
> split_pmd_page() and migrates its PTE-mapped THP, will the kernel see the sequence of PMD-mapped THP,
> PTE-mapped THP, and PMD-mapped THP while walking VMAs? Will the second PMD-mapped THP
> reset the mlock on the page?

VM_LOCKED is not inheritable. child2 will not have the VMA mlocked and
will not try to mlock the page. If child2 will do mlock() manually it will
cause CoW and the process will ge new pages in the new VMA.

> In addition, I also discover that PageDoubleMap is not set for double mapped Anon THPs after migration,
> the following patch fixes it. Do you want me to send it separately or you can merge it
> with your patch?

I think we can live without DoubleMap for anon-THP: rmap walking order
semantics and the fact that page can be shared only over fork() should be
enough to get it under control. DoubleMap comes with overhead and I would
like to avoid it where possible.

-- 
 Kirill A. Shutemov

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D3EC26B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 16:57:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h14-v6so17029226pfi.19
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 13:57:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e67-v6si20101866plb.272.2018.07.11.13.57.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 13:57:09 -0700 (PDT)
Date: Wed, 11 Jul 2018 13:57:02 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH] mm/hugetlb: remove gigantic page support for HIGHMEM
Message-ID: <20180711205702.d4xeu552xgxjbse3@linux-r8p5>
References: <20180711195913.1294-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20180711195913.1294-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michal Hocko <mhocko@kernel.org>, Cannon Matthews <cannonmatthews@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 11 Jul 2018, Mike Kravetz wrote:

>This reverts commit ee8f248d266e ("hugetlb: add phys addr to struct
>huge_bootmem_page")
>
>At one time powerpc used this field and supporting code. However that
>was removed with commit 79cc38ded1e1 ("powerpc/mm/hugetlb: Add support
>for reserving gigantic huge pages via kernel command line").
>
>There are no users of this field and supporting code, so remove it.

Considering the title, don't you wanna also get rid of try_to_free_low()
and something like the following, which I'm sure can be done fancier, and
perhaps also thp?

diff --git a/fs/Kconfig b/fs/Kconfig
index ac474a61be37..849da70e35d6 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -192,8 +192,8 @@ config TMPFS_XATTR
 
 config HUGETLBFS
        bool "HugeTLB file system support"
-       depends on X86 || IA64 || SPARC64 || (S390 && 64BIT) || \
-                  SYS_SUPPORTS_HUGETLBFS || BROKEN
+       depends on !HIGHMEM && (X86 || IA64 || SPARC64 || (S390 && 64BIT) || \
+                  SYS_SUPPORTS_HUGETLBFS || BROKEN)
        help
          hugetlbfs is a filesystem backing for HugeTLB pages, based on
          ramfs. For architectures that support it, say Y here and read

Thanks,
Davidlohr

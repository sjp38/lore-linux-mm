Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 453DF6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 15:34:48 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id t9-v6so13900040ioa.2
        for <linux-mm@kvack.org>; Tue, 29 May 2018 12:34:48 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id p78-v6si9459102itg.18.2018.05.29.12.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 12:34:46 -0700 (PDT)
Subject: Re: [patch] mm, hugetlb_cgroup: suppress SIGBUS when hugetlb_cgroup
 charge fails
References: <alpine.DEB.2.21.1805251316090.167008@chino.kir.corp.google.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <7cf79250-a58a-b8a3-50ca-5e472762b510@oracle.com>
Date: Tue, 29 May 2018 11:13:06 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1805251316090.167008@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/25/2018 01:16 PM, David Rientjes wrote:
> When charging to a hugetlb_cgroup fails, alloc_huge_page() returns
> ERR_PTR(-ENOSPC) which will cause VM_FAULT_SIGBUS to be returned to the
> page fault handler.
> 
> Instead, return the proper error code, ERR_PTR(-ENOMEM), so VM_FAULT_OOM
> is handled correctly.  This is consistent with failing mem cgroup charges
> in the non-hugetlb fault path.

Apologies for the late reply.

I am not %100 sure we want to make this change.  When hugetlb cgroup support
was added by Aneesh, the intention was for the application to get SIGBUS.

commit 2bc64a204697
https://lwn.net/Articles/499255/

Since the code has always caused SIGBUS when exceeding cgroup limit, there
may be applications depending on this behavior.  I would be especially
concerned with HPC applications which were the original purpose for adding
the feature.

Perhaps, the original code should have returned ENOMEM to be consistent as
in your patch.  That does seem to be the more correct behavior.  But, do we
want to change behavior now (admittedly undocumented) and potentially break
some application?

I echo Michal's question about the reason for the change.  If there is a
real problem or issue to solve, that makes more of a case for making the
change.  If it is simply code/behavior cleanup for consistency then I would
suggest not making the change, but rather documenting this as another
hugetlbfs "special behavior".

As a quick test, I added a shell to a hugetlb cgroup with 2 huge page
limit and started a task using huge pages.

Current behavior
----------------
ssh_to_dbg # sudo ./test_mmap 4
mapping 4 huge pages
address 7f62bba00000 read (-)
address 7f62bbc00000 read (-)
Bus error
ssh_to_dbg #

Behavior with patch
-------------------
ssh_to_dbg # sudo ./test_mmap 4
mapping 4 huge pages
address 7f62bba00000 read (-)
address 7f62bbc00000 read (-)
Connection to dbg closed by remote host.
Connection to dbf closed.

OOM did kick in (lots of console/log output) and killed the shell
as well.
-- 
Mike Kravetz

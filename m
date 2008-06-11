Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5BLNwJE028236
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 17:23:58 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5BLNwtK222196
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 17:23:58 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5BLNvij032765
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 17:23:57 -0400
Subject: Re: [v4][PATCH 2/2] fix large pages in pagemap
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080611135207.32a46267.akpm@linux-foundation.org>
References: <20080611180228.12987026@kernel>
	 <20080611180230.7459973B@kernel>
	 <20080611123724.3a79ea61.akpm@linux-foundation.org>
	 <1213213980.20045.116.camel@calx>
	 <20080611131108.61389481.akpm@linux-foundation.org>
	 <1213216462.20475.36.camel@nimitz>
	 <20080611135207.32a46267.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 11 Jun 2008 14:23:55 -0700
Message-Id: <1213219435.20475.44.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mpm@selenic.com, hans.rosenfeld@amd.com, linux-mm@kvack.org, hugh@veritas.com, riel@redhat.com, nacc <nacc@linux.vnet.ibm.com>, Adam Litke <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-06-11 at 13:52 -0700, Andrew Morton wrote:
> access_process_vm-device-memory-infrastructure.patch is a powerpc
> feature, and it uses pmd_huge().

I think that's bogus.  It probably needs to check the VMA in
generic_access_phys() if it wants to be safe.  I don't see any way that
pmd_huge() can give anything back other than 0 on ppc:

arch/powerpc/mm/hugetlbpage.c:

	int pmd_huge(pmd_t pmd)
	{
	        return 0;
	}

or in include/linux/hugetlb.h:

	#define pmd_huge(x)     0

> Am I missing something, or is pmd_huge() a whopping big grenade for x86
> developers to toss at non-x86 architectures?  It seems quite dangerous.

Yeah, it isn't really usable outside of arch code, although it kinda
looks like it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

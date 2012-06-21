Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 9FB316B00F7
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 16:19:40 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3306446pbb.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 13:19:40 -0700 (PDT)
Date: Thu, 21 Jun 2012 13:19:35 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: Early boot panic on machine with lots of memory
Message-ID: <20120621201935.GC4642@google.com>
References: <1339623535.3321.4.camel@lappy>
 <20120614032005.GC3766@dhcp-172-17-108-109.mtv.corp.google.com>
 <1339667440.3321.7.camel@lappy>
 <20120618223203.GE32733@google.com>
 <1340059850.3416.3.camel@lappy>
 <20120619041154.GA28651@shangw>
 <20120619212059.GJ32733@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120619212059.GJ32733@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello,

Sasha, can you please apply the following patch and verify that the
issue is gone?

Thanks.

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index d23415c..4aa5e5d 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -111,9 +111,6 @@ unsigned long __init free_low_memory_core_early(int nodeid)
 	phys_addr_t start, end;
 	u64 i;
 
-	/* free reserved array temporarily so that it's treated as free area */
-	memblock_free_reserved_regions();
-
 	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL) {
 		unsigned long start_pfn = PFN_UP(start);
 		unsigned long end_pfn = min_t(unsigned long,
@@ -124,8 +121,6 @@ unsigned long __init free_low_memory_core_early(int nodeid)
 		}
 	}
 
-	/* put region array back? */
-	memblock_reserve_reserved_regions();
 	return count;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

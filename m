Subject: Re: [v4][PATCH 2/2] fix large pages in pagemap
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1213219435.20475.44.camel@nimitz>
References: <20080611180228.12987026@kernel>
	 <20080611180230.7459973B@kernel>
	 <20080611123724.3a79ea61.akpm@linux-foundation.org>
	 <1213213980.20045.116.camel@calx>
	 <20080611131108.61389481.akpm@linux-foundation.org>
	 <1213216462.20475.36.camel@nimitz>
	 <20080611135207.32a46267.akpm@linux-foundation.org>
	 <1213219435.20475.44.camel@nimitz>
Content-Type: text/plain
Date: Wed, 11 Jun 2008 17:37:05 -0500
Message-Id: <1213223825.20045.138.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, hans.rosenfeld@amd.com, linux-mm@kvack.org, hugh@veritas.com, riel@redhat.com, nacc <nacc@linux.vnet.ibm.com>, Adam Litke <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-06-11 at 14:23 -0700, Dave Hansen wrote:
> On Wed, 2008-06-11 at 13:52 -0700, Andrew Morton wrote:
> > access_process_vm-device-memory-infrastructure.patch is a powerpc
> > feature, and it uses pmd_huge().
> 
> I think that's bogus.  It probably needs to check the VMA in
> generic_access_phys() if it wants to be safe.  I don't see any way that
> pmd_huge() can give anything back other than 0 on ppc:
> 
> arch/powerpc/mm/hugetlbpage.c:
> 
> 	int pmd_huge(pmd_t pmd)
> 	{
> 	        return 0;
> 	}
> 
> or in include/linux/hugetlb.h:
> 
> 	#define pmd_huge(x)     0
> 
> > Am I missing something, or is pmd_huge() a whopping big grenade for x86
> > developers to toss at non-x86 architectures?  It seems quite dangerous.
> 
> Yeah, it isn't really usable outside of arch code, although it kinda
> looks like it.

That begs the question: if we can't use it reliably outside of arch
code, why do other arches even bother defining it?

And the answer seems to be because of the two uses in mm/memory.c. The
first seems like it could be avoided with an implementation of
follow_huge_addr on x86. The second is either bogus (only works on x86)
or superfluous (not needed at all), no?

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] powerpc: mem_init crash for sparsemem
Date: Fri, 4 Nov 2005 22:59:33 +0100
References: <200511041631.17237.arnd@arndb.de> <436BC20B.9070704@shadowen.org> <20051104205758.GA5397@w-mikek2.ibm.com>
In-Reply-To: <20051104205758.GA5397@w-mikek2.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511042259.33880.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linuxppc64-dev@ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Freedag 04 November 2005 21:57, Mike Kravetz wrote:

> This earlier statement in mem_init (or at least the comment),
> 
> num_physpages = max_pfn;        /* RAM is assumed contiguous */
> 
> may be a cause for concern.  I'm pretty sure max_pfn has previously
> been set based on the value of lmb_end_of_DRAM().  My guess is that we
> are going to report the system as having more memory that it actually
> does (will not account for the hole(s)).

Yes, that's likely to cause trouble later. Unfortunately, there are still
multiple places that determine the memory size by different means
and save the result in a global variable, so it's hard to get them
all right.

I'll probably move Cell to use NUMA mode for setups with multiple CPUs
(each of which is already SMT), which means we can use the code that
we already know handles this correctly, in addtition to the option
of using NUMA aware memory allocation and scheduling for the SPUs.

> That being said, the pfn_valid() check is still needed here.  But,
> it looks like that code was originally written under the assumption
> that there were no holes.
> 
> Can someone 'more in the know' of ppc architecture comment on the
> ram is contiguous assumption?  Is this no longer the case?

For all I know, the firmware interface can legally declare noncontiguous
memory, but that is not done on product level hardware except NUMA.
The configuration for SPARSEMEM without NUMA is normally not possible
on ppc64, I had to hack Kconfig to allow this in the first place.
Without SPARSEMEM, the noncontiguous memory seems to be handled well
except for the size detection.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

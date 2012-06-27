Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id E966D6B005C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 11:47:07 -0400 (EDT)
Date: Wed, 27 Jun 2012 11:39:11 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
Message-ID: <20120627153911.GH17154@phenom.dumpdata.com>
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <4FEA9FDD.6030102@kernel.org>
 <4FEAA4AA.3000406@intel.com>
 <4FEAA7A1.9020307@kernel.org>
 <90bcc2c8-bcac-4620-b3c0-6b65f8d9174d@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <90bcc2c8-bcac-4620-b3c0-6b65f8d9174d@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, Alex Shi <alex.shi@intel.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Wed, Jun 27, 2012 at 08:12:56AM -0700, Dan Magenheimer wrote:
> > From: Minchan Kim [mailto:minchan@kernel.org]
> > Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
> > 
> > Hello,
> > 
> > On 06/27/2012 03:14 PM, Alex Shi wrote:
> > 
> > > On 06/27/2012 01:53 PM, Minchan Kim wrote:
> > >
> > >> On 06/26/2012 01:14 AM, Seth Jennings wrote:
> > >>
> > >>> This patch adds support for a local_tlb_flush_kernel_range()
> > >>> function for the x86 arch.  This function allows for CPU-local
> > >>> TLB flushing, potentially using invlpg for single entry flushing,
> > >>> using an arch independent function name.
> > >>>
> > >>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> > >>
> > >>
> > >> Anyway, we don't matter INVLPG_BREAK_EVEN_PAGES's optimization point is 8 or something.
> > >
> > >
> > > Different CPU type has different balance point on the invlpg replacing
> > > flush all. and some CPU never get benefit from invlpg, So, it's better
> > > to use different value for different CPU, not a fixed
> > > INVLPG_BREAK_EVEN_PAGES.
> > 
> > I think it could be another patch as further step and someone who are
> > very familiar with architecture could do better than.
> > So I hope it could be merged if it doesn't have real big problem.
> > 
> > Thanks for the comment, Alex.
> 
> Just my opinion, but I have to agree with Alex.  Hardcoding
> behavior that is VERY processor-specific is a bad idea.  TLBs should
> only be messed with when absolutely necessary, not for the
> convenience of defending an abstraction that is nice-to-have
> but, in current OS kernel code, unnecessary.

At least put a big fat comment in the patch saying:
"This is based on research done by Alex, where ...


This needs to be redone where it is automatically figured
out based on the CPUID, but ." [include what Dan just
said about breakeven point]


> 
> IIUC, zsmalloc only cares that the breakeven point is greater
> than two.  An arch-specific choice of (A) two page flushes
> vs (B) one all-TLB flush should be all that is necessary right
> now.  (And, per separate discussion, even this isn't really
> necessary either.)
> 
> If zsmalloc _ever_ gets extended to support items that might
> span three or more pages, a more generic TLB flush-pages-vs-flush-all
> approach may be warranted and, by then, may already exist in some
> future kernel.  Until then, IMHO, keep it simple.

Comments are simple :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

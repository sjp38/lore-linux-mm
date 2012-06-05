Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 6D96A6B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 13:26:35 -0400 (EDT)
Date: Tue, 5 Jun 2012 13:17:27 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 04/35] autonuma: define _PAGE_NUMA_PTE and _PAGE_NUMA_PMD
Message-ID: <20120605171727.GA9472@phenom.dumpdata.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-5-git-send-email-aarcange@redhat.com>
 <20120530182247.GA28341@localhost.localdomain>
 <20120530183406.GH21339@redhat.com>
 <20120530200150.GA30148@localhost.localdomain>
 <20120605171354.GJ21339@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120605171354.GJ21339@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Tue, Jun 05, 2012 at 07:13:54PM +0200, Andrea Arcangeli wrote:
> On Wed, May 30, 2012 at 04:01:51PM -0400, Konrad Rzeszutek Wilk wrote:
> > The only time the _PAGE_PSE (_PAGE_PAT) is set is when
> > _PAGE_PCD | _PAGE_PWT are set. It is this ugly transformation
> > of doing:
> > 
> >  if (pat_enabled && _PAGE_PWT | _PAGE_PCD)
> > 	pte = ~(_PAGE_PWT | _PAGE_PCD) | _PAGE_PAT;
> > 
> > and then writting the pte with the 7th bit set instead of the
> > 2nd and 3rd to mark it as WC. There is a corresponding reverse too
> > (to read the pte - so the pte_val calls) - so if _PAGE_PAT is
> > detected it will remove the _PAGE_PAT and return the PTE as
> > if it had _PAGE_PWT | _PAGE_PCD.
> > 
> > So that little bit of code will need some tweaking - as it does
> > that even if _PAGE_PRESENT is not set. Meaning it would
> > transform your _PAGE_PAT to _PAGE_PWT | _PAGE_PCD. Gah!
> 
> It looks like this is disabled in current upstream?
> 8eaffa67b43e99ae581622c5133e20b0f48bcef1

Yup. But it is a temporary bandaid that I hope to fix soon.
> 
> > OK. I can whip up a patch to deal with the 'Gah!' case easily if needed.
> 
> That would help! But again it looks disabled in Xen?
> 
> About linux host (no xen) when I decided to use PSE I checked this part:
> 
> 	/* Set PWT to Write-Combining. All other bits stay the same */
> 	/*
> 	 * PTE encoding used in Linux:
> 	 *      PAT
> 	 *      |PCD
> 	 *      ||PWT
> 	 *      |||
> 	 *      000 WB		_PAGE_CACHE_WB
> 	 *      001 WC		_PAGE_CACHE_WC
> 	 *      010 UC-		_PAGE_CACHE_UC_MINUS
> 	 *      011 UC		_PAGE_CACHE_UC
> 	 * PAT bit unused
> 	 */
> 
> I need to go read the specs pdf and audit the code against the specs
> to be sure but if my interpretation correct, PAT is never set on linux
> host (novirt) the way the relevant msr are programmed.
> 
> If I couldn't use the PSE (/PAT) it'd screw with 32bit because I need
> to poke a bit between _PAGE_BIT_DIRTY and _PAGE_BIT_GLOBAL to avoid
> losing space on the swap entry, and there's just one bit in that range
> (PSE).
> 
> _PAGE_UNUSED1 (besides it's used by Xen) wouldn't work unless I change
> the swp entry format for 32bit x86 reducing the max amount of swap
> (conditional to CONFIG_AUTONUMA so it wouldn't be the end of the
> world, plus the amount of swap on 32bit NUMA may not be so important)

Yeah, I concur. I think stick with _PAGE_PAT (/PSE) and I can cook
up the appropiate patch for it on the Xen side.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

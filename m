Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9E5CI2H017505
	for <linux-mm@kvack.org>; Fri, 14 Oct 2005 01:12:18 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9E5CHFx094088
	for <linux-mm@kvack.org>; Fri, 14 Oct 2005 01:12:17 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9E5CHiw009944
	for <linux-mm@kvack.org>; Fri, 14 Oct 2005 01:12:17 -0400
Subject: Re: [Lhms-devel] Re: [PATCH 5/8] Fragmentation Avoidance V17:
	005_fallback
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <434D47FF.1000602@austin.ibm.com>
References: <20051011151221.16178.67130.sendpatchset@skynet.csn.ul.ie>
	 <20051011151246.16178.40148.sendpatchset@skynet.csn.ul.ie>
	 <20051012164353.GA9425@w-mikek2.ibm.com>
	 <Pine.LNX.4.58.0510121806550.9602@skynet> <434D47FF.1000602@austin.ibm.com>
Content-Type: text/plain
Date: Thu, 13 Oct 2005 22:12:00 -0700
Message-Id: <1129266720.22903.23.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Mike Kravetz <kravetz@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-12 at 12:29 -0500, Joel Schopp wrote:
> > In reality, no and it would only happen if a caller had specified both
> > __GFP_USER and __GFP_KERNRCLM in the call to alloc_pages() or friends. It
> > makes *no* sense for someone to do this, but if they did, an oops would be
> > thrown during an interrupt. The alternative is to get rid of this last
> > element and put a BUG_ON() check before the spinlock is taken.
> > 
> > This way, a stupid caller will damage the fragmentation strategy (which is
> > bad). The alternative, the kernel will call BUG() (which is bad). The
> > question is, which is worse?
> > 
> 
> If in the future we hypothetically have code that damages the fragmentation 
> strategy we want to find it sooner rather than never.  I'd rather some kernels 
> BUG() than we have bugs which go unnoticed.

It isn't a bug.  It's a normal
let-the-stupid-user-shoot-themselves-in-the-foot situation.  Let's
explicitly document the fact that you can't pass both flags, then maybe
add a WARN_ON() or another printk.  Or, we just fail the allocation.  

Failing the allocation seems like the simplest and most effective
solution.  A developer will run into it when they're developing, it
won't be killing off processes or locking things up like a BUG(), and it
doesn't ruin any of the fragmentation strategy.  It also fits with the
current behavior if someone asks the allocator do do something silly
like give them memory from a non-present zone.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

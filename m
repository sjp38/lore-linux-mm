Date: Fri, 4 Apr 2003 19:24:01 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: objrmap and vmtruncate
Message-Id: <20030404192401.03292293.akpm@digeo.com>
In-Reply-To: <20030405024414.GP16293@dualathlon.random>
References: <20030404163154.77f19d9e.akpm@digeo.com>
	<12880000.1049508832@flay>
	<20030405024414.GP16293@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: mbligh@aracnet.com, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>
> Indeed. objrmap is the only way to avoid the big rmap waste. Infact I'm
> not even convinced about the hybrid approch, rmap should be avoided even
> for the anon pages. And the swap cpu doesn't matter, as far as we can
> reach pagteables in linear time that's fine, doesn't matter how many
> fixed cycles it takes. Only the complexity factor matters, and objrmap
> takes care of it just fine.

Well not really.

Consider the case where 100 processes each own 100 vma's against the same
file.

To unmap a page with objrmap we need to search those 10,000 vma's (10000
cachelines).  With full rmap we need to search only 100 pte_chain slots (3 to
33 cachelines).  That's an enormous difference.  It happens for *each* page.

And, worse, we have the same cost when searching for referenced bits in the
pagetables.  Nobody has written an "exploit" for this yet, but it's there.

Possibly we should defer the assembly of the pte chain until a page hits the
tail of the LRU.  That's an awkward time to be allocating memory though.  We
could perhaps fall back to the vma walk if pte_chain allocation starts to
endanger the page reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

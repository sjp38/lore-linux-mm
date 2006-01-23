Date: Mon, 23 Jan 2006 15:19:50 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH/RFC] Shared page tables
Message-ID: <20060123201950.GI1008@kvack.org>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]> <Pine.LNX.4.61.0601202020001.8821@goblin.wat.veritas.com> <6F40FCDC9FFDE7B6ACD294F5@[10.1.1.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6F40FCDC9FFDE7B6ACD294F5@[10.1.1.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 23, 2006 at 11:39:07AM -0600, Dave McCracken wrote:
> The pmd level is important for ppc because it works in segments, which are
> 256M in size and consist of a full pmd page.  The current implementation of
> the way ppc loads its tlb doesn't allow sharing at smaller than segment
> size.  I currently also enable pmd sharing for x86_64, but I'm not sure how
> much of a win it is.  I use it to share pmd pages for hugetlb, as well.

For EM64T at least, pmd sharing is definately worthwhile.  pud sharing is 
a bit more out there, but would still help database workloads.  In the case 
of a thousand connections (which is not unreasonable for some users) you 
save 4MB of memory and reduce the cache footprint of those saved 4MB of 
pages to 4KB.  Ideally the code can be structured to compile out to nothing 
if not needed.

Of course, once we have shared page tables it makes great sense to try to 
get userland to align code segments and data segments to seperate puds so 
that we could share all the page tables for common system libraries amongst 
processes...

		-ben
-- 
"Ladies and gentlemen, I'm sorry to interrupt, but the police are here 
and they've asked us to stop the party."  Don't Email: <dont@kvack.org>.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

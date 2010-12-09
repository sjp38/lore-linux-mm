Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B4E106B008A
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 13:15:06 -0500 (EST)
Date: Thu, 9 Dec 2010 19:13:54 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 44 of 66] skip transhuge pages in ksm for now
Message-ID: <20101209181354.GF19131@random.random>
References: <patchbomb.1288798055@v2.random>
 <91ac2384163d0f01633e.1288798099@v2.random>
 <20101118160613.GZ8135@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118160613.GZ8135@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 04:06:13PM +0000, Mel Gorman wrote:
> On Wed, Nov 03, 2010 at 04:28:19PM +0100, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Skip transhuge pages in ksm for now.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > Reviewed-by: Rik van Riel <riel@redhat.com>
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> 
> This is an idle concern that I haven't looked into but is there any conflict
> between khugepaged scanning the KSM scanning?
> 
> Specifically, I *think* the impact of this patch is that KSM will not
> accidentally split a huge page. Is that right? If so, it could do with
> being included in the changelog.

KSM wasn't aware about hugepages and in turn it'd never split them
anyway. We want KSM to split hugepages only when if finds two equal
subpages. That will happen later.

Right now there is no collision of ksmd and khugepaged, regular pages,
hugepages and ksm pages will co-exist fine in the same vma. The only
problem is that the system has now to start swapping before KSM has a
chance to find equal pages and we'll fix it in the future so KSM can
scan inside hugepages too and split them and merge the subpages as
needed before the memory pressure starts.

> On the other hand, can khugepaged be prevented from promoting a hugepage
> because of KSM?

Sure, khugepaged won't promote if there's any ksm page in the
range. That's not going to change. When KSM is started, the priority
remains in saving memory. If people uses enabled=madvise and
MADV_HUGEPAGE+MADV_MERGEABLE there is actually zero memory loss
because of THP and there is a speed improvement for all pages that
aren't equal. So it's an ideal setup even for embedded. Regular cloud
setup would be enabled=always + MADV_MERGEABLE (with enabled=always
MADV_HUGEPAGE becomes a noop).

On a related note I'm also going to introduce a MADV_NO_HUGEPAGE, is
that a good name for it? cloud management wants to be able to disable
THP per-VM basis (when the VM are totally idle, and low priority, this
currently also helps to maximize the power of KSM that would otherwise
be activated only after initial sawpping, but the KSM part will be
fixed). It could be achieved also with enabled=madvise and
MADV_HUGEPAGE but we don't want to change the system wide default in
order to disable THP on a per-VM basis: it's much nicer if the default
behavior of the host remains the same in case it's not a pure
hypervisor usage but there are other loads running in parallel to the
virt load. In theory a prctl(PR_NO_HUGEPAGE) could also do it and it'd
be possible to use from a wrapper (madvise can't be wrapped), but I
think MADV_NO_HUGEPAGE is cleaner and it won't require brand new
per-process info.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

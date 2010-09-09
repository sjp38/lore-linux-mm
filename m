Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 38BF06B008C
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 19:41:06 -0400 (EDT)
Date: Fri, 10 Sep 2010 01:40:08 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Transparent Hugepage Support #30
Message-ID: <20100909234008.GS8925@random.random>
References: <20100901190859.GA20316@random.random>
 <20100909104630.GO4443@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100909104630.GO4443@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

Hello,

On Thu, Sep 09, 2010 at 04:16:30PM +0530, Balbir Singh wrote:
> * Andrea Arcangeli <aarcange@redhat.com> [2010-09-01 21:08:59]:
> > btw, memcg developers could already support THP inside memcg even if
> > THP is not included yet without any sort of problem, so it's also
> 
> Could you elaborate by what you mean here?

Ok, what I mean is that you could already stop assuming the "page"
passed as parameter to memcg is PAGE_SIZE in size. It would still work
fine. The check should later be done with PageTransCompound as that
will be optimized away at compile time when
CONFIG_TRANSPARENT_HUGEPAGE=n. But in the meantime PageCompund shall
work fine.

One nasty detail to pay attention to later (which isn't possible to
implement until compound_lock is defined), is that at times we may
also need to take the compound_lock to avoid the size of the page to
change from under us (it should only be needed if PageTransCompound
returns true so it won't affect the regular paths and it won't be
built if THP is off at compile time). The collapsing takes the
mmap_sem write mode which normally won't risk to run in parallel,
furthermore the collapsing isn't done in place so it's unlikely to
give issues. So only the transition from transcompound to regular
page, is likely to require special care.

> We try not to change too drastically, but several of the current
> changes are fixes, we are currently contemplating some more changes to
> support the I/O control. Some of the recent changes have been driven
> by tracing. We will pay closer attention to THP changes, thanks for
> bring your concern to our notice.

Thanks a lot. I can already start looking more closely into the memcg
of current upstream myself, if this is a good time and there are no
more big changes planned or already queued in some git tree waiting to
be pulled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

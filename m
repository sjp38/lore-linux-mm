Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 554EE6B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 19:48:09 -0500 (EST)
Date: Tue, 30 Nov 2010 09:38:04 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 53 of 66] add numa awareness to hugepage allocations
Message-Id: <20101130093804.23f8c355.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101129161103.GE24474@random.random>
References: <patchbomb.1288798055@v2.random>
	<223ee926614158fc1353.1288798108@v2.random>
	<20101129143801.abef5228.nishimura@mxp.nes.nec.co.jp>
	<20101129161103.GE24474@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Nov 2010 17:11:03 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Mon, Nov 29, 2010 at 02:38:01PM +0900, Daisuke Nishimura wrote:
> > I think this should be:
> > 
> > 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
> > #ifdef CONFIG_NUMA
> > 		put_page(new_page);
> > #endif
> > 		goto out;
> > 	}
> 
> Hmm no, the change you suggest would generate memory corruption with
> use after free.

I'm sorry if I miss something, "new_page" will be reused in !CONFIG_NUMA case
as you say, but, in CONFIG_NUMA case, it is allocated in this function
(collapse_huge_page()) by alloc_hugepage_vma(), and is not freed when memcg's
charge failed.
Actually, we do in collapse_huge_page():
	if (unlikely(!isolated)) {
		...
#ifdef CONFIG_NUMA
		put_page(new_page);
#endif
		goto out;
	}
later. I think we need a similar logic in memcg's failure path too.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 27 Feb 2008 12:57:29 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 04/15] memcg: when do_swap's do_wp_page fails
In-Reply-To: <20080227050854.GA2317@balbir.in.ibm.com>
Message-ID: <Pine.LNX.4.64.0802271243500.8683@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
 <Pine.LNX.4.64.0802252337110.27067@blonde.site> <20080227050854.GA2317@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2008, Balbir Singh wrote:
> * Hugh Dickins <hugh@veritas.com> [2008-02-25 23:38:02]:
> > Don't uncharge when do_swap_page's call to do_wp_page fails: the page which
> > was charged for is there in the pagetable, and will be correctly uncharged
> > when that area is unmapped - it was only its COWing which failed.
> 
> Looks good to me. Do you think we could add some of the description
> from above as a comment in the code? People would not have to look at
> the git log to understand why we did not uncharge.

Sorry to be uncooperative, but I honestly think not.  If we put in
a comment everywhere somebody once made a mistake (a temptation at
the time indeed), or everywhere we remove some unnecessary code,
the kernel source will not become more readable.  We don't have (and
don't need) a comment there for why there isn't a page_cache_release.

If any comment were needed (but its repetition would become tedious,
I'm happier without it), it's on the mem_cgroup_charges, pointing out
that it's a speculative charge while we're still allowed to sleep for
memory, which the subsequent add_rmap will either preserve or reverse
according to whether this is the first mapping of the page or not.

You know that, and the matching page_add_anon_rmap has clearly been
done above this write_access call to do_wp_page, so the mystery would
be why we should mem_cgroup_uncharge_page there.  If do_wp_page were
an unmapping operation, which for some reason didn't uncharge what
it unmapped, then a mem_cgroup_uncharge_page with comment would be
appropriate.  But that's not the case.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

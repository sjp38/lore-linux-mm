Date: Mon, 6 Aug 2007 12:15:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Apply memory policies to top two highest zones when
 highest zone is ZONE_MOVABLE
Message-Id: <20070806121558.e1977ba5.akpm@linux-foundation.org>
In-Reply-To: <200708040002.18167.ak@suse.de>
References: <20070802172118.GD23133@skynet.ie>
	<200708040002.18167.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 4 Aug 2007 00:02:17 +0200 Andi Kleen <ak@suse.de> wrote:

> On Thursday 02 August 2007 19:21:18 Mel Gorman wrote:
> > The NUMA layer only supports NUMA policies for the highest zone. When
> > ZONE_MOVABLE is configured with kernelcore=, the the highest zone becomes
> > ZONE_MOVABLE. The result is that policies are only applied to allocations
> > like anonymous pages and page cache allocated from ZONE_MOVABLE when the
> > zone is used.
> > 
> > This patch applies policies to the two highest zones when the highest zone
> > is ZONE_MOVABLE. As ZONE_MOVABLE consists of pages from the highest "real"
> > zone, it's always functionally equivalent.
> > 
> > The patch has been tested on a variety of machines both NUMA and non-NUMA
> > covering x86, x86_64 and ppc64. No abnormal results were seen in kernbench,
> > tbench, dbench or hackbench. It passes regression tests from the numactl
> > package with and without kernelcore= once numactl tests are patched to
> > wait for vmstat counters to update.
>  
> I must honestly say I really hate the patch. It's a horrible hack and makes fast paths
> slower. When I designed mempolicies I especially tried to avoid things
> like that, please don't add them through the backdoor now.
> 

We don't want to be adding horrible hacks and slowness to the core of
__alloc_pages().

So where do we stand on this?  We made a mess of NUMA policies, and merging
"grouping pages by mobility" would fix that mess, only we're not sure that
we want to merge those and it's too late for 2.6.23 anwyay?

If correct, I would suggest merging the horrible hack for .23 then taking
it out when we merge "grouping pages by mobility".  But what if we don't do
that merge?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

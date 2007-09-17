Date: Mon, 17 Sep 2007 20:51:05 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH mm] fix swapoff breakage; however...
In-Reply-To: <46EED1A7.5080606@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0709172038090.25512@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0709171947130.15413@blonde.wat.veritas.com>
 <46EED1A7.5080606@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, Balbir Singh wrote:
> Hugh Dickins wrote:
> > More fundamentally, it looks like any container brought over its limit in
> > unuse_pte will abort swapoff: that doesn't doesn't seem "contained" to me.
> > Maybe unuse_pte should just let containers go over their limits without
> > error?  Or swap should be counted along with RSS?  Needs reconsideration.
> 
> Thanks, for the catching this. There are three possible solutions
> 
> 1. Account each RSS page with a probable swap cache page, double
>    the RSS accounting to ensure that swapoff will not fail.
> 2. Account for the RSS page just once, do not account swap cache
>    pages

Neither of those makes sense to me, but I may be misunderstanding.

What would make sense is (what I meant when I said swap counted
along with RSS) not to count pages out and back in as they are
go out to swap and back in, just keep count of instantiated pages

I say "make sense" meaning that the numbers could be properly
accounted; but it may well be unpalatable to treat fast RAM as
equal to slow swap.

> 3. Follow your suggestion and let containers go over their limits
>    without error
> 
> With the current approach, a container over it's limit will not
> be able to call swapoff successfully, is that bad?

That's not so bad.  What's bad is that anyone else with the
CAP_SYS_ADMIN to swapoff is liable to be prevented by containers
going over their limits.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

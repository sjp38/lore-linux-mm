Date: Fri, 16 Mar 2007 21:35:45 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: ZERO_PAGE refcounting causes cache line bouncing
Message-ID: <20070317043545.GH8915@holomorphy.com>
References: <Pine.LNX.4.64.0703161514170.7846@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703161514170.7846@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 16, 2007 at 03:17:39PM -0700, Christoph Lameter wrote:
> We have issues with ZERO_PAGE refcounting causing severe cacheline 
> bouncing. ZERO_PAGES are mapped into multiple processes running on 
> multiple nodes. Refcounter modifications therefore have to acquire a 
> remote exclusive cacheline.
> Could we somehow fix this? There are a couple of ways to do this:
> 1. No refcounting on reserved pages in the VM. ZERO_PAGEs are
>    reserved and there is no point in refcounting them since they
>    will not go away.
> 2. Having a percpu or pernode ZERO_PAGE?
>    May be a simpler solution but then we still may have issues
>    if the ZERO_PAGE gets "freed" from other processors/ nodes.

It's dumb to refcount the zero page. Someone should've noticed this
when the PG_reserved patches went in. I can't think of an easy way
around this apart from a backout. OTOH it's a simple matter of
programming to arrange for it without a backout.

Provisions should be made for per-node zero pages in addition to this.
AFAICT the primary thing needed is to wrap checks for a page being a
zero page with some testing function instead of using a raw equality
check. This is above and beyond solving the mere zero page refcount
problem; I'm saying that both proposals should be done even though only
one is needed to resolve the bouncing issue.

I guess this is an "ack of the concept" of sorts. None of this is so
involved that I should jump on it and try to get a patch out ahead of
you.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

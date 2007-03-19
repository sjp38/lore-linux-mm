Message-ID: <45FE261F.3030903@yahoo.com.au>
Date: Mon, 19 Mar 2007 16:56:47 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: ZERO_PAGE refcounting causes cache line bouncing
References: <Pine.LNX.4.64.0703161514170.7846@schroedinger.engr.sgi.com> <20070317043545.GH8915@holomorphy.com>
In-Reply-To: <20070317043545.GH8915@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> On Fri, Mar 16, 2007 at 03:17:39PM -0700, Christoph Lameter wrote:
> 
>>We have issues with ZERO_PAGE refcounting causing severe cacheline 
>>bouncing. ZERO_PAGES are mapped into multiple processes running on 
>>multiple nodes. Refcounter modifications therefore have to acquire a 
>>remote exclusive cacheline.
>>Could we somehow fix this? There are a couple of ways to do this:
>>1. No refcounting on reserved pages in the VM. ZERO_PAGEs are
>>   reserved and there is no point in refcounting them since they
>>   will not go away.
>>2. Having a percpu or pernode ZERO_PAGE?
>>   May be a simpler solution but then we still may have issues
>>   if the ZERO_PAGE gets "freed" from other processors/ nodes.
> 
> 
> It's dumb to refcount the zero page. Someone should've noticed this
> when the PG_reserved patches went in.

The patch author did notice ;)

http://groups.google.com/group/fa.linux.kernel/msg/48108a5faa20a667?hl=en&

But was subsequently told that special casing the ZERO_PAGE was stupid
(as if it isn't a special object in the VM), and so it was removed (and
a warning added to the changelog)

http://lwn.net/Articles/155280/

I also subsequently submitted a standalone patch to reintroduce it after
the core patch was merged, but again was rejected (can't find the link for
that one, off hand).


> I can't think of an easy way
> around this apart from a backout. OTOH it's a simple matter of
> programming to arrange for it without a backout.

Yes, I have the patch to do it quite easily. Per-node ZERO_PAGE could be
another option, but that's going to cost another page flag if we wish to
recognise the zero page in wp faults like we do now (hmm, for some reason
it is OK to special case it _there_).


> Provisions should be made for per-node zero pages in addition to this.
> AFAICT the primary thing needed is to wrap checks for a page being a
> zero page with some testing function instead of using a raw equality
> check. This is above and beyond solving the mere zero page refcount
> problem; I'm saying that both proposals should be done even though only
> one is needed to resolve the bouncing issue.

I've always thought the bouncing issue was a silly one and should be
fixed, of course. Maybe the reason my fix was vetoed was lack of numbers.
Christoph, would you oblige? I'll dig out the patch and repost.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

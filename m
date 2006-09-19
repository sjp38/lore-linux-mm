Message-ID: <45101806.4070900@yahoo.com.au>
Date: Wed, 20 Sep 2006 02:17:10 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Get rid of zone_table V2
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>	<20060918132818.603196e2.akpm@osdl.org>	<Pine.LNX.4.64.0609181544420.29365@schroedinger.engr.sgi.com>	<20060918161528.9714c30c.akpm@osdl.org>	<Pine.LNX.4.64.0609181642210.30206@schroedinger.engr.sgi.com>	<20060918165808.c410d1d4.akpm@osdl.org>	<Pine.LNX.4.64.0609181711210.30365@schroedinger.engr.sgi.com>	<20060918173134.d3850903.akpm@osdl.org>	<Pine.LNX.4.64.0609182309050.3152@schroedinger.engr.sgi.com>	<20060918233337.ef539a2b.akpm@osdl.org>	<Pine.LNX.4.64.0609190709190.4787@schroedinger.engr.sgi.com> <20060919083851.75b26075.akpm@osdl.org>
In-Reply-To: <20060919083851.75b26075.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 19 Sep 2006 07:10:18 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:

>>Yeah but we have added so much stuff in between that such a thing is 
>>highly unlikely. Even with padding we could increase the size of zone to 
>>the next power of two.
> 
> 
> unlikely != impossible.  If some distro were to send the "unlikely" to
> zillions of users, that would be sad.

I suspect if nobody else, then the ScaleMP guys would be sad about
this. But as you say, it is probably even worse that anybody might
suddenly get suboptimal behaviour depending on the phase of the moon.

> 
> I suspect what we want in there is to make the buddy-allocator's fields
> land in a separate cacheline from the vm-scanner's fields.  I don't think
> the code has been reviewed for correctness wrt that for quite some time.
> 
> If there's some smarter way of doing the padding then cool.

I probably touched this padding stuff last, and indeed I tried to break
it into allocator / scanner / readmostly. There is quite a bit of
readmostly stuff in the allocator area (pages_* x 3, lowmem_reserve,
and the 2 CONFIG_NUMA fields), but it is generally accessed around the
same time as the other fields (lock and free_pages), so it might be
best to keep them together.

vm_stat may not be in the right place. I'd say put it up in the
allocator section, because quite a few stats happen there and
allocation is more performance critical than reclaim.

> Of course, it might be that we _want_ both things in the same cacheline:
> the page scanner often frees pages (we hope ;)).  And it'll usually be the
> case that a page-allocator immediately goes and adds the page to the LRU. 
> ANd ditto for a page-freer.

That's very true. There is some element of work batching though
(buddy allocation and freeing happening in batches, lru adding and
reclaim freeing happening in pagevec chunks).

So you'd still rather their cachelines don't overlap I suspect. Of
course, I can't imagine it will be easy to benchmark (other than on
ScaleMP systems, maybe).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

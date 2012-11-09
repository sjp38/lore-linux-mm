Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 57BA16B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 04:04:50 -0500 (EST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 9 Nov 2012 19:01:33 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA98sCsO62783502
	for <linux-mm@kvack.org>; Fri, 9 Nov 2012 19:54:12 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA994aZ1022330
	for <linux-mm@kvack.org>; Fri, 9 Nov 2012 20:04:37 +1100
Message-ID: <509CC6D2.6090700@linux.vnet.ibm.com>
Date: Fri, 09 Nov 2012 14:33:14 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 6/8] mm: Demarcate and maintain pageblocks in region-order
 in the zones' freelists
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121106195342.6941.94892.stgit@srivatsabhat.in.ibm.com> <CAKD8Uxd=BguLj=4VvRRfKBDdqrz+p_6Sj6JF2UNEjLd-HNmHMw@mail.gmail.com>
In-Reply-To: <CAKD8Uxd=BguLj=4VvRRfKBDdqrz+p_6Sj6JF2UNEjLd-HNmHMw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ankita Garg <gargankita@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, andi@firstfloor.org

Hi Ankita,

On 11/09/2012 11:31 AM, Ankita Garg wrote:
> Hi Srivatsa,
> 
> I understand that you are maintaining the page blocks in region sorted
> order. So that way, when the memory requests come in, you can hand out
> memory from the regions in that order.

Yes, that's right.

> However, do you take this
> scenario into account - in some bucket of the buddy allocator, there
> might not be any pages belonging to, lets say, region 0, while the next
> higher bucket has them. So, instead of handing out memory from whichever
> region thats present there, to probably go to the next bucket and split
> that region 0 pageblock there and allocate from it ? (Here, region 0 is
> just an example). Been a while since I looked at kernel code, so I might
> be missing something!
> 

This patchset doesn't attempt to do that because that can hurt the fast
path performance of page allocation (ie., because we could end up trying
to split pageblocks even when we already have pageblocks of the required
order ready at hand... and not to mention the searching involved in finding
out whether any higher order free lists really contain pageblocks belonging
to this region 0). In this patchset, I have consciously tried to keep the
overhead from memory regions as low as possible, and have moved most of
the overhead to the page free path.

But the scenario that you brought out is very relevant, because that would
help achieve more aggressive power-savings. I will try to implement
something to that end with least overhead in the next version and measure
whether its cost vs benefit really works out or not. Thank you very much
for pointing it out!

Regards,
Srivatsa S. Bhat

> 
> 
> On Tue, Nov 6, 2012 at 1:53 PM, Srivatsa S. Bhat
> <srivatsa.bhat@linux.vnet.ibm.com
> <mailto:srivatsa.bhat@linux.vnet.ibm.com>> wrote:
> 
>     The zones' freelists need to be made region-aware, in order to influence
>     page allocation and freeing algorithms. So in every free list in the
>     zone, we
>     would like to demarcate the pageblocks belonging to different memory
>     regions
>     (we can do this using a set of pointers, and thus avoid splitting up the
>     freelists).
> 
>     Also, we would like to keep the pageblocks in the freelists sorted in
>     region-order. That is, pageblocks belonging to region-0 would come
>     first,
>     followed by pageblocks belonging to region-1 and so on, within a given
>     freelist. Of course, a set of pageblocks belonging to the same
>     region need
>     not be sorted; it is sufficient if we maintain the pageblocks in
>     region-sorted-order, rather than a full address-sorted-order.
> 
>     For each freelist within the zone, we maintain a set of pointers to
>     pageblocks belonging to the various memory regions in that zone.
> 
>     Eg:
> 
>         |<---Region0--->|   |<---Region1--->|   |<-------Region2--------->|
>          ____      ____      ____      ____      ____      ____      ____
>     --> |____|--> |____|--> |____|--> |____|--> |____|--> |____|-->
>     |____|-->
> 
>                      ^                  ^                              ^
>                      |                  |                              |
>                     Reg0               Reg1                          Reg2
> 
> 
>     Page allocation will proceed as usual - pick the first item on the
>     free list.
>     But we don't want to keep updating these region pointers every time
>     we allocate
>     a pageblock from the freelist. So, instead of pointing to the
>     *first* pageblock
>     of that region, we maintain the region pointers such that they point
>     to the
>     *last* pageblock in that region, as shown in the figure above. That
>     way, as
>     long as there are > 1 pageblocks in that region in that freelist,
>     that region
>     pointer doesn't need to be updated.
> 
> 
>     Page allocation algorithm:
>     -------------------------
> 
>     The heart of the page allocation algorithm remains it is - pick the
>     first
>     item on the appropriate freelist and return it.
> 
> 
>     Pageblock order in the zone freelists:
>     -------------------------------------
> 
>     This is the main change - we keep the pageblocks in region-sorted order,
>     where pageblocks belonging to region-0 come first, followed by those
>     belonging
>     to region-1 and so on. But the pageblocks within a given region need
>     *not* be
>     sorted, since we need them to be only region-sorted and not fully
>     address-sorted.
> 
>     This sorting is performed when adding pages back to the freelists, thus
>     avoiding any region-related overhead in the critical page allocation
>     paths.
> 
>     Page reclaim [Todo]:
>     --------------------
> 
>     Page allocation happens in the order of increasing region number. We
>     would
>     like to do page reclaim in the reverse order, to keep allocated
>     pages within
>     a minimal number of regions (approximately).
> 
>     ---------------------------- Increasing region
>     number---------------------->
> 
>     Direction of allocation--->                         <---Direction of
>     reclaim
> 
>     Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

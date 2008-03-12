From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] Move memory controller allocations to their own slabs (v2)
Date: Wed, 12 Mar 2008 14:38:01 +1100
References: <20080311061836.6664.5072.sendpatchset@localhost.localdomain> <47D66865.1080508@linux.vnet.ibm.com> <Pine.LNX.4.64.0803111256110.18261@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0803111256110.18261@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803121438.02857.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 12 March 2008 00:05, Hugh Dickins wrote:
> On Tue, 11 Mar 2008, Balbir Singh wrote:
> > On my 64 bit powerpc system (structure size could be different on other
> > systems)
> >
> > 1. sizeof page_cgroup is 40 bytes
> >    which means kmalloc will allocate 64 bytes
> > 2. With 4K pagesize SLAB with HWCACHE_ALIGN, 59 objects are packed per
> > slab 3. With SLUB the value is 102 per slab
>
> I expect you got those numbers with 2.6.25-rc4?  Towards the end of -rc5
> there's a patch from Nick to make SLUB's treatment of HWCACHE_ALIGN the
> same as SLAB's, so I expect you'd be back to a similar poor density with
> SLUB too.  (But I'm replying without actually testing it out myself.)

Yes, that will be the case.

With a 64 byte cacheline size, 

page_cgroup: |----|----|----|----|----|----|----|----
cacheline:   |-------|-------|-------|-------|-------

So if you are accessing each field in a random page_cgroup, then it
will statistically cost you 1.5 cachelines (really: half the time, it
takes 2 cachelines).

If you HWCACHE_ALIGN this, it will cost you just 1 line.

Long live the size/speed tradeoff ;)

Whether this improvement is actually noticable is a different matter.


> I think you'd need a strong reason to choose HWCACHE_ALIGN for these.
>
> Consider: the (normal configuration) x86_64 struct page size was 56
> bytes for a long time (and still is without MEM_RES_CTLR), but we've
> never inserted padding to make that a round 64 bytes (and they would
> benefit additionally from some simpler arithmetic, not the case with
> page_cgroups).

I actually still think padding struct page will be a good idea. And
hopefully we can get rid of the page_cgroups pointer out of struct
page in order that we can have both config cases padded to 64 bytes
and use the extra space for larger refcounters maybe ;)

I simply haven't tried to run a realistic workload where it would
matter a great deal. I have a feeling that the oltp workloads could
see some improvement, because they're mainly just using the kernel
for direct IO, struct page is one of the few data structures that
they actually spend any cache on.


> Though it's good to avoid unnecessary sharing and 
> multiple cacheline accesses, it's not so good as to justify almost
> doubling the size of a very very common structure.  I think.

Anyway, back on topic from my rant, yes I agree with Hugh: I think
there should be some demonstration of a speedup (even in a "best
case" situation), before spending more bytes on a common data
structure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

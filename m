Date: Wed, 10 Sep 2008 20:27:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Approach #2] [RFC][PATCH] Remove cgroup member from struct
 page
Message-Id: <20080910202744.0cc27be5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200809110702.45003.nickpiggin@yahoo.com.au>
References: <48C66AF8.5070505@linux.vnet.ibm.com>
	<200809110644.39334.nickpiggin@yahoo.com.au>
	<20080910200304.fd078007.kamezawa.hiroyu@jp.fujitsu.com>
	<200809110702.45003.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Sep 2008 07:02:44 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> On Wednesday 10 September 2008 21:03, KAMEZAWA Hiroyuki wrote:
> > On Thu, 11 Sep 2008 06:44:37 +1000
> >
> > Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > > On Wednesday 10 September 2008 11:49, KAMEZAWA Hiroyuki wrote:
> > > > On Tue, 9 Sep 2008 18:20:48 -0700
> > > >
> > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-09-09
> > > > > 21:30:12]: OK, here is approach #2, it works for me and gives me
> > > > > really good performance (surpassing even the current memory
> > > > > controller). I am seeing almost a 7% increase
> > > >
> > > > This number is from pre-allcation, maybe.
> > > > We really do alloc-at-boot all page_cgroup ? This seems a big change.
> > >
> > > It seems really nice to me -- we get the best of both worlds, less
> > > overhead for those who don't enable the memory controller, and even
> > > better performance for those who do.
> >
> > No trobles for me for allocating-all-at-boot policy.
> > My small concern is
> >   - wasting page_cgroup for hugepage area.
> >   - memory hotplug
> 
> In those cases you still waste the struct page area too. I realise that
> isn't a good way to justify even more wastage. But I guess it is
> relatively low. At least, I would think the users would be more happy to
> get a 7% performance increase for small pages! :)
> 
I guess the increase mostly because we can completely avoid kmalloc/kfree slow path.

Balbir, how about fix our way to allocate-all-at-boot-policy ?
If you say yes, I think I can help you and I'll find usable part from my garbage.

Following is lockless+remove-page-cgroup-pointer-from-page-struct patch's result.

rc5-mm1
==
Execl Throughput                           3006.5 lps   (29.8 secs, 3 samples)
C Compiler Throughput                      1006.7 lpm   (60.0 secs, 3 samples)
Shell Scripts (1 concurrent)               4863.7 lpm   (60.0 secs, 3 samples)
Shell Scripts (8 concurrent)                943.7 lpm   (60.0 secs, 3 samples)
Shell Scripts (16 concurrent)               482.7 lpm   (60.0 secs, 3 samples)
Dc: sqrt(2) to 99 decimal places         124804.9 lpm   (30.0 secs, 3 samples)

lockless
==
Execl Throughput                           3035.5 lps   (29.6 secs, 3 samples)
C Compiler Throughput                      1010.3 lpm   (60.0 secs, 3 samples)
Shell Scripts (1 concurrent)               4881.0 lpm   (60.0 secs, 3 samples)
Shell Scripts (8 concurrent)                947.7 lpm   (60.0 secs, 3 samples)
Shell Scripts (16 concurrent)               485.0 lpm   (60.0 secs, 3 samples)
Dc: sqrt(2) to 99 decimal places         125437.9 lpm   (30.0 secs, 3 samples)

lockless + remove page cgroup pointer (my version).
==
Execl Throughput                           3021.1 lps   (29.5 secs, 3 samples)
C Compiler Throughput                       980.3 lpm   (60.0 secs, 3 samples)
Shell Scripts (1 concurrent)               4600.0 lpm   (60.0 secs, 3 samples)
Shell Scripts (8 concurrent)                915.7 lpm   (60.0 secs, 3 samples)
Shell Scripts (16 concurrent)               468.3 lpm   (60.0 secs, 3 samples)
Dc: sqrt(2) to 99 decimal places         124909.1 lpm   (30.0 secs, 3 samples)

Oh,yes. siginificant slow down. I'm glad to kick this patch out to trash box.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

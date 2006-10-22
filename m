From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [patch 2/2] htlb forget rss with pt sharing
Date: Sun, 22 Oct 2006 14:28:37 -0700
Message-ID: <000001c6f621$0a3afef0$8085030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <1161446321.5230.69.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Peter Zijlstra' <a.p.zijlstra@chello.nl>
Cc: 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org, arjan <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote on Saturday, October 21, 2006 8:59 AM
> On Thu, 2006-10-19 at 12:12 -0700, Chen, Kenneth W wrote:
> > Imprecise RSS accounting is an irritating ill effect with pt sharing. 
> > After consulted with several VM experts, I have tried various methods to
> > solve that problem: (1) iterate through all mm_structs that share the PT
> > and increment count; (2) keep RSS count in page table structure and then
> > sum them up at reporting time.  None of the above methods yield any
> > satisfactory implementation.
> > 
> > Since process RSS accounting is pure information only, I propose we don't
> > count them at all for hugetlb page. rlimit has such field, though there is
> > absolutely no enforcement on limiting that resource.  One other method is
> > to account all RSS at hugetlb mmap time regardless they are faulted or not.
> > I opt for the simplicity of no accounting at all.
> 
> I do feel I must object to this. Especially with hugetlb getting real
> accessible with libhugetlbfs etc., I suspect administrators will shortly
> be confused where all their memory went.

We have /proc/<pid>/smap.  That should have all the information there.  It
reminds me though that smap needs fix on hugetlb area as it prints nothing
for hugetlb vma at the moment.  I will fix that.


> Also, like stated earlier, I don't like breaking RSS accounting now, and
> when we do have thought up a valid meaning for the field, again. You
> state correctly that RLIMIT_RSS is currently not enforced, but its an
> active area int that we do want to enforce it in the near future.
> 
> I do grant its a very hard problem, comming up with a
> valid/meaningfull/workable definition of RSS, but I dislike this opt out
> of just not counting it at all - and thereby making the effort of
> enforcing RSS harder.

Hugetlb page are special, they are reserved up front in global reservation
pool and is not reclaimable.  From physical memory resource point of view,
it is already consumed regardless whether there are users using them.

If the concern is that RSS can be used to control resource allocation, we
already can specify hugetlb fs size limit and sysadmin can enforce that at
mount time.  Combined with the two points mentioned above, I fail to see
if there is anything got affected because of this patch.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

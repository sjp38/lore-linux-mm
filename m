Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 37E7D6B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 01:05:20 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id 11so142387335qkl.4
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 22:05:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u3si11241607qkc.216.2017.01.30.22.05.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 22:05:19 -0800 (PST)
Date: Tue, 31 Jan 2017 01:05:12 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC V2 08/12] mm: Add new VMA flag VM_CDM
Message-ID: <20170131060509.GA2017@redhat.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-9-khandual@linux.vnet.ibm.com>
 <20170130185213.GA7198@redhat.com>
 <28bd4abc-3cbd-514e-1535-15ce67131772@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28bd4abc-3cbd-514e-1535-15ce67131772@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Tue, Jan 31, 2017 at 09:52:20AM +0530, Anshuman Khandual wrote:
> On 01/31/2017 12:22 AM, Jerome Glisse wrote:
> > On Mon, Jan 30, 2017 at 09:05:49AM +0530, Anshuman Khandual wrote:
> >> VMA which contains CDM memory pages should be marked with new VM_CDM flag.
> >> These VMAs need to be identified in various core kernel paths for special
> >> handling and this flag will help in their identification.
> >>
> >> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> > 
> > 
> > Why doing this on vma basis ? Why not special casing all those path on page
> > basis ?
> 
> The primary motivation being the cost. Wont it be too expensive to account
> for and act on individual pages rather than on the VMA as a whole ? For
> example page_to_nid() seemed pretty expensive when tried to tag VMA on
> individual page fault basis.

No i don't think it would be too expensive. What is confusing in this patchset
is that you are conflating 3 different problems. First one is how to create
struct page for coherent device memory and exclude those pages from regular
allocations.

Second one is how to allow userspace to set allocation policy that would direct
allocation for a given vma to use a specific device memory.

Finaly last one is how to block some kernel feature such as numa or ksm as you
expect (and i share that believe) that they will be hurtfull.

I do believe, that this last requirement, is better left to be done on a per page
basis as page_to_nid() is only a memory lookup and i would be stun if that memory
lookup register as more than a blip on any profiler radar.

The vma flag as all or nothing choice is bad in my view and its stickyness and how
to handle its lifetime and inheritance is troubling and hard. Checking through node
if a page should undergo ksm or numa is a better solution in my view.

> 
> > 
> > After all you can have a big vma with some pages in it being cdm and other
> > being regular page. The CPU process might migrate to different CPU in a
> > different node and you might still want to have the regular page to migrate
> > to this new node and keep the cdm page while the device is still working
> > on them.
> 
> Right, that is the ideal thing to do. But wont it be better to split the
> big VMA into smaller chunks and tag them appropriately so that those VMAs
> tagged would contain as much CDM pages as possible for them to be likely
> restricted from auto NUMA, KSM etc.

Think a vma in which every odd 4k address point to a device page is device and
even 4k address point to a regular page, would you want to create as many vma
for this ?

Setting policy for allocation make sense, but setting flag that enable/disable
kernel feature for a range, overridding other policy is bad in my view.

> 
> > 
> > This is just an example, same can apply for ksm or any other kernel feature
> > you want to special case. Maybe we can store a set of flag in node that
> > tells what is allowed for page in node (ksm, hugetlb, migrate, numa, ...).
> > 
> > This would be more flexible and the policy choice can be left to each of
> > the device driver.
> 
> Hmm, thats another way of doing the special cases. The other way as Dave
> had mentioned before is to classify coherent memory property into various
> kinds and store them for each node and implement a predefined set of
> restrictions for each kind of coherent memory which might include features
> like auto NUMA, HugeTLB, KSM etc. Maintaining two different property sets
> one for the kind of coherent memory and the other being for each special
> cases) wont be too complicated ?

I am not sure i follow, you have a single mask provided by the driver that
register the memory something like:

CDM_ALLOW_NUMA (1 << 0)
CDM_ALLOW_KSM  (1 << 1)
...

Then you have bool page_node_allow_numa(page), bool page_node_allow_ksm(page),
... that is it. Both numa and ksm perform heavy operations and having to go
check a mask inside node struct isn't gonna slow them down.

I am not talking about kind matching to sets of restriction. Just a simple
mask of thing that allowed on that memory. You can add thing like GUP or any
other mechanism that i can't think of right now.

I really think that the vma flag is a bad idea, my expectation is that we
will see more vma with a mix of device and regular memory. I don't think the
only workload will be some big vma device only (ie only access by device) or
CPU only. I believe we will see everything on the spectrum from highly
fragmented to completetly regular.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 14 Oct 2008 08:00:35 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 1/1] hugetlbfs: handle pages higher order than MAX_ORDER
Message-ID: <20081014070035.GE15657@brain>
References: <1223458431-12640-1-git-send-email-apw@shadowen.org> <1223458431-12640-2-git-send-email-apw@shadowen.org> <48ECDD37.8050506@linux-foundation.org> <20081008185532.GA13304@brain> <48ED0B68.2060001@linux-foundation.org> <20081013133404.GC15657@brain> <48F37190.2020801@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48F37190.2020801@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 13, 2008 at 09:04:32AM -0700, Christoph Lameter wrote:
> Andy Whitcroft wrote:
>> Currently memory hot remove is not supported with VMEMMAP.  Obviously
>> that should be fixed overall and I am assuming it will.  But the fact
>> remains that the buddy guarentee is that the mem_map is contigious out
>> to MAX_ORDER-1 order pages only beyond that we may not assume
>> contiguity.  This code is broken under the guarentees that are set out
>> by buddy.  Yes it is true that we do only have one memory model combination
>> currently where a greater guarentee of contigious within a node is
>> violated, but right now this code violates the current guarentees.
>>   I assume the objection here is the injection of the additional branch
>> into these loops.  The later rejig patch removes this for the non-giant
>> cases for the non-huge use cases.  Are we worried about these same
>> branches in the huge cases?  If so we could make this support dependant
>> on a new configuration option, or perhaps only have two loop chosen
>> based on the order of the page.
>>   
> I think we are worried about these additional checks spreading further  
> because there may be assumptions of contiguity elsewhere (in particular  
> when new code is added) since the traditional nature of the memmap is to  
> be linear and not spread out over memory.

Yes, but it is guarenteed to be contigious in all models out to order
MAX_ORDER-1, and only gigantic pages are larger than this.  We already
have to cope with discontiguity at the MAX_ORDER boundaries in paths
which scan over the mem_map in more general terms as SPARSEMEM introduced
that long long ago, and only gained a contigious mode when we added your
VMEMMAP mode to that.

I thought that the approach recommended by Nick, which led to the other
patch in this series which pulled out compound page preparation to a
specific gigantic initialiser, helped a lot with this worry as it removed
any change from the regular case and helped limit gigantic page support
to hugetlb only.  The only reason that initialiser was placed with the
normal form was to ensure they were maintained together.

Would it help if I posted these two together, or perhaps even merged as
a single patch?

> A fix for this particular situation may be as simple as making gigantic  
> pages depend on SPARSE_VMEMMAP? For x86_64 this is certainly sufficient.

Well that is only true if it doesn't support memory hotplug.

>> Something like the patch below?  This patch is not tested as yet, but if
>> this form is acceptable we can get the pair of patches (this plus the
>> prep compound update) tested together and I can repost them once that is
>> done.  This against 2.6.27.
>>   
> What is the difference here to the earlier versions?

This was a move to following the model I felt Nick preferred in the
prep_compound_page where the gigantic support is pulled out of line and
made very explicit.  Minimising the normal case impacts.  Which I felt
was part of the objections to these changes.

The plan here is to only fix up gigantic pages within the context of
hugetlbfs.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

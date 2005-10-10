Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9AGHStE018036
	for <linux-mm@kvack.org>; Mon, 10 Oct 2005 12:17:28 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9AGHS2t077268
	for <linux-mm@kvack.org>; Mon, 10 Oct 2005 12:17:28 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9AGHRhP008225
	for <linux-mm@kvack.org>; Mon, 10 Oct 2005 12:17:27 -0400
Subject: RE: FW: [PATCH 0/3] Demand faulting for huge pages
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0510091306440.7878@goblin.wat.veritas.com>
References: <200510080758.j987w0g06343@unix-os.sc.intel.com>
	 <Pine.LNX.4.61.0510091306440.7878@goblin.wat.veritas.com>
Content-Type: text/plain
Date: Mon, 10 Oct 2005 11:17:25 -0500
Message-Id: <1128961046.8453.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, "Seth, Rohit" <rohit.seth@intel.com>, William Irwin <wli@holomorphy.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Sun, 2005-10-09 at 13:27 +0100, Hugh Dickins wrote:
> On Sat, 8 Oct 2005, Chen, Kenneth W wrote:
> > Rohit Seth wrote on Friday, October 07, 2005 2:29 PM
> > > On Fri, 2005-10-07 at 10:47 -0700, Adam Litke wrote:
> > > > If I were to spend time coding up a patch to remove truncation
> > > > support for hugetlbfs, would it be something other people would
> > > > want to see merged as well?
> > > 
> > > In its current form, there is very little use of huegtlb truncate
> > > functionality.  Currently it only allows reducing the size of hugetlb
> > > backing file.   
> 
> And is that functionality actually used?
> 
> > > IMO it will be useful to keep and enhance this capability so that
> > > apps can dynamically reduce or increase the size of backing files
> > > (for example based on availability of memory at any time).
> 
> And is that functionality actually being asked for?
> 
> > Yup, here is a patch to enhance that capability.  It is more of bring
> > ftruncate on hugetlbfs file a step closer to the same semantics for
> > file on other file systems.
> 
> Well, it's peculiar semantics that extending a file slots its pages
> into existing mmaps, as in your patch.  Though that may indeed match
> the existing prefault semantics for hugetlb mmaps and files.  But in
> those existing peculiar semantics, the file can already be extended,
> by mmaping further, so you're not really adding new capability.
> 
> But please don't expect me to decide one way or another.  We all seem
> to have different agendas for hugetlb.  I'm interested in fixing the
> existing bugs with truncation (see -mm), and getting the locking to
> fit with my page_table_lock patches.  Prohibiting truncation is an
> attractively easy and efficient way of fixing several such problems.
> Adam is interested in fault on demand, which needs further work if
> truncation is allowed.  You and Rohit are interested in enhancing
> the generality of hugetlbfs.
> 
> I'd imagine supporting "read" and "write" would be the first priorities
> if you were really trying to make hugetlbfs more like an ordinary fs.
> But I thought it was intentionally kept at the minimum to do its job.

Honestly, I think there is an even more fundamental issue at hand.  If
the goal is transparent and flexible use of huge pages it seems to me
that there is two ways to go:

1) Continue with hugetlbfs and work to finish implementing all of the
operations (that make sense) properly (like read, write, truncate, etc).

2) Recognize that trying to use hugetlbfs files to transparently replace
normal memory is ultimately a hack.  Normal memory is not implemented as
a file system so using hugetlb pages here will always cause headaches as
implemented.  So work towards removing filesystem-like behaviour and
treating huge pages more like regular memory.

If we can all agree on 1 or 2 then it should be easier to make decisions
like this thread calls for.  I'll put my vote in for #2.  Thoughts? 

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

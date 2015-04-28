Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 72A326B008A
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 13:20:50 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so834911qcb.2
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 10:20:50 -0700 (PDT)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id k2si18952659qge.58.2015.04.28.10.20.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 10:20:49 -0700 (PDT)
Received: by qgfi89 with SMTP id i89so728257qgf.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 10:20:48 -0700 (PDT)
Date: Tue, 28 Apr 2015 13:20:39 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150428172035.GA11810@gmail.com>
References: <20150425114633.GI5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504271004240.28895@gentwo.org>
 <20150427154728.GA26980@gmail.com>
 <alpine.DEB.2.11.1504271113480.29515@gentwo.org>
 <20150427164325.GB26980@gmail.com>
 <alpine.DEB.2.11.1504271148240.29735@gentwo.org>
 <20150427172143.GC26980@gmail.com>
 <alpine.DEB.2.11.1504271411060.30615@gentwo.org>
 <20150427205206.GD26980@gmail.com>
 <alpine.DEB.2.11.1504280907350.4809@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504280907350.4809@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Tue, Apr 28, 2015 at 09:18:55AM -0500, Christoph Lameter wrote:
> On Mon, 27 Apr 2015, Jerome Glisse wrote:
> 
> > > is the mechanism that DAX relies on in the VM.
> >
> > Which would require fare more changes than you seem to think. First using
> > MIXED|PFNMAP means we loose any kind of memory accounting and forget about
> > memcg too. Seconds it means we would need to set those flags on all vma,
> > which kind of point out that something must be wrong here. You will also
> > need to have vm_ops for all those vma (including for anonymous private vma
> > which sounds like it will break quite few place that test for that). Then
> > you have to think about vma that already have vm_ops but you would need
> > to override it to handle case where its device memory and then forward
> > other case to the existing vm_ops, extra layering, extra complexity.
> 
> These vmas would only be used for those section of memory that use
> memory in the coprocessor. Special memory accounting etc can be done at
> the device driver layer. Multiple processes would be able to use different
> GPU contexts (or devices) which provides proper isolations.
> 
> memcg is about accouting for regular memory and this is not regular
> memory. It ooks like one would need a lot of special casing in
> the VM if one wanted to handle f.e. GPU memory as regular memory under
> Linux.

Well i shoed this does not need much changes refer to :
http://lwn.net/Articles/597289/
More specifically :
http://thread.gmane.org/gmane.linux.kernel.mm/116584
http://thread.gmane.org/gmane.linux.kernel.mm/116584
http://thread.gmane.org/gmane.linux.kernel.mm/116584

Idea here is that even if device memory is speciak kind of memory we still
want to account it properly against process ie an anonymous page that is
on the device memory would still be accounted as regular anonymous page for
memcg (same apply to file backed pages). With that existing memcg keeps
working as intended and process memory use are properly accounted.

This does not prevent the device driver to perform its own accounting of
device memory and to allow or block migration for a given process. At this
point we do not think it is meaningfull to move such accounting to a common
layer.

Bottom line is, we want to keep existing memcg accounting intact and we
want to reflect remote memory as regular memory. Note that the memcg changes
would be even smaller now that Johannes cleaned up and simplified memcg. I
have not rebase that part of HMM yet.


> 
> > I think at this point there is nothing more to discuss here. It is pretty
> > clear to me that any solution using block device/MIXEDMAP would be far
> > more complex and far more intrusive. I do not mind being prove wrong but
> > i will certainly not waste my time trying to implement such solution.
> 
> The device driver method is the current solution used by the GPUS and
> that would be the natural starting point for development. And they do not
> currently add code to the core vm. I think we first need to figure out if
> we cannot do what you want through that method.

We do need a different solution, i have been working on that for last 2 years
for a reason.

Requirement: _no_ special allocator in userspace so that all kind of memory
(anonymous, share, file backed) can be use and migrated to device memory in
a transparent fashion for the application.

No special allocator imply no special vma so no special vm_ops. So we need
either to hook up in few places inside mm code with minor change to deal with
special CPU pte entry of migrated memory (on page fault, fork, write back).
For all those place it's just about adding :
  if(new_special_pte)
      new_helper_function()

Other solution would have been to introduce yet another vm_ops that would
superceed the existing vm_ops. This work for page fault but require more
changes for page fault and fork, and major changes for write back. Hence,
why first solution was favor.

I explored many different path before going down the road i am, and all
you are doing is hand waving some idea without even considering any of
the objection i formulated. I explained why your idea can not work or
require excessive and more complex change than solution we are proposing.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

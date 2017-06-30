Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9072802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 09:08:17 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v76so52508162qka.5
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 06:08:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z29si7728378qth.126.2017.06.30.06.08.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 06:08:16 -0700 (PDT)
Date: Fri, 30 Jun 2017 15:08:13 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH] userfaultfd: Add feature to request for a signal
 delivery
Message-ID: <20170630130813.GA5738@redhat.com>
References: <9363561f-a9cd-7ab6-9c11-ab9a99dc89f1@oracle.com>
 <20170627070643.GA28078@dhcp22.suse.cz>
 <20170627153557.GB10091@rapoport-lnx>
 <51508e99-d2dd-894f-8d8a-678e3747c1ee@oracle.com>
 <20170628131806.GD10091@rapoport-lnx>
 <3a8e0042-4c49-3ec8-c59f-9036f8e54621@oracle.com>
 <20170629080910.GC31603@dhcp22.suse.cz>
 <936bde7b-1913-5589-22f4-9bbfdb6a8dd5@oracle.com>
 <20170630094718.GE22917@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170630094718.GE22917@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "prakash.sangappa" <prakash.sangappa@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, linux-api@vger.kernel.org, John Stultz <john.stultz@linaro.org>

On Fri, Jun 30, 2017 at 11:47:35AM +0200, Michal Hocko wrote:
> [CC John, the thread started
> http://lkml.kernel.org/r/9363561f-a9cd-7ab6-9c11-ab9a99dc89f1@oracle.com]
> 
> On Thu 29-06-17 14:41:22, prakash.sangappa wrote:
> > 
> > 
> > On 06/29/2017 01:09 AM, Michal Hocko wrote:
> > >On Wed 28-06-17 11:23:32, Prakash Sangappa wrote:
> > >>
> > >>On 6/28/17 6:18 AM, Mike Rapoport wrote:
> > >[...]
> > >>>I've just been thinking that maybe it would be possible to use
> > >>>UFFD_EVENT_REMOVE for this case. We anyway need to implement the generation
> > >>>of UFFD_EVENT_REMOVE for the case of hole punching in hugetlbfs for
> > >>>non-cooperative userfaultfd. It could be that it will solve your issue as
> > >>>well.
> > >>>
> > >>Will this result in a signal delivery?
> > >>
> > >>In the use case described, the database application does not need any event
> > >>for  hole punching. Basically, just a signal for any invalid access to
> > >>mapped area over holes in the file.
> > >OK, but it would be better to think that through for other potential
> > >usecases so that this doesn't end up as a single hugetlb feature. E.g.
> > >what should happen if a regular anonymous memory gets swapped out?
> > >Should we deliver signal as well? How does userspace tell whether this
> > >was a no backing page from unavailable backing page?
> > 
> > This may not be useful in all cases. Potential, it could be used
> > with use of mlock() on anonymous memory to ensure any access
> > to memory that is not locked is caught, again for robustness
> > purpose.
> 
> The thing I wanted to point out is that not only this should be a single
> usecase thing (I believe others will pop out as well - see below) but it
> should also be well defined as this is a user visible API. Please try to
> write a patch to the userfaultfd man page to clarify the exact semantic.
> This should help the further discussion.
> 
> As an aside, I rememeber that prior to MADV_FREE there was long
> discussion about lazy freeing of memory from userspace. Some users
> wanted to be signalled when their memory was freed by the system so that
> they could rebuild the original content (e.g. uncompressed images in
> memory). It seems like MADV_FREE + this signalling could be used for
> that usecase. John would surely know more about those usecases.

That would provide an equivalent API to the one volatile pages
provided agreed. So it would allow to adapt code (if any?) more easily
to drop the duplicate feature in volatile pages code (however it would
be faster if the userland code using volatile pages lazy reclaim mode
was converted to poll the uffd so the kernel talks directly to the
monitor without involving a SIGBUS signal handler which will cause
spurious enter/exit if compared to signal-less uffd API).

The main benefit in my view is not volatile pages but that
UFFD_FEATURE_SIGBUS would work equally well to enforce robustness on
all kind of memory not only hugetlbfs (so one could run the database
with robustness on THP over tmpfs) and the new cache can be injected
in the filesystem using UFFDIO_COPY which is likely faster than
fallocate as UFFDIO_COPY was already demonstrated to be faster even
than a regular page fault.

It's also simpler to handle backwards compatibility with the
UFFDIO_API call, that allows probing if UFFD_FEATURE_SIGBUS is
supported by the running kernel regardless of kernel version (so it
can be backported and enabled by the database, without the database
noticing it's on a older kernel version).

So while this wasn't the intended way to use the userfault and I
already pointed out the possibility to use a single monitor to do all
this, I'm positive about UFFD_FEATURE_SIGBUS if the overhead of having
a monitor is so concerning.

Ultimately there are many pros and just a single cons: the branch in
handle_userfault().

I wonder if it would be possible to use static_branch_enable() in
UFFDIO_API and static_branch_unlikely in handle_userfault() to
eliminate that branch but perhaps it's overkill and UFFDIO_API is
unprivileged and it would send an IPI to all CPUs. I don't think we
normally expose the static_branch_enable() to unprivileged userland
and making UFFD_FEATURE_SIGBUS a privileged op doesn't sound
attractive (although the alternative of altering a hugetlbfs mount
option would be a privileged op).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 70E3F6B02B4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:36:10 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p64so31304263wrc.8
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:36:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g145si2847604wmg.198.2017.06.27.08.36.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 08:36:08 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5RFXt3h015227
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:36:07 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bbsub8y5w-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:36:07 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 27 Jun 2017 16:36:05 +0100
Date: Tue, 27 Jun 2017 18:35:58 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] userfaultfd: Add feature to request for a signal
 delivery
References: <9363561f-a9cd-7ab6-9c11-ab9a99dc89f1@oracle.com>
 <20170627070643.GA28078@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170627070643.GA28078@dhcp22.suse.cz>
Message-Id: <20170627153557.GB10091@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>

On Tue, Jun 27, 2017 at 09:06:43AM +0200, Michal Hocko wrote:
> This is an user visible API so let's CC linux-api mailing list.
> 
> On Mon 26-06-17 12:46:13, Prakash Sangappa wrote:
> > In some cases, userfaultfd mechanism should just deliver a SIGBUS signal
> > to the faulting process, instead of the page-fault event. Dealing with
> > page-fault event using a monitor thread can be an overhead in these
> > cases. For example applications like the database could use the signaling
> > mechanism for robustness purpose.
> 
> this is rather confusing. What is the reason that the monitor would be
> slower than signal delivery and handling?
> 
> > Database uses hugetlbfs for performance reason. Files on hugetlbfs
> > filesystem are created and huge pages allocated using fallocate() API.
> > Pages are deallocated/freed using fallocate() hole punching support.
> > These files are mmapped and accessed by many processes as shared memory.
> > The database keeps track of which offsets in the hugetlbfs file have
> > pages allocated.
> > 
> > Any access to mapped address over holes in the file, which can occur due
> > to bugs in the application, is considered invalid and expect the process
> > to simply receive a SIGBUS.  However, currently when a hole in the file is
> > accessed via the mapped address, kernel/mm attempts to automatically
> > allocate a page at page fault time, resulting in implicitly filling the
> > hole in the file. This may not be the desired behavior for applications
> > like the database that want to explicitly manage page allocations of
> > hugetlbfs files.
> 
> So you register UFFD_FEATURE_SIGBUS on each region tha you are unmapping
> and than just let those offenders die?
 
If I understand correctly, the database will create the mapping, then it'll
open userfaultfd and register those mappings with the userfault.
Afterwards, when the application accesses a hole userfault will cause
SIGBUS and the application will process it in whatever way it likes, e.g.
just die.

What I don't understand is why won't you use userfault monitor process that
will take care of the page fault events?
It shouldn't be much overhead running it and it can keep track on all the
userfault file descriptors for you and it will allow more versatile error
handling that SIGBUS.

> > Using userfaultfd mechanism, with this support to get a signal, database
> > application can prevent pages from being allocated implicitly when
> > processes access mapped address over holes in the file.
> > 
> > This patch adds the feature to request for a SIGBUS signal to userfaultfd
> > mechanism.
> > 
> > See following for previous discussion about the database requirement
> > leading to this proposal as suggested by Andrea.
> > 
> > http://www.spinics.net/lists/linux-mm/msg129224.html
> 
> Please make those requirements part of the changelog.
> 
> > Signed-off-by: Prakash <prakash.sangappa@oracle.com>
> > ---
> >  fs/userfaultfd.c                 |  5 +++++
> >  include/uapi/linux/userfaultfd.h | 10 +++++++++-
> >  2 files changed, 14 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > index 1d622f2..5686d6d2 100644
> > --- a/fs/userfaultfd.c
> > +++ b/fs/userfaultfd.c
> > @@ -371,6 +371,11 @@ int handle_userfault(struct vm_fault *vmf, unsigned
> > long reason)
> >      VM_BUG_ON(reason & ~(VM_UFFD_MISSING|VM_UFFD_WP));
> >      VM_BUG_ON(!(reason & VM_UFFD_MISSING) ^ !!(reason & VM_UFFD_WP));
> > 
> > +    if (ctx->features & UFFD_FEATURE_SIGBUS) {
> > +        goto out;
> > +    }
> > +
> >      /*
> >       * If it's already released don't get it. This avoids to loop
> >       * in __get_user_pages if userfaultfd_release waits on the
> > diff --git a/include/uapi/linux/userfaultfd.h
> > b/include/uapi/linux/userfaultfd.h
> > index 3b05953..d39d5db 100644
> > --- a/include/uapi/linux/userfaultfd.h
> > +++ b/include/uapi/linux/userfaultfd.h
> > @@ -23,7 +23,8 @@
> >                 UFFD_FEATURE_EVENT_REMOVE |    \
> >                 UFFD_FEATURE_EVENT_UNMAP |        \
> >                 UFFD_FEATURE_MISSING_HUGETLBFS |    \
> > -               UFFD_FEATURE_MISSING_SHMEM)
> > +               UFFD_FEATURE_MISSING_SHMEM |        \
> > +               UFFD_FEATURE_SIGBUS)
> >  #define UFFD_API_IOCTLS                \
> >      ((__u64)1 << _UFFDIO_REGISTER |        \
> >       (__u64)1 << _UFFDIO_UNREGISTER |    \
> > @@ -153,6 +154,12 @@ struct uffdio_api {
> >       * UFFD_FEATURE_MISSING_SHMEM works the same as
> >       * UFFD_FEATURE_MISSING_HUGETLBFS, but it applies to shmem
> >       * (i.e. tmpfs and other shmem based APIs).
> > +     *
> > +     * UFFD_FEATURE_SIGBUS feature means no page-fault
> > +     * (UFFD_EVENT_PAGEFAULT) event will be delivered, instead
> > +     * a SIGBUS signal will be sent to the faulting process.
> > +     * The application process can enable this behavior by adding
> > +     * it to uffdio_api.features.
> >       */
> >  #define UFFD_FEATURE_PAGEFAULT_FLAG_WP        (1<<0)
> >  #define UFFD_FEATURE_EVENT_FORK            (1<<1)
> > @@ -161,6 +168,7 @@ struct uffdio_api {
> >  #define UFFD_FEATURE_MISSING_HUGETLBFS        (1<<4)
> >  #define UFFD_FEATURE_MISSING_SHMEM        (1<<5)
> >  #define UFFD_FEATURE_EVENT_UNMAP        (1<<6)
> > +#define UFFD_FEATURE_SIGBUS            (1<<7)
> >      __u64 features;
> > 
> >      __u64 ioctls;
> > -- 
> > 2.7.4
> > 
> -- 
> Michal Hocko
> SUSE Labs
> 
--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

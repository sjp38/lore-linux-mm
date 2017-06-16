Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 463846B02C3
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 09:15:59 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id d4so35001784qte.11
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 06:15:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y53si2012436qty.197.2017.06.16.06.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 06:15:57 -0700 (PDT)
Date: Fri, 16 Jun 2017 15:15:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
Message-ID: <20170616131554.GD11676@redhat.com>
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
 <7ff6fb32-7d16-af4f-d9d5-698ab7e9e14b@intel.com>
 <03127895-3c5a-5182-82de-3baa3116749e@oracle.com>
 <22557bf3-14bb-de02-7b1b-a79873c583f1@intel.com>
 <7677d20e-5d53-1fb7-5dac-425edda70b7b@oracle.com>
 <48a544c4-61b3-acaf-0386-649f073602b6@intel.com>
 <476ea1b6-36d1-bc86-fa99-b727e3c2650d@oracle.com>
 <20170509085825.GB32555@infradead.org>
 <1031e0d4-cdbb-db8b-dae7-7c733921e20e@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1031e0d4-cdbb-db8b-dae7-7c733921e20e@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>

Hello Prakash,

On Tue, May 09, 2017 at 01:59:34PM -0700, Prakash Sangappa wrote:
> 
> 
> On 5/9/17 1:58 AM, Christoph Hellwig wrote:
> > On Mon, May 08, 2017 at 03:12:42PM -0700, prakash.sangappa wrote:
> >> Regarding #3 as a general feature, do we want to
> >> consider this and the complexity associated with the
> >> implementation?
> > We have to.  Given that no one has exclusive access to hugetlbfs
> > a mount option is fundamentally the wrong interface.
> 
> 
> A hugetlbfs filesystem may need to be mounted for exclusive use by
> an application. Note, recently the 'min_size' mount option was added
> to hugetlbfs, which would reserve minimum number of huge pages
> for that filesystem for use by an application. If the filesystem with
> min size specified, is not setup for exclusive use by an application,
> then the purpose of reserving huge pages is defeated.  The
> min_size option was for use by applications like the database.
> 
> Also, I am investigating enabling hugetlbfs mounts within user
> namespace's mount namespace. That would allow an application
> to mount a hugetlbfs filesystem inside a namespace exclusively for
> its use, running as a non root user. For this it seems like the 'min_size'
> should be subject to some user limits. Anyways, mounting inside
> user namespaces is  a different discussion.
> 
> So, if a filesystem has to be setup for exclusive use by an application,
> then different mount options can be used for that filesystem.

Before userfaultfd I used a madvise that triggered SIGBUS. Aside from
performance that is much lower than userfaultfd because of the return
to userland, SIGBUS handling and new enter kernel to communicate
through a pipe with a memory manager, it couldn't work reliably
because you're not going to get exact information on the virtual
address that triggered the fault if the SIGBUS triggers in some random
in a copy-user of some random syscall, depending on the syscall some
random error will be returned. So it couldn't work transparently to
the app as far as syscalls and get_user_pages drivers were concerned.

With your solution if you pass a corrupted pointer to a random read()
syscall you're going to get a error, but supposedly you already handle
any syscall error and stop the app.

This is a special case because you don't care about performance and
you don't care about not returning random EFAULT errors from syscalls
like read().

This mount option seems non intrusive enough and hugetlbfs is quite
special already, so I'm not particularly concerned by the fact it's
one more special tweak.

If it would be enough to convert the SIGBUS into a (killable) process
hang, you could still use uffd and there would be no need to send the
uffd to a manager. You'd find the corrupting buggy process stuck in
handle_userfault().

As an alternative to the mount option we could consider adding
UFFD_FEATURE_SIGBUS that tells the handle_userfault() to simply return
VM_FAULT_SIGBUS in presence of a pagefault event. You'd still get
weird EFAULT or erratic retvals from syscalls so it would only be
usable in for your robustness feature. Then you could use UFFDIO_COPY
too to fill the memory atomically which runs faster than a page fault
(fallocate punch hole still required to zap it).

Adding a single if (ctx->feature & UFFD_FEATURE_SIGBUS) goto out,
branch for this corner case to handle_userfault() isn't great and the
hugetlbfs mount option is absolutely zero cost to the handle_userfault
which is primarily why I'm not against it.. although it's not going to
be measurable so it would be ok also to add such feature.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

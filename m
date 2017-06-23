Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 495336B0374
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 11:28:55 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id h15so18284495qte.0
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:28:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d4si4241934qta.282.2017.06.23.08.28.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 08:28:54 -0700 (PDT)
Date: Fri, 23 Jun 2017 11:28:50 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 00/15] HMM (Heterogeneous Memory Management) v23
Message-ID: <20170623152849.GA3128@redhat.com>
References: <20170524172024.30810-1-jglisse@redhat.com>
 <CAA_GA1e7LbvY3rZ+FpJ6fLhZ1oUJ_FXVjQvjmS_YSrjZMAv9jw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAA_GA1e7LbvY3rZ+FpJ6fLhZ1oUJ_FXVjQvjmS_YSrjZMAv9jw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>

On Fri, Jun 23, 2017 at 11:00:37PM +0800, Bob Liu wrote:
> Hi,
> 
> On Thu, May 25, 2017 at 1:20 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> > Patchset is on top of git://git.cmpxchg.org/linux-mmotm.git so i
> > test same kernel as kbuild system, git branch:
> >
> > https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v23
> >
> > Change since v22 is use of static key for special ZONE_DEVICE case in
> > put_page() and build fix for architecture with no mmu.
> >
> > Everything else is the same. Below is the long description of what HMM
> > is about and why. At the end of this email i describe briefly each patch
> > and suggest reviewers for each of them.
> >
> >
> > Heterogeneous Memory Management (HMM) (description and justification)
> >
> > Today device driver expose dedicated memory allocation API through their
> > device file, often relying on a combination of IOCTL and mmap calls. The
> > device can only access and use memory allocated through this API. This
> > effectively split the program address space into object allocated for the
> > device and useable by the device and other regular memory (malloc, mmap
> > of a file, share memory, a) only accessible by CPU (or in a very limited
> > way by a device by pinning memory).
> >
> > Allowing different isolated component of a program to use a device thus
> > require duplication of the input data structure using device memory
> > allocator. This is reasonable for simple data structure (array, grid,
> > image, a) but this get extremely complex with advance data structure
> > (list, tree, graph, a) that rely on a web of memory pointers. This is
> > becoming a serious limitation on the kind of work load that can be
> > offloaded to device like GPU.
> >
> > New industry standard like C++, OpenCL or CUDA are pushing to remove this
> > barrier. This require a shared address space between GPU device and CPU so
> > that GPU can access any memory of a process (while still obeying memory
> > protection like read only). This kind of feature is also appearing in
> > various other operating systems.
> >
> > HMM is a set of helpers to facilitate several aspects of address space
> > sharing and device memory management. Unlike existing sharing mechanism
> 
> It looks like the address space sharing and device memory management
> are two different things. They don't depend on each other and HMM has
> helpers for both.
> 
> Is it possible to separate these two things into two patchsets?
> Which will make it's more easy to review and also follow the "Do one
> thing, and do it well" philosophy.
> 

They are already seperate. Patch 3-5 are for address space mirroring.
Patch 6-10 for device memory using struct page and ZONE_DEVICE. Finaly
patch 11-15 for adding new page migration helper capable of using
device DMA engine to perform memory copy operation.

Patch 1 is just common documentation and patch 2 is common helpers and
definitions.

Also they are separate at kernel configuration level. So for all intents
and purposes this is already 2 separate things, just in one posting
because first user will use both. You can use one without the other and
it will work properly.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

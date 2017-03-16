Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEAAA6B038B
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 19:49:55 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n37so52020339qtb.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 16:49:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d63si5124755qkh.85.2017.03.16.16.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 16:49:54 -0700 (PDT)
Date: Thu, 16 Mar 2017 19:49:51 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 00/16] HMM (Heterogeneous Memory Management) v18
Message-ID: <20170316234950.GA5725@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <20170316134321.c5cf727c21abf89b7e6708a2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="0F1p//8PRICkK4MW"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170316134321.c5cf727c21abf89b7e6708a2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Thu, Mar 16, 2017 at 01:43:21PM -0700, Andrew Morton wrote:
> On Thu, 16 Mar 2017 12:05:19 -0400 J__r__me Glisse <jglisse@redhat.com> wrote:
> 
> > Cliff note:
> 
> "Cliff's notes" isn't appropriate for a large feature such as this. 
> Where's the long-form description?  One which permits readers to fully
> understand the requirements, design, alternative designs, the
> implementation, the interface(s), etc?
> 
> Have you ever spoken about HMM at a conference?  If so, the supporting
> presentation documents might help here.  That's the level of detail
> which should be presented here.

Longer description of patchset rational, motivation and design choices
were given in the first few posting of the patchset to which i included
a link in my cover letter. Also given that i presented that for last 3
or 4 years to mm summit and kernel summit i thought that by now peoples
were familiar about the topic and wanted to spare them the long version.
My bad.

I attach a patch that is a first stab at a Documentation/hmm.txt that
explain the motivation and rational behind HMM. I can probably add a
section about how to use HMM from device driver point of view.


> > HMM offers 2 things (each standing on its own). First
> > it allows to use device memory transparently inside any process
> > without any modifications to process program code.
> 
> Well.  What is "device memory"?  That's very vague.  What are the
> characteristics of this memory?  Why is it a requirement that
> userspace code be unaltered?  What are the security implications - does
> the process need particular permissions to access this memory?  What is
> the proposed interface to set up this access?

Thing like GPU memory, think 16GBytes, 32GBytes with 1TeraBytes/s of
bandwidth so something that is just completely in a different category
than DDR3/DDR4 or PCIE bandwidth.

To allow GPU/FPGA/... to be transparently use by program we need to
avoid any requirement to modify any code. Advance in high level langage
construct (in C++ but others too) gives opportunities to compiler to
leverage GPU transparently without programmer knowledge. But for this
to happen we need a share address space ie any pointer in program must
be accessible by the device and we must also be able to migrate memory
to device memory to benefit from the device memory bandwidth.

Moreover if you think about complex software that use a plethora of
various library, you want to allow some of the library to leverage GPU
or DSP transparently without forcing the library to copy/duplicate its
input data which can be highly complex if you think of tree, list, ...
Making all this transparent from program/library point of view ease
the development of thoses. Quite frankly without that it is border line
impossible to efficiently use GPU or other device in many cases.

The device memory is treated like regular memory from kernel point of
view (except that CPU can not access it) but everything else about page
holds (read, write, execution protections ...). So there is no security
implications. Device under consideration have page table and works like
CPU from process isolation point of view (modulo hardware bug but CPU
or main memory have those same issues).


There is no propose interface here, nor i see a need for one. When the
device starts accessing a range of the process address space the device
driver can decide to migrate that range to device memory in order to
speed computations. Only the device driver has enough informations on
wether or not this is a good idea and this changes continously during
run time (depends on what other process are doing ...).

So for now like it was discuss in some CDM threads and in some previous
HMM threads i believe it is better to let the device driver decide and
keep HMM out of any policy choices. Latter down the road once we get more
devices and more real world usage we can try to figure out if there is
a good way to expose a generic memory placement hint to userspace to
allow program to improve performances by helping device driver to make
better decissions.

 
> > Second it allows to mirror process address space on a device.
> 
> Why?  Why is this a requirement, how will it be used, what are the
> use cases, etc?

>From above, the requirement is that any address the CPU can access could
also be access by the device with the same restriction (like read/write
protection). This greatly simplify use of such device, either transparently
by the compiler without programmer knowledge or through some library again
without main program developer knowledge. The whole point is to make it
easier to use thing like GPU without having to ask developer to use
special memory allocator and to duplicate their dataset.


> 
> I spent a bit of time trying to locate a decent writeup of this feature
> but wasn't able to locate one.  I'm not seeing a Documentation/ update
> in this patchset.  Perhaps if you were to sit down and write a detailed
> Documentation/vm/hmm.txt then that would be a good starting point.

Attach is hmm.txt like i said i thought that all the previous at length
description that i have given in the numerous posting of the patchset
were enough and that i only needed to refresh peoples memory.

> 
> This stuff is important - it's not really feasible to perform a decent
> review of this proposal unless the reviewer has access to this
> high-level conceptual stuff.

Does the above and the attach documentation answer your questions ? Is
there thing i should describe more thouroughly or aspect you feel are
missing ?

Cheers,
Jerome

--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="0001-hmm-heterogeneous-memory-management-documentation.patch"
Content-Transfer-Encoding: 8bit


--0F1p//8PRICkK4MW--

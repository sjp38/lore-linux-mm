Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 221466B759B
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 13:01:36 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n50so21622586qtb.9
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 10:01:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c19si5026526qkb.99.2018.12.05.10.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 10:01:34 -0800 (PST)
Date: Wed, 5 Dec 2018 13:01:28 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Message-ID: <20181205180127.GH3536@redhat.com>
References: <2f146730-1bf9-db75-911d-67809fc7afef@deltatee.com>
 <20181204205902.GM2937@redhat.com>
 <e4d8bf6b-5b2c-58a5-577b-66d02f2342c1@deltatee.com>
 <20181204215146.GO2937@redhat.com>
 <c5cf87e8-9104-c2e6-9646-188f66fec581@deltatee.com>
 <20181204235630.GQ2937@redhat.com>
 <b77849e1-e05a-1071-7c48-ac93191e3134@deltatee.com>
 <CAPcyv4ihEesx1G1on6JA8qZ6RooOsgO2CL_=1gXVMXpMJW_N9w@mail.gmail.com>
 <20181205023724.GF3045@redhat.com>
 <2f53e0c0-a8af-b003-5bd7-a341431908df@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2f53e0c0-a8af-b003-5bd7-a341431908df@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Wed, Dec 05, 2018 at 10:25:31AM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2018-12-04 7:37 p.m., Jerome Glisse wrote:
> >>
> >> This came up before for apis even better defined than HMS as well as
> >> more limited scope, i.e. experimental ABI availability only for -rc
> >> kernels. Linus said this:
> >>
> >> "There are no loopholes. No "but it's been only one release". No, no,
> >> no. The whole point is that users are supposed to be able to *trust*
> >> the kernel. If we do something, we keep on doing it.
> >>
> >> And if it makes it harder to add new user-visible interfaces, then
> >> that's a *good* thing." [1]
> >>
> >> The takeaway being don't land work-in-progress ABIs in the kernel.
> >> Once an application depends on it, there are no more incompatible
> >> changes possible regardless of the warnings, experimental notices, or
> >> "staging" designation. DAX is experimental because there are cases
> >> where it currently does not work with respect to another kernel
> >> feature like xfs-reflink, RDMA. The plan is to fix those, not continue
> >> to hide behind an experimental designation, and fix them in a way that
> >> preserves the user visible behavior that has already been exposed,
> >> i.e. no regressions.
> >>
> >> [1]: https://lists.linuxfoundation.org/pipermail/ksummit-discuss/2017-August/004742.html
> > 
> > So i guess i am heading down the vXX road ... such is my life :)
> 
> I recommend against it. I really haven't been convinced by any of your
> arguments for having a second topology tree. The existing topology tree
> in sysfs already better describes the links between hardware right now,
> except for the missing GPU links (and those should be addressable within
> the GPU community). Plus, maybe, some other enhancements to sockets/numa
> node descriptions if there's something missing there.
> 
> Then, 'hbind' is another issue but I suspect it would be better
> implemented as an ioctl on existing GPU interfaces. I certainly can't
> see any benefit in using it myself.
> 
> It's better to take an approach that would be less controversial with
> the community than to brow beat them with a patch set 20+ times until
> they take it.

So here is what i am gonna do because i need this code now. I am gonna
split the helper code that does policy and hbind out from its sysfs
peerage and i am gonna turn it into helpers that each device driver
can use. I will move the sysfs and syscall to be a patchset on its own
which use the exact same above infrastructure.

This means that i am loosing feature as it means that userspace can
not provide a list of multiple device memory to use (which is much more
common that you might think) but at least i can provide something for
the single device case through ioctl.

I am not giving up on sysfs or syscall as this is needed long term so
i am gonna improve it, port existing userspace (OpenCL, ROCm, ...) to
use it (in branch) and demonstrate how it get use by end application.
I will beat it again and again until either i convince people through
hard evidence or i get bored. I do not get bored easily :)

Cheers,
J�r�me

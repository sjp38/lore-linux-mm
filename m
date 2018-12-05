Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 260C56B71FB
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 21:34:51 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id j15so8533352ota.17
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 18:34:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n131sor8524585oif.164.2018.12.04.18.34.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 18:34:49 -0800 (PST)
MIME-Version: 1.0
References: <20181204185725.GE2937@redhat.com> <de7c1099-2717-6396-bf56-c4ab4085ee83@deltatee.com>
 <20181204192221.GG2937@redhat.com> <f759cc28-309d-930c-da7d-34144a4d5517@deltatee.com>
 <20181204201347.GK2937@redhat.com> <2f146730-1bf9-db75-911d-67809fc7afef@deltatee.com>
 <20181204205902.GM2937@redhat.com> <e4d8bf6b-5b2c-58a5-577b-66d02f2342c1@deltatee.com>
 <20181204215146.GO2937@redhat.com> <c5cf87e8-9104-c2e6-9646-188f66fec581@deltatee.com>
 <20181204235630.GQ2937@redhat.com> <b77849e1-e05a-1071-7c48-ac93191e3134@deltatee.com>
In-Reply-To: <b77849e1-e05a-1071-7c48-ac93191e3134@deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 4 Dec 2018 18:34:37 -0800
Message-ID: <CAPcyv4ihEesx1G1on6JA8qZ6RooOsgO2CL_=1gXVMXpMJW_N9w@mail.gmail.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS) documentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Tue, Dec 4, 2018 at 5:15 PM Logan Gunthorpe <logang@deltatee.com> wrote:
>
>
>
> On 2018-12-04 4:56 p.m., Jerome Glisse wrote:
> > One example i have is 4 nodes (CPU socket) each nodes with 8 GPUs and
> > two 8 GPUs node connected through each other with fast mesh (ie each
> > GPU can peer to peer to each other at the same bandwidth). Then this
> > 2 blocks are connected to the other block through a share link.
> >
> > So it looks like:
> >     SOCKET0----SOCKET1-----SOCKET2----SOCKET3
> >     |          |           |          |
> >     S0-GPU0====S1-GPU0     S2-GPU0====S1-GPU0
> >     ||     \\//            ||     \\//
> >     ||     //\\            ||     //\\
> >     ...    ====...    -----...    ====...
> >     ||     \\//            ||     \\//
> >     ||     //\\            ||     //\\
> >     S0-GPU7====S1-GPU7     S2-GPU7====S3-GPU7
>
> Well the existing NUMA node stuff tells userspace which GPU belongs to
> which socket (every device in sysfs already has a numa_node attribute).
> And if that's not good enough we should work to improve how that works
> for all devices. This problem isn't specific to GPUS or devices with
> memory and seems rather orthogonal to an API to bind to device memory.
>
> > How the above example would looks like ? I fail to see how to do it
> > inside current sysfs. Maybe by creating multiple virtual device for
> > each of the inter-connect ? So something like
> >
> > link0 -> device:00 which itself has S0-GPU0 ... S0-GPU7 has child
> > link1 -> device:01 which itself has S1-GPU0 ... S1-GPU7 has child
> > link2 -> device:02 which itself has S2-GPU0 ... S2-GPU7 has child
> > link3 -> device:03 which itself has S3-GPU0 ... S3-GPU7 has child
>
> I think the "links" between GPUs themselves would be a bus. In the same
> way a NUMA node is a bus. Each device in sysfs would then need a
> directory or something to describe what "link bus(es)" they are a part
> of. Though there are other ways to do this: a GPU driver could simply
> create symlinks to other GPUs inside a "neighbours" directory under the
> device path or something like that.
>
> The point is that this seems like it is specific to GPUs and could
> easily be solved in the GPU community without any new universal concepts
> or big APIs.
>
> And for applications that need topology information, a lot of it is
> already there, we just need to fill in the gaps with small changes that
> would be much less controversial. Then if you want to create a libhms
> (or whatever) to help applications parse this information out of
> existing sysfs that would make sense.
>
> > My proposal is to do HMS behind staging for a while and also avoid
> > any disruption to existing code path. See with people living on the
> > bleeding edge if they get interested in that informations. If not then
> > i can strip down my thing to the bare minimum which is about device
> > memory.
>
> This isn't my area or decision to make, but it seemed to me like this is
> not what staging is for. Staging is for introducing *drivers* that
> aren't up to the Kernel's quality level and they all reside under the
> drivers/staging path. It's not meant to introduce experimental APIs
> around the kernel that might be revoked at anytime.
>
> DAX introduced itself by marking the config option as EXPERIMENTAL and
> printing warnings to dmesg when someone tries to use it. But, to my
> knowledge, DAX also wasn't creating APIs with the intention of changing
> or revoking them -- it was introducing features using largely existing
> APIs that had many broken corner cases.
>
> Do you know of any precedents where big APIs were introduced and then
> later revoked or radically changed like you are proposing to do?

This came up before for apis even better defined than HMS as well as
more limited scope, i.e. experimental ABI availability only for -rc
kernels. Linus said this:

"There are no loopholes. No "but it's been only one release". No, no,
no. The whole point is that users are supposed to be able to *trust*
the kernel. If we do something, we keep on doing it.

And if it makes it harder to add new user-visible interfaces, then
that's a *good* thing." [1]

The takeaway being don't land work-in-progress ABIs in the kernel.
Once an application depends on it, there are no more incompatible
changes possible regardless of the warnings, experimental notices, or
"staging" designation. DAX is experimental because there are cases
where it currently does not work with respect to another kernel
feature like xfs-reflink, RDMA. The plan is to fix those, not continue
to hide behind an experimental designation, and fix them in a way that
preserves the user visible behavior that has already been exposed,
i.e. no regressions.

[1]: https://lists.linuxfoundation.org/pipermail/ksummit-discuss/2017-August/004742.html

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 185546B006E
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 17:45:08 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id i50so16180560qgf.10
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 14:45:07 -0800 (PST)
Received: from mail-qg0-x234.google.com (mail-qg0-x234.google.com. [2607:f8b0:400d:c04::234])
        by mx.google.com with ESMTPS id 49si40803163qgh.88.2015.01.05.14.45.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 14:45:06 -0800 (PST)
Received: by mail-qg0-f52.google.com with SMTP id i50so2851821qgf.25
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 14:45:06 -0800 (PST)
From: j.glisse@gmail.com
Subject: HMM (Heterogeneous Memory Management) v8
Date: Mon,  5 Jan 2015 17:44:43 -0500
Message-Id: <1420497889-10088-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, linux-fsdevel@vger.kernel.org, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Jeff Law <law@redhat.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

So a resend with corrections base on Haggai comments. This patchset is just
the ground foundation on to which we want to build our features set. Main
feature being migrating memory to device memory. The very first version of
this patchset already show cased proof of concept of much of the features.

Below is previous patchset cover letter pretty much unchanged as background
and motivation for it did not.


What it is ?

In a nutshell HMM is a subsystem that provide an easy to use api to mirror a
process address on a device with minimal hardware requirement (mainly device
page fault and read only page mapping). This does not rely on ATS and PASID
PCIE extensions. It intends to supersede those extensions by allowing to move
system memory to device memory in a transparent fashion for core kernel mm
code (ie cpu page fault on page residing in device memory will trigger
migration back to system memory).


Why doing this ?

We want to be able to mirror a process address space so that compute api such
as OpenCL or other similar api can start using the exact same address space on
the GPU as on the CPU. This will greatly simplify usages of those api. Moreover
we believe that we will see more and more specialize unit functions that will
want to mirror process address using their own mmu.

The migration side is simply because GPU memory bandwidth is far beyond than
system memory bandwith and there is no sign that this gap is closing (quite the
opposite).


Current status and future features :

None of this core code change in any major way core kernel mm code. This
is simple ground work with no impact on existing code path. Features that
will be implemented on top of this are :
  1 - Tansparently handle page mapping on behalf of device driver (DMA).
  2 - Improve DMA api to better match new usage pattern of HMM.
  3 - Migration of anonymous memory to device memory.
  4 - Locking memory to remote memory (CPU access trigger SIGBUS).
  5 - Access exclusion btw CPU and device for atomic operations.
  6 - Migration of file backed memory to device memory.


How future features will be implemented :
1 - Simply use existing DMA api to map page on behalf of a device.
2 - Introduce new DMA api to match new semantic of HMM. It is no longer page
    we map but address range and managing which page is effectively backing
    an address should be easy to update. I gave a presentation about that
    during this LPC.
3 - Requires change to cpu page fault code path to handle migration back to
    system memory on cpu access. An implementation of this was already sent
    as part of v1. This will be low impact and only add a new special swap
    type handling to existing fault code.
4 - Require a new syscall as i can not see which current syscall would be
    appropriate for this. My first feeling was to use mbind as it has the
    right semantic (binding a range of address to a device) but mbind is
    too numa centric.

    Second one was madvise, but semantic does not match, madvise does allow
    kernel to ignore them while we do want to block cpu access for as long
    as the range is bind to a device.

    So i do not think any of existing syscall can be extended with new flags
    but maybe i am wrong.
5 - Allowing to map a page as read only on the CPU while a device perform
    some atomic operation on it (this is mainly to work around system bus
    that do not support atomic memory access and sadly there is a large
    base of hardware without that feature).

    Easiest implementation would be using some page flags but there is none
    left. So it must be some flags in vma to know if there is a need to query
    HMM for write protection.

6 - This is the trickiest one to implement and while i showed a proof of
    concept with v1, i am still have a lot of conflictual feeling about how
    to achieve this.


As usual comments are more then welcome. Thanks in advance to anyone that
take a look at this code.

Previous patchset posting :
  v1 http://lwn.net/Articles/597289/
  v2 https://lkml.org/lkml/2014/6/12/559 (cover letter did not make it to ml)
  v3 https://lkml.org/lkml/2014/6/13/633
  v4 https://lkml.org/lkml/2014/8/29/423
  v5 https://lkml.org/lkml/2014/11/3/759
  v6 http://lwn.net/Articles/619737/

Cheers,
JA(C)rA'me

To: "Andrew Morton" <akpm@linux-foundation.org>,
Cc: <linux-kernel@vger.kernel.org>,
Cc: linux-mm <linux-mm@kvack.org>,
Cc: <linux-fsdevel@vger.kernel.org>,
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
Cc: "Mel Gorman" <mgorman@suse.de>,
Cc: "H. Peter Anvin" <hpa@zytor.com>,
Cc: "Peter Zijlstra" <peterz@infradead.org>,
Cc: "Linda Wang" <lwang@redhat.com>,
Cc: "Kevin E Martin" <kem@redhat.com>,
Cc: "Jerome Glisse" <jglisse@redhat.com>,
Cc: "Andrea Arcangeli" <aarcange@redhat.com>,
Cc: "Johannes Weiner" <jweiner@redhat.com>,
Cc: "Larry Woodman" <lwoodman@redhat.com>,
Cc: "Rik van Riel" <riel@redhat.com>,
Cc: "Dave Airlie" <airlied@redhat.com>,
Cc: "Jeff Law" <law@redhat.com>,
Cc: "Brendan Conoboy" <blc@redhat.com>,
Cc: "Joe Donohue" <jdonohue@redhat.com>,
Cc: "Duncan Poole" <dpoole@nvidia.com>,
Cc: "Sherry Cheung" <SCheung@nvidia.com>,
Cc: "Subhash Gutti" <sgutti@nvidia.com>,
Cc: "John Hubbard" <jhubbard@nvidia.com>,
Cc: "Mark Hairgrove" <mhairgrove@nvidia.com>,
Cc: "Lucien Dunning" <ldunning@nvidia.com>,
Cc: "Cameron Buschardt" <cabuschardt@nvidia.com>,
Cc: "Arvind Gopalakrishnan" <arvindg@nvidia.com>,
Cc: "Haggai Eran" <haggaie@mellanox.com>,
Cc: "Or Gerlitz" <ogerlitz@mellanox.com>,
Cc: "Sagi Grimberg" <sagig@mellanox.com>
Cc: "Shachar Raindel" <raindel@mellanox.com>,
Cc: "Liran Liss" <liranl@mellanox.com>,
Cc: "Roland Dreier" <roland@purestorage.com>,
Cc: "Sander, Ben" <ben.sander@amd.com>,
Cc: "Stoner, Greg" <Greg.Stoner@amd.com>,
Cc: "Bridgman, John" <John.Bridgman@amd.com>,
Cc: "Mantor, Michael" <Michael.Mantor@amd.com>,
Cc: "Blinzer, Paul" <Paul.Blinzer@amd.com>,
Cc: "Morichetti, Laurent" <Laurent.Morichetti@amd.com>,
Cc: "Deucher, Alexander" <Alexander.Deucher@amd.com>,
Cc: "Gabbay, Oded" <Oded.Gabbay@amd.com>,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

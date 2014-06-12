Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id EBAAA6B0104
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:33:59 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id o8so2585140qcw.3
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 11:33:59 -0700 (PDT)
Received: from mail-qa0-x22b.google.com (mail-qa0-x22b.google.com [2607:f8b0:400d:c00::22b])
        by mx.google.com with ESMTPS id o1si2005615qcj.26.2014.06.12.11.33.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 11:33:59 -0700 (PDT)
Received: by mail-qa0-f43.google.com with SMTP id k15so2194281qaq.16
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 11:33:59 -0700 (PDT)
From: j.glisse@gmail.com
Subject: Heterogeneous memory management v2
Date: Thu, 12 Jun 2014 14:33:44 -0400
Message-Id: <1402598029-3331-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>

This is a v2 of the hmm patchset. I intentionaly removed the remote memory
support from this version as i would like to see the basic hmm foundation
merge for next kernel (3.17). It apply on top of linux-next.

Below is the nutshell and motivation for hmm. Anyone more curious should
refer to my previous email as it contains a deeper analysis. I should stress
again that dedicated video memory is not vanishing on the contrary the
bandwidth and latency gap between system memory and dedicated video memory
is growing.

Also as stated in previous discusion, hmm can only be implemented using the
mmu_notifier api (or it would need to insert callback in all same spot as
the mmu_notifier). What hmm needs can not be achieve during tlb flush.


In a nutshell:

The heterogeneous memory management (hmm) patchset implement a new api that
sit on top of the mmu notifier api. It provides a simple api to device driver
to mirror a process address space without having to lock or take reference on
page and block them from being reclam or migrated. Any changes on a process
address space is mirrored to the device page table by the hmm code. To achieve
this not only we need each driver to implement a set of callback functions but
hmm also interface itself in many key location of the mm code and fs code.
Moreover hmm allow to migrate range of memory to the device remote memory to
take advantages of its lower latency and higher bandwidth.

The why:

We want to be able to mirror a process address space so that compute api such
as OpenCL or other similar api can start using the exact same address space on
the GPU as on the CPU. This will greatly simplify usages of those api. Moreover
we believe that we will see more and more specialize unit functions that will
want to mirror process address using their own mmu.


Cheers,
JA(C)rA'me Glisse


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

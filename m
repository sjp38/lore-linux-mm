Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4B60C6B00CA
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 15:09:47 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so13467249pab.26
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 12:09:47 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id ef7si23765997pac.71.2014.11.12.12.09.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Nov 2014 12:09:45 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so13666095pab.33
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 12:09:45 -0800 (PST)
Date: Wed, 12 Nov 2014 15:09:14 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: HMM (heterogeneous memory management) v6
Message-ID: <20141112200911.GA7720@gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
 <alpine.DEB.2.11.1411111259560.6657@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1411111259560.6657@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, linux-fsdevel@vger.kernel.org, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Jeff Law <law@redhat.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

On Tue, Nov 11, 2014 at 01:00:56PM -0600, Christoph Lameter wrote:
> On Mon, 10 Nov 2014, j.glisse@gmail.com wrote:
> 
> > In a nutshell HMM is a subsystem that provide an easy to use api to mirror a
> > process address on a device with minimal hardware requirement (mainly device
> > page fault and read only page mapping). This does not rely on ATS and PASID
> > PCIE extensions. It intends to supersede those extensions by allowing to move
> > system memory to device memory in a transparent fashion for core kernel mm
> > code (ie cpu page fault on page residing in device memory will trigger
> > migration back to system memory).
> 
> Could we define a new NUMA node that maps memory from the GPU and
> then simply use the existing NUMA features to move a process over there.

Sorry for late reply, i am traveling and working on an updated patchset to
change the device page table design to something simpler and easier to grasp.

So GPU process will never run on CPU nor will they have a kernel task struct
associated with them. From core kernel point of view they do not exist. I
hope that at one point down the line the hw will allow for better integration
with kernel core but it's not there yet.

So the NUMA idea was considered early on but was discarded as it's not really
appropriate. You can have several CPU thread working with several GPU thread
at the same time and they can either access disjoint memory or some share
memory. Usual case will be few kbytes of share memory for synchronization
btw CPU and GPU threads.

But when a GPU job is launch we want most of the memory it will use to be
migrated to device memory. Issue is that the device memory is not accessible
from the CPU (PCIE bar are too small). So there is no way to keep the memory
mapped for the CPU. We do need to mark the memory as unaccessible to the CPU
and then migrate it to the GPU memory.

Now when there is a CPU page fault on some migrated memory we need to migrate
memory back to system memory. Hence why i need to tie HMM with some core MM
code so that on this kind of fault core kernel knows it needs to call into
HMM which will perform housekeeping and starts migration back to system
memory.


So technicaly there is no task migration only memory migration.


Is there something i missing inside NUMA or some NUMA work in progress that
change NUMA sufficiently that it might somehow address the use case i am
describing above ?


Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

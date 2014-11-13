Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB0E6B00DC
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 23:28:45 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id i17so10472429qcy.17
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 20:28:45 -0800 (PST)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id g5si44787621qab.49.2014.11.12.20.28.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Nov 2014 20:28:44 -0800 (PST)
Received: by mail-qg0-f50.google.com with SMTP id a108so9822449qge.37
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 20:28:43 -0800 (PST)
Date: Wed, 12 Nov 2014 23:28:21 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: HMM (heterogeneous memory management) v6
Message-ID: <20141113042819.GB7720@gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
 <alpine.DEB.2.11.1411111259560.6657@gentwo.org>
 <20141112200911.GA7720@gmail.com>
 <alpine.DEB.2.11.1411121703200.17784@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1411121703200.17784@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, linux-fsdevel@vger.kernel.org, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Jeff Law <law@redhat.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

On Wed, Nov 12, 2014 at 05:08:47PM -0600, Christoph Lameter wrote:
> On Wed, 12 Nov 2014, Jerome Glisse wrote:
> 
> > > Could we define a new NUMA node that maps memory from the GPU and
> > > then simply use the existing NUMA features to move a process over there.
> >
> > So GPU process will never run on CPU nor will they have a kernel task struct
> > associated with them. From core kernel point of view they do not exist. I
> > hope that at one point down the line the hw will allow for better integration
> > with kernel core but it's not there yet.
> 
> Right. So all of this is not relevant because the GPU manages it. You only
> need access from the regular processors from Linux which has and uses Page
> tables.
> 
> > So the NUMA idea was considered early on but was discarded as it's not really
> > appropriate. You can have several CPU thread working with several GPU thread
> > at the same time and they can either access disjoint memory or some share
> > memory. Usual case will be few kbytes of share memory for synchronization
> > btw CPU and GPU threads.
> 
> It is possible to ahve several threads accessing the memory in Linux. The
> GPU threads run on the gpu and therefore are not a Linux issue. Where did
> you see the problem?

When they both use system memory there is no issue but if you want to leverage
GPU to its full potential you need to migrate memory from system memory to GPU
memory for the duration of the GPU computation (might be several minutes/hours
or more). But at the same time you do not want CPU access to be forbiden thus
if CPU access does happen you want to catch the CPU fault schedule a migration
of GPU memory back to system memory and resume the CPU thread that faulted.

So from CPU point of view this GPU memory is like a swap, the memory is swaped
in the GPU memory and this is exactly how i implemented in, using a special swap
type. Refer to the v1 of my patchset where i show case implementation of most
of the features.

> 
> > But when a GPU job is launch we want most of the memory it will use to be
> > migrated to device memory. Issue is that the device memory is not accessible
> > from the CPU (PCIE bar are too small). So there is no way to keep the memory
> > mapped for the CPU. We do need to mark the memory as unaccessible to the CPU
> > and then migrate it to the GPU memory.
> 
> Ok so this is transfer issue? Isnt this like block I/O? Write to a device?
> 

It can be as slow as block I/O but it's unlike a block device, it's closer to
NUMA in theory because it's just about having memory close to the compute unit
(ie GPU memory in this case) but nothing else beside that match NUMA.

> 
> > Now when there is a CPU page fault on some migrated memory we need to migrate
> > memory back to system memory. Hence why i need to tie HMM with some core MM
> > code so that on this kind of fault core kernel knows it needs to call into
> > HMM which will perform housekeeping and starts migration back to system
> > memory.
> 
> 
> Sounds like a read operation and like a major fault if you would use
> device semantics. You write the pages to the device and then evict them
> from memory (madvise can do that for you). An access then causes a page
> fault which leads to a read operation from the device.

Yes it's a major fault case but we do not want to use this with any special
syscall think existing application that link against library. Now you port
the library to use GPU but application is ignorant of this and thus any CPU
access it does will be through usual mmaped range that did not go through any
special syscall.

> 
> > So technicaly there is no task migration only memory migration.
> >
> >
> > Is there something i missing inside NUMA or some NUMA work in progress that
> > change NUMA sufficiently that it might somehow address the use case i am
> > describing above ?
> 
> I think you need to be looking at treating GPU memory as a block device
> then you have the semantics you need.

This was explored too but block device does not match what we want. Block device
is nice for file backed memory and we could have special file that would be backed
by GPU memory and process would open those special file and write to it. But this
is not how we want to use this, we do really want to mirror process address space,
ie any kind of existing CPU mapping can be use by GPU (except mmaped IO) and we
want to be able to migrate any of those existing CPU mapping to GPU memory while
still being able to service CPU page fault on range migrated to GPU memory.

So unless there is something i am completely oblivious too in the block device
model in the linux kernel, i fail to see how it could apply to what we want to
achieve.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id BF2836B00DB
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 18:08:54 -0500 (EST)
Received: by mail-yh0-f50.google.com with SMTP id 29so6492701yhl.23
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 15:08:54 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id f3si43955281qch.31.2014.11.12.15.08.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 12 Nov 2014 15:08:53 -0800 (PST)
Date: Wed, 12 Nov 2014 17:08:47 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: HMM (heterogeneous memory management) v6
In-Reply-To: <20141112200911.GA7720@gmail.com>
Message-ID: <alpine.DEB.2.11.1411121703200.17784@gentwo.org>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com> <alpine.DEB.2.11.1411111259560.6657@gentwo.org> <20141112200911.GA7720@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, linux-fsdevel@vger.kernel.org, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Jeff Law <law@redhat.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

On Wed, 12 Nov 2014, Jerome Glisse wrote:

> > Could we define a new NUMA node that maps memory from the GPU and
> > then simply use the existing NUMA features to move a process over there.
>
> So GPU process will never run on CPU nor will they have a kernel task struct
> associated with them. From core kernel point of view they do not exist. I
> hope that at one point down the line the hw will allow for better integration
> with kernel core but it's not there yet.

Right. So all of this is not relevant because the GPU manages it. You only
need access from the regular processors from Linux which has and uses Page
tables.

> So the NUMA idea was considered early on but was discarded as it's not really
> appropriate. You can have several CPU thread working with several GPU thread
> at the same time and they can either access disjoint memory or some share
> memory. Usual case will be few kbytes of share memory for synchronization
> btw CPU and GPU threads.

It is possible to ahve several threads accessing the memory in Linux. The
GPU threads run on the gpu and therefore are not a Linux issue. Where did
you see the problem?

> But when a GPU job is launch we want most of the memory it will use to be
> migrated to device memory. Issue is that the device memory is not accessible
> from the CPU (PCIE bar are too small). So there is no way to keep the memory
> mapped for the CPU. We do need to mark the memory as unaccessible to the CPU
> and then migrate it to the GPU memory.

Ok so this is transfer issue? Isnt this like block I/O? Write to a device?


> Now when there is a CPU page fault on some migrated memory we need to migrate
> memory back to system memory. Hence why i need to tie HMM with some core MM
> code so that on this kind of fault core kernel knows it needs to call into
> HMM which will perform housekeeping and starts migration back to system
> memory.


Sounds like a read operation and like a major fault if you would use
device semantics. You write the pages to the device and then evict them
from memory (madvise can do that for you). An access then causes a page
fault which leads to a read operation from the device.

> So technicaly there is no task migration only memory migration.
>
>
> Is there something i missing inside NUMA or some NUMA work in progress that
> change NUMA sufficiently that it might somehow address the use case i am
> describing above ?

I think you need to be looking at treating GPU memory as a block device
then you have the semantics you need.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

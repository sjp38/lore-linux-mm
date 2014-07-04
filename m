Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 967B66B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 20:03:58 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id e89so887690qgf.29
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 17:03:58 -0700 (PDT)
Received: from mail-qc0-x235.google.com (mail-qc0-x235.google.com [2607:f8b0:400d:c01::235])
        by mx.google.com with ESMTPS id r76si11569299qgr.35.2014.07.03.17.03.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 17:03:57 -0700 (PDT)
Received: by mail-qc0-f181.google.com with SMTP id x13so906804qcv.40
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 17:03:57 -0700 (PDT)
Date: Thu, 3 Jul 2014 20:03:49 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
Message-ID: <20140704000347.GA2442@gmail.com>
References: <20140630181623.GE26537@8bytes.org>
 <20140630183556.GB3280@gmail.com>
 <20140701091535.GF26537@8bytes.org>
 <019CCE693E457142B37B791721487FD91806DD8B@storexdag01.amd.com>
 <20140701110018.GH26537@8bytes.org>
 <20140701193343.GB3322@gmail.com>
 <20140701210620.GL26537@8bytes.org>
 <20140701213208.GC3322@gmail.com>
 <20140703183024.GA3306@gmail.com>
 <20140703231541.GR26537@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140703231541.GR26537@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: "Gabbay, Oded" <Oded.Gabbay@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Lewycky, Andrew" <Andrew.Lewycky@amd.com>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "hpa@zytor.com" <hpa@zytor.com>, peterz@infradead.org, "aarcange@redhat.com" <aarcange@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>

On Fri, Jul 04, 2014 at 01:15:41AM +0200, Joerg Roedel wrote:
> Hi Jerome,
> 
> On Thu, Jul 03, 2014 at 02:30:26PM -0400, Jerome Glisse wrote:
> > Joerg do you still object to this patch ?
> 
> Yes.
> 
> > Again the natural place to call this is from mmput and the fact that many
> > other subsystem already call in from there to cleanup there own per mm data
> > structure is a testimony that this is a valid use case and valid design.
> 
> Device drivers are something different than subsystems. I think the
> point that the mmu_notifier struct can not be freed in the .release
> call-back is a weak reason for introducing a new notifier. In the end
> every user of mmu_notifiers has to call mmu_notifier_register somewhere
> (file-open/ioctl path or somewhere else where the mm<->device binding is
>  set up) and can call mmu_notifier_unregister in a similar path which
> destroys the binding.
> 
> > You pointed out that the cleanup should be done from the device driver file
> > close call. But as i stressed some of the new user will not necessarily have
> > a device file open hence no way for them to free the associated structure
> > except with hackish delayed job.
> 
> Please tell me more about these 'new users', how does mm<->device binding
> is set up there if no fd is used?

It could be setup on behalf of another process through others means like
local socket. Thought main use case i am thinking about is you open device
fd you setup your gpu queue and then you close the fd but you keep using
the gpu and the gpu keep accessing the address space.

Further done the lane we might even see gpu code as directly executable
thought that seems yet unreleasistic at this time.

Anyway whole point is that no matter how you turn the matter anything that
mirror a process address is linked to the lifetime of the mm_struct so in
order to have some logic there it is far best to have destruction match
the destruction of mm. This also make things like fork lot cleaner, as on
work the device file descriptor is duplicated inside the child process
but nothing setup child process to keep using the gpu. Thus you might
end up with way delayed file closure compare to parent process mm
destruction.

Cheers,
Jerome


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

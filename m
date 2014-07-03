Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 08FED6B0036
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 14:30:38 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id hi2so2803648wib.7
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:30:38 -0700 (PDT)
Received: from mail-we0-x231.google.com (mail-we0-x231.google.com [2a00:1450:400c:c03::231])
        by mx.google.com with ESMTPS id p10si25057535wic.44.2014.07.03.11.30.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 11:30:38 -0700 (PDT)
Received: by mail-we0-f177.google.com with SMTP id u56so645915wes.8
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:30:38 -0700 (PDT)
Date: Thu, 3 Jul 2014 14:30:26 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
Message-ID: <20140703183024.GA3306@gmail.com>
References: <20140630154042.GD26537@8bytes.org>
 <20140630160604.GF1956@gmail.com>
 <20140630181623.GE26537@8bytes.org>
 <20140630183556.GB3280@gmail.com>
 <20140701091535.GF26537@8bytes.org>
 <019CCE693E457142B37B791721487FD91806DD8B@storexdag01.amd.com>
 <20140701110018.GH26537@8bytes.org>
 <20140701193343.GB3322@gmail.com>
 <20140701210620.GL26537@8bytes.org>
 <20140701213208.GC3322@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140701213208.GC3322@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: "Gabbay, Oded" <Oded.Gabbay@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Lewycky, Andrew" <Andrew.Lewycky@amd.com>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "hpa@zytor.com" <hpa@zytor.com>, peterz@infradead.org, "aarcange@redhat.com" <aarcange@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>

On Tue, Jul 01, 2014 at 05:32:09PM -0400, Jerome Glisse wrote:
> On Tue, Jul 01, 2014 at 11:06:20PM +0200, Joerg Roedel wrote:
> > On Tue, Jul 01, 2014 at 03:33:44PM -0400, Jerome Glisse wrote:
> > > On Tue, Jul 01, 2014 at 01:00:18PM +0200, Joerg Roedel wrote:
> > > > No, its not in this case. The file descriptor is used to connect a
> > > > process address space with a device context. Thus without the mappings
> > > > the file-descriptor is useless and the mappings should stay in-tact
> > > > until the fd is closed.
> > > > 
> > > > It would be a very bad semantic for userspace if a fd that is passed on
> > > > fails on the other side because the sending process died.
> > > 
> > > Consider use case where there is no file associated with the mmu_notifier
> > > ie there is no device file descriptor that could hold and take care of
> > > mmu_notifier destruction and cleanup. We need this call chain for this
> > > case.
> > 
> > Example of such a use-case where no fd will be associated?
> > 
> > Anyway, even without an fd, there will always be something that sets the
> > mm->device binding up (calling mmu_notifier_register) and tears it down
> > in the end (calling mmu_notifier_unregister). And this will be the
> > places where any resources left from the .release call-back can be
> > cleaned up.
> > 
> 
> That's the whole point we can not do what we want without the callback ie
> the place where we do the cleanup is the mm callback we need. If you do not
> like the call chain than we will just add ourself as another caller in the
> exact same spot where the notifier chain is which Andrew disliked because
> there are already enough submodule that are interested in being inform of
> mm destruction.
> 
> Cheers,
> Jerome

Joerg do you still object to this patch ? Knowing that we need to bind the
lifetime of our object with the mm_struct. While the release callback of
mmu_notifier allow us to stop any further processing in timely manner with
mm destruction, we can not however free some of the associated resources
namely the structure containing the mmu_notifier struct. We could schedule
a delayed job to do it sometimes after we get the release callback but that
would be hackish.

Again the natural place to call this is from mmput and the fact that many
other subsystem already call in from there to cleanup there own per mm data
structure is a testimony that this is a valid use case and valid design.

This patch realy just try to allow new user to easily interface themself
at proper place in mm lifetime. It is just as the task exit notifier chain
but i deals with the mm_struct.

You pointed out that the cleanup should be done from the device driver file
close call. But as i stressed some of the new user will not necessarily have
a device file open hence no way for them to free the associated structure
except with hackish delayed job.

So i do not see any reasons to block this patch.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

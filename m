Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 20B856B0036
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 03:01:21 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hi2so3546271wib.4
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 00:01:20 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id er6si18591416wib.22.2014.07.21.00.01.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 00:01:19 -0700 (PDT)
Received: by mail-wi0-f181.google.com with SMTP id bs8so3494958wib.14
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 00:01:18 -0700 (PDT)
Date: Mon, 21 Jul 2014 09:01:28 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
Message-ID: <20140721070128.GU15237@phenom.ffwll.local>
References: <53C7D645.3070607@amd.com>
 <20140720174652.GE3068@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140720174652.GE3068@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Oded Gabbay <oded.gabbay@amd.com>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <deathsimple@vodafone.de>, Michel =?iso-8859-1?Q?D=E4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>

On Sun, Jul 20, 2014 at 01:46:53PM -0400, Jerome Glisse wrote:
> On Thu, Jul 17, 2014 at 04:57:25PM +0300, Oded Gabbay wrote:
> > Forgot to cc mailing list on cover letter. Sorry.
> > 
> > As a continuation to the existing discussion, here is a v2 patch series
> > restructured with a cleaner history and no totally-different-early-versions
> > of the code.
> > 
> > Instead of 83 patches, there are now a total of 25 patches, where 5 of them
> > are modifications to radeon driver and 18 of them include only amdkfd code.
> > There is no code going away or even modified between patches, only added.
> > 
> > The driver was renamed from radeon_kfd to amdkfd and moved to reside under
> > drm/radeon/amdkfd. This move was done to emphasize the fact that this driver
> > is an AMD-only driver at this point. Having said that, we do foresee a
> > generic hsa framework being implemented in the future and in that case, we
> > will adjust amdkfd to work within that framework.
> > 
> > As the amdkfd driver should support multiple AMD gfx drivers, we want to
> > keep it as a seperate driver from radeon. Therefore, the amdkfd code is
> > contained in its own folder. The amdkfd folder was put under the radeon
> > folder because the only AMD gfx driver in the Linux kernel at this point
> > is the radeon driver. Having said that, we will probably need to move it
> > (maybe to be directly under drm) after we integrate with additional AMD gfx
> > drivers.
> > 
> > For people who like to review using git, the v2 patch set is located at:
> > http://cgit.freedesktop.org/~gabbayo/linux/log/?h=kfd-next-3.17-v2
> > 
> > Written by Oded Gabbayh <oded.gabbay@amd.com>
> 
> So quick comments before i finish going over all patches. There is many
> things that need more documentation espacialy as of right now there is
> no userspace i can go look at.
> 
> There few show stopper, biggest one is gpu memory pinning this is a big
> no, that would need serious arguments for any hope of convincing me on
> that side.
> 
> It might be better to add a drivers/gpu/drm/amd directory and add common
> stuff there.
> 
> Given that this is not intended to be final HSA api AFAICT then i would
> say this far better to avoid the whole kfd module and add ioctl to radeon.
> This would avoid crazy communication btw radeon and kfd.
> 
> The whole aperture business needs some serious explanation. Especialy as
> you want to use userspace address there is nothing to prevent userspace
> program from allocating things at address you reserve for lds, scratch,
> ... only sane way would be to move those lds, scratch inside the virtual
> address reserved for kernel (see kernel memory map).
> 
> The whole business of locking performance counter for exclusive per process
> access is a big NO. Which leads me to the questionable usefullness of user
> space command ring. I only see issues with that. First and foremost i would
> need to see solid figures that kernel ioctl or syscall has a higher an
> overhead that is measurable in any meaning full way against a simple
> function call. I know the userspace command ring is a big marketing features
> that please ignorant userspace programmer. But really this only brings issues
> and for absolutely not upside afaict.
> 
> So i would rather see a very simple ioctl that write the doorbell and might
> do more than that in case of ring/queue overcommit where it would first have
> to wait for a free ring/queue to schedule stuff. This would also allow sane
> implementation of things like performance counter that could be acquire by
> kernel for duration of a job submitted by userspace. While still not optimal
> this would be better that userspace locking.

Quick aside and mostly off the record: In i915 we plan to have the first
implementation exactly as Jerome suggests here:
- New flag at context creationg for svm/seamless-gpgpu contexts.
- New ioctl in i915 for submitting stuff to the hw (through doorbell or
  whatever else we want to do). The ring in the ctx would be under the
  kernel's control.

Of course there's lots of GEM stuff we don't need at all for such
contexts, but there's still lots of shared code. Imo creating a 2nd driver
has too much interface surface and so is a maintainence hell.

And the ioctl submission gives us flexibility in case the hw doesn't quite
live up to promise (e.g. scheduling, cmd parsing, ...).
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

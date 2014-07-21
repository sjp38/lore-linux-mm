Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id EB7056B0039
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:05:40 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id k48so6601066wev.26
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:05:39 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id e17si29310315wjx.19.2014.07.21.10.05.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 10:05:38 -0700 (PDT)
Received: by mail-wi0-f181.google.com with SMTP id bs8so4450155wib.14
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:05:37 -0700 (PDT)
Date: Mon, 21 Jul 2014 19:05:46 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
Message-ID: <20140721170546.GB15237@phenom.ffwll.local>
References: <53C7D645.3070607@amd.com>
 <20140720174652.GE3068@gmail.com>
 <53CD0961.4070505@amd.com>
 <53CD17FD.3000908@vodafone.de>
 <20140721152511.GW15237@phenom.ffwll.local>
 <20140721155851.GB4519@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140721155851.GB4519@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Christian =?iso-8859-1?Q?K=F6nig?= <deathsimple@vodafone.de>, Oded Gabbay <oded.gabbay@amd.com>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, Michel =?iso-8859-1?Q?D=E4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>

On Mon, Jul 21, 2014 at 11:58:52AM -0400, Jerome Glisse wrote:
> On Mon, Jul 21, 2014 at 05:25:11PM +0200, Daniel Vetter wrote:
> > On Mon, Jul 21, 2014 at 03:39:09PM +0200, Christian Konig wrote:
> > > Am 21.07.2014 14:36, schrieb Oded Gabbay:
> > > >On 20/07/14 20:46, Jerome Glisse wrote:
> > > >>On Thu, Jul 17, 2014 at 04:57:25PM +0300, Oded Gabbay wrote:
> > > >>>Forgot to cc mailing list on cover letter. Sorry.
> > > >>>
> > > >>>As a continuation to the existing discussion, here is a v2 patch series
> > > >>>restructured with a cleaner history and no
> > > >>>totally-different-early-versions
> > > >>>of the code.
> > > >>>
> > > >>>Instead of 83 patches, there are now a total of 25 patches, where 5 of
> > > >>>them
> > > >>>are modifications to radeon driver and 18 of them include only amdkfd
> > > >>>code.
> > > >>>There is no code going away or even modified between patches, only
> > > >>>added.
> > > >>>
> > > >>>The driver was renamed from radeon_kfd to amdkfd and moved to reside
> > > >>>under
> > > >>>drm/radeon/amdkfd. This move was done to emphasize the fact that this
> > > >>>driver
> > > >>>is an AMD-only driver at this point. Having said that, we do foresee a
> > > >>>generic hsa framework being implemented in the future and in that
> > > >>>case, we
> > > >>>will adjust amdkfd to work within that framework.
> > > >>>
> > > >>>As the amdkfd driver should support multiple AMD gfx drivers, we want
> > > >>>to
> > > >>>keep it as a seperate driver from radeon. Therefore, the amdkfd code is
> > > >>>contained in its own folder. The amdkfd folder was put under the radeon
> > > >>>folder because the only AMD gfx driver in the Linux kernel at this
> > > >>>point
> > > >>>is the radeon driver. Having said that, we will probably need to move
> > > >>>it
> > > >>>(maybe to be directly under drm) after we integrate with additional
> > > >>>AMD gfx
> > > >>>drivers.
> > > >>>
> > > >>>For people who like to review using git, the v2 patch set is located
> > > >>>at:
> > > >>>http://cgit.freedesktop.org/~gabbayo/linux/log/?h=kfd-next-3.17-v2
> > > >>>
> > > >>>Written by Oded Gabbayh <oded.gabbay@amd.com>
> > > >>
> > > >>So quick comments before i finish going over all patches. There is many
> > > >>things that need more documentation espacialy as of right now there is
> > > >>no userspace i can go look at.
> > > >So quick comments on some of your questions but first of all, thanks for
> > > >the time you dedicated to review the code.
> > > >>
> > > >>There few show stopper, biggest one is gpu memory pinning this is a big
> > > >>no, that would need serious arguments for any hope of convincing me on
> > > >>that side.
> > > >We only do gpu memory pinning for kernel objects. There are no userspace
> > > >objects that are pinned on the gpu memory in our driver. If that is the
> > > >case, is it still a show stopper ?
> > > >
> > > >The kernel objects are:
> > > >- pipelines (4 per device)
> > > >- mqd per hiq (only 1 per device)
> > > >- mqd per userspace queue. On KV, we support up to 1K queues per process,
> > > >for a total of 512K queues. Each mqd is 151 bytes, but the allocation is
> > > >done in 256 alignment. So total *possible* memory is 128MB
> > > >- kernel queue (only 1 per device)
> > > >- fence address for kernel queue
> > > >- runlists for the CP (1 or 2 per device)
> > > 
> > > The main questions here are if it's avoid able to pin down the memory and if
> > > the memory is pinned down at driver load, by request from userspace or by
> > > anything else.
> > > 
> > > As far as I can see only the "mqd per userspace queue" might be a bit
> > > questionable, everything else sounds reasonable.
> > 
> > Aside, i915 perspective again (i.e. how we solved this): When scheduling
> > away from contexts we unpin them and put them into the lru. And in the
> > shrinker we have a last-ditch callback to switch to a default context
> > (since you can't ever have no context once you've started) which means we
> > can evict any context object if it's getting in the way.
> 
> So Intel hardware report through some interrupt or some channel when it is
> not using a context ? ie kernel side get notification when some user context
> is done executing ?

Yes, as long as we do the scheduling with the cpu we get interrupts for
context switches. The mechanic is already published in the execlist
patches currently floating around. We get a special context switch
interrupt.

But we have this unpin logic already on the current code where we switch
contexts through in-line cs commands from the kernel. There we obviously
use the normal batch completion events.

> The issue with radeon hardware AFAICT is that the hardware do not report any
> thing about the userspace context running ie you do not get notification when
> a context is not use. Well AFAICT. Maybe hardware do provide that.

I'm not sure whether we can do the same trick with the hw scheduler. But
then unpinning hw contexts will drain the pipeline anyway, so I guess we
can just stop feeding the hw scheduler until it runs dry. And then unpin
and evict.

> Like the VMID is a limited resources so you have to dynamicly bind them so
> maybe we can only allocate pinned buffer for each VMID and then when binding
> a PASID to a VMID it also copy back pinned buffer to pasid unpinned copy.

Yeah, pasid assignment will be fun. Not sure whether Jesse's patches will
do this already. We _do_ already have fun with ctx id assigments though
since we move them around (and the hw id is the ggtt address afaik). So we
need to remap them already. Not sure on the details for pasid mapping,
iirc it's a separate field somewhere in the context struct. Jesse knows
the details.
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

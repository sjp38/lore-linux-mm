Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C32B6B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 11:58:53 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id a108so5603565qge.10
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 08:58:53 -0700 (PDT)
Received: from mail-qa0-x22a.google.com (mail-qa0-x22a.google.com [2607:f8b0:400d:c00::22a])
        by mx.google.com with ESMTPS id m9si28572424qge.84.2014.07.21.08.58.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 08:58:52 -0700 (PDT)
Received: by mail-qa0-f42.google.com with SMTP id j15so5399624qaq.29
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 08:58:52 -0700 (PDT)
Date: Mon, 21 Jul 2014 11:58:52 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
Message-ID: <20140721155851.GB4519@gmail.com>
References: <53C7D645.3070607@amd.com>
 <20140720174652.GE3068@gmail.com>
 <53CD0961.4070505@amd.com>
 <53CD17FD.3000908@vodafone.de>
 <20140721152511.GW15237@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140721152511.GW15237@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian =?iso-8859-1?Q?K=F6nig?= <deathsimple@vodafone.de>, Oded Gabbay <oded.gabbay@amd.com>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, Michel =?iso-8859-1?Q?D=E4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>

On Mon, Jul 21, 2014 at 05:25:11PM +0200, Daniel Vetter wrote:
> On Mon, Jul 21, 2014 at 03:39:09PM +0200, Christian Konig wrote:
> > Am 21.07.2014 14:36, schrieb Oded Gabbay:
> > >On 20/07/14 20:46, Jerome Glisse wrote:
> > >>On Thu, Jul 17, 2014 at 04:57:25PM +0300, Oded Gabbay wrote:
> > >>>Forgot to cc mailing list on cover letter. Sorry.
> > >>>
> > >>>As a continuation to the existing discussion, here is a v2 patch series
> > >>>restructured with a cleaner history and no
> > >>>totally-different-early-versions
> > >>>of the code.
> > >>>
> > >>>Instead of 83 patches, there are now a total of 25 patches, where 5 of
> > >>>them
> > >>>are modifications to radeon driver and 18 of them include only amdkfd
> > >>>code.
> > >>>There is no code going away or even modified between patches, only
> > >>>added.
> > >>>
> > >>>The driver was renamed from radeon_kfd to amdkfd and moved to reside
> > >>>under
> > >>>drm/radeon/amdkfd. This move was done to emphasize the fact that this
> > >>>driver
> > >>>is an AMD-only driver at this point. Having said that, we do foresee a
> > >>>generic hsa framework being implemented in the future and in that
> > >>>case, we
> > >>>will adjust amdkfd to work within that framework.
> > >>>
> > >>>As the amdkfd driver should support multiple AMD gfx drivers, we want
> > >>>to
> > >>>keep it as a seperate driver from radeon. Therefore, the amdkfd code is
> > >>>contained in its own folder. The amdkfd folder was put under the radeon
> > >>>folder because the only AMD gfx driver in the Linux kernel at this
> > >>>point
> > >>>is the radeon driver. Having said that, we will probably need to move
> > >>>it
> > >>>(maybe to be directly under drm) after we integrate with additional
> > >>>AMD gfx
> > >>>drivers.
> > >>>
> > >>>For people who like to review using git, the v2 patch set is located
> > >>>at:
> > >>>http://cgit.freedesktop.org/~gabbayo/linux/log/?h=kfd-next-3.17-v2
> > >>>
> > >>>Written by Oded Gabbayh <oded.gabbay@amd.com>
> > >>
> > >>So quick comments before i finish going over all patches. There is many
> > >>things that need more documentation espacialy as of right now there is
> > >>no userspace i can go look at.
> > >So quick comments on some of your questions but first of all, thanks for
> > >the time you dedicated to review the code.
> > >>
> > >>There few show stopper, biggest one is gpu memory pinning this is a big
> > >>no, that would need serious arguments for any hope of convincing me on
> > >>that side.
> > >We only do gpu memory pinning for kernel objects. There are no userspace
> > >objects that are pinned on the gpu memory in our driver. If that is the
> > >case, is it still a show stopper ?
> > >
> > >The kernel objects are:
> > >- pipelines (4 per device)
> > >- mqd per hiq (only 1 per device)
> > >- mqd per userspace queue. On KV, we support up to 1K queues per process,
> > >for a total of 512K queues. Each mqd is 151 bytes, but the allocation is
> > >done in 256 alignment. So total *possible* memory is 128MB
> > >- kernel queue (only 1 per device)
> > >- fence address for kernel queue
> > >- runlists for the CP (1 or 2 per device)
> > 
> > The main questions here are if it's avoid able to pin down the memory and if
> > the memory is pinned down at driver load, by request from userspace or by
> > anything else.
> > 
> > As far as I can see only the "mqd per userspace queue" might be a bit
> > questionable, everything else sounds reasonable.
> 
> Aside, i915 perspective again (i.e. how we solved this): When scheduling
> away from contexts we unpin them and put them into the lru. And in the
> shrinker we have a last-ditch callback to switch to a default context
> (since you can't ever have no context once you've started) which means we
> can evict any context object if it's getting in the way.

So Intel hardware report through some interrupt or some channel when it is
not using a context ? ie kernel side get notification when some user context
is done executing ?

The issue with radeon hardware AFAICT is that the hardware do not report any
thing about the userspace context running ie you do not get notification when
a context is not use. Well AFAICT. Maybe hardware do provide that.

Like the VMID is a limited resources so you have to dynamicly bind them so
maybe we can only allocate pinned buffer for each VMID and then when binding
a PASID to a VMID it also copy back pinned buffer to pasid unpinned copy.

Cheers,
Jerome

> 
> We must do that since the contexts have to be in global gtt, which is
> shared for scanouts. So fragmenting that badly with lots of context
> objects and other stuff is a no-go, since that means we'll start to fail
> pageflips.
> 
> I don't know whether ttm has a ready-made concept for such
> opportunistically pinned stuff. I guess you could wire up the "switch to
> dflt context" action to the evict/move function if ttm wants to get rid of
> the currently used hw context.
> 
> Oh and: This is another reason for letting the kernel schedule contexts,
> since you can't do this defrag trick if the gpu does all the scheduling
> itself.
> -Daniel
> -- 
> Daniel Vetter
> Software Engineer, Intel Corporation
> +41 (0) 79 365 57 48 - http://blog.ffwll.ch
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> http://lists.freedesktop.org/mailman/listinfo/dri-devel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

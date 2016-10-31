Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5642F6B0290
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 15:28:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r68so25819788wmd.0
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 12:28:30 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id u197si26216696wmf.33.2016.10.31.12.28.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 12:28:29 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id u144so599662wmu.0
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 12:28:28 -0700 (PDT)
Date: Mon, 31 Oct 2016 19:28:26 +0000
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH 2/2] mm: remove get_user_pages_locked()
Message-ID: <20161031192826.GA13380@lucifer>
References: <20161031100228.17917-1-lstoakes@gmail.com>
 <20161031100228.17917-3-lstoakes@gmail.com>
 <cc508436-156e-eb4b-ae01-b44f33c2d692@redhat.com>
 <20161031134849.GA13609@lucifer>
 <ddbe34d0-5d29-abce-1627-f464635bbfe6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ddbe34d0-5d29-abce-1627-f464635bbfe6@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, kvm@vger.kernel.org, linux-media@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, Oct 31, 2016 at 06:55:33PM +0100, Paolo Bonzini wrote:
> > 2. There is currently only one caller of get_user_pages_locked() in
> >    mm/frame_vector.c which seems to suggest this function isn't widely
> >    used/known.
>
> Or not widely necessary. :)

Well, quite :)
>
> > 3. This change results in all slow-path get_user_pages*() functions having the
> >    ability to use VM_FAULT_RETRY logic rather than 'defaulting' to using
> >    get_user_pages() that doesn't let you do this even if you wanted to.
>
> This is only true if someone does the work though.  From a quick look
> at your series, the following files can be trivially changed to use
> get_user_pages_unlocked:
>
> - drivers/gpu/drm/via/via_dmablit.c
> - drivers/platform/goldfish/goldfish_pipe.c
> - drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
> - drivers/rapidio/devices/rio_mport_cdev.c
> - drivers/virt/fsl_hypervisor.c
>

Ah indeed, I rather glossed through the callers and noticed that at least some
held locks long enough or were called with a lock held sufficient that I wasn't
sure it could be released.

> Also, videobuf_dma_init_user could be changed to use retry by adding a
> *locked argument to videobuf_dma_init_user_locked, prototype patch
> after my signature.
>

Very nice!

> Everything else is probably best kept using get_user_pages.
>
> > 4. It's somewhat confusing/redundant having both get_user_pages_locked() and
> >    get_user_pages() functions which both require mmap_sem to be held (i.e. both
> >    are 'locked' versions.)
> >
> >> If all callers were changed, then sure removing the _locked suffix would
> >> be a good idea.
> >
> > It seems many callers cannot release mmap_sem so VM_FAULT_RETRY logic couldn't
> > happen anyway in this cases and in these cases we couldn't change the caller.
>
> But then get_user_pages_locked remains a less-common case, so perhaps
> it's a good thing to give it a longer name!

My (somewhat minor) concern was that there would be confusion due to the
existence of the triumvirate of g_u_p()/g_u_p_unlocked()/g_u_p_locked(), however
the comments do a decent enough job of explaining the situation.

>
> > Overall, an alternative here might be to remove get_user_pages() and update
> > get_user_pages_locked() to add a 'vmas' parameter, however doing this renders
> > get_user_pages_unlocked() asymmetric as it would lack an vmas parameter (adding
> > one there would make no sense as VM_FAULT_RETRY logic invalidates VMAs) though
> > perhaps not such a big issue as it makes sense as to why this is the case.
>
> Adding the 'vmas' parameter to get_user_pages_locked would make little
> sense.  Since VM_FAULT_RETRY invalidates it and g_u_p_locked can and
> does retry, it would generally not be useful.

I meant only in the case where we'd remove get_user_pages() and instead be left
with get_user_pages_[un]locked() only, meaning we'd have to add some means of
retrieving vmas if locked was set NULL, of course in cases where locked is not
NULL it makes no sense to add it.

>
> So I think we have the right API now:
>
> - do not have lock?  Use get_user_pages_unlocked, get retry for free,
> no need to handle  mmap_sem and the locked argument; cannot get back vmas.
>
> - have and cannot drop lock?  User get_user_pages, no need to pass NULL
> for the locked argument; can get back vmas.
>
> - have but can drop lock (rare case)?  Use get_user_pages_locked,
> cannot get back vams.

Yeah I think this is sane as it is actually, this patch set was a lot less
convincing of a cleanup than prior ones and overall it seems we are better off
with the existing API.

I wonder whether a better patch series to come out of this would be to find
cases where the lock could be dropped (i.e. the ones you mention above) and to
switch to using get_user_pages_[un]locked() where it makes sense to.

I am happy to look into these cases (though of course I must leave your
suggested patch here to you :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

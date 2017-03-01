Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA6116B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 03:43:31 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id e15so13775215wmd.6
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 00:43:31 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id g16si21036242wmg.156.2017.03.01.00.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 00:43:30 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id m70so6049025wma.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 00:43:30 -0800 (PST)
Date: Wed, 1 Mar 2017 09:43:26 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH RESEND] drm/via: use get_user_pages_unlocked()
Message-ID: <20170301084326.tdz32zvjg62znclq@phenom.ffwll.local>
References: <20170227215008.21457-1-lstoakes@gmail.com>
 <20170228090110.m4pxtjlbgaft7oet@phenom.ffwll.local>
 <20170228193539.GT29622@ZenIV.linux.org.uk>
 <CAA5enKa4Asp4qSHkeV3saLZrhOMf2DJ9vuiwTDo1t5t54z4sTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA5enKa4Asp4qSHkeV3saLZrhOMf2DJ9vuiwTDo1t5t54z4sTQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dri-devel@lists.freedesktop.org, linux-mm <linux-mm@kvack.org>

On Tue, Feb 28, 2017 at 08:28:08PM +0000, Lorenzo Stoakes wrote:
> On 28 February 2017 at 19:35, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > On Tue, Feb 28, 2017 at 10:01:10AM +0100, Daniel Vetter wrote:
> >
> >> > +   ret = get_user_pages_unlocked((unsigned long)xfer->mem_addr,
> >> > +                   vsg->num_pages, vsg->pages,
> >> > +                   (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0);
> >
> > Umm...  Why not
> >         ret = get_user_pages_fast((unsigned long)xfer->mem_addr,
> >                         vsg->num_pages,
> >                         vsg->direction == DMA_FROM_DEVICE,
> >                         vsg->pages);
> >
> > IOW, do you really need a warranty that ->mmap_sem will be grabbed and
> > released?
> 
> Daniel will be better placed to answer in this specific case, but more
> generally is there any reason why we can't just use
> get_user_pages_fast() in all such cases? These patches were simply a
> mechanical/cautious replacement for code that is more or less exactly
> equivalent but if this would make sense perhaps it'd be worth using
> gup_fast() where possible?

I have no idea. drm/via is unmaintained, it's a dri1 racy driver with
problems probably everywhere, and I'm not sure we even have someone left
who cares (there's an out-of-tree kms conversion of via, but it's stuck
since years).

In short, it's the drm dungeons and the only reason I merge patches is to
give people an easy target for test driving the patch submission process
to dri-devel. And to avoid drm being a blocker for tree-wide refactorings.
Otherwise 0 reasons to change anything here.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

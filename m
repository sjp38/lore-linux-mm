Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD45E6B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 17:34:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r74so2074578wrb.7
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 14:34:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t50si7968918wrc.507.2017.09.26.14.34.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 14:34:32 -0700 (PDT)
Date: Tue, 26 Sep 2017 23:34:40 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 02/22] drm/i915: introduce simple gemfs
Message-ID: <20170926213440.GD3418@kroah.com>
References: <20170925184737.8807-1-matthew.auld@intel.com>
 <20170925184737.8807-3-matthew.auld@intel.com>
 <20170926075221.GB32088@kroah.com>
 <1506432107.5228.26.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506432107.5228.26.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Matthew Auld <matthew.auld@intel.com>, devel@driverdev.osuosl.org, Dave Hansen <dave.hansen@intel.com>, intel-gfx@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, dri-devel@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, Riley Andrews <riandrews@android.com>, Daniel Vetter <daniel.vetter@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Sep 26, 2017 at 04:21:47PM +0300, Joonas Lahtinen wrote:
> On Tue, 2017-09-26 at 09:52 +0200, Greg Kroah-Hartman wrote:
> > On Mon, Sep 25, 2017 at 07:47:17PM +0100, Matthew Auld wrote:
> > > Not a fully blown gemfs, just our very own tmpfs kernel mount. Doing so
> > > moves us away from the shmemfs shm_mnt, and gives us the much needed
> > > flexibility to do things like set our own mount options, namely huge=
> > > which should allow us to enable the use of transparent-huge-pages for
> > > our shmem backed objects.
> > > 
> > > v2: various improvements suggested by Joonas
> > > 
> > > v3: move gemfs instance to i915.mm and simplify now that we have
> > > file_setup_with_mnt
> > > 
> > > v4: fallback to tmpfs shm_mnt upon failure to setup gemfs
> > > 
> > > v5: make tmpfs fallback kinder
> > 
> > Why do this only for one specific driver?  Shouldn't the drm core handle
> > this for you, for all other drivers as well?  Otherwise trying to figure
> > out how to "contain" this type of thing is going to be a pain (mount
> > options, selinux options, etc.)
> 
> We actually started quite grande by making stripped down version of
> shmemfs for drm core, but kept running into nacks about how we were
> implementing it (after getting a recommendation to try implementing it
> some way). After a few iterations and massive engineering time, we have
> been progressively reducing the amount of changes outside i915 in the
> hopes to get this merged.
> 
> And all the while clock is ticking, so we thought the best way to get
> something to support our future work is to implement this first locally
> with minimal external changes outside i915 and then once we have
> something working, it'll be easier to generalize it for the drm core.
> Otherwise we'll never get to work with the huge page support, for which
> gemfs is the stepping stone here.
> 
> So we're not planning on sitting on top of it, we'll just incubate it
> under i915/ so that it'll then be less pain for others to adopt when
> the biggest hurdles with core MM interactions are sorted out.

But by doing this, you are now creating a new user/kernel api that you
have to support for forever, right?  Will it not change if you make it
"generic" to the drm core eventually?

Worse case, name it a generic name that everyone will end up using in
the future, and then you can just claim that all other drivers need to
implement it :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

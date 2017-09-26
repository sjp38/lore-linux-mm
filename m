Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4CEA6B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:22:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f84so18242462pfj.0
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:22:07 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id n73si2143943pfi.98.2017.09.26.06.22.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 06:22:06 -0700 (PDT)
Message-ID: <1506432107.5228.26.camel@linux.intel.com>
Subject: Re: [PATCH 02/22] drm/i915: introduce simple gemfs
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Tue, 26 Sep 2017 16:21:47 +0300
In-Reply-To: <20170926075221.GB32088@kroah.com>
References: <20170925184737.8807-1-matthew.auld@intel.com>
	 <20170925184737.8807-3-matthew.auld@intel.com>
	 <20170926075221.GB32088@kroah.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Matthew Auld <matthew.auld@intel.com>
Cc: intel-gfx@lists.freedesktop.org, devel@driverdev.osuosl.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Riley Andrews <riandrews@android.com>, dri-devel@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, Dave Hansen <dave.hansen@intel.com>, Arve =?ISO-8859-1?Q?Hj=F8nnev=E5g?= <arve@android.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Daniel Vetter <daniel.vetter@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2017-09-26 at 09:52 +0200, Greg Kroah-Hartman wrote:
> On Mon, Sep 25, 2017 at 07:47:17PM +0100, Matthew Auld wrote:
> > Not a fully blown gemfs, just our very own tmpfs kernel mount. Doing so
> > moves us away from the shmemfs shm_mnt, and gives us the much needed
> > flexibility to do things like set our own mount options, namely huge=
> > which should allow us to enable the use of transparent-huge-pages for
> > our shmem backed objects.
> > 
> > v2: various improvements suggested by Joonas
> > 
> > v3: move gemfs instance to i915.mm and simplify now that we have
> > file_setup_with_mnt
> > 
> > v4: fallback to tmpfs shm_mnt upon failure to setup gemfs
> > 
> > v5: make tmpfs fallback kinder
> 
> Why do this only for one specific driver?  Shouldn't the drm core handle
> this for you, for all other drivers as well?  Otherwise trying to figure
> out how to "contain" this type of thing is going to be a pain (mount
> options, selinux options, etc.)

We actually started quite grande by making stripped down version of
shmemfs for drm core, but kept running into nacks about how we were
implementing it (after getting a recommendation to try implementing it
some way). After a few iterations and massive engineering time, we have
been progressively reducing the amount of changes outside i915 in the
hopes to get this merged.

And all the while clock is ticking, so we thought the best way to get
something to support our future work is to implement this first locally
with minimal external changes outside i915 and then once we have
something working, it'll be easier to generalize it for the drm core.
Otherwise we'll never get to work with the huge page support, for which
gemfs is the stepping stone here.

So we're not planning on sitting on top of it, we'll just incubate it
under i915/ so that it'll then be less pain for others to adopt when
the biggest hurdles with core MM interactions are sorted out.

Regards, Joonas
-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 99FB46B0007
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 16:36:17 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id t1so7850779oth.21
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 13:36:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x10si1857834oif.241.2018.02.20.13.36.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 13:36:16 -0800 (PST)
Date: Wed, 21 Feb 2018 08:36:04 +1100
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: [RFC PATCH v16 0/6] mm: security: ro protection for dynamic data
Message-ID: <20180220213604.GD3728@rh>
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
 <CAGXu5j+ZNFX17Vxd37rPnkahFepFn77Fi9zEy+OL8nNd_2bjqQ@mail.gmail.com>
 <20180220012111.GC3728@rh>
 <24e65dec-f452-a444-4382-d1f88fbb334c@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24e65dec-f452-a444-4382-d1f88fbb334c@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Tue, Feb 20, 2018 at 08:03:49PM +0200, Igor Stoppa wrote:
> 
> 
> On 20/02/18 03:21, Dave Chinner wrote:
> > On Mon, Feb 12, 2018 at 03:32:36PM -0800, Kees Cook wrote:
> >> On Mon, Feb 12, 2018 at 8:52 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
> >>> This patch-set introduces the possibility of protecting memory that has
> >>> been allocated dynamically.
> >>>
> >>> The memory is managed in pools: when a memory pool is turned into R/O,
> >>> all the memory that is part of it, will become R/O.
> >>>
> >>> A R/O pool can be destroyed, to recover its memory, but it cannot be
> >>> turned back into R/W mode.
> >>>
> >>> This is intentional. This feature is meant for data that doesn't need
> >>> further modifications after initialization.
> >>
> >> This series came up in discussions with Dave Chinner (and Matthew
> >> Wilcox, already part of the discussion, and others) at LCA. I wonder
> >> if XFS would make a good initial user of this, as it could allocate
> >> all the function pointers and other const information about a
> >> superblock in pmalloc(), keeping it separate from the R/W portions?
> >> Could other filesystems do similar things?
> > 
> > I wasn't cc'd on this patchset, (please use david@fromorbit.com for
> > future postings) 
> 
> Apologies, somehow I didn't realize that I should have put you too in
> CC. It will be fixed at the next iteration.

No worries, If you weren't at LCA, you wouldn't have known :P

> > so I can't really say anything about it right
> > now. My interest for XFS was that we have a fair amount of static
> > data in XFS that we set up at mount time and it never gets modified
> > after that.
> 
> This is the typical use case I had in mind, although it requires a
> conversion.
> Ex:
> 
> before:
> 
> static int a;
> 
> 
> void set_a(void)
> {
> 	a = 4;
> }
> 
> 
> 
> after:
> 
> static int *a __ro_after_init;
> struct gen_pool *pool;
> 
> void init_a(void)
> {
> 	pool = pmalloc_create_pool("pool", 0);
> 	a = (int *)pmalloc(pool, sizeof(int), GFP_KERNEL);
> }
> 
> void set_a(void)
> {
> 	*a = 4;
> 	pmalloc_protect_pool(pool);
> }

Yeah, that's kinda what I figured. I'm guessing that I treat a pool
just like a normal heap allocation, but then when all the objects I
need to allocate are fully initialised, then I write protect the
pool? i.e. the API isn't using an object-based protection scope?

FWIW, I'm not wanting to use it to replace static variables. All the
structures are dynamically allocated right now, and get assigned to
other dynamically allocated pointers. I'd likely split the current
structures into a "ro after init" structure and rw structure, so
how does the "__ro_after_init" attribute work in that case? Is it
something like this?

struct xfs_mount {
	struct xfs_mount_ro{
		.......
	} *ro __ro_after_init;
	......

Also, what compile time checks are in place to catch writes to
ro structure members? Is sparse going to be able to check this sort
of thing, like is does with endian-specific variables?

> I'd be interested to have your review of the pmalloc API, if you think
> something is missing, once I send out the next revision.

I'll look at it in more depth when it comes past again. :P

Cheers,

Dave.
-- 
Dave Chinner
dchinner@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

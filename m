Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E2D096B000E
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 18:56:15 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id x3so5063754plo.9
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 15:56:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d5-v6si7861738plm.759.2018.02.20.15.56.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Feb 2018 15:56:14 -0800 (PST)
Date: Tue, 20 Feb 2018 15:56:00 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH v16 0/6] mm: security: ro protection for dynamic data
Message-ID: <20180220235600.GA3706@bombadil.infradead.org>
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
 <CAGXu5j+ZNFX17Vxd37rPnkahFepFn77Fi9zEy+OL8nNd_2bjqQ@mail.gmail.com>
 <20180220012111.GC3728@rh>
 <24e65dec-f452-a444-4382-d1f88fbb334c@huawei.com>
 <20180220213604.GD3728@rh>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180220213604.GD3728@rh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, Kees Cook <keescook@chromium.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, Feb 21, 2018 at 08:36:04AM +1100, Dave Chinner wrote:
> FWIW, I'm not wanting to use it to replace static variables. All the
> structures are dynamically allocated right now, and get assigned to
> other dynamically allocated pointers. I'd likely split the current
> structures into a "ro after init" structure and rw structure, so
> how does the "__ro_after_init" attribute work in that case? Is it
> something like this?
> 
> struct xfs_mount {
> 	struct xfs_mount_ro{
> 		.......
> 	} *ro __ro_after_init;
> 	......

No, you'd do:

struct xfs_mount_ro {
	[...]
};

struct xfs_mount {
	const struct xfs_mount_ro *ro;
	[...]
};

We can't do protection on less than a page boundary, so you can't embed
a ro struct inside a rw struct.

> Also, what compile time checks are in place to catch writes to
> ro structure members? Is sparse going to be able to check this sort
> of thing, like is does with endian-specific variables?

Just labelling the pointer const should be enough for the compiler to
catch unintended writes.

> > I'd be interested to have your review of the pmalloc API, if you think
> > something is missing, once I send out the next revision.
> 
> I'll look at it in more depth when it comes past again. :P

I think the key question is whether you want a slab-style interface
or whether you want a kmalloc-style interface.  I'd been assuming
the former, but Igor has implemented the latter already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

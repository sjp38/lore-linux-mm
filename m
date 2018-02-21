Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id AFA5B6B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 16:36:42 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id 20so1405583oii.1
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 13:36:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j6si3386851oth.32.2018.02.21.13.36.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 13:36:41 -0800 (PST)
Date: Thu, 22 Feb 2018 08:36:29 +1100
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: [RFC PATCH v16 0/6] mm: security: ro protection for dynamic data
Message-ID: <20180221213629.GF3728@rh>
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
 <CAGXu5j+ZNFX17Vxd37rPnkahFepFn77Fi9zEy+OL8nNd_2bjqQ@mail.gmail.com>
 <20180220012111.GC3728@rh>
 <24e65dec-f452-a444-4382-d1f88fbb334c@huawei.com>
 <20180220213604.GD3728@rh>
 <20180220235600.GA3706@bombadil.infradead.org>
 <20180221013636.GE3728@rh>
 <46a9610a-182b-4765-9d83-cab6297377f3@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46a9610a-182b-4765-9d83-cab6297377f3@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, Feb 21, 2018 at 11:56:22AM +0200, Igor Stoppa wrote:
> On 21/02/18 03:36, Dave Chinner wrote:
> > On Tue, Feb 20, 2018 at 03:56:00PM -0800, Matthew Wilcox wrote:
> >> On Wed, Feb 21, 2018 at 08:36:04AM +1100, Dave Chinner wrote:
> >>> FWIW, I'm not wanting to use it to replace static variables. All the
> >>> structures are dynamically allocated right now, and get assigned to
> >>> other dynamically allocated pointers. I'd likely split the current
> >>> structures into a "ro after init" 
> 
> I would prefer to use a different terminology, because, if I have
> understood the use case, this is not exactly the same as __ro_after_init

I want a dynamically allocated "write once" structure.

A "write once" structure is, conceptually, is exactly the same as
"ro after init". Implementation wise, it may be different to
"__ro_after_init", especially when compared to static/global
variables.

It seems lots of people get confused when discussing concepts vs
implementation... :)

> >>> 	......
> >>
> >> No, you'd do:
> >>
> >> struct xfs_mount_ro {
> >> 	[...]
> >> };
> 
> is this something that is readonly from the beginning and then shared
> among mount points or is it specific to each mount point?

It's dynamically allocated for each mount point, made read-only
before the mount completes and lives for the length of the mount
point.

> >> struct xfs_mount {
> >> 	const struct xfs_mount_ro *ro;
> >> 	[...]
> >> };
> > 
> > .... so that's pretty much the same thing :P
> 
> The "const" modifier is a nice way to catch errors through the compiler,
> iff the ro data will not be initialized through this handle, when it's
> still writable.

That's kinda implied by the const, isn't it? If we don't do it that
way, then the compiler will throw errors....

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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9AFF26B00A0
	for <linux-mm@kvack.org>; Mon, 18 May 2015 06:31:36 -0400 (EDT)
Received: by qcvo8 with SMTP id o8so86908375qcv.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 03:31:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f136si6355335qka.63.2015.05.18.03.31.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 03:31:36 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CALq1K=KSkPB9LY__rh04ic_rv2H0rGCLNfeKoY-+U2=EF32sBg@mail.gmail.com>
References: <CALq1K=KSkPB9LY__rh04ic_rv2H0rGCLNfeKoY-+U2=EF32sBg@mail.gmail.com>
Subject: Re: [RFC] Refactor kenter/kleave/kdebug macros
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <7253.1431945085.1@warthog.procyon.org.uk>
Date: Mon, 18 May 2015 11:31:25 +0100
Message-ID: <7254.1431945085@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@leon.nu>
Cc: dhowells@redhat.com, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-cachefs@redhat.com, linux-afs@lists.infradead.org

Leon Romanovsky <leon@leon.nu> wrote:

> During my work on NOMMU system (mm/nommu.c), I saw definition and
> usage of kenter/kleave/kdebug macros. These macros are compiled as
> empty because of "#if 0" construction.

Because you only need them if you're debugging.  They shouldn't, generally, be
turned on upstream.

> This code was changed in 2009 [1] and similar definitions can be found
> in 9 other files [2]. The protection of these definitions is slightly
> different. There are places with "#if 0" protection and others with
> "#if defined(__KDEBUG)" protection. __KDEBUG is supposed to be
> inserted by GCC.

I can turn on all the macros in a file just be #defining __KDEBUG at the top.
When I first did this, pr_xxx() didn't exist.

Note that the macros in afs, cachefiles, fscache and rxrpc are more complex
than a grep tells you.  There are _enter(), _leave() and _debug() macros which
are conditional via a module parameter.  These are trivially individually
enableable during debugging by changing the initial underscore to a 'k'.  They
are otherwise enableable by module parameter (macros are individually
selectable) or enableably by file __KDEBUG.  These are well used.  Note that
just turning them all into pr_devel() would represent a loss of useful
function.

The ones in the keys directory are also very well used, though they aren't
externally selectable.  I've added functionality to the debugging, but haven't
necessarily needed to backport it to earlier variants.

For the mn10300 macros, I would just recommend leaving them as is.

For the nommu macros, you could convert them to pr_devel() - but putting all
the information in the kenter/kleave/kdebug macro into each pr_devel macro
would be more intrusive in the code since you'd have to move the stuff out of
there macro definition into each caller.  You could also reexpress the macros
in terms of pr_devel and get rid of the conditional.  OTOH, there's not that
much in the nommu code, so you could probably slim down a lot of what's
printed.

For the cred macro, just convert to pr_devel() or pr_debug() and make pr_fmt
insert current->comm and current->pid.

> 2. Move it to general include file (for example linux/printk.h) and
> commonize the output to be consistent between different kdebug users.

I would quite like to see kenter() and kleave() be moved to printk.h,
expressed in a similar way to pr_devel() or pr_debug() (and perhaps renamed
pr_enter() and pr_leave()) but separately so they can be enabled separately.
OTOH, possibly they should be enableable by compilation block rather than by
macro set.

The main thing I like out of the ones in afs, cachefiles, fscache and rxrpc is
the ability to just turn on a few across a bunch of files so as not to get
overwhelmed by data.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

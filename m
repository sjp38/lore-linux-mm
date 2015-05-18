Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2F66D6B00B8
	for <linux-mm@kvack.org>; Mon, 18 May 2015 09:27:26 -0400 (EDT)
Received: by wgjc11 with SMTP id c11so27031470wgj.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 06:27:25 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id dc7si17714195wjc.204.2015.05.18.06.27.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 06:27:24 -0700 (PDT)
Received: by wicnf17 with SMTP id nf17so69647604wic.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 06:27:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALq1K=J4iRqD5qiSr2S7m+jgr63K7=e1PmA-pX1s4MEDimsLbw@mail.gmail.com>
References: <CALq1K=KSkPB9LY__rh04ic_rv2H0rGCLNfeKoY-+U2=EF32sBg@mail.gmail.com>
 <7254.1431945085@warthog.procyon.org.uk> <CALq1K=J4iRqD5qiSr2S7m+jgr63K7=e1PmA-pX1s4MEDimsLbw@mail.gmail.com>
From: Leon Romanovsky <leon@leon.nu>
Date: Mon, 18 May 2015 16:27:03 +0300
Message-ID: <CALq1K=Jz95du5B+foiSEDkkUXHwCvHtqyLhij_NK20EPMHrm+A@mail.gmail.com>
Subject: Re: [RFC] Refactor kenter/kleave/kdebug macros
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-cachefs <linux-cachefs@redhat.com>, linux-afs <linux-afs@lists.infradead.org>

Sorry for reposting.

On Mon, May 18, 2015 at 1:31 PM, David Howells <dhowells@redhat.com> wrote:
>
> I can turn on all the macros in a file just be #defining __KDEBUG at the
> top.
> When I first did this, pr_xxx() didn't exist.
>
> Note that the macros in afs, cachefiles, fscache and rxrpc are more
> complex
> than a grep tells you.  There are _enter(), _leave() and _debug() macros
> which
> are conditional via a module parameter.  These are trivially individually
> enableable during debugging by changing the initial underscore to a 'k'.
> They
> are otherwise enableable by module parameter (macros are individually
> selectable) or enableably by file __KDEBUG.  These are well used.  Note
> that
> just turning them all into pr_devel() would represent a loss of useful
> function.
>
> The ones in the keys directory are also very well used, though they aren't
> externally selectable.  I've added functionality to the debugging, but
> haven't
> necessarily needed to backport it to earlier variants.
>
> For the mn10300 macros, I would just recommend leaving them as is.
>
> For the nommu macros, you could convert them to pr_devel() - but putting
> all
> the information in the kenter/kleave/kdebug macro into each pr_devel macro
> would be more intrusive in the code since you'd have to move the stuff out
> of
> there macro definition into each caller.  You could also reexpress the
> macros
> in terms of pr_devel and get rid of the conditional.  OTOH, there's not
> that
> much in the nommu code, so you could probably slim down a lot of what's
> printed.
>
> For the cred macro, just convert to pr_devel() or pr_debug() and make
> pr_fmt
> insert current->comm and current->pid.
>
> > 2. Move it to general include file (for example linux/printk.h) and
> > commonize the output to be consistent between different kdebug users.
>
> I would quite like to see kenter() and kleave() be moved to printk.h,
> expressed in a similar way to pr_devel() or pr_debug() (and perhaps
> renamed
> pr_enter() and pr_leave()) but separately so they can be enabled
> separately.
> OTOH, possibly they should be enableable by compilation block rather than
> by
> macro set.
>
> The main thing I like out of the ones in afs, cachefiles, fscache and
> rxrpc is
> the ability to just turn on a few across a bunch of files so as not to get
> overwhelmed by data.

 Blind conversion to pr_debug will blow the code because it will be always
 compiled in. In current implementation, it replaced by empty functions which
 is thrown by compiler.

 Additionally, It looks like the output of these macros can be viewed by
 ftrace mechanism.

 Maybe we should delete them from mm/nommu.c as was pointed by Joe?


>
>
> David




 --
 Leon Romanovsky | Independent Linux Consultant
         www.leon.nu | leon@leon.nu



-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

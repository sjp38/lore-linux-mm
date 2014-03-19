Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f174.google.com (mail-ve0-f174.google.com [209.85.128.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5D18D6B014C
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 22:57:01 -0400 (EDT)
Received: by mail-ve0-f174.google.com with SMTP id oz11so7947823veb.5
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:57:01 -0700 (PDT)
Received: from mail-ve0-x22f.google.com (mail-ve0-x22f.google.com [2607:f8b0:400c:c01::22f])
        by mx.google.com with ESMTPS id w5si7200661vcl.141.2014.03.18.19.57.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 19:57:00 -0700 (PDT)
Received: by mail-ve0-f175.google.com with SMTP id oz11so8135869veb.34
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:57:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1403181928370.3499@eggly.anvils>
References: <20140311045109.GB12551@redhat.com>
	<20140310220158.7e8b7f2a.akpm@linux-foundation.org>
	<20140311053017.GB14329@redhat.com>
	<20140311132024.GC32390@moon>
	<531F0E39.9020100@oracle.com>
	<20140311134158.GD32390@moon>
	<20140311142817.GA26517@redhat.com>
	<20140311143750.GE32390@moon>
	<20140311171045.GA4693@redhat.com>
	<20140311173603.GG32390@moon>
	<20140311173917.GB4693@redhat.com>
	<alpine.LSU.2.11.1403181703470.7055@eggly.anvils>
	<CA+55aFx0ZyCVrkosgTongBrNX6mJM4B8+QZQE1p0okk8ubbv7g@mail.gmail.com>
	<alpine.LSU.2.11.1403181848380.3318@eggly.anvils>
	<CA+55aFxVG7HLmsvCzoiA7PBRPvX3utRfyVGrBs6gVLZ-fUCuPQ@mail.gmail.com>
	<alpine.LSU.2.11.1403181928370.3499@eggly.anvils>
Date: Tue, 18 Mar 2014 19:57:00 -0700
Message-ID: <CA+55aFyjXdfsGniSHvCg83KCB-BD4SYNrJ+dcpr-8bnHsoet_Q@mail.gmail.com>
Subject: Re: bad rss-counter message in 3.14rc5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, Mar 18, 2014 at 7:37 PM, Hugh Dickins <hughd@google.com> wrote:
>
> For 3.15, and probably 3.16 too, we should keep in place whatever
> partial accommodations we have for the case (such as allowing for
> anon and swap in fremap's zap_pte), in case we do need to revert;
> but clean those away later on.  (Not many, I think: it was mainly
> a guilty secret that VM accounting didn't really hold together.)

Absolutely. See if it works to just stop doing that special COW, and
then later on, if we have decided "nobody even noticed", we can remove
the hacks we have to support the fact that shared mappings sometimes
have anon pages in them.

> :)  That fits with what I heard of HP-UX mmap,
> but I never had the pleasure of dealing with it.

They had purely virtually indexed caches, making coherency
"interesting". Together with a VM based on some really old BSD VM code
that everybody else had thrown out, and that didn't allow you to unmap
things partially etc. So HPUX mmap really didn't work, not even for
non-shared mmap's.

I think they fixed the interfaces in HP-UX 11. But not being coherent
meant that the shared mappings tended to still have trouble. nntp
largely died, but was replaced with the cyrus imapd that played
similar games.

At least out mmap was always coherent. Even in MAP_PRIVATE, and with
regards to both write() system calls and other mmap PROT_WRITE users.

Except when we had bugs. Shared mmap really isn't very simple to get right.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

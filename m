Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id A6B946B0255
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 15:30:32 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id 77so99644500ioc.2
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 12:30:32 -0800 (PST)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id sb8si7231851igb.39.2016.01.22.12.30.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 12:30:32 -0800 (PST)
Received: by mail-io0-x243.google.com with SMTP id k127so8489441iok.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 12:30:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56A28613.5070104@de.ibm.com>
References: <20151228211015.GL2194@uranus>
	<CA+55aFzxT02gGCAokDFich=kjsf1VtvL=i315Uk9p=HRrCAY5Q@mail.gmail.com>
	<56A28613.5070104@de.ibm.com>
Date: Fri, 22 Jan 2016 12:30:31 -0800
Message-ID: <CA+55aFwPeMhGj47DLvD7BsUd66TjxmX4_Aw9SHihmmqZue-GeA@mail.gmail.com>
Subject: Re: [PATCH RFC] mm: Rework virtual memory accounting
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Andrew Morton <akpm@linuxfoundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Jan 22, 2016 at 11:42 AM, Christian Borntraeger
<borntraeger@de.ibm.com> wrote:
>
> Just want to mention that this patch breaks older versions of valgrind
> (including the current release)
> https://bugs.kde.org/show_bug.cgi?id=357833

Ugh. Looks like valgrind is doing something that fundamentally can't
be "tweaked" around in the algorithm. Setting the data limit to zero
will never work with any model that starts accounting any mmap, so we
can't just tweak things a bit..

> It is fixed in trunk (and even triggered some good cleanups, so the valgrind
> developers do NOT want it to get reverted).

Hmm. If we start getting complaints from users, I suspect we'll just
have to revert. The fact that the valgrind developers are ok with the
change doesn't much matter - all that matters is whether users are ok
with it.

The only saving grace is that valgrind is fairly specialized, so it's
not like it breaks some core workflow. But I could easily see people
who run valgrind as part of some regression suite having their
day-to-day work broken.

So I'll let it slide for now, but if I start seeing complaints, I
think we'll just have to revert and wait for fixed valgrind versions
to actually percolate out to people and re-do it later.. (The
"percolate out to people" tends to take a _loong_ time, though).

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

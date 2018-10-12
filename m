Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 49AE96B0008
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 08:10:21 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id 36so8266824ott.22
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 05:10:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r12sor583350oti.52.2018.10.12.05.10.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 05:10:20 -0700 (PDT)
MIME-Version: 1.0
References: <20181010152736.99475-1-jannh@google.com> <20181010171944.GJ5873@dhcp22.suse.cz>
 <CAG48ez04KK62doMwsTVN4nN8y_wmv7hn+4my2jk5VXKL0wP7Lg@mail.gmail.com> <87tvlr1n1i.fsf@concordia.ellerman.id.au>
In-Reply-To: <87tvlr1n1i.fsf@concordia.ellerman.id.au>
From: Jann Horn <jannh@google.com>
Date: Fri, 12 Oct 2018 14:09:52 +0200
Message-ID: <CAG48ez1gc2aKWAhmtLjXB6pSGP75JKNVbBvk_1ZcHO5OM4XhfA@mail.gmail.com>
Subject: Re: [PATCH] mm: don't clobber partially overlapping VMA with MAP_FIXED_NOREPLACE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Khalid Aziz <khalid.aziz@oracle.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, abdhalee@linux.vnet.ibm.com, joel@jms.id.au, Kees Cook <keescook@chromium.org>, Jason Evans <jasone@google.com>, David Goldblatt <davidtgoldblatt@gmail.com>, =?UTF-8?Q?Edward_Tomasz_Napiera=C5=82a?= <trasz@freebsd.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Daniel Micay <danielmicay@gmail.com>, kernel list <linux-kernel@vger.kernel.org>

On Fri, Oct 12, 2018 at 12:23 PM Michael Ellerman <mpe@ellerman.id.au> wrote:
> Jann Horn <jannh@google.com> writes:
> > On Wed, Oct 10, 2018 at 7:19 PM Michal Hocko <mhocko@suse.com> wrote:
> >> On Wed 10-10-18 17:27:36, Jann Horn wrote:
> >> > Daniel Micay reports that attempting to use MAP_FIXED_NOREPLACE in an
> >> > application causes that application to randomly crash. The existing check
> >> > for handling MAP_FIXED_NOREPLACE looks up the first VMA that either
> >> > overlaps or follows the requested region, and then bails out if that VMA
> >> > overlaps *the start* of the requested region. It does not bail out if the
> >> > VMA only overlaps another part of the requested region.
> >>
> >> I do not understand. Could you give me an example?
> >
> > Sure.
> >
> > =======
> > user@debian:~$ cat mmap_fixed_simple.c
> > #include <sys/mman.h>
> > #include <errno.h>
> > #include <stdio.h>
> > #include <stdlib.h>
> > #include <unistd.h>
>
> ..
>
> Mind if I turn that into a selftest?

Feel free to do that. :)

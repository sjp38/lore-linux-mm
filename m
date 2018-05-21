Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E68216B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 19:16:23 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id m24-v6so13469598ioh.5
        for <linux-mm@kvack.org>; Mon, 21 May 2018 16:16:23 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x7-v6sor8690401itf.130.2018.05.21.16.16.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 16:16:23 -0700 (PDT)
MIME-Version: 1.0
References: <CAKOZuetOD6MkGPVvYFLj5RXh200FaDyu3sQqZviVRhTFFS3fjA@mail.gmail.com>
 <aacd607f-4a0d-2b0a-d8d9-b57c686d24fc@intel.com> <CAKOZuetDX905PeLt5cs7e_maSeKHrP0DgM1Kr3vvOb-+n=a7Gw@mail.gmail.com>
 <e6bdfa05-fa80-41d1-7b1d-51cf7e4ac9a1@intel.com> <CAKOZuev=Pa6FkvxTPbeA1CcYG+oF2JM+JVL5ELHLZ--7wyr++g@mail.gmail.com>
 <20eeca79-0813-a921-8b86-4c2a0c98a1a1@intel.com> <CAKOZuesoh7svdmdNY9md3N+vWGurigDLZ5_xDjwgU=uYdKkwqg@mail.gmail.com>
 <2e7fb27e-90b4-38d2-8ae1-d575d62c5332@intel.com>
In-Reply-To: <2e7fb27e-90b4-38d2-8ae1-d575d62c5332@intel.com>
From: Daniel Colascione <dancol@google.com>
Date: Mon, 21 May 2018 16:16:10 -0700
Message-ID: <CAKOZueu8ckN1b-cYOxPhL5f7Bdq+LLRP20NK3x7Vtw79oUT3pg@mail.gmail.com>
Subject: Re: Why do we let munmap fail?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: linux-mm@kvack.org, Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On Mon, May 21, 2018 at 4:02 PM Dave Hansen <dave.hansen@intel.com> wrote:

> On 05/21/2018 03:54 PM, Daniel Colascione wrote:
> >> There are also certainly denial-of-service concerns if you allow
> >> arbitrary numbers of VMAs.  The rbtree, for instance, is O(log(n)), but
> >> I 'd be willing to be there are plenty of things that fall over if you
> >> let the ~65k limit get 10x or 100x larger.
> > Sure. I'm receptive to the idea of having *some* VMA limit. I just think
> > it's unacceptable let deallocation routines fail.

> If you have a resource limit and deallocation consumes resources, you
> *eventually* have to fail a deallocation.  Right?

That's why robust software sets aside at allocation time whatever resources
are needed to make forward progress at deallocation time. That's what I'm
trying to propose here, essentially: if we specify the VMA limit in terms
of pages and not the number of VMAs, we've effectively "budgeted" for the
worst case of VMA splitting, since in the worst case, you end up with one
page per VMA.

Done this way, we still prevent runaway VMA tree growth, but we can also
make sure that anyone who's successfully called mmap can successfully call
munmap.

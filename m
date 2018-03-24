Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6096B0012
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 20:46:44 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id r24so11631601ioa.11
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 17:46:44 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f131-v6sor4928516itd.87.2018.03.23.17.46.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Mar 2018 17:46:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com>
References: <20180323174447.55F35636@viggo.jf.intel.com> <CA+55aFwEC1O+6qRc35XwpcuLSgJ+0GP6ciqw_1Oc-msX=efLvQ@mail.gmail.com>
 <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 23 Mar 2018 17:46:42 -0700
Message-ID: <CA+55aFxn=NiAhtz77nrx1_10em8bume-M0UzYZU2eVm5n71juA@mail.gmail.com>
Subject: Re: [PATCH 00/11] Use global pages with PTI
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On Fri, Mar 23, 2018 at 5:40 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> Well, rats.  This somehow makes things slower with PCIDs on.

.. what happens when you enable global pages with PCID? You disabled
them explicitly because you thought they wouldn't matter..

Even with PCID, a global TLB entry for the shared pages would make
sense, because it's now just *one* entry in the TLB rather that "one
per PCID and one for the kernel mapping".

So even if in theory the lifetime of the TLB entry is the same, when
you have capacity misses it most definitely isn't.

And for process tear-down and build-up the per-PCID TLB entry does
nothing at all. While for a true global entry, it gets shared even
across process creation/deletion. So even ignoring TLB capacity
issues, with lots of shortlived processes global TLB entries are much
better.

It is, of course, possible that I misunderstood what you actually
benchmarked. But I assume the above benchmark numbers are with the
whole "don't even do global entries if you have PCID".

               Linus

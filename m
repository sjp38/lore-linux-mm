Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3EF6B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 19:16:19 -0400 (EDT)
Received: by iecrt8 with SMTP id rt8so30691729iec.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:16:18 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id d16si9826855igm.0.2015.04.28.16.16.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 16:16:18 -0700 (PDT)
Received: by iget9 with SMTP id t9so97751141ige.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:16:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrUYc0W49-CVFpsj33CQx0N_ssaQeree3S7Zh3aisr3kNw@mail.gmail.com>
References: <20150428221553.GA5770@node.dhcp.inet.fi>
	<55400CA7.3050902@redhat.com>
	<CALCETrUYc0W49-CVFpsj33CQx0N_ssaQeree3S7Zh3aisr3kNw@mail.gmail.com>
Date: Tue, 28 Apr 2015 16:16:18 -0700
Message-ID: <CA+55aFz6CfnVgGABpGZ4ywqaOyt2E3KFO9zY_H_nH1R=nria-A@mail.gmail.com>
Subject: Re: PCID and TLB flushes (was: [GIT PULL] kdbus for 4.1-rc1)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Tue, Apr 28, 2015 at 3:54 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>
> I had a totally different implementation idea in mind.  It goes
> something like this:
>
> For each CPU, we allocate a fixed number of PCIDs, e.g. 0-7.  We have
> a per-cpu array of the mm [1] that owns each PCID. [...]

We've done this before on other architectures.  See for example alpha.
Look up "__get_new_mm_context()" and friends. I think sparc does the
same (and I think sparc copied a lot of it from the alpha
implementation).

Iirc, the alpha version just generates a (per-cpu) asid one at a time,
and has a generation counter so that when you run out of ASID's you do
a global TLB invalidate on that CPU and start from 0 again. Actually,
I think the generation number is just the high bits of the asid
counter (alpha calls them "asn", intel calls them "pcid", and I tend
to prefer "asid", but it's all the same thing).

Then each thread just has a per-thread ASID. We don't try to make that
be per-thread and per-cpu, but instead just force a new allocation
when a thread moves to another CPU.

It's not obvious what alpha does, because we end up hiding the
per-thread ASN in the "struct pcb_struct" (in 'struct thread_info')
which is part the alpha pal-code interface. But it seemed to work and
is fairly simple.

I think something very similar should work with intel pcid's.

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

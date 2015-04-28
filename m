Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 04A736B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 19:38:06 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so35560008igb.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:38:05 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id zw6si2878igc.11.2015.04.28.16.38.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 16:38:05 -0700 (PDT)
Received: by igblo3 with SMTP id lo3so103723375igb.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:38:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrXEP+00uezAo5dYTRFLFH0hfk9KxgDTd2zSusUgJz8NDg@mail.gmail.com>
References: <20150428221553.GA5770@node.dhcp.inet.fi>
	<55400CA7.3050902@redhat.com>
	<CALCETrUYc0W49-CVFpsj33CQx0N_ssaQeree3S7Zh3aisr3kNw@mail.gmail.com>
	<CA+55aFz6CfnVgGABpGZ4ywqaOyt2E3KFO9zY_H_nH1R=nria-A@mail.gmail.com>
	<CALCETrXEP+00uezAo5dYTRFLFH0hfk9KxgDTd2zSusUgJz8NDg@mail.gmail.com>
Date: Tue, 28 Apr 2015 16:38:05 -0700
Message-ID: <CA+55aFw2KMm=E9OYQkhJqL+9pmUoaqdO9m4jJZFw3Jr4=Br4Eg@mail.gmail.com>
Subject: Re: PCID and TLB flushes (was: [GIT PULL] kdbus for 4.1-rc1)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Tue, Apr 28, 2015 at 4:23 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>
> I think we can do it without that by keeping the mapping in reverse as
> I sort of outlined -- for each cpu, store a mapping from mm to pcid.
> When things fall out of the list, no big deal.

So you do it by just having a per-cpu array of (say, 64 entries), you
now end up having to search that every time you do a task switch to
find the asid for the mm. And even then you've limited yourself to
just six bits, because doing the same for a possible full 12-bit asid
would not be possible.

It's actually much simpler if you just do it the other way.

But hey, maybe you do something clever and can figure out a good way
to do it. I'm just saying that we *have* done this before on other
architectures, and it has worked. I think ARM has another asid
implementation in arch/arm/mm/context.c. I really think it would be a
good idea to copy some existing case rather than make up a new one.
It's not like asid's are unusual. It's arguably x86 that was unusual
in _not_ having them.

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

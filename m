Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 01CE86B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 19:19:51 -0400 (EDT)
Received: by iget9 with SMTP id t9so97788495ige.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:19:50 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com. [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id ro2si9808384igb.38.2015.04.28.16.19.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 16:19:50 -0700 (PDT)
Received: by iebrs15 with SMTP id rs15so30721757ieb.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:19:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrVuvbSrA=Ekz3fc2oE5psPyqEvL0YN7JvCCkOx-D18N3w@mail.gmail.com>
References: <20150428221553.GA5770@node.dhcp.inet.fi>
	<55400CA7.3050902@redhat.com>
	<CALCETrUYc0W49-CVFpsj33CQx0N_ssaQeree3S7Zh3aisr3kNw@mail.gmail.com>
	<5540101D.7020800@redhat.com>
	<CALCETrVuvbSrA=Ekz3fc2oE5psPyqEvL0YN7JvCCkOx-D18N3w@mail.gmail.com>
Date: Tue, 28 Apr 2015 16:19:50 -0700
Message-ID: <CA+55aFynMmhcbdv-ofWRssm8R7HYW_ut6rgKO6x88sa+=rEZzw@mail.gmail.com>
Subject: Re: PCID and TLB flushes (was: [GIT PULL] kdbus for 4.1-rc1)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Tue, Apr 28, 2015 at 4:01 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>
> The reason I thought of PCIDs this way is that 12 bits isn't nearly
> enough to get away with allocating each mm its own PCID.

Not even close. And really, we've already done this for other
architectures. On alpha, the number of bits in the pcid is
model-specific, but it was something like 6 for the ones I used.
That's plenty.

Also, I don't think Intel actually does 12 bits of pcid. What they do
is to hash the 12 bits down to something smaller (like two or three
bits in the actual TLB data structure), and then the CPU basically
invalidates any pcid's that alias (have a small 4- or 8-entry array
saying that "this hash was used for this 12-bit pcid).

So there's actually *another* level of dynamic mapping going on below
the software interface.

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

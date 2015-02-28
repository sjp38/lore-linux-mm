Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6D97F6B0095
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 16:49:18 -0500 (EST)
Received: by iecar1 with SMTP id ar1so39364134iec.0
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 13:49:18 -0800 (PST)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com. [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id gy6si5021488igb.18.2015.02.28.13.49.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Feb 2015 13:49:17 -0800 (PST)
Received: by iecvy18 with SMTP id vy18so39249760iec.6
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 13:49:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1425158083.4645.139.camel@kernel.crashing.org>
References: <1422361485.6648.71.camel@opensuse.org>
	<54C78756.9090605@suse.cz>
	<alpine.LSU.2.11.1501271347440.30227@nerf60.vanv.qr>
	<1422364084.6648.82.camel@opensuse.org>
	<s5h7fw8hvdp.wl-tiwai@suse.de>
	<CA+55aFyzy_wYHHnr2gDcYr7qcgOKM2557bRdg6RBa=cxrynd+Q@mail.gmail.com>
	<CA+55aFxRnj97rpSQvvzLJhpo7C8TQ-F=eB1Ry2n53AV1rN8mwA@mail.gmail.com>
	<CAMo8BfLsKCV_2NfgMH4k9jGOHs_-3=NKjCD3o3KK1uH23-6RRg@mail.gmail.com>
	<CA+55aFzQ5QEZ1AYauWviq1gp5j=mqByAtt4fpteeK7amuxcyjw@mail.gmail.com>
	<1422836637.17302.9.camel@au1.ibm.com>
	<CA+55aFw9sg7pu9-2RbMGyPv5yUtcH54QowoH+5RhWqpPYg4YGQ@mail.gmail.com>
	<1425107567.4645.108.camel@kernel.crashing.org>
	<CA+55aFy5UvzSgOMKq09u4psz5twtC4aowuK6tofGKDEu-KFMJQ@mail.gmail.com>
	<1425158083.4645.139.camel@kernel.crashing.org>
Date: Sat, 28 Feb 2015 13:49:17 -0800
Message-ID: <CA+55aFzLQWZJR+Y8HAhdPDSiL0QH_Lx2BqPkiFckAO69bJcOtA@mail.gmail.com>
Subject: Re: Generic page fault (Was: libsigsegv ....)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sat, Feb 28, 2015 at 1:14 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
>
> BTW. I fail to see how x86 checks PF_INSTR vs. VM_NOEXEC ... or it doesn't ?

It doesn't. x86 traditionally doesn't have an execute bit, so
traditionally "read == exec".

So PF_INSTR really wasn't historically very useful, in that it would
only show if the *first* access to a page was an instruction fetch -
if you did a regular read to brign the page in, then subsequent
instruction fetches would just work.

Then NX came along, and what happens now is

 - we handle write faults separately (see the first part of access_error()

 - so now we know it was a read or an instruction fetch

 - if PF_PROT is set, that means that the present bit was set in the
page tables, so it must have been an exec access to a NX page

 - otherwise, we just say "PROTNONE means no access, otherwise
populate the page tables"

.. and if it turns out that it was a PF_INSTR to a NX page, we'll end
up taking the page fault *again* after it's been populated, and now
since the page table was populated, the access_error() will catch it
with the PF_PROT case.

Or something like that. I might have screwed up some detail, but it
should all work.

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

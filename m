Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0C86B0255
	for <linux-mm@kvack.org>; Sat,  1 Aug 2015 13:03:17 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so49871987igb.0
        for <linux-mm@kvack.org>; Sat, 01 Aug 2015 10:03:17 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id 70si9898166ioe.170.2015.08.01.10.03.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Aug 2015 10:03:16 -0700 (PDT)
Received: by igbpg9 with SMTP id pg9so49871928igb.0
        for <linux-mm@kvack.org>; Sat, 01 Aug 2015 10:03:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150801164910.GA15407@nazgul.tnic>
References: <1431714237-880-6-git-send-email-toshi.kani@hp.com>
	<1432628901-18044-6-git-send-email-bp@alien8.de>
	<tip-0cc705f56e400764a171055f727d28a48260bb4b@git.kernel.org>
	<20150731131802.GW25159@twins.programming.kicks-ass.net>
	<20150731144452.GA8106@nazgul.tnic>
	<20150731150806.GX25159@twins.programming.kicks-ass.net>
	<20150731152713.GA9756@nazgul.tnic>
	<20150801142820.GU30479@wotan.suse.de>
	<20150801163311.GA15356@nazgul.tnic>
	<CA+55aFzBvRYLufS46QR2aXLYX=rMBQ-qKjkkhQm-L9dFgwWywA@mail.gmail.com>
	<20150801164910.GA15407@nazgul.tnic>
Date: Sat, 1 Aug 2015 10:03:16 -0700
Message-ID: <CA+55aFxQHPPsviY=CcwLKi-u1q_vizQd5ANqaKCBeasu-r0sQQ@mail.gmail.com>
Subject: Re: [tip:x86/mm] x86/mm/mtrr: Clean up mtrr_type_lookup()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: "Luis R. Rodriguez" <mcgrof@suse.com>, Toshi Kani <toshi.kani@hp.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, Denys Vlasenko <dvlasenk@redhat.com>, Borislav Petkov <bp@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Brian Gerst <brgerst@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-tip-commits@vger.kernel.org" <linux-tip-commits@vger.kernel.org>

On Sat, Aug 1, 2015 at 9:49 AM, Borislav Petkov <bp@alien8.de> wrote:
>
> My simplistic mental picture while thinking of this is the IO range
> where you send the commands to the device and you don't really want to
> delay those but they should reach the device as they get issued.

Well, even for command streams, people often do go for a
write-combining approach, simply because it is *so* much more
efficient on the bus to buffer and burst things. The interface is set
up to not really "combine" things in the over-writing sense, but just
in the "combine continuous writes into bigger buffers on the CPU, and
then write it out as efficiently as possible" sense.

Of course, the device (and the driver) has to be designed properly for
that, and it makes sense only with certain kinds of models, but it can
actually be much more efficient to make the device interface be
something like "write 32-byte command packets to a circular
write-combining buffer" than it is to do things other ways. Back in
the days, that was one of the most efficient ways to try to fill up
the PCI bandwidth.

There are other approaches too, of course, with the modern variation
tending to be "the device does all real accesses by reading over DMA,
and the only time you use IO accesses is for setup and as a 'start
your DMA transfers now' kind of interface". But write-combining MMIO
used to be a very common model for high-performace IO not that long
ago, because DMA didn't actually use to be all that efficient at all
(nasty behavior with caches and snooping etc back before the memory
controller was on-die and DMA accesses snooped caches directly). So
the "DMA is efficient even for smaller things" thing is relatively
recent.

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

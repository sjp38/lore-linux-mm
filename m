Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B3B246B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 01:59:28 -0400 (EDT)
Received: from mail-wy0-f169.google.com (mail-wy0-f169.google.com [74.125.82.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5G5xPBd001384
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 22:59:26 -0700
Received: by wyf19 with SMTP id 19so1026680wyf.14
        for <linux-mm@kvack.org>; Wed, 15 Jun 2011 22:59:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CDE289EC-7844-48E1-BB6A-6230ADAF6B7C@suse.de>
References: <47FAB15C-B113-40FD-9CE0-49566AACC0DF@suse.de> <BANLkTimubRW2Az2MmRbgV+iTB+s6UEF5-w@mail.gmail.com>
 <CDE289EC-7844-48E1-BB6A-6230ADAF6B7C@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 15 Jun 2011 22:59:04 -0700
Message-ID: <BANLkTikLLfJ6yGNVcZ+o1RFmRoqRVrRSYQ@mail.gmail.com>
Subject: Re: Oops in VMA code
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>

On Wed, Jun 15, 2011 at 10:32 PM, Alexander Graf <agraf@suse.de> wrote:
>
> 0xc000000000190580 <find_vma_prev+44>: =A0ld =A0 =A0 =A0r9,16(r9)
> 0xc000000000190584 <find_vma_prev+48>: =A0mr =A0 =A0 =A0r26,r11
> 0xc000000000190588 <find_vma_prev+52>: =A0cmpdi =A0 cr7,r9,0
> 0xc00000000019058c <find_vma_prev+56>: =A0mr =A0 =A0 =A0r11,r26
> 0xc000000000190590 <find_vma_prev+60>: =A0beq =A0 =A0 cr7,0xc000000000190=
5c4 <find_vma_prev+112>
> 0xc000000000190594 <find_vma_prev+64>: =A0addi =A0 =A0r26,r9,-56
> 0xc000000000190598 <find_vma_prev+68>: =A0ld =A0 =A0 =A0r0,16(r26)
> 0xc00000000019059c <find_vma_prev+72>: =A0cmpld =A0 cr7,r31,r0
> 0xc0000000001905a0 <find_vma_prev+76>: =A0blt =A0 =A0 cr7,0xc000000000190=
580 <find_vma_prev+44>

That's the inner loop in find_vma_prev(), and yes, it was inlined into
do_munmap.

And the fault happens in that "ld r0,16(r26)", and it looks like you
have memory corruption.

r26 has the value 0xc00090026236bbb0, and that "90" byte in the middle
there looks bogus. It's not a valid pointer any more, but if that "9"
had been a zero, it would have been.

So it looks like the rbtree has become corrupt, and it _looks_ like
it's just a couple of bits that are set in what otherwise looks like a
reasonable pointer. It *could* be a two-bit error that wasn't
corrected (I assume you have ECC or parity on your RAM or caches), so
it's theoretically possible that it's hardware, but generally memory
corruption is due to software bugs, so that's a pretty far-fetched
thing.

At a guess, there's not a lot more to be had from the oops. The
corruption probably came from some totally unrelated code. Without
more of a pattern, it's pretty much impossible to even guess.

It may be that somebody can see something I'm missing, but unless you
can find an ECC error report in your logs and say "oh, that's it", I
suspect that you're better off ignoring it, and hoping that it will
happen again (and again) so that we'd get enough of a pattern to start
making any educated guesses about what's going on.

That's why I often google oops reports - one report may not give much
of a pattern, but if google finds lots of them that all look roughly
similar, you end up possibly seeing what the common issue is.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

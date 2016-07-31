Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id ADCFC6B0260
	for <linux-mm@kvack.org>; Sun, 31 Jul 2016 16:56:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w128so233340424pfd.3
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 13:56:38 -0700 (PDT)
Received: from outbound1a.ore.mailhop.org (outbound1a.ore.mailhop.org. [54.213.22.21])
        by mx.google.com with ESMTPS id j71si31259543pfa.161.2016.07.31.13.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Jul 2016 13:56:37 -0700 (PDT)
Date: Sun, 31 Jul 2016 20:56:32 +0000
From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v2 1/7] random: Simplify API for random address requests
Message-ID: <20160731205632.GY4541@io.lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net>
 <20160730154244.403-1-jason@lakedaemon.net>
 <20160730154244.403-2-jason@lakedaemon.net>
 <CAGXu5jL3ZtjbhOYujVUpBuDttPjetaz8rSY_hNK13r6OtR4sFQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jL3ZtjbhOYujVUpBuDttPjetaz8rSY_hNK13r6OtR4sFQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "Roberts, William C" <william.c.roberts@intel.com>, Yann Droneaud <ydroneaud@opteya.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Arnd Bergmann <arnd@arndb.de>, Greg KH <gregkh@linuxfoundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Nick Kralevich <nnk@google.com>, Jeffrey Vander Stoep <jeffv@google.com>, Daniel Cashman <dcashman@android.com>

On Sun, Jul 31, 2016 at 09:46:53AM -0700, Kees Cook wrote:
> On Sat, Jul 30, 2016 at 8:42 AM, Jason Cooper <jason@lakedaemon.net> wrote:
> > To date, all callers of randomize_range() have set the length to 0, and
> > check for a zero return value.  For the current callers, the only way
> > to get zero returned is if end <= start.  Since they are all adding a
> > constant to the start address, this is unnecessary.
> >
> > We can remove a bunch of needless checks by simplifying the API to do
> > just what everyone wants, return an address between [start, start +
> > range).
> >
> > While we're here, s/get_random_int/get_random_long/.  No current call
> > site is adversely affected by get_random_int(), since all current range
> > requests are < UINT_MAX.  However, we should match caller expectations
> > to avoid coming up short (ha!) in the future.
> >
> > All current callers to randomize_range() chose to use the start address
> > if randomize_range() failed.  Therefore, we simplify things by just
> > returning the start address on error.
> >
> > randomize_range() will be removed once all callers have been converted
> > over to randomize_addr().
> >
> > Signed-off-by: Jason Cooper <jason@lakedaemon.net>
> > ---
> > Changes from v1:
> >  - Explicitly mention page_aligned start assumption (Yann Droneaud)
> >  - pick random pages vice random addresses (Yann Droneaud)
> >  - catch range=0 last
> >
> >  drivers/char/random.c  | 28 ++++++++++++++++++++++++++++
> >  include/linux/random.h |  1 +
> >  2 files changed, 29 insertions(+)
> >
> > diff --git a/drivers/char/random.c b/drivers/char/random.c
> > index 0158d3bff7e5..3bedf69546d6 100644
> > --- a/drivers/char/random.c
> > +++ b/drivers/char/random.c
> > @@ -1840,6 +1840,34 @@ randomize_range(unsigned long start, unsigned long end, unsigned long len)
> >         return PAGE_ALIGN(get_random_int() % range + start);
> >  }
> >
> > +/**
> > + * randomize_addr - Generate a random, page aligned address
> > + * @start:     The smallest acceptable address the caller will take.
> > + * @range:     The size of the area, starting at @start, within which the
> > + *             random address must fall.
> > + *
> > + * If @start + @range would overflow, @range is capped.
> > + *
> > + * NOTE: Historical use of randomize_range, which this replaces, presumed that
> > + * @start was already page aligned.  This assumption still holds.
> > + *
> > + * Return: A page aligned address within [start, start + range).  On error,
> > + * @start is returned.
> > + */
> > +unsigned long
> > +randomize_addr(unsigned long start, unsigned long range)
> 
> Since we're changing other things about this, let's try to document
> its behavior in its name too and call this "randomize_page" instead.

Ack.  Definitely more accurate.

> If it requires a page-aligned value, we should probably also BUG_ON
> it, or adjust the start too.

merf.  So, this whole series started from a suggested cleanup by William
to s/get_random_int/get_random_long/.

The current users have all been stable the way they are for a long time.
Like pre-git long.  So, if this is just a cleanup for those callers, I
don't think we need to do more than we already are.

However, if the intent is for this function to see wider use, then by
all means, we need to handle start != PAGE_ALIGN(start).

Do you have any new call sites in mind?

thx,

Jason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

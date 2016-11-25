Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5DF6B0253
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 11:18:40 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g23so23522777wme.4
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 08:18:40 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.74])
        by mx.google.com with ESMTPS id k8si43261280wjv.25.2016.11.25.08.18.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 08:18:39 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] z3fold: use %z modifier for format string
Date: Fri, 25 Nov 2016 17:11:49 +0100
Message-ID: <4155555.0I0VNuaa72@wuerfel>
In-Reply-To: <CAMJBoFOo5e9N-2KqtjU=oRm24YO3gSG-zdT-z8XKw3USOwVvpw@mail.gmail.com>
References: <20161124163158.3939337-1-arnd@arndb.de> <3177176.drX8hSSUx4@wuerfel> <CAMJBoFOo5e9N-2KqtjU=oRm24YO3gSG-zdT-z8XKw3USOwVvpw@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>, zhong jiang <zhongjiang@huawei.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Friday, November 25, 2016 4:51:03 PM CET Vitaly Wool wrote:
> On Fri, Nov 25, 2016 at 9:41 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Friday, November 25, 2016 8:38:25 AM CET Vitaly Wool wrote:
> >> >> diff --git a/mm/z3fold.c b/mm/z3fold.c
> >> >> index e282ba073e77..66ac7a7dc934 100644
> >> >> --- a/mm/z3fold.c
> >> >> +++ b/mm/z3fold.c
> >> >> @@ -884,7 +884,7 @@ static int __init init_z3fold(void)
> >> >>  {
> >> >>       /* Fail the initialization if z3fold header won't fit in one chunk */
> >> >>       if (sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED) {
> >> >> -             pr_err("z3fold: z3fold_header size (%d) is bigger than "
> >> >> +             pr_err("z3fold: z3fold_header size (%zd) is bigger than "
> >> >>                       "the chunk size (%d), can't proceed\n",
> >> >>                       sizeof(struct z3fold_header) , ZHDR_SIZE_ALIGNED);
> >> >>               return -E2BIG;
> >> >
> >> > The embedded "z3fold: " prefix here should be removed
> >> > as there's a pr_fmt that also adds it.
> >> >
> >> > The test looks like it should be a BUILD_BUG_ON rather
> >> > than any runtime test too.
> >>
> >> It used to be BUILD_BUG_ON but we deliberately changed that because
> >> sizeof(spinlock_t) gets bloated in debug builds, so it just won't
> >> build with default CHUNK_SIZE.
> >
> > Could this be improved by making the CHUNK_SIZE bigger depending on
> > the debug options?
> 
> I don't see how silently enforcing a suboptimal configuration is
> better than failing the initialization (so that you can adjust
> CHUNK_SIZE yourself). I can add something descriptive to
> Documentation/vm/z3fold.txt for that matter.

Failing at runtime when you know it's broken at compile-time
seems wrong, too. If you can't use z3fold with spinlock debugging,
you may as well hide the option in Kconfig based on the other ones.

Printing a runtime warning for the suboptimal configuration but
making it work anyway is probably better than just failing.

> > Alternatively, how about using a bit_spin_lock instead of raw_spin_lock?
> > That would guarantee a fixed size for the lock and make z3fold_header
> > always 24 bytes (on 32-bit architectures) or 40 bytes
> > (on 64-bit architectures). You could even play some tricks with the
> > first_num field to make it fit in the same word as the lock and make the
> > structure fit into 32 bytes if you care about that.
> 
> That is interesting. Actually I can have that bit in page->private and
> then I don't need to handle headless pages in a special way, that
> sounds appealing. However, there is a warning about bit_spin_lock
> performance penalty. Do you know how big it is?

No idea, sorry. On x86, test_and_set_bit() seems to be only
one instruction to test/set the bit, followed by a conditional
branch, compared to a cmpxchg() for the raw_spin_lock(), so the
fast path seems pretty much the same.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

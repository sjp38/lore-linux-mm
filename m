Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2C26B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 00:46:19 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e26so4690575pfi.15
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 21:46:19 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id a13si3137454pgd.408.2017.12.06.21.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Dec 2017 21:46:16 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
In-Reply-To: <20171206070355.GA32044@bombadil.infradead.org>
References: <20171129144219.22867-1-mhocko@kernel.org> <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com> <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz> <20171201152640.GA3765@rei> <87wp20e9wf.fsf@concordia.ellerman.id.au> <20171206045433.GQ26021@bombadil.infradead.org> <20171206070355.GA32044@bombadil.infradead.org>
Date: Thu, 07 Dec 2017 16:46:11 +1100
Message-ID: <87bmjbks4c.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@kernel.org>, Kees Cook <keescook@chromium.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>

Matthew Wilcox <willy@infradead.org> writes:

> On Tue, Dec 05, 2017 at 08:54:35PM -0800, Matthew Wilcox wrote:
>> On Wed, Dec 06, 2017 at 03:51:44PM +1100, Michael Ellerman wrote:
>> > Cyril Hrubis <chrubis@suse.cz> writes:
>> > 
>> > > Hi!
>> > >> > MAP_FIXED_UNIQUE
>> > >> > MAP_FIXED_ONCE
>> > >> > MAP_FIXED_FRESH
>> > >> 
>> > >> Well, I can open a poll for the best name, but none of those you are
>> > >> proposing sound much better to me. Yeah, naming sucks...
>> > >
>> > > Given that MAP_FIXED replaces the previous mapping MAP_FIXED_NOREPLACE
>> > > would probably be a best fit.
>> > 
>> > Yeah that could work.
>> > 
>> > I prefer "no clobber" as I just suggested, because the existing
>> > MAP_FIXED doesn't politely "replace" a mapping, it destroys the current
>> > one - which you or another thread may be using - and clobbers it with
>> > the new one.
>> 
>> It's longer than MAP_FIXED_WEAK :-P
>> 
>> You'd have to be pretty darn strong to clobber an existing mapping.
>
> I think we're thinking about this all wrong.  We shouldn't document it as
> "This is a variant of MAP_FIXED".  We should document it as "Here's an
> alternative to MAP_FIXED".
>
> So, just like we currently say "exactly one of MAP_SHARED or MAP_PRIVATE",
> we could add a new paragraph saying "at most one of MAP_FIXED or
> MAP_REQUIRED" and "any of the following values".
>
> Now, we should implement MAP_REQUIRED as having each architecture
> define _MAP_NOT_A_HINT, and then #define MAP_REQUIRED (MAP_FIXED |
> _MAP_NOT_A_HINT), but that's not information to confuse users with.
>
> Also, that lets us add a third option at some point that is Yet Another
> Way to interpret the 'addr' argument, by having MAP_FIXED clear and
> _MAP_NOT_A_HINT set.
>
> I'm not set on MAP_REQUIRED.  I came up with some awful names
> (MAP_TODDLER, MAP_TANTRUM, MAP_ULTIMATUM, MAP_BOSS, MAP_PROGRAM_MANAGER,
> etc).  But I think we should drop FIXED from the middle of the name.

MAP_REQUIRED doesn't immediately grab me, but I don't actively dislike
it either :)

What about MAP_AT_ADDR ?

It's short, and says what it does on the tin. The first argument to mmap
is actually called "addr" too.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

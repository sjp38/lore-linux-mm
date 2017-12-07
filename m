Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9396B026D
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:14:30 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id v71so4491566vkd.0
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:14:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w5sor2204175uae.280.2017.12.07.11.14.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 11:14:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87bmjbks4c.fsf@concordia.ellerman.id.au>
References: <20171129144219.22867-1-mhocko@kernel.org> <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
 <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz> <20171201152640.GA3765@rei>
 <87wp20e9wf.fsf@concordia.ellerman.id.au> <20171206045433.GQ26021@bombadil.infradead.org>
 <20171206070355.GA32044@bombadil.infradead.org> <87bmjbks4c.fsf@concordia.ellerman.id.au>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 7 Dec 2017 11:14:27 -0800
Message-ID: <CAGXu5jLWRQn6EaXEEvdvXr+4gbiJawwp1EaLMfYisHVfMiqgSA@mail.gmail.com>
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Matthew Wilcox <willy@infradead.org>, Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@kernel.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Pavel Machek <pavel@ucw.cz>

On Wed, Dec 6, 2017 at 9:46 PM, Michael Ellerman <mpe@ellerman.id.au> wrote:
> Matthew Wilcox <willy@infradead.org> writes:
>
>> On Tue, Dec 05, 2017 at 08:54:35PM -0800, Matthew Wilcox wrote:
>>> On Wed, Dec 06, 2017 at 03:51:44PM +1100, Michael Ellerman wrote:
>>> > Cyril Hrubis <chrubis@suse.cz> writes:
>>> >
>>> > > Hi!
>>> > >> > MAP_FIXED_UNIQUE
>>> > >> > MAP_FIXED_ONCE
>>> > >> > MAP_FIXED_FRESH
>>> > >>
>>> > >> Well, I can open a poll for the best name, but none of those you are
>>> > >> proposing sound much better to me. Yeah, naming sucks...
>>> > >
>>> > > Given that MAP_FIXED replaces the previous mapping MAP_FIXED_NOREPLACE
>>> > > would probably be a best fit.
>>> >
>>> > Yeah that could work.
>>> >
>>> > I prefer "no clobber" as I just suggested, because the existing
>>> > MAP_FIXED doesn't politely "replace" a mapping, it destroys the current
>>> > one - which you or another thread may be using - and clobbers it with
>>> > the new one.
>>>
>>> It's longer than MAP_FIXED_WEAK :-P
>>>
>>> You'd have to be pretty darn strong to clobber an existing mapping.
>>
>> I think we're thinking about this all wrong.  We shouldn't document it as
>> "This is a variant of MAP_FIXED".  We should document it as "Here's an
>> alternative to MAP_FIXED".
>>
>> So, just like we currently say "exactly one of MAP_SHARED or MAP_PRIVATE",
>> we could add a new paragraph saying "at most one of MAP_FIXED or
>> MAP_REQUIRED" and "any of the following values".
>>
>> Now, we should implement MAP_REQUIRED as having each architecture
>> define _MAP_NOT_A_HINT, and then #define MAP_REQUIRED (MAP_FIXED |
>> _MAP_NOT_A_HINT), but that's not information to confuse users with.
>>
>> Also, that lets us add a third option at some point that is Yet Another
>> Way to interpret the 'addr' argument, by having MAP_FIXED clear and
>> _MAP_NOT_A_HINT set.
>>
>> I'm not set on MAP_REQUIRED.  I came up with some awful names
>> (MAP_TODDLER, MAP_TANTRUM, MAP_ULTIMATUM, MAP_BOSS, MAP_PROGRAM_MANAGER,
>> etc).  But I think we should drop FIXED from the middle of the name.
>
> MAP_REQUIRED doesn't immediately grab me, but I don't actively dislike
> it either :)
>
> What about MAP_AT_ADDR ?
>
> It's short, and says what it does on the tin. The first argument to mmap
> is actually called "addr" too.

"FIXED" is supposed to do this too.

Pavel suggested:

MAP_ADD_FIXED

(which is different from "use fixed", and describes why it would fail:
can't add since it already exists.)

Perhaps "MAP_FIXED_NEW"?

There has been a request to drop "FIXED" from the name, so these:

MAP_FIXED_NOCLOBBER
MAP_FIXED_NOREPLACE
MAP_FIXED_ADD
MAP_FIXED_NEW

Could be:

MAP_NOCLOBBER
MAP_NOREPLACE
MAP_ADD
MAP_NEW

and we still have the unloved, but acceptable:

MAP_REQUIRED

My vote is still for "NOREPLACE" or "NOCLOBBER" since it's very
specific, though "NEW" is pretty clear too.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

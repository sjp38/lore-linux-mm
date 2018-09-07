Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 00A7A6B7F43
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 12:30:47 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id m185-v6so22172808itm.1
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 09:30:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u15-v6sor5398201ite.84.2018.09.07.09.30.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 09:30:46 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1535629099.git.andreyknvl@google.com> <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
 <CA+55aFyW9N2tSb2bQvkthbVVyY6nt5yFeWQRLHp1zruBmb5ocw@mail.gmail.com>
 <CA+55aFy2t_MHgr_CgwbhtFkL+djaCq2qMM1G+f2DwJ0qEr1URQ@mail.gmail.com> <20180907152600.myidisza5o4kdmvf@armageddon.cambridge.arm.com>
In-Reply-To: <20180907152600.myidisza5o4kdmvf@armageddon.cambridge.arm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 7 Sep 2018 09:30:35 -0700
Message-ID: <CA+55aFzQ+ykLu10q3AdyaaKJx8SDWWL9Qiu6WH2jbN_ugRUTOg@mail.gmail.com>
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by sparse
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, cpandya@codeaurora.org, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Evgenii Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben.Ayrapetyan@arm.com, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Dmitry Vyukov <dvyukov@google.com>, linux-mm <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Sep 7, 2018 at 8:26 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> So it's not about casting to another pointer; it's rather about no
> longer using the value as a user pointer but as an actual (untyped,
> untagged) virtual address.
>
> There may be better options to address this but I haven't seen any
> concrete proposal so far. Or we could simply consider that we've found
> all places where it matters and not bother with any static analysis
> tools (but for the time being it's still worth investigating whether we
> can do better than this).

I actually originally wanted to have sparse not just check types, but
actually do transformations too, in order to check more.

For example, for just the user pointer case, we actually have two
wildy different kinds of user pointers: "checked" user pointers and
"wild" user pointers.

Most of the time it doesn't matter, but it does for the unsafe ones:
"__get_user()" and friends.

So long long ago I wanted sparse to not just do the completely static
type analysis, but also do actual "data flow" analysis where doing an
"access_on()" on a pointer would turn it from "wild" to "checked", and
then I could have warned about "hey, this function does __get_user(),
but the flow analysis shows that you passed it a pointer that had
never been checked".

But sparse never ended up doing that kind of much smarter things. Some
of the lock context stuff does it on a very small local level, and not
very well there either.

But it sounds like this is exactly what you guys would want for the
tagged pointers. Some functions can take a "wild" pointer, because
they deal with the tag part natively. And others need to be "checked"
and have gone through the cleaning and verification.

But sparse is sadly not the right tool for this, and having a single
"__user" address space is not sufficient. I guess for the arm64 case,
you really could make up a *new* address space: "__user_untagged", and
then have functions that convert from "void __user *" to "void
__user_untagged *", and then mark the functions that need the tag
removed as taking that new kind of user pointer.

And if you never mix types, that would actually work. But I'm guessing
you can also pass "__user_untagged" pointers to the regular user
access functions, and you do?

                  Linus

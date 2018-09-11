Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56B4B8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 12:42:02 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q11-v6so32364728oih.15
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 09:42:02 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s206-v6si13323787oib.419.2018.09.11.09.42.00
        for <linux-mm@kvack.org>;
        Tue, 11 Sep 2018 09:42:01 -0700 (PDT)
Date: Tue, 11 Sep 2018 17:41:53 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by
 sparse
Message-ID: <20180911164152.GA29166@arrakis.emea.arm.com>
References: <cover.1535629099.git.andreyknvl@google.com>
 <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
 <CA+55aFyW9N2tSb2bQvkthbVVyY6nt5yFeWQRLHp1zruBmb5ocw@mail.gmail.com>
 <CA+55aFy2t_MHgr_CgwbhtFkL+djaCq2qMM1G+f2DwJ0qEr1URQ@mail.gmail.com>
 <20180907152600.myidisza5o4kdmvf@armageddon.cambridge.arm.com>
 <CA+55aFzQ+ykLu10q3AdyaaKJx8SDWWL9Qiu6WH2jbN_ugRUTOg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzQ+ykLu10q3AdyaaKJx8SDWWL9Qiu6WH2jbN_ugRUTOg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, cpandya@codeaurora.org, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Evgenii Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben.Ayrapetyan@arm.com, Andrey Konovalov <andreyknvl@google.com>, Lee Smith <Lee.Smith@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Linus,

On Fri, Sep 07, 2018 at 09:30:35AM -0700, Linus Torvalds wrote:
> On Fri, Sep 7, 2018 at 8:26 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > So it's not about casting to another pointer; it's rather about no
> > longer using the value as a user pointer but as an actual (untyped,
> > untagged) virtual address.
[...]
> I actually originally wanted to have sparse not just check types, but
> actually do transformations too, in order to check more.
[...]
> But it sounds like this is exactly what you guys would want for the
> tagged pointers. Some functions can take a "wild" pointer, because
> they deal with the tag part natively. And others need to be "checked"
> and have gone through the cleaning and verification.
> 
> But sparse is sadly not the right tool for this, and having a single
> "__user" address space is not sufficient. I guess for the arm64 case,
> you really could make up a *new* address space: "__user_untagged", and
> then have functions that convert from "void __user *" to "void
> __user_untagged *", and then mark the functions that need the tag
> removed as taking that new kind of user pointer.

Fortunately, most (all) functions taking a __user pointer can cope with
tagged pointers since they never dereference the pointer directly but
pass it through uaccess functions (which can access tagged pointers
without untagging). The problem appears when the pointer is no longer
used for access but converted to a long for other uses like rbtree
look-up, so not actually dereferenced. Such conversion, in a few cases,
needs to lose the tag.

Of course, there are lots of void __user * conversions to long where
removing the tag is not always the right thing or required (hence the
__force annotations in this patchset).

As Luc mentioned in this thread, we can consider that __user pointers
are always tagged. What I think we'd need is a few annotations where
ulong must be an __untagged address (and I guess in smaller numbers than
the __force ones proposed here). For example we can allow
get_user_pages() to get an (ulong)(void __user *) conversion but
find_vma() would only take an (unsigned long __untagged) argument. Such
attribute conversion would be handled by an untagged_addr() macro. So we
move the detection problem from pointer conversion to an ulong (tagged
by default) to ulong __untagged conversion (I'm not sure sparse can do
this).

That's slightly different than trying to identify all the __user ptr to
long conversions but, as you said, it's probably not a complete solution
anyway and with lots of __force annotations throughout the kernel.

-- 
Catalin

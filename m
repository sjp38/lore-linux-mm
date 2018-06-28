Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4744F6B0007
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 11:28:47 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w10-v6so2199274eds.7
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 08:28:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z9-v6sor2912291edh.10.2018.06.28.08.28.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 08:28:45 -0700 (PDT)
Date: Thu, 28 Jun 2018 17:28:43 +0200
From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v4 0/7] arm64: untag user pointers passed to the kernel
Message-ID: <20180628152841.rgc62aqqckcuecaf@ltop.local>
References: <cover.1529507994.git.andreyknvl@google.com>
 <CAAeHK+zqtyGzd_CZ7qKZKU-uZjZ1Pkmod5h8zzbN0xCV26nSfg@mail.gmail.com>
 <20180626172900.ufclp2pfrhwkxjco@armageddon.cambridge.arm.com>
 <CAAeHK+yqWKTdTG+ymZ2-5XKiDANV+fmUjnQkRy-5tpgphuLJRA@mail.gmail.com>
 <0cef1643-a523-98e7-95e2-9ec595137642@arm.com>
 <20180627171757.amucnh5znld45cpc@armageddon.cambridge.arm.com>
 <20180628061758.j6bytsaj5jk4aocg@ltop.local>
 <20180628102741.vk6vphfinlj3lvhv@armageddon.cambridge.arm.com>
 <20180628104610.czsnq4w3lfhxrn53@ltop.local>
 <20180628144858.2fu7kq56cxhp2kpg@armageddon.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180628144858.2fu7kq56cxhp2kpg@armageddon.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Ramana Radhakrishnan <ramana.radhakrishnan@arm.com>, Al Viro <viro@zeniv.linux.org.uk>nd <nd@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Kostya Serebryany <kcc@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <Robin.Murphy@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Jun 28, 2018 at 03:48:59PM +0100, Catalin Marinas wrote:
> On Thu, Jun 28, 2018 at 12:46:11PM +0200, Luc Van Oostenryck wrote:
> > On Thu, Jun 28, 2018 at 11:27:42AM +0100, Catalin Marinas wrote:
> > > On Thu, Jun 28, 2018 at 08:17:59AM +0200, Luc Van Oostenryck wrote:
> > > > On Wed, Jun 27, 2018 at 06:17:58PM +0100, Catalin Marinas wrote:
> > > > > sparse is indeed an option. The current implementation doesn't warn on
> > > > > an explicit cast from (void __user *) to (unsigned long) since that's a
> > > > > valid thing in the kernel. I couldn't figure out if there's any other
> > > > > __attribute__ that could be used to warn of such conversion.
> > > > 
> > > > sparse doesn't have such attribute but would an new option that would warn
> > > > on such cast be a solution for your case?
> > > 
> > > I can't tell for sure whether such sparse option would be the full
> > > solution but detecting explicit __user pointer casts to long is a good
> > > starting point. So far this patchset pretty much relies on detecting
> > > a syscall failure and trying to figure out why, patching the kernel. It
> > > doesn't really scale.
> > 
> > OK, I'll add such an option this evening.
> 
> That's great, thanks. I think this should cover casting pointers to any
> integer types, not just "unsigned long" (e.g. long long).

Yes, of course.
 
> The only downside is that with this patchset the untagging can be done
> after the conversion to ulong (get_user_pages()) as that's where the
> problem was noticed. With a new sparse feature, we'd have to annotate
> the conversion sites (not sure how many until we run the tool though).

I've done a lot of hacking on sparse and as such I run a lot of tests.
What I see with these tests is that a lot of annotations are wrong or
missing so I'm very reluctant to add another attribute. Even more so
one that would be only slightly different than an existing one. OTOH,
if it's something localized or a one-shot and there is a need, ...
why not?

What would you ideally need?

-- Luc

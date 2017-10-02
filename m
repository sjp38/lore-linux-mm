Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1298F6B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 16:27:28 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id x15so6036897itb.6
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 13:27:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t186sor5036853iof.167.2017.10.02.13.27.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 13:27:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171002200805.GF8421@gate.crashing.org>
References: <20170921093729.1080368AC1@po15668-vm-win7.idsi0.si.c-s.fr>
 <CAGXu5jJ54+bCcXaPK1ExsxtTDPHNn1+1gywb3TDbe-SEtt1zuQ@mail.gmail.com>
 <20170925073721.GM8421@gate.crashing.org> <063D6719AE5E284EB5DD2968C1650D6DD007F58B@AcuExch.aculab.com>
 <20170925194130.GV8421@gate.crashing.org> <CAGXu5j+bj1NHmrrEmcwPavKubavLh1b01AyyJEFRvycg9FkLpg@mail.gmail.com>
 <20171002200805.GF8421@gate.crashing.org>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 2 Oct 2017 13:27:25 -0700
Message-ID: <CAGXu5jLQMKDxgjeRNC5uhYxy8s0Fqd=vmch75d-VarjZMYDO7g@mail.gmail.com>
Subject: Re: [PATCH] mm: fix RODATA_TEST failure "rodata_test: test data was
 not read only"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Segher Boessenkool <segher@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, David Laight <David.Laight@aculab.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jinbum Park <jinb.park7@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Mon, Oct 2, 2017 at 1:08 PM, Segher Boessenkool
<segher@kernel.crashing.org> wrote:
> On Mon, Oct 02, 2017 at 12:29:45PM -0700, Kees Cook wrote:
>> On Mon, Sep 25, 2017 at 12:41 PM, Segher Boessenkool
>> <segher@kernel.crashing.org> wrote:
>> > On Mon, Sep 25, 2017 at 04:01:55PM +0000, David Laight wrote:
>> >> From: Segher Boessenkool
>> >> > The compiler puts this item in .sdata, for 32-bit.  There is no .srodata,
>> >> > so if it wants to use a small data section, it must use .sdata .
>> >> >
>> >> > Non-external, non-referenced symbols are not put in .sdata, that is the
>> >> > difference you see with the "static".
>> >> >
>> >> > I don't think there is a bug here.  If you think there is, please open
>> >> > a GCC bug.
>> >>
>> >> The .sxxx sections are for 'small' data that can be accessed (typically)
>> >> using small offsets from a global register.
>> >> This means that all sections must be adjacent in the image.
>> >> So you can't really have readonly small data.
>> >>
>> >> My guess is that the linker script is putting .srodata in with .sdata.
>> >
>> > .srodata does not *exist* (in the ABI).
>>
>> So, I still think this is a bug. The variable is marked const: this is
>> not a _suggestion_. :) If the compiler produces output where the
>> variable is writable, that's a bug.
>
> C11 6.7.3/6: "If an attempt is made to modify an object defined with a
> const-qualified type through use of an lvalue with non-const-qualified
> type, the behavior is undefined."
>
> And that is all that "const" means.
>
> The compiler is free to put this var in *no* data section, or to copy
> it to the stack before using it, or anything else it thinks is a good
> idea.

The kernel depends on const things being read-only. I realize C11 says
this is "undefined", but from a kernel security perspective, const
means read-only, and this is true on other architectures. Now,
strictly speaking, the compiler is just responsible for doing section
assignment for a variable, and the linker then lays things out, but
the result carries the requested memory protections (i.e. read-only,
executable, etc). If "const" is just a hint, then what is the
canonical way to have gcc put a variable into a section that the
linker will always request be kept read-only?

> If you think it would be a good idea for the compiler to change its
> behaviour here, please file a PR (or send a patch).  Please bring
> arguments why we would want to change this.

Sure:
https://gcc.gnu.org/bugzilla/show_bug.cgi?id=82411

>> I can't tell if this bug is related:
>> https://gcc.gnu.org/bugzilla/show_bug.cgi?id=9571
>
> I don't think so: the only remaining bug there is that a copy of the
> constant is put in .rodata.cst8 (although there is a copy in .sdata2
> already).

Okay, thanks for checking.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

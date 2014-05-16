Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f170.google.com (mail-ve0-f170.google.com [209.85.128.170])
	by kanga.kvack.org (Postfix) with ESMTP id 98FD06B0036
	for <linux-mm@kvack.org>; Fri, 16 May 2014 18:41:09 -0400 (EDT)
Received: by mail-ve0-f170.google.com with SMTP id db11so3933818veb.29
        for <linux-mm@kvack.org>; Fri, 16 May 2014 15:41:09 -0700 (PDT)
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
        by mx.google.com with ESMTPS id v2si1976016vet.88.2014.05.16.15.41.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 May 2014 15:41:08 -0700 (PDT)
Received: by mail-ve0-f179.google.com with SMTP id oy12so3838996veb.38
        for <linux-mm@kvack.org>; Fri, 16 May 2014 15:41:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrUTM7ZJrWvWa4bHi0RSFhzAZu7+z5XHbJuP+==Cd8GRqw@mail.gmail.com>
References: <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com>
 <20140514221140.GF28328@moon> <CALCETrUc2CpTEeo=NjLGxXQWHn-HG3uYUo-L3aOU-yVjVx3PGg@mail.gmail.com>
 <20140515084558.GI28328@moon> <CALCETrWwWXEoNparvhx4yJB8YmiUBZCuR6yQxJOTjYKuA8AdqQ@mail.gmail.com>
 <20140515195320.GR28328@moon> <CALCETrWbf8XYvBh=zdyOBqVqRd7s8SVbbDX=O2X+zAZn83r-bw@mail.gmail.com>
 <20140515201914.GS28328@moon> <20140515213124.GT28328@moon>
 <CALCETrXe80dx+ODPF1o2iUMOEOO_JAdev4f9gOQ4SUj4JQv36Q@mail.gmail.com>
 <20140515215722.GU28328@moon> <CALCETrUTM7ZJrWvWa4bHi0RSFhzAZu7+z5XHbJuP+==Cd8GRqw@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 16 May 2014 15:40:48 -0700
Message-ID: <CALCETrU5-4sMyOW7t75PJ4RQ3WdUg=s2xhYG5uEstm_LEOV+mg@mail.gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, "H. Peter Anvin" <hpa@zytor.com>

On Thu, May 15, 2014 at 3:15 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Thu, May 15, 2014 at 2:57 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
>> On Thu, May 15, 2014 at 02:42:48PM -0700, Andy Lutomirski wrote:
>>> >
>>> > Looking forward the question appear -- will VDSO_PREV_PAGES and rest of variables
>>> > be kind of immutable constants? If yes, we could calculate where the additional
>>> > vma lives without requiring any kind of [vdso] mark in proc/pid/maps output.
>>>
>>> Please don't!
>>>
>>> These might, in principle, even vary between tasks on the same system.
>>>  Certainly the relative positions of the vmas will be different
>>> between 3.15 and 3.16, since we need almost my entire cleanup series
>>> to reliably put them into their 3.16 location.  And I intend to change
>>> the number of pages in 3.16 or 3.17.
>>
>> There are other ways how to find where additional pages are laying but it
>> would be great if there a straightforward interface for that (ie some mark
>> in /proc/pid/maps output).
>
> I'll try to write a patch in time for 3.15.
>

My current draft is here:

https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=vdso/cleanups

On 64-bit userspace, it results in:

7fffa1dfd000-7fffa1dfe000 r-xp 00000000 00:00 0                          [vdso]
7fffa1dfe000-7fffa1e00000 r--p 00000000 00:00 0                          [vvar]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0
  [vsyscall]

On 32-bit userspace, it results in:

f7748000-f7749000 r-xp 00000000 00:00 0                                  [vdso]
f7749000-f774b000 r--p 00000000 00:00 0                                  [vvar]
ffd94000-ffdb5000 rw-p 00000000 00:00 0                                  [stack]

Is this good for CRIU?  Another approach would be to name both of
these things "vdso", since they are sort of both the vdso, but that
might be a bit confusing -- [vvar] is not static text the way that
[vdso] is.

If I backport this for 3.15 (which might be nasty -- I would argue
that the code change is actually a cleanup, but it's fairly
intrusive), then [vvar] will be *before* [vdso], not after it.  I'd be
very hesitant to name both of them "[vdso]" in that case, since there
is probably code that assumes that the beginning of "[vdso]" is a DSO.

Note that it is *not* safe to blindly read from "[vvar]".  On some
configurations you *will* get SIGBUS if you try to read from some of
the vvar pages.  (That's what started this whole thread.)  Some pages
in "[vvar]" may have strange caching modes, so SIGBUS might not be the
only surprising thing about poking at it.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

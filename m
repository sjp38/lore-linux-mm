Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9A71A6B0036
	for <linux-mm@kvack.org>; Sat, 17 May 2014 02:15:59 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id s7so2570725lbd.36
        for <linux-mm@kvack.org>; Fri, 16 May 2014 23:15:58 -0700 (PDT)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id mt9si3136436lbc.221.2014.05.16.23.15.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 May 2014 23:15:57 -0700 (PDT)
Received: by mail-la0-f50.google.com with SMTP id b8so2583499lan.23
        for <linux-mm@kvack.org>; Fri, 16 May 2014 23:15:57 -0700 (PDT)
Date: Sat, 17 May 2014 10:15:55 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Message-ID: <20140517061555.GX28328@moon>
References: <20140515084558.GI28328@moon>
 <CALCETrWwWXEoNparvhx4yJB8YmiUBZCuR6yQxJOTjYKuA8AdqQ@mail.gmail.com>
 <20140515195320.GR28328@moon>
 <CALCETrWbf8XYvBh=zdyOBqVqRd7s8SVbbDX=O2X+zAZn83r-bw@mail.gmail.com>
 <20140515201914.GS28328@moon>
 <20140515213124.GT28328@moon>
 <CALCETrXe80dx+ODPF1o2iUMOEOO_JAdev4f9gOQ4SUj4JQv36Q@mail.gmail.com>
 <20140515215722.GU28328@moon>
 <CALCETrUTM7ZJrWvWa4bHi0RSFhzAZu7+z5XHbJuP+==Cd8GRqw@mail.gmail.com>
 <CALCETrU5-4sMyOW7t75PJ4RQ3WdUg=s2xhYG5uEstm_LEOV+mg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrU5-4sMyOW7t75PJ4RQ3WdUg=s2xhYG5uEstm_LEOV+mg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, "H. Peter Anvin" <hpa@zytor.com>

On Fri, May 16, 2014 at 03:40:48PM -0700, Andy Lutomirski wrote:
> >>
> >> There are other ways how to find where additional pages are laying but it
> >> would be great if there a straightforward interface for that (ie some mark
> >> in /proc/pid/maps output).
> >
> > I'll try to write a patch in time for 3.15.
> >
> 
> My current draft is here:
> 
> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=vdso/cleanups
> 
> On 64-bit userspace, it results in:
> 
> 7fffa1dfd000-7fffa1dfe000 r-xp 00000000 00:00 0                          [vdso]
> 7fffa1dfe000-7fffa1e00000 r--p 00000000 00:00 0                          [vvar]
> ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
> 
> On 32-bit userspace, it results in:
> 
> f7748000-f7749000 r-xp 00000000 00:00 0                                  [vdso]
> f7749000-f774b000 r--p 00000000 00:00 0                                  [vvar]
> ffd94000-ffdb5000 rw-p 00000000 00:00 0                                  [stack]
> 
> Is this good for CRIU?  Another approach would be to name both of
> these things "vdso", since they are sort of both the vdso, but that
> might be a bit confusing -- [vvar] is not static text the way that
> [vdso] is.

Yeah, thanks a lot, Andy, this is more than enough.

> If I backport this for 3.15 (which might be nasty -- I would argue
> that the code change is actually a cleanup, but it's fairly
> intrusive), then [vvar] will be *before* [vdso], not after it.  I'd be
> very hesitant to name both of them "[vdso]" in that case, since there
> is probably code that assumes that the beginning of "[vdso]" is a DSO.
> 
> Note that it is *not* safe to blindly read from "[vvar]".  On some
> configurations you *will* get SIGBUS if you try to read from some of
> the vvar pages.  (That's what started this whole thread.)  Some pages
> in "[vvar]" may have strange caching modes, so SIGBUS might not be the
> only surprising thing about poking at it.

Ouch. Thanks for the note, I'll read new code with more attention and
report the effect it did over criu (prob. on next week).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

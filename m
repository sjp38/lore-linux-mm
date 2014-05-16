Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id D5C206B0036
	for <linux-mm@kvack.org>; Fri, 16 May 2014 18:56:20 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so1895852eek.16
        for <linux-mm@kvack.org>; Fri, 16 May 2014 15:56:20 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id c6si8091669eem.120.2014.05.16.15.56.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 May 2014 15:56:19 -0700 (PDT)
Message-ID: <53769785.6060809@zytor.com>
Date: Fri, 16 May 2014 15:56:05 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
References: <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com> <20140514221140.GF28328@moon> <CALCETrUc2CpTEeo=NjLGxXQWHn-HG3uYUo-L3aOU-yVjVx3PGg@mail.gmail.com> <20140515084558.GI28328@moon> <CALCETrWwWXEoNparvhx4yJB8YmiUBZCuR6yQxJOTjYKuA8AdqQ@mail.gmail.com> <20140515195320.GR28328@moon> <CALCETrWbf8XYvBh=zdyOBqVqRd7s8SVbbDX=O2X+zAZn83r-bw@mail.gmail.com> <20140515201914.GS28328@moon> <20140515213124.GT28328@moon> <CALCETrXe80dx+ODPF1o2iUMOEOO_JAdev4f9gOQ4SUj4JQv36Q@mail.gmail.com> <20140515215722.GU28328@moon> <CALCETrUTM7ZJrWvWa4bHi0RSFhzAZu7+z5XHbJuP+==Cd8GRqw@mail.gmail.com> <CALCETrU5-4sMyOW7t75PJ4RQ3WdUg=s2xhYG5uEstm_LEOV+mg@mail.gmail.com>
In-Reply-To: <CALCETrU5-4sMyOW7t75PJ4RQ3WdUg=s2xhYG5uEstm_LEOV+mg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On 05/16/2014 03:40 PM, Andy Lutomirski wrote:
> 
> My current draft is here:
> 
> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=vdso/cleanups
> 
> On 64-bit userspace, it results in:
> 
> 7fffa1dfd000-7fffa1dfe000 r-xp 00000000 00:00 0                          [vdso]
> 7fffa1dfe000-7fffa1e00000 r--p 00000000 00:00 0                          [vvar]
> ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0
>   [vsyscall]
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
> 
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
> 

mremap() should work on these pages, right?

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

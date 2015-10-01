Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 999B36B027E
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 16:45:51 -0400 (EDT)
Received: by obbda8 with SMTP id da8so67667499obb.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 13:45:51 -0700 (PDT)
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com. [209.85.214.171])
        by mx.google.com with ESMTPS id y186si4205574oiy.89.2015.10.01.13.45.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 13:45:50 -0700 (PDT)
Received: by obbzf10 with SMTP id zf10so67633546obb.2
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 13:45:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com> <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com> <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com> <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com> <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 1 Oct 2015 13:45:30 -0700
Message-ID: <CALCETrWaar55uTv5q3Ym1KEdQjfgjDfwMM=PPnjb9eV+ASS_ig@mail.gmail.com>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave@sr71.net>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On Thu, Oct 1, 2015 at 1:39 PM, Kees Cook <keescook@google.com> wrote:
> On Thu, Oct 1, 2015 at 4:17 AM, Ingo Molnar <mingo@kernel.org> wrote:
>>
>> * Dave Hansen <dave@sr71.net> wrote:
>>
>>> > If yes then this could be a significant security feature / usecase for pkeys:
>
> Which CPUs (will) have pkeys?
>
>>> > executable sections of shared libraries and binaries could be mapped with pkey
>>> > access disabled. If I read the Intel documentation correctly then that should
>>> > be possible.
>>>
>>> Agreed.  I've even heard from some researchers who are interested in this:
>>>
>>> https://www.infsec.cs.uni-saarland.de/wp-content/uploads/sites/2/2014/10/nuernberger2014ccs_disclosure.pdf
>>
>> So could we try to add an (opt-in) kernel option that enables this transparently
>> and automatically for all PROT_EXEC && !PROT_WRITE mappings, without any
>> user-space changes and syscalls necessary?
>
> I would like this very much. :)
>
>> Beyond the security improvement, this would enable this hardware feature on most
>> x86 Linux distros automatically, on supported hardware, which is good for testing.
>>
>> Assuming it boots up fine on a typical distro, i.e. assuming that there are no
>> surprises where PROT_READ && PROT_EXEC sections are accessed as data.
>
> I can't wait to find out what implicitly expects PROT_READ from
> PROT_EXEC mappings. :)

There's one annoying issue at least:

mprotect_pkey(..., PROT_READ | PROT_EXEC, 0) sets protection key 0.
mprotect_pkey(..., PROT_EXEC, 0) maybe sets protection key 15 or
whatever we use for this.  What does mprotect_pkey(..., PROT_EXEC, 0)
do?  What if the caller actually wants key 0?  What if some CPU vendor
some day implements --x for real?


Also, how do we do mprotect_pkey and say "don't change the key"?

>
> -Kees
>
> --
> Kees Cook
> Chrome OS Security



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

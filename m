Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E2DC36B0253
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 19:28:10 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so872486pab.3
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 16:28:10 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id gu1si52605235pac.39.2015.10.06.16.28.07
        for <linux-mm@kvack.org>;
        Tue, 06 Oct 2015 16:28:07 -0700 (PDT)
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
References: <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com> <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com> <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <CALCETrWaar55uTv5q3Ym1KEdQjfgjDfwMM=PPnjb9eV+ASS_ig@mail.gmail.com>
 <20151002062340.GB30051@gmail.com> <560EC3EC.2080803@sr71.net>
 <20151003072755.GA23524@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56145905.6070109@sr71.net>
Date: Tue, 6 Oct 2015 16:28:05 -0700
MIME-Version: 1.0
In-Reply-To: <20151003072755.GA23524@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On 10/03/2015 12:27 AM, Ingo Molnar wrote:
>  - I'd also suggest providing an initial value with the 'alloc' call. It's true 
>    that user-space can do this itself in assembly, OTOH there's no reason not to 
>    provide a C interface for this.

You mean an initial value for the rights register (PKRU), correct?

So init_val would be something like

	PKEY_DENY_ACCESS
	PKEY_DENY_WRITE

and it would refer only to the key that was allocated.

>  - Along similar considerations, also add a sys_pkey_query() system call to query 
>    the mapping of a specific pkey. (returns -EBADF or so if the key is not mapped
>    at the moment.) This too could be vDSO accelerated in the future.

Do you mean whether the key is being used on a mapping (VMA) or rather
whether the key is currently allocated (has been returned from
sys_pkey_alloc() in the past)?

> I.e. something like:
> 
>      unsigned long sys_pkey_alloc (unsigned long flags, unsigned long init_val)
>      unsigned long sys_pkey_set   (int pkey, unsigned long new_val)
>      unsigned long sys_pkey_get   (int pkey)
>      unsigned long sys_pkey_free  (int pkey)
> 
> Optional suggestion:
> 
>  - _Maybe_ also allow the 'remote managed' setup of pkeys: of non-local tasks - 
>    but I'm not sure about that: it looks expensive and complex, and a TID argument 
>    can always be added later if there's some real need.

Yeah, let's see how the stuff above looks first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

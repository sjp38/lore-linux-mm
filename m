Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 27E8582F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 11:12:57 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so25411939pac.3
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 08:12:56 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id lp10si30167608pab.101.2015.10.16.08.12.50
        for <linux-mm@kvack.org>;
        Fri, 16 Oct 2015 08:12:50 -0700 (PDT)
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
Message-ID: <562113F0.6060307@sr71.net>
Date: Fri, 16 Oct 2015 08:12:48 -0700
MIME-Version: 1.0
In-Reply-To: <20151003072755.GA23524@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On 10/03/2015 12:27 AM, Ingo Molnar wrote:
>  - Along similar considerations, also add a sys_pkey_query() system call to query 
>    the mapping of a specific pkey. (returns -EBADF or so if the key is not mapped
>    at the moment.) This too could be vDSO accelerated in the future.
> 
> I.e. something like:
> 
>      unsigned long sys_pkey_alloc (unsigned long flags, unsigned long init_val)
>      unsigned long sys_pkey_set   (int pkey, unsigned long new_val)
>      unsigned long sys_pkey_get   (int pkey)
>      unsigned long sys_pkey_free  (int pkey)

The pkey_set() operation is going to get a wee bit interesting with signals.

pkey_set() will modify the _current_ context's PKRU which includes the
register itself and the kernel XSAVE buffer (if active).  But, since the
PKRU state is saved/restored with the XSAVE state, we will blow away any
state set during the signal.

I _think_ the right move here is to either keep a 'shadow' version of
PKRU inside the kernel (for each thread) and always update the task's
XSAVE PKRU state when returning from a signal handler.  Or, _copy_ the
signal's PKRU state in to the main process's PKRU state when returning
from a signal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

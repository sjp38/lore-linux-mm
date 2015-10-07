Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5306D6B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 03:11:29 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so198222778wic.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 00:11:28 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id at5si43627113wjc.111.2015.10.07.00.11.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 00:11:27 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so199112315wic.0
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 00:11:27 -0700 (PDT)
Date: Wed, 7 Oct 2015 09:11:24 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Message-ID: <20151007071124.GC7837@gmail.com>
References: <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com>
 <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <CALCETrWaar55uTv5q3Ym1KEdQjfgjDfwMM=PPnjb9eV+ASS_ig@mail.gmail.com>
 <20151002062340.GB30051@gmail.com>
 <560EC3EC.2080803@sr71.net>
 <20151003072755.GA23524@gmail.com>
 <56145905.6070109@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56145905.6070109@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>


* Dave Hansen <dave@sr71.net> wrote:

> On 10/03/2015 12:27 AM, Ingo Molnar wrote:
> >  - I'd also suggest providing an initial value with the 'alloc' call. It's true 
> >    that user-space can do this itself in assembly, OTOH there's no reason not to 
> >    provide a C interface for this.
> 
> You mean an initial value for the rights register (PKRU), correct?
> 
> So init_val would be something like
> 
> 	PKEY_DENY_ACCESS
> 	PKEY_DENY_WRITE
> 
> and it would refer only to the key that was allocated.

Correct.

> >  - Along similar considerations, also add a sys_pkey_query() system call to query 
> >    the mapping of a specific pkey. (returns -EBADF or so if the key is not mapped
> >    at the moment.) This too could be vDSO accelerated in the future.
> 
> Do you mean whether the key is being used on a mapping (VMA) or rather
> whether the key is currently allocated (has been returned from
> sys_pkey_alloc() in the past)?

So in my mind 'pkeys' are an array of 16 values. The hardware allows us to map any 
'protection key value' to any of the 16 indices.

The query interface would only query this array, i.e. it would tell us what 
current protection value a given pkey index has - if it's allocated. So 
sys_pkey_query(6) would return the current protection key value for index 6. If 
the index has not been allocated yet, it would return -EBADF or so.

This is what 'managed pkeys' means in essence.

Allocation/freeing of pkeys is a relatively rare operation, and pkeys get 
inherited across fork()/clone() (which further cuts down on management 
activities), but it looks simple in any case.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

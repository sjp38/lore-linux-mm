Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id CF2BF4402F8
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 13:50:41 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so111611069pab.3
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 10:50:41 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id wv1si18241628pab.150.2015.10.02.10.50.39
        for <linux-mm@kvack.org>;
        Fri, 02 Oct 2015 10:50:39 -0700 (PDT)
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com> <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com> <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <CALCETrWaar55uTv5q3Ym1KEdQjfgjDfwMM=PPnjb9eV+ASS_ig@mail.gmail.com>
 <20151002062340.GB30051@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <560EC3EC.2080803@sr71.net>
Date: Fri, 2 Oct 2015 10:50:36 -0700
MIME-Version: 1.0
In-Reply-To: <20151002062340.GB30051@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@amacapital.net>
Cc: Kees Cook <keescook@google.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On 10/01/2015 11:23 PM, Ingo Molnar wrote:
>> > Also, how do we do mprotect_pkey and say "don't change the key"?
> So if we start managing keys as a resource (i.e. alloc/free up to 16 of them), and 
> provide APIs for user-space to do all that, then user-space is not supposed to 
> touch keys it has not allocated for itself - just like it's not supposed to write 
> to fds it has not opened.

I like that.  It gives us at least a "soft" indicator to userspace about
what keys it should or shouldn't be using.

> Such an allocation method can still 'mess up', and if the kernel allocates a key 
> for its purposes it should not assume that user-space cannot change it, but at 
> least for non-buggy code there's no interaction and it would work out fine.

Yeah.  It also provides a clean interface so that future hardware could
enforce enforce kernel "ownership" of a key which could protect against
even buggy code.

So, we add a pair of syscalls,

	unsigned long sys_alloc_pkey(unsigned long flags??)
	unsigned long sys_free_pkey(unsigned long pkey)

keep the metadata in the mm, and then make sure that userspace allocated
it before it is allowed to do an mprotect_pkey() with it.

mprotect_pkey(add, flags, pkey)
{
	if (!(mm->pkeys_allocated & (1 << pkey))
		return -EINVAL;
}

That should be pretty easy to implement.  The only real overhead is the
16 bits we need to keep in the mm somewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB1282F87
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 18:58:19 -0400 (EDT)
Received: by oixx17 with SMTP id x17so49388012oix.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 15:58:19 -0700 (PDT)
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com. [209.85.214.181])
        by mx.google.com with ESMTPS id dw10si4414896obb.57.2015.10.01.15.58.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 15:58:18 -0700 (PDT)
Received: by obbda8 with SMTP id da8so69939216obb.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 15:58:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <560DB4A6.6050107@sr71.net>
References: <20150916174903.E112E464@viggo.jf.intel.com> <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com> <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com> <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com> <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <560DB4A6.6050107@sr71.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 1 Oct 2015 15:57:59 -0700
Message-ID: <CALCETrUXqzZjGOxf0bKrr7VmSBS89zB0DK+5Xo2quToRRQu3DA@mail.gmail.com>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Kees Cook <keescook@google.com>, Ingo Molnar <mingo@kernel.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Paolo Bonzini <pbonzini@redhat.com>, kvm list <kvm@vger.kernel.org>

On Thu, Oct 1, 2015 at 3:33 PM, Dave Hansen <dave@sr71.net> wrote:
> On 10/01/2015 01:39 PM, Kees Cook wrote:
>> On Thu, Oct 1, 2015 at 4:17 AM, Ingo Molnar <mingo@kernel.org> wrote:
>>> So could we try to add an (opt-in) kernel option that enables this transparently
>>> and automatically for all PROT_EXEC && !PROT_WRITE mappings, without any
>>> user-space changes and syscalls necessary?
>>
>> I would like this very much. :)
>
> Here it is in a quite fugly form (well, it's not opt-in).  Init crashes
> if I boot with this, though.

Somebody really ought to rework things so that a crash in init prints
out a normal indication of the unhandled signal and optionally leaves
everything else running.

Also...

EPT seems to have separate R, W, and X flags.  I wonder if it would
make sense to add a KVM paravirt feature that maps the entire guest
physical space an extra time at a monstrous offset with R cleared in
the EPT and passes through a #PF or other notification (KVM-specific
thing? #VE?) on a read fault.

This wouldn't even need a whole duplicate paging hierarchy -- it would
just duplicate the EPT PML4 entries, so it would add exactly zero
runtime memory usage.

The guest would use it by treating the high bit of the physical
address as a "may read" bit.

This reminds me -- we should probably wire up X86_TRAP_VE with a stub
that OOPSes until someone figures out some more useful thing to do.
We're probably not doing anyone any favors by unconditionally
promoting them to double-faults.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

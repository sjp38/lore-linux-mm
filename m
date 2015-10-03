Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id A932244030A
	for <linux-mm@kvack.org>; Sat,  3 Oct 2015 03:28:00 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so59295807wic.0
        for <linux-mm@kvack.org>; Sat, 03 Oct 2015 00:28:00 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id o5si17776566wjf.27.2015.10.03.00.27.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Oct 2015 00:27:59 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so55557432wic.0
        for <linux-mm@kvack.org>; Sat, 03 Oct 2015 00:27:59 -0700 (PDT)
Date: Sat, 3 Oct 2015 09:27:55 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Message-ID: <20151003072755.GA23524@gmail.com>
References: <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com>
 <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com>
 <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <CALCETrWaar55uTv5q3Ym1KEdQjfgjDfwMM=PPnjb9eV+ASS_ig@mail.gmail.com>
 <20151002062340.GB30051@gmail.com>
 <560EC3EC.2080803@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <560EC3EC.2080803@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>


* Dave Hansen <dave@sr71.net> wrote:

> On 10/01/2015 11:23 PM, Ingo Molnar wrote:
> >> > Also, how do we do mprotect_pkey and say "don't change the key"?
> >
> > So if we start managing keys as a resource (i.e. alloc/free up to 16 of them), 
> > and provide APIs for user-space to do all that, then user-space is not 
> > supposed to touch keys it has not allocated for itself - just like it's not 
> > supposed to write to fds it has not opened.
> 
> I like that.  It gives us at least a "soft" indicator to userspace about what 
> keys it should or shouldn't be using.

Yes. A 16-bit allocation bitmap would solve this nicely.

> > Such an allocation method can still 'mess up', and if the kernel allocates a key 
> > for its purposes it should not assume that user-space cannot change it, but at 
> > least for non-buggy code there's no interaction and it would work out fine.
> 
> Yeah.  It also provides a clean interface so that future hardware could
> enforce enforce kernel "ownership" of a key which could protect against
> even buggy code.
> 
> So, we add a pair of syscalls,
> 
> 	unsigned long sys_alloc_pkey(unsigned long flags??)
> 	unsigned long sys_free_pkey(unsigned long pkey)
> 
> keep the metadata in the mm, and then make sure that userspace allocated
> it before it is allowed to do an mprotect_pkey() with it.

Yeah, so such an interface would allow the clean, transparent usage of pkeys for 
pure PROT_EXEC mappings.

I'd expect the --x/PROT_EXEC mappings to be _by far_ more frequently used than 
pure pkeys - but we still need the management interface to keep the kernel's use 
of pkeys separate from user-space's use.

If all the necessary tooling changes are propagated through then in fact I'd 
expect every pkeys capable Linux system to use pkeys, for almost every user-space 
task.

To have maximum future flexibility for pkeys I'd suggest the following additional 
changes to the syscall ABI:

 - Please name them with a pkey_ prefix, along the sys_pkey_* nomenclature, so 
   that it becomes an easily identified 'family' of system calls.

 - I'd also suggest providing an initial value with the 'alloc' call. It's true 
   that user-space can do this itself in assembly, OTOH there's no reason not to 
   provide a C interface for this.

 - Make the pkey identifier 'int', not 'long', like fds are. There's very little
   expectation to ever have more than 4 billion pkeys per mm, right?

 - How far do we want the kernel to manage this? Any reason we don't want a
   'set pkey' operation, if user-space wants to use pure C interfaces? That could 
   be vDSO accelerated as well, to use the unprivileged op. An advantage of such
   an interface would be that it would enable the kernel to more actively manage
   the actual mappings as well in the future: for example to automatically not
   allow accidental RWX mappings. Such an interface would also allow the future
   introduction of privileged pkey mappings on the hardware side, without having
   to change user-space, since everything goes via the kernel interface.

 - Along similar considerations, also add a sys_pkey_query() system call to query 
   the mapping of a specific pkey. (returns -EBADF or so if the key is not mapped
   at the moment.) This too could be vDSO accelerated in the future.

I.e. something like:

     unsigned long sys_pkey_alloc (unsigned long flags, unsigned long init_val)
     unsigned long sys_pkey_set   (int pkey, unsigned long new_val)
     unsigned long sys_pkey_get   (int pkey)
     unsigned long sys_pkey_free  (int pkey)

Optional suggestion:

 - _Maybe_ also allow the 'remote managed' setup of pkeys: of non-local tasks - 
   but I'm not sure about that: it looks expensive and complex, and a TID argument 
   can always be added later if there's some real need.

> That should be pretty easy to implement.  The only real overhead is the 16 bits 
> we need to keep in the mm somewhere.

Yes.

Note that if we use the C syscall interface suggestions I outlined above, we could 
in the future also change to have a full table, and manage it explicitly - without 
user-space changes - if the hardware side is tweaked to allow kernel side pkeys.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6906B028B
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:35:12 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 31so6543844wru.0
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:35:12 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c21si19974wrc.92.2018.01.16.11.35.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 11:35:10 -0800 (PST)
Date: Tue, 16 Jan 2018 20:34:59 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 07/16] x86/mm: Move two more functions from pgtable_64.h
 to pgtable.h
In-Reply-To: <20180116191105.GC28161@8bytes.org>
Message-ID: <alpine.DEB.2.20.1801162033220.2366@nanos>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org> <1516120619-1159-8-git-send-email-joro@8bytes.org> <727a7eba-41a0-d5bb-df54-8e58b33fde76@intel.com> <20180116191105.GC28161@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On Tue, 16 Jan 2018, Joerg Roedel wrote:

> On Tue, Jan 16, 2018 at 10:03:09AM -0800, Dave Hansen wrote:
> > On 01/16/2018 08:36 AM, Joerg Roedel wrote:
> > > +	return (((ptr & ~PAGE_MASK) / sizeof(pgd_t)) < KERNEL_PGD_BOUNDARY);
> > > +}
> > 
> > One of the reasons to implement it the other way:
> > 
> > -	return (ptr & ~PAGE_MASK) < (PAGE_SIZE / 2);
> > 
> > is that the compiler can do this all quickly.  KERNEL_PGD_BOUNDARY
> > depends on PAGE_OFFSET which depends on a variable.  IOW, the compiler
> > can't do it.
> > 
> > How much worse is the code that this generates?
> 
> I havn't looked at the actual code this generates, but the
> (PAGE_SIZE / 2) comparison doesn't work on 32 bit where the address
> space is not always evenly split. I'll look into a better way to check
> this.

It should be trivial enough to do

   return (ptr & ~PAGE_MASK) < PGD_SPLIT_SIZE);

and define it PAGE_SIZE/2 for 64bit and for PAE make it depend on the
configured address space split.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

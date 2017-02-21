Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 51B386B039B
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 05:47:40 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w37so4283547wrc.0
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 02:47:40 -0800 (PST)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id b47si8566155wrb.1.2017.02.21.02.47.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 02:47:38 -0800 (PST)
Received: by mail-wr0-x242.google.com with SMTP id q39so14718122wrb.2
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 02:47:38 -0800 (PST)
Date: Tue, 21 Feb 2017 13:47:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and
 PR_GET_MAX_VADDR
Message-ID: <20170221104736.GA13174@node.shutemov.name>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
 <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
 <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com>
 <CALCETrW6YBxZw0NJGHe92dy7qfHqRHNr0VqTKV=O4j9r8hcSew@mail.gmail.com>
 <CA+55aFxu0p90nz6-VPFLCLBSpEVx7vNFGP_M8j=YS-Dk-zfJGg@mail.gmail.com>
 <CALCETrW91F0=GLWt4yBJVbt7U=E6nLXDUMNUvTpnmn6XLjaY6g@mail.gmail.com>
 <CA+55aFw4hAe-SUp9K8kfgT+RO60Ow8c=Bi=ZTw9qzHy2D=h8pQ@mail.gmail.com>
 <20170221103401.GA31018@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170221103401.GA31018@e104818-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm <linux-mm@kvack.org>

On Tue, Feb 21, 2017 at 10:34:02AM +0000, Catalin Marinas wrote:
> On Fri, Feb 17, 2017 at 03:21:27PM -0800, Linus Torvalds wrote:
> > On Feb 17, 2017 3:02 PM, "Andy Lutomirski" <luto@amacapital.net> wrote:
> > >   What I'm trying to say is: if we're going to do the route of 48-bit
> > >   limit unless a specific mmap call requests otherwise, can we at least
> > >   have an interface that doesn't suck?
> > 
> > No, I'm not suggesting specific mmap calls at all. I'm suggesting the complete
> > opposite: not having some magical "max address" at all in the VM layer. Keep
> > all the existing TASK_SIZE defines as-is, and just make those be the new 56-bit
> > limit.
> > 
> > But to then not make most processes use it, just make the default x86
> > arch_get_free_area() return an address limited to the old 47-bit limit. So
> > effectively all legacy programs work exactly the same way they always did.
> 
> arch_get_unmapped_area() changes would not cover STACK_TOP which is
> currently defined as TASK_SIZE (on both x86 and arm64). I don't think it
> matters much (normally such upper bits tricks are done on heap objects)
> but you may find some weird user program that passes pointers to the
> stack around and expects bits 48-63 to be masked out. If that's a real
> issue, we could also limit STACK_TOP to 47-bit (48-bit on arm64).

I've limited STACK_TOP to 47-bit in my implementation of Linus' proposal:

http://lkml.kernel.org/r/20170220131515.GA9502@node.shutemov.name

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE466B0390
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 06:32:30 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g31so14951078wrg.15
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 03:32:30 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id w198si4035718wmf.107.2017.04.17.03.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 03:32:28 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id o81so8181834wmb.0
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 03:32:28 -0700 (PDT)
Date: Mon, 17 Apr 2017 12:32:25 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/8] x86/boot/64: Add support of additional page table
 level during early boot
Message-ID: <20170417103225.ycv73fdrfx33e5sd@gmail.com>
References: <20170406140106.78087-1-kirill.shutemov@linux.intel.com>
 <20170406140106.78087-4-kirill.shutemov@linux.intel.com>
 <20170411070203.GA14621@gmail.com>
 <20170411105106.4zgbzuu4s4267zyv@node.shutemov.name>
 <20170411112845.GA15212@gmail.com>
 <20170411114616.otx2f6aw5lcvfc2o@black.fi.intel.com>
 <20170411140907.GD4021@tassilo.jf.intel.com>
 <20170412101804.cxo6h472ns76ukgo@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170412101804.cxo6h472ns76ukgo@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Tue, Apr 11, 2017 at 07:09:07AM -0700, Andi Kleen wrote:
> > > I'll look closer (building proccess it's rather complicated), but my
> > > understanding is that VDSO is stand-alone binary and doesn't really links
> > > with the rest of the kernel, rather included as blob, no?
> > > 
> > > Andy, may be you have an idea?
> > 
> > There isn't any way I know of to directly link them together. The ELF 
> > format wasn't designed for that. You would need to merge blobs and then use
> > manual jump vectors, like the 16bit startup code does. It would be likely
> > complicated and ugly.
> 
> Ingo, can we proceed without coverting this assembly to C?
> 
> I'm committed to convert it to C later if we'll find reasonable solution
> to the issue.

So one way to do it would be to build it standalone as a .o, then add it not to 
the regular kernel objects link target (as you found out it's not possible to link 
32-bit and 64-bit objects), but to link it in a manual fashion, as part of 
vmlinux.bin.all-y in arch/x86/boot/compressed/Makefile.

But there would be other complications with this approach, such as we'd have to 
add a size field and there might be symbol linking problems ...

Another, pretty hacky way would be to generate a .S from the .c, then post-process 
the .S and essentially generate today's 32-bit .S from it.

Probably not worth the trouble.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

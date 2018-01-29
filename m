Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9D6C6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 08:48:03 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y18so5596259wrh.12
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 05:48:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x38sor5208194eda.41.2018.01.29.05.48.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jan 2018 05:48:02 -0800 (PST)
Date: Mon, 29 Jan 2018 16:48:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/kexec: Make kexec work in 5-level paging mode
Message-ID: <20180129134800.a3sbcqzdy6vd5jjy@node.shutemov.name>
References: <20180129110845.26633-1-kirill.shutemov@linux.intel.com>
 <20180129115927.GB18247@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180129115927.GB18247@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 29, 2018 at 03:59:27AM -0800, Matthew Wilcox wrote:
> On Mon, Jan 29, 2018 at 02:08:45PM +0300, Kirill A. Shutemov wrote:
> > I've missed that we need to change relocate_kernel() to set CR4.LA57
> > flag if the kernel has 5-level paging enabled.
> > 
> > I avoided to use ifdef CONFIG_X86_5LEVEL here and inferred if we need to
> > enabled 5-level paging from previous CR4 value. This way the code is
> > ready for boot-time switching between paging modes.
> 
> Forgive me if I'm missing something ... can you kexec a 5-level kernel
> from a 4-level kernel or vice versa?

With this patch you can kexec from 4-to-5 and from 5-to-5 in addition to
current 4-to-4. 4-to-5 basically takes the same path as UEFI boot in new
kernel.

I think I will be able to make 5-to-4 work too, when boot-time switching
code will be upstream, assuming both kernels are build from the tree with
boot-time switching support and the new kernel is loaded below 128TiB.

For 5-to-4, kernel decompression code of the new kernel starts on 5-level
paging identity mapping constructed by caller. Decompression code then
would switch over to 4-level paging via 32-bit trampoline (we cannot
switch between 4- and 5-level paging directly) and proceed as in normal
boot.

Let me check.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

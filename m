Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CEEAA6B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 11:13:52 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id h12so2196792wre.12
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 08:13:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 39sor928145wrz.12.2017.11.29.08.13.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 08:13:51 -0800 (PST)
Date: Wed, 29 Nov 2017 19:13:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 0/4] x86: 5-level related changes into decompression
 code
Message-ID: <20171129161349.d7ksuhwhdamloty6@node.shutemov.name>
References: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
 <20171129154908.6y4st6xc7hbsey2v@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129154908.6y4st6xc7hbsey2v@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 29, 2017 at 04:49:08PM +0100, Borislav Petkov wrote:
> On Sat, Nov 11, 2017 at 01:06:41AM +0300, Kirill A. Shutemov wrote:
> > Hi Ingo,
> > 
> > Here's updated changes that prepare the code to boot-time switching between
> > paging modes and handle booting in 5-level mode when bootloader put kernel
> > image above 4G, but haven't enabled 5-level paging for us.
> 
> Btw, if I enable CONFIG_X86_5LEVEL with 4.15-rc1 on an AMD box, the box
> triple-faults and ends up spinning in a reboot loop. Even though it
> should say:
> 
> early console in setup code
> This kernel requires the following features not present on the CPU:
> la57 
> Unable to boot - please use a kernel appropriate for your CPU.
> 
> and halt.
> 
> A kvm guest still does that but baremetal triple-faults.
> 
> Ideas?

Looks like we call check_cpuflags() too late. 5-level paging gets enabled
before image decompression started.

For qemu/kvm it works because it's supported in softmmu, even if not
advertised in cpuid.

I'm not sure if it worth fixing on its own. I would rather get boot-time
switching code upstream sooner. It will get problem go away naturally.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

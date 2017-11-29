Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB5606B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 12:08:34 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id f9so2365793wra.2
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:08:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z16sor957959wrc.34.2017.11.29.09.08.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 09:08:33 -0800 (PST)
Date: Wed, 29 Nov 2017 20:08:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 0/4] x86: 5-level related changes into decompression
 code
Message-ID: <20171129170831.2iqpop2u534mgrbc@node.shutemov.name>
References: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
 <20171129154908.6y4st6xc7hbsey2v@pd.tnic>
 <20171129161349.d7ksuhwhdamloty6@node.shutemov.name>
 <alpine.DEB.2.20.1711291740050.1825@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1711291740050.1825@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 29, 2017 at 05:40:32PM +0100, Thomas Gleixner wrote:
> On Wed, 29 Nov 2017, Kirill A. Shutemov wrote:
> 
> > On Wed, Nov 29, 2017 at 04:49:08PM +0100, Borislav Petkov wrote:
> > > On Sat, Nov 11, 2017 at 01:06:41AM +0300, Kirill A. Shutemov wrote:
> > > > Hi Ingo,
> > > > 
> > > > Here's updated changes that prepare the code to boot-time switching between
> > > > paging modes and handle booting in 5-level mode when bootloader put kernel
> > > > image above 4G, but haven't enabled 5-level paging for us.
> > > 
> > > Btw, if I enable CONFIG_X86_5LEVEL with 4.15-rc1 on an AMD box, the box
> > > triple-faults and ends up spinning in a reboot loop. Even though it
> > > should say:
> > > 
> > > early console in setup code
> > > This kernel requires the following features not present on the CPU:
> > > la57 
> > > Unable to boot - please use a kernel appropriate for your CPU.
> > > 
> > > and halt.
> > > 
> > > A kvm guest still does that but baremetal triple-faults.
> > > 
> > > Ideas?
> > 
> > Looks like we call check_cpuflags() too late. 5-level paging gets enabled
> > before image decompression started.
> > 
> > For qemu/kvm it works because it's supported in softmmu, even if not
> > advertised in cpuid.
> > 
> > I'm not sure if it worth fixing on its own. I would rather get boot-time
> > switching code upstream sooner. It will get problem go away naturally.
> 
> It needs to be fixed now. Because that problem exists in 4.14

Okay.

We're really early in the boot -- startup_64 in decompression code -- and
I don't know a way print a message there. Is there a way?

no_longmode handled by just hanging the machine. Is it enough for no_la57
case too?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

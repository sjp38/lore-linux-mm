Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 746AC6B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 04:54:29 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y39so902290wrd.17
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 01:54:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p79sor142210wmf.18.2017.11.01.01.54.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 01:54:28 -0700 (PDT)
Date: Wed, 1 Nov 2017 09:54:25 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Message-ID: <20171101085424.cwvc4nrrdhvjc3su@gmail.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, borisBrian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Thomas Garnier <thgarnie@google.com>


(Filled in the missing Cc: list)

* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> tl;dr:
> 
> KAISER makes it harder to defeat KASLR, but makes syscalls and
> interrupts slower.  These patches are based on work from a team at
> Graz University of Technology posted here[1].  The major addition is
> support for Intel PCIDs which builds on top of Andy Lutomorski's PCID
> work merged for 4.14.  PCIDs make KAISER's overhead very reasonable
> for a wide variety of use cases.

Ok, while I never thought I'd see the 4g:4g patch come to 64-bit kernels ;-),
this series is a lot better than earlier versions of this feature, and it
solves a number of KASLR timing attacks rather fundamentally.

Beyond the inevitable cavalcade of (solvable) problems that will pop up during 
review, one major item I'd like to see addressed is runtime configurability: it 
should be possible to switch between a CR3-flushing and a regular syscall and page 
table model on the admin level, without restarting the kernel and apps. Distros 
really, really don't want to double the number of kernel variants they have.

The 'Kaiser off' runtime switch doesn't have to be as efficient as 
CONFIG_KAISER=n, at least initialloy, but at minimum it should avoid the most 
expensive page table switching paths in the syscall entry codepaths.

Also, this series should be based on Andy's latest syscall entry cleanup work.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

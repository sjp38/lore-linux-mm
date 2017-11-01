Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3EFA16B0261
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 18:14:17 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v78so3302679pfk.8
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 15:14:17 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q15si677497pli.661.2017.11.01.15.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 15:14:16 -0700 (PDT)
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171101085424.cwvc4nrrdhvjc3su@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <d7cb1705-5ef0-5f6e-b1cf-e3f28e998477@linux.intel.com>
Date: Wed, 1 Nov 2017 15:14:11 -0700
MIME-Version: 1.0
In-Reply-To: <20171101085424.cwvc4nrrdhvjc3su@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, borisBrian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Thomas Garnier <thgarnie@google.com>, Kees Cook <keescook@google.com>

On 11/01/2017 01:54 AM, Ingo Molnar wrote:
> Beyond the inevitable cavalcade of (solvable) problems that will pop up during 
> review, one major item I'd like to see addressed is runtime configurability: it 
> should be possible to switch between a CR3-flushing and a regular syscall and page 
> table model on the admin level, without restarting the kernel and apps. Distros 
> really, really don't want to double the number of kernel variants they have.
> 
> The 'Kaiser off' runtime switch doesn't have to be as efficient as 
> CONFIG_KAISER=n, at least initialloy, but at minimum it should avoid the most 
> expensive page table switching paths in the syscall entry codepaths.

Due to popular demand, I went and implemented this today.  It's not the
prettiest code I ever wrote, but it's pretty small.

Just in case anyone wants to play with it, I threw a snapshot of it up here:

> https://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-kaiser.git/log/?h=kaiser-dynamic-414rc6-20171101

I ran some quick tests.  When CONFIG_KAISER=y, but "echo 0 >
kaiser-enabled", the tests that I ran were within the noise vs. a
vanilla kernel, and that's with *zero* optimization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

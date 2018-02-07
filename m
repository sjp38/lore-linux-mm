Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id C75306B0367
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 15:27:05 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id b186so1614941ywe.4
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 12:27:05 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id 203si381114ywy.230.2018.02.07.12.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 12:27:04 -0800 (PST)
Subject: Re: [RFC 0/3] x86: Patchable constants
References: <20180207145913.2703-1-kirill.shutemov@linux.intel.com>
 <CA+55aFxJO7kDNp6wRnU58Z6-sPbK1SqdzpgLBTAe54mdPjnd=g@mail.gmail.com>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <8fea57cc-8772-f8b4-3298-91b0de126358@zytor.com>
Date: Wed, 7 Feb 2018 12:20:09 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFxJO7kDNp6wRnU58Z6-sPbK1SqdzpgLBTAe54mdPjnd=g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 02/07/18 09:01, Linus Torvalds wrote:
> 
> Look - much smaller code, and register %rcx isn't used at all. And no
> D$ miss on loading that constant (that is a constant depending on
> boot-time setup only).
> 
> It's rather more complex, but it actually gives a much bigger win. The
> code itself will be much better, and smaller.
> 
> The *infrastructure* for the code gets pretty hairy, though.
> 
> The good news is that the patch already existed to at least _some_
> degree. Peter Anvin did it about 18 months ago.
> 
> It was not really pursued all the way because it *is* a lot of extra
> complexity, and I think there was some other hold-up, but he did have
> skeleton code for the actual replacement.
> 
> There was a thread on the x86 arch list with the subject line
> 
>     Disgusting pseudo-self-modifying code idea: "variable constants"
> 
> but I'm unable to actually find the patch. I know there was at least a
> vert early prototype.
> 
> Adding hpa to the cc in the hope that he has some prototype code still
> laying around..
> 

The patchset I have is about 85% complete.  It mostly needs cleanup,
testing, and breaking into reasonable chunks (it got put on the
backburner for somewhat obvious reasons, but I don't think it'll take
very long at all to productize it.)

The main reason I haven't submitted it yet is that I got a bit overly
ambitious and wanted to implement a whole bunch of more complex
subcases, such as 64-bit shifts on a 32-bit kernel.  The win in that
case is actually quite huge, but it is requires data-dependent code
patching and not just immediate patching, which requires augmentation of
the alternatives framework.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

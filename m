Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 314566B0254
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 10:48:13 -0500 (EST)
Received: by pfdd184 with SMTP id d184so31803151pfd.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 07:48:12 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id ym10si13397765pab.146.2015.12.09.07.48.12
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 07:48:12 -0800 (PST)
Subject: Re: [PATCH 26/34] mm: implement new mprotect_key() system call
References: <20151204011424.8A36E365@viggo.jf.intel.com>
 <20151204011500.69487A6C@viggo.jf.intel.com> <5662894B.7090903@gmail.com>
 <5665B767.8020802@sr71.net> <56680BA6.20406@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56684D3B.5050805@sr71.net>
Date: Wed, 9 Dec 2015 07:48:11 -0800
MIME-Version: 1.0
In-Reply-To: <56680BA6.20406@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, linux-api@vger.kernel.org

Hi Michael,

Thanks for all the comments!  I'll fix most of it when I post a new
version of the manpage, but I have a few general questions.

On 12/09/2015 03:08 AM, Michael Kerrisk (man-pages) wrote:
>>
>> +is the protection or storage key to assign to the memory.
> 
> Why "protection or storage key" here? This phrasing seems a
> little ambiguous to me, given that we also have a 'prot'
> argument.  I think it would be clearer just to say 
> "protection key". But maybe I'm missing something.

x86 calls it a "protection key" while powerpc calls it a "storage key".
 They're called "protection keys" consistently inside the kernel.

Should we just stick to one name in the manpages?

> * A general overview of why this functionality is useful.

Any preference on a central spot to do the general overview?  Does it go
in one of the manpages I'm already modifying, or a new one?

> * A note on which architectures support/will support
>   this functionality.

x86 only for now.  We might get powerpc support down the road somewhere.

> * Explanation of what a protection domain is.

A protection domain is a unique view of memory and is represented by the
value in the PKRU register.

> * Explanation of how a process (thread?) changes its
>   protection domain.

Changing protection domains is done by pkey_set() system call, or by
using the WRPKRU instruction.  The system call is preferred and less
error-prone since it enforces that a protection is allocated before its
access protection can be modified.

> * Explanation of the relationship between page permission
>   bits (PROT_READ/PROT_WRITE/PROTE_EXEC) and 
>   PKEY_DISABLE_ACCESS and PKEY_DISABLE_WRITE.
>   It's still not clear to me. Do the PKEY_* bits
>   override the PROT_* bits. Or, something else?

Protection keys add access restrictions in addition to existing page
permissions.  They can only take away access; they never grant
additional access.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

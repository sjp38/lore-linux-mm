Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 141966B0263
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 05:50:01 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so20282901wic.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 02:50:00 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id vu2si7232422wjc.90.2015.09.24.02.49.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 02:49:59 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so104830648wic.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 02:49:59 -0700 (PDT)
Date: Thu, 24 Sep 2015 11:49:56 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Message-ID: <20150924094956.GA30349@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com>
 <55FF88BA.6080006@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55FF88BA.6080006@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@google.com>


* Dave Hansen <dave@sr71.net> wrote:

> > Another question, related to enumeration as well: I'm wondering whether 
> > there's any way for the kernel to allocate a bit or two for its own purposes - 
> > such as protecting crypto keys? Or is the facility fundamentally intended for 
> > user-space use only?
> 
> No, that's not possible with the current setup.

Ok, then another question, have you considered the following usecase:

AFAICS pkeys only affect data loads and stores. Instruction fetches are notably 
absent from the documentation. Can you clarify that instructions can be fetched 
and executed from PTE_READ but pkeys-all-access-disabled pags?

If yes then this could be a significant security feature / usecase for pkeys: 
executable sections of shared libraries and binaries could be mapped with pkey 
access disabled. If I read the Intel documentation correctly then that should be 
possible.

The advantage of doing that is that an existing attack method to circumvent ASLR 
(or to scout out an unknown binary) is to use an existing (user-space) information 
leak to read the address space of a server process - and to use that to figure out 
the actual code present at that address.

The code signature can then be be used to identify the precise layout of the 
binary, and/or to create ROP gadgets - to escallate permissions using an otherwise 
not exploitable buffer overflow.

I.e. AFAICS pkeys could be used to create true '--x' permissions for executable 
(user-space) pages.

But I might be reading it wrong ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

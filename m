Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC1A680DC6
	for <linux-mm@kvack.org>; Sat,  3 Oct 2015 04:17:16 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so56394368wic.0
        for <linux-mm@kvack.org>; Sat, 03 Oct 2015 01:17:15 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id xs8si17930876wjc.98.2015.10.03.01.17.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Oct 2015 01:17:15 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so56494227wic.1
        for <linux-mm@kvack.org>; Sat, 03 Oct 2015 01:17:14 -0700 (PDT)
Date: Sat, 3 Oct 2015 10:17:10 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Message-ID: <20151003081710.GA26206@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com>
 <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150924094956.GA30349@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@google.com>, Brian Gerst <brgerst@gmail.com>


* Ingo Molnar <mingo@kernel.org> wrote:

> 
> * Dave Hansen <dave@sr71.net> wrote:
> 
> > > Another question, related to enumeration as well: I'm wondering whether 
> > > there's any way for the kernel to allocate a bit or two for its own purposes - 
> > > such as protecting crypto keys? Or is the facility fundamentally intended for 
> > > user-space use only?
> > 
> > No, that's not possible with the current setup.
> 
> Ok, then another question, have you considered the following usecase:

So, I'm wondering about the following additional usecase:

Right now the native x86 PTE format allows two protection related bits for 
user-space pages:

  _PAGE_BIT_RW:                   if 0 the page is read-only,  if 1 then it's read-write
  _PAGE_BIT_NX:                   if 0 the page is executable, if 1 then it's not executable

As discussed previously, pkeys allows 'true execute only (--x)' mappings.

Another possibility would be 'true write-only (-w-)' mappings.

This too could in theory be introduced 'transparently', via 'pure PROT_WRITE' 
mappings (i.e. no PROT_READ|PROT_EXEC bits set). Assuming the amount of user-space 
with implicit 'PROT_WRITE implies PROT_READ' assumptions is not unmanageble for a 
distro willing to try this.

Usage of this would be more limited than of pure PROT_EXEC mappings, but it's a 
nonzero set:

 - Write-only log buffers that are normally mmap()-ed from a file.

 - Write-only write() IO buffers that are only accessed via write().
   (kernel-space accesses ignore pkey values.)

   glibc's buffered IO might possibly make use of this, for write-only
   fopen()ed files.

 - Language runtimes could improve their security by eliminating W+X mappings of 
   JIT-ed code, instead they could use two alias mappings: one alias is a 
   true-exec (--x) mapping, the other (separately mapped, separately randomized)
   mapping is a true write-only (--x) mapping for generated code.

In addition to the security advantage, another advantage would be increased 
robustness: no accidental corruption of IO (or JIT) buffers via read-only 
codepaths.

Another advantage would be that it would utilize pkeys without having to teach 
applications to use new system calls.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

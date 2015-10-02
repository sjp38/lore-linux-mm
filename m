Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6887F82F99
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 03:09:48 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so18650657wic.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 00:09:47 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id td12si8183400wic.52.2015.10.02.00.09.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 00:09:47 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so20756762wic.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 00:09:46 -0700 (PDT)
Date: Fri, 2 Oct 2015 09:09:43 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Message-ID: <20151002070943.GA1623@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com>
 <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com>
 <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <560DB4A6.6050107@sr71.net>
 <CA+55aFwUAY01QC8A3mCOoq5aYjT7Lw-gVx6DvqYBr0UMZ9kZEQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwUAY01QC8A3mCOoq5aYjT7Lw-gVx6DvqYBr0UMZ9kZEQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave@sr71.net>, Kees Cook <keescook@google.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Thu, Oct 1, 2015 at 6:33 PM, Dave Hansen <dave@sr71.net> wrote:
> >
> > Here it is in a quite fugly form (well, it's not opt-in).  Init crashes if I 
> > boot with this, though.
> >
> > I'll see if I can turn it in to a bit more of an opt-in and see what's 
> > actually going wrong.
> 
> It's quite likely that you will find that compilers put read-only constants in 
> the text section, knowing that executable means readable.

At least with pkeys enabling true --x mappings, that compiler practice becomes a 
(mild) security problem: it provides a readable and executable return target for 
stack/buffer overflow attacks - FWIIW. (It's a limited concern because the true 
code areas are executable already.)

I'd expect such readonly data to eventually move out into the regular data 
sections, the moment the kernel gives a tool to distros to enforce true PROT_EXEC 
mappings.

> So it's entirely possible that it's pretty much all over.

I'd expect that too.

> That said, I don't understand your patch. Why check PROT_WRITE? We've had
> :"execute but not write" forever. It's "execute and not *read*" that is
> interesting.

Yeah, but almost none of user-space seems to be using it.

> So I wonder if your testing is just bogus. But maybe I'm mis-reading this?

I don't think you are mis-reading it: my (hacky! bad! not signed off!) debug idea 
was to fudge PROT_EXEC|PROT_READ bits into pure PROT_EXEC only - at least to get 
pkeys used in a much more serious fashion than standalone testcases, without 
having to change the distro itself.

You are probably right that true data reads from executable sections are very 
common, so this might not be a viable technique even for testing purposes.

But worth a try.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

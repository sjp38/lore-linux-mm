Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4BB82F7A
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 21:38:11 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so7876369igc.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 18:38:11 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id q93si6923915ioi.48.2015.10.01.18.38.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 18:38:10 -0700 (PDT)
Received: by igbkq10 with SMTP id kq10so7861605igb.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 18:38:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <560DBA24.5010201@sr71.net>
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
	<560DBA24.5010201@sr71.net>
Date: Thu, 1 Oct 2015 21:38:10 -0400
Message-ID: <CA+55aFxf3ExQEq2zhNhj4zk5nC5in9=1acVfynOVxZdN9RLbdA@mail.gmail.com>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Kees Cook <keescook@google.com>, Ingo Molnar <mingo@kernel.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On Thu, Oct 1, 2015 at 6:56 PM, Dave Hansen <dave@sr71.net> wrote:
>
> Also, a quick ftrace showed that most mmap() callers that set PROT_EXEC
> also set PROT_READ.  I'm just assuming that folks are setting PROT_READ
> but aren't _really_ going to read it, so we can safely deny them all
> access other than exec.

That's a completely insane assumption. There are tons of reasons to
have code and read-only data in the same segment, and it's very
traditional. Just assuming that you only execute out of something that
has PROT_EXEC | PROT_READ is insane.

No, what you *should* look at is to use the protection keys to
actually enforce a plain PROT_EXEC. That has never worked before
(because traditionally R implies X, and then we got NX).

That would at least allow people who know they don't intersperse
read-only constants in the code to use PROT_EXE only.

Of course, there may well be users who use PROT_EXE that actually *do*
do reads, and just relied on the old hardware behavior. So it's not
guaranteed to work either without any extra flags. But at least it's
worth a try, unlike the "yeah, the user asked for read, but the user
doesn't know what he's doing" thinking that is just crazy talk.

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

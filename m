Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 170B228089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 15:51:47 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id d38so84694305uad.4
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 12:51:47 -0800 (PST)
Received: from mail-ua0-x234.google.com (mail-ua0-x234.google.com. [2607:f8b0:400c:c08::234])
        by mx.google.com with ESMTPS id 62si2659985uaj.27.2017.02.08.12.51.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 12:51:46 -0800 (PST)
Received: by mail-ua0-x234.google.com with SMTP id 35so119073235uak.1
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 12:51:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 8 Feb 2017 12:51:24 -0800
Message-ID: <CALCETrVfah6AFG5mZDjVcRrdXKL=07+WC9ES9ZKU90XqVpWCOg@mail.gmail.com>
Subject: Re: PCID review?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, Feb 7, 2017 at 10:56 AM, Andy Lutomirski <luto@kernel.org> wrote:
> Quite a few people have expressed interest in enabling PCID on (x86)
> Linux.  Here's the code:
>
> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/pcid
>
> The main hold-up is that the code needs to be reviewed very carefully.
> It's quite subtle.  In particular, "x86/mm: Try to preserve old TLB
> entries using PCID" ought to be looked at carefully to make sure the
> locking is right, but there are plenty of other ways this this could
> all break.
>
> Anyone want to take a look or maybe scare up some other reviewers?
> (Kees, you seemed *really* excited about getting this in.)

Nadav pointed out that this doesn't work right with
ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH.  Mel, here's the issue:

I want to add ASID (Intel calls it PCID) support to x86.  This means
that "flush the TLB on a given CPU" will no longer be a particularly
well defined operation because it's not clear which ASID tag to flush.
Instead there's "flush the TLB for a given mm on a given CPU".

If I'm understanding the batched flush code, all it's trying to do is
to flush more than one mm at a time.  Would it make sense to add a new
arch API to flush more than one mm?  Presumably it would take a linked
list, and the batched flush code would fall back to flushing in pieces
if it can't allocate a new linked list node when needed.

Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

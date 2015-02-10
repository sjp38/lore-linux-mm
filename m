Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 664106B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 18:07:17 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id w55so43317wes.5
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 15:07:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bz13si27791460wjb.21.2015.02.10.15.07.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Feb 2015 15:07:15 -0800 (PST)
Date: Wed, 11 Feb 2015 00:07:12 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] x86, kaslr: propagate base load address calculation
In-Reply-To: <CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz>
References: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz> <CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Tue, 10 Feb 2015, Kees Cook wrote:

> > Instead of fixing the logic in module.c, this patch takes more generic
> > aproach, and exposes __KERNEL_OFFSET macro, which calculates the real
> > offset that has been established by choose_kernel_location() during boot.
> > This can be used later by other kernel code as well (such as, but not
> > limited to, live patching).
> >
> > OOPS offset dumper and module loader are converted to that they make use
> > of this macro as well.
> >
> > Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> 
> Ah, yes! This is a good clean up. Thanks! I do see, however, one
> corner case remaining: kASLR randomized to 0 offset. This will force
> module ASLR off, which I think is a mistake. 

Ah, right, good point. I thought that zero-randomization is not possible, 
but looking closely, it is.

> Perhaps we need to export the kaslr state as a separate item to be 
> checked directly, instead of using __KERNEL_OFFSET?

I wanted to avoid sharing variables between compressed loader and the rest 
of the kernel, but if that's what you prefer, I can do it.

Alternatively, we can forbid zero-sized randomization, and always enforce 
at least some minimal offset to be chosen in case zero would be chosen.

I think that'd be even more bulletproof for any future changes, as it 
automatically clearly and immediately distinguishes between 'disabled' and 
'randomized' states, and the loss of entropy is negligible.

Let me know which of the two you'd prefer; I'll then send you a 
corresponding patch, as I don't have a strong opinion either way.

Thanks,

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

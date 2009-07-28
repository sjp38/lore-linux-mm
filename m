Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7F56B0055
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 20:41:40 -0400 (EDT)
Date: Mon, 27 Jul 2009 17:41:38 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC/PATCH] mm: Pass virtual address to
 [__]p{te,ud,md}_free_tlb()
In-Reply-To: <20090728002529.GB22668@linux-sh.org>
Message-ID: <alpine.LFD.2.01.0907271727220.3186@localhost.localdomain>
References: <20090715074952.A36C7DDDB2@ozlabs.org> <20090715135620.GD7298@wotan.suse.de> <1248073873.13067.31.camel@pasglop> <alpine.LFD.2.01.0907220930320.19335@localhost.localdomain> <1248310415.3367.22.camel@pasglop> <alpine.LFD.2.01.0907271210210.25224@localhost.localdomain>
 <1248740260.30993.26.camel@pasglop> <20090728002529.GB22668@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Hugh Dickins <hugh@tiscali.co.uk>, ralf <ralf@linux-mips.org>
List-ID: <linux-mm.kvack.org>



On Tue, 28 Jul 2009, Paul Mundt wrote:
>
> Yup, that seems to be what happened. I've never seen a warning about this
> with any compiler version, otherwise we would have caught this much
> earlier. As soon as the addr -> a rename took place it blew up
> immediately as a redefinition. Is there a magical gcc flag we can turn on
> to warn on identical definitions, even if just for testing?

No, this is actually defined C behavior - identical macro redefinitions 
are ok. That's very much on purpose, and allows different header files to 
use an identical #define to define some common macro.

Strictly speaking, this is a "safety feature", in that you obviously 
_could_ just always do a #undef+#define, but such a case would be able to 
redefine a macro even if the new definition didn't match the old one. So 
the C pre-processor rules is that you can safely re-define something if 
you re-define it identically.

Of course, we could make the rules for the kernel be stricter, but I don't 
know if there are any flags to warn about it, since it's such a standard C 
feature: the lack of warning is _not_ an accident.

It would be trivial to teach sparse to warn about it, of course. Look at 
sparse/pre-process.c, function do_handle_define(). Notice how it literally 
checks that any previous #define is identical in both expansion and 
argument list, with:

		if (token_list_different(sym->expansion, expansion) ||
		    token_list_different(sym->arglist, arglist)) {

and just make token_list_different() always return true (this is the only 
use of that function).

I haven't checked if such a change would actually result in a lot of 
warnings.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

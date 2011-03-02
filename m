Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 223468D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 14:48:55 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p22JmN0t020505
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 2 Mar 2011 11:48:24 -0800
Received: by iyf13 with SMTP id 13so333374iyf.14
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 11:48:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110302.114018.104077586.davem@davemloft.net>
References: <20110302162650.GA26810@redhat.com> <20110302164428.GF26810@redhat.com>
 <AANLkTinzQmprg+XHKjTj7bA+jFf_N4hta3_09M+SEfRt@mail.gmail.com> <20110302.114018.104077586.davem@davemloft.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 2 Mar 2011 11:48:03 -0800
Message-ID: <AANLkTi=e7n63cCTUe1T+C0d6Ni1VVBFZZ6y_rj-2RQwu@mail.gmail.com>
Subject: Re: [PATCH v3 0/4] exec: unify native/compat code
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: oleg@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pageexec@freemail.hu, solar@openwall.com, eteo@redhat.com, spender@grsecurity.net, roland@redhat.com, miltonm@bga.com

On Wed, Mar 2, 2011 at 11:40 AM, David Miller <davem@davemloft.net> wrote:
>
> We purposely don't do that "page table entry typedef'd to aggregate" stuff
> on sparc32 because otherwise such values get passed on the stack.
>
> Architectures can currently avoid this bad code generation for the
> page table case, but with this new code they won't be able to avoid
> pass-by-value.

Well, the thing is, on architectures that _can_ pass by value, it
avoids one indirection.

And if you do pass it on stack, then the code generated will be the
same as if we passed a pointer. So sparc may not be able to take
advantage of the optimization, but I don't think the code generation
would be worse.

For the page table case, we don't have that kind of trade-off: the
trade-off there is literally just between "pass in registers, or pass
on stack". Here the trade-off is "pass as an aggregate value or pass
as a pointer to an aggregate value".

That said, since I suspect that the main user will always just get
inlined (ie the helper function that actually fetches the pointers), I
suspect even sparc will see the advantage of the pass-by-value model.

But you might want to actually test the difference and look at the
code generation.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

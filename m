Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D4E798D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 12:39:57 -0400 (EDT)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.14.2/Debian-2build1) with ESMTP id p31Gdr6b028589
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 09:39:54 -0700
Received: by iyf13 with SMTP id 13so5268479iyf.14
        for <linux-mm@kvack.org>; Fri, 01 Apr 2011 09:39:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1301659631.4859.565.camel@twins>
References: <20110217162327.434629380@chello.nl> <20110217163234.823185666@chello.nl>
 <20110310155032.GB32302@csn.ul.ie> <1300301742.2203.1899.camel@twins>
 <4D87109A.1010005@redhat.com> <1301659631.4859.565.camel@twins>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 1 Apr 2011 09:13:51 -0700
Message-ID: <AANLkTimvHdGZptwmmw73C2jsy=HqgreEAxNurT1Hxbv=@mail.gmail.com>
Subject: Re: [PATCH 02/17] mm: mmu_gather rework
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Avi Kivity <avi@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Tony Luck <tony.luck@intel.com>, Hugh Dickins <hughd@google.com>

On Fri, Apr 1, 2011 at 5:07 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> No, although I do try to avoid it in structures because I'm ever unsure
> of the storage type used. But yes, good suggestion, thanks!

I have to admit to not being a huge fan of "bool". You never know what
it actually is in C, and it's a possible source of major confusion.

Some environments will make it "int", others "char", and others - like
the kernel - will make it a C99/C++-like "true boolean" (C99 _Bool).

What's the difference? Integer assignment makes a hell of a difference. Do this:

  long long expression = ...
  ...
  bool val = expression;

and depending on implementation it will either just truncate the value
to a random number of bits, or actually do a compare with zero.

And while we use the C99 _Bool type, and thus get those true boolean
semantics (ie not just be a truncated integer type), I have to say
that it's still a dangerous thing to do in C because you generally
cannot rely on it. There's _tons_ of software that just typedefs int
or char to bool.

So even outside of structures, I'm not necessarily convinced "bool" is
always such a good thing. But I'm not going to stop people from using
it (inside the kernel it should be safe), I just want to raise a
warning and ask people to not use it mindlessly. And avoid the casts -
even if they are safe in the kernel.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

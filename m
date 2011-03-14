Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B55188D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:36:47 -0400 (EDT)
Received: from mail-gw0-f41.google.com (mail-gw0-f41.google.com [74.125.83.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p2EHajEH000607
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:36:45 -0700
Received: by gwaa12 with SMTP id a12so2547077gwa.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:36:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110314165922.GE10696@random.random>
References: <alpine.LSU.2.00.1103140059510.1661@sister.anvils>
 <20110314155232.GB10696@random.random> <alpine.LSU.2.00.1103140910570.2601@sister.anvils>
 <20110314165922.GE10696@random.random>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 14 Mar 2011 10:30:11 -0700
Message-ID: <AANLkTikWh5tFUZuALYRP3Dx2Zcs33u0UVdjf4d_7KhPJ@mail.gmail.com>
Subject: Re: [PATCH] mm: PageBuddy and mapcount underflows robustness
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 14, 2011 at 9:59 AM, Andrea Arcangeli <aarcange@redhat.com> wro=
te:
>
> +#define PAGE_BUDDY_MAPCOUNT_VALUE (-1024*1024)

I realize that this is a nitpick, but from a code generation
standpoint, large random constants like these are just nasty.

I would suggest aiming for constants that are easy to generate and/or
fit better in the code stream. In many encoding schemes (eg x86), -128
is much easier to generate, since it fits in a signed byte and allows
small instructions etc. And in most RISC encodings, 8- or 16-bit
constants can be encoded much more easily than something like your
current one, and bigger ones often end up resulting in a load from
memory or at least several immediate-building instructions.

> - =A0 =A0 =A0 __ClearPageBuddy(page);
> + =A0 =A0 =A0 if (PageBuddy(page)) /* __ClearPageBuddy VM_BUG_ON(!PageBud=
dy(page)) */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __ClearPageBuddy(page);

Also, this is just disgusting. It adds no safety here to have that
VM_BUG_ON(), so it's just unnecessary code generation to do this.
Also, we don't even WANT to do that stupid "__ClearPageBuddy()" in the
first place! What those two code-sites actually want are just a simple

    reset_page_mapcount(page);

which does the right thing in _general_, and not just for the buddy
case - we want to reset the mapcount for other reasons than just
pagebuddy (ie the underflow/overflow case).

And it avoids the VM_BUG_ON() too, making the crazy conditionals be not nee=
ded.

No?

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

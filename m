Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E90226004C0
	for <linux-mm@kvack.org>; Sat,  1 May 2010 13:11:33 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <3a62a058-7976-48d7-acd2-8c6a8312f10f@default>
Date: Sat, 1 May 2010 10:10:45 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com>>
 <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>>
 <4BD1A74A.2050003@redhat.com>>
 <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>> <4BD1B427.9010905@redhat.com>
 <4BD1B626.7020702@redhat.com>>
 <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>>
 <4BD3377E.6010303@redhat.com>>
 <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>>
 <ce808441-fae6-4a33-8335-f7702740097a@default>>
 <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz>
 <4BDA8324.7090409@redhat.com> <084f72bf-21fd-4721-8844-9d10cccef316@default>
 <4BDB026E.1030605@redhat.com> <4BDB18CE.2090608@goop.org
 4BDB2069.4000507@redhat.com>
In-Reply-To: <4BDB2069.4000507@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> Eventually you'll have to swap frontswap pages, or kill uncooperative
> guests.  At which point all of the simplicity is gone.

OK, now I think I see the crux of the disagreement.

NO!  Frontswap on Xen+tmem never *never* _never_ NEVER results
in host swapping.  Host swapping is evil.  Host swapping is
the root of most of the bad reputation that memory overcommit
has gotten from VMware customers.  Host swapping can't be
avoided with some memory overcommit technologies (such as page
sharing), but frontswap on Xen+tmem CAN and DOES avoid it.

So, to summarize:

1) You agreed that a synchronous interface for frontswap makes
   sense for swap-to-in-kernel-compressed-RAM because it is
   truly swapping to RAM.
2) You have pointed out that an asynchronous interface for
   frontswap makes more sense for KVM than a synchronous
   interface, because KVM does host swapping.  Then you said
   if you have an asynchronous interface anyway, the existing
   swap code works just fine with no changes so frontswap
   is not needed at all... for KVM.
3) You have suggested that if Xen were more like KVM and required
   host-swapping, then Xen doesn't need frontswap either.

BUT frontswap on Xen+tmem always truly swaps to RAM.

So there are two users of frontswap for which the synchronous
interface makes sense.  I believe there may be more in the
future and you disagree but, as Jeremy said, "a general Linux
principle is not to overdesign interfaces for hypothetical users,
only for real needs."  We have demonstrated there is a need
with at least two users so the debate is only whether the
number of users is two or more than two.

Frontswap is a very non-invasive patch and is very cleanly
layered so that if it is not in the presence of either of=20
the intended "users", it can be turned off in many different
ways with zero overhead (CONFIG'ed off) or extremely small overhead
(frontswap_ops is never set; or frontswap_ops is set but the
underlying hypervisor doesn't support it so frontswap_poolid
never gets set).

So... KVM doesn't need it and won't use it.  Do you, Avi, have
any other objections as to why the frontswap patch shouldn't be
accepted as is for the users that DO need it and WILL use it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

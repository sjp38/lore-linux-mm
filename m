Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0D2776B01E3
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 04:30:35 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <a0c1615e-c64a-4d4a-bd49-9e3e614d031b@default>
Date: Tue, 27 Apr 2010 01:29:35 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com>
 <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default>
 <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default>
 <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>
 <4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>
 <4BD1B427.9010905@redhat.com> <4BD24E37.30204@vflare.org>
 <4BD33822.2000604@redhat.com> <4BD3B2D1.8080203@vflare.org>
 <4BD4329A.9010509@redhat.com> <4BD4684E.9040802@vflare.org>
 <4BD52D55.3070803@redhat.com> <2634f2cb-3e7e-4c86-b7ef-cf4a3f1e0d8a@default
 4BD5987F.7080505@redhat.com>
In-Reply-To: <4BD5987F.7080505@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > Well if you are saying that your primary objection to the
> > frontswap synchronous API is that it is exposed to modules via
> > some EXPORT_SYMBOLs, we can certainly fix that, at least
> > unless/until there are other pseudo-RAM devices that can use it.
> >
> > Would that resolve your concerns?
> >
>=20
> By external interfaces I mean the guest/hypervisor interface.
> EXPORT_SYMBOL is an internal interface as far as I'm concerned.
>=20
> Now, the frontswap interface is also an internal interface, but it's
> close to the external one.  I'd feel much better if it was
> asynchronous.

OK, so on the one hand, you think that the proposed synchronous
interface for frontswap is insufficiently extensible for other
uses (presumably including KVM).  On the other hand, you agree
that using the existing I/O subsystem is unnecessarily heavyweight.
On the third hand, Nitin has answered your questions and spent
a good part of three years finding that extending the existing swap
interface to efficiently support swap-to-pseudo-RAM requires
some kind of in-kernel notification mechanism to which Linus
has already objected.

So you are instead proposing some new guest-to-host asynchronous
notification mechanism that doesn't use the existing bio
mechanism (and so presumably not irqs), imitates or can
utilize a dma engine, and uses less cpu cycles than copying
pages.  AND, for long-term maintainability, you'd like to avoid
creating a new guest-host API that does all this, even one that
is as simple and lightweight as the proposed frontswap hooks.

Does that summarize your objection well?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

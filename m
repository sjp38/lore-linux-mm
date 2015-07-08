Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id DCACB6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 17:17:53 -0400 (EDT)
Received: by obdbs4 with SMTP id bs4so159524855obd.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 14:17:53 -0700 (PDT)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id n206si2535297oif.97.2015.07.08.14.17.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jul 2015 14:17:52 -0700 (PDT)
Date: Wed, 8 Jul 2015 15:17:50 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH V3 3/5] mm: mlock: Introduce VM_LOCKONFAULT and add
 mlock flags to enable it
Message-ID: <20150708151750.75e65859@lwn.net>
In-Reply-To: <20150708203456.GC4669@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
	<1436288623-13007-4-git-send-email-emunson@akamai.com>
	<20150708132351.61c13db6@lwn.net>
	<20150708203456.GC4669@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Wed, 8 Jul 2015 16:34:56 -0400
Eric B Munson <emunson@akamai.com> wrote:

> > Quick, possibly dumb question: I've been beating my head against these =
for
> > a little bit, and I can't figure out what's supposed to happen in this
> > case:
> >=20
> > 	mlock2(addr, len, MLOCK_ONFAULT);
> > 	munlock2(addr, len, MLOCK_LOCKED);
> >=20
> > It looks to me like it will clear VM_LOCKED without actually unlocking =
any
> > pages.  Is that the intended result? =20
>=20
> This is not quite right, what happens when you call munlock2(addr, len,
> MLOCK_LOCKED); is we call apply_vma_flags(addr, len, VM_LOCKED, false).

=46rom your explanation, it looks like what I said *was* right...what I was
missing was the fact that VM_LOCKED isn't set in the first place.  So that
call would be a no-op, clearing a flag that's already cleared.

One other question...if I call mlock2(MLOCK_ONFAULT) on a range that
already has resident pages, I believe that those pages will not be locked
until they are reclaimed and faulted back in again, right?  I suspect that
could be surprising to users.

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

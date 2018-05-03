Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 917956B0005
	for <linux-mm@kvack.org>; Thu,  3 May 2018 00:05:22 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id n2-v6so11401436pgs.2
        for <linux-mm@kvack.org>; Wed, 02 May 2018 21:05:22 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b23-v6si10973901pgw.529.2018.05.02.21.05.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 21:05:21 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8C30E2176D
	for <linux-mm@kvack.org>; Thu,  3 May 2018 04:05:20 +0000 (UTC)
Received: by mail-wm0-f41.google.com with SMTP id i3so27659438wmf.3
        for <linux-mm@kvack.org>; Wed, 02 May 2018 21:05:20 -0700 (PDT)
MIME-Version: 1.0
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com> <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net> <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com>
 <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
 <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com> <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
 <20180503021058.GA5670@ram.oc3035372033.ibm.com>
In-Reply-To: <20180503021058.GA5670@ram.oc3035372033.ibm.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 03 May 2018 04:05:08 +0000
Message-ID: <CALCETrXRQF08exQVZqtTLOKbC8Ywq5x4EYH_1D7r5v9bdOSwbg@mail.gmail.com>
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: Andrew Lutomirski <luto@kernel.org>, Florian Weimer <fweimer@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, ".linuxppc-dev"@lists.ozlabs.org

On Wed, May 2, 2018 at 7:11 PM Ram Pai <linuxram@us.ibm.com> wrote:

> On Wed, May 02, 2018 at 09:23:49PM +0000, Andy Lutomirski wrote:
> >
> > > If I recall correctly, the POWER maintainer did express a strong
desire
> > > back then for (what is, I believe) their current semantics, which my
> > > PKEY_ALLOC_SIGNALINHERIT patch implements for x86, too.
> >
> > Ram, I really really don't like the POWER semantics.  Can you give some
> > justification for them?  Does POWER at least have an atomic way for
> > userspace to modify just the key it wants to modify or, even better,
> > special load and store instructions to use alternate keys?

> I wouldn't call it POWER semantics. The way I implemented it on power
> lead to the semantics, given that nothing was explicitly stated
> about how the semantics should work within a signal handler.

I think that this is further evidence that we should introduce a new
pkey_alloc() mode and deprecate the old.  To the extent possible, this
thing should work the same way on x86 and POWER.

I think that we, as kernel API designers enabling fancy hardware features,
need to think about them with some care.  Our goal isn't just to expose the
hardware feature to userspace and let userspace run wild with it -- our
goal is to figure out what the use cases are and make the API useful for
those use cases without introducing more footguns that necessary.  For
pkey, this means realizing that user code consists of various loosely
coupled components and that the purpose of pkeys is to allow some userspace
component to prevent other components from *accidentally* clobbering or
leaking data due to bugs.  And I think that the current APIs don't really
achieve this.

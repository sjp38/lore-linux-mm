Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 604176B0033
	for <linux-mm@kvack.org>; Sat,  2 Dec 2017 17:19:14 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f7so9784048pfa.21
        for <linux-mm@kvack.org>; Sat, 02 Dec 2017 14:19:14 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r76si7434909pfb.324.2017.12.02.14.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Dec 2017 14:19:13 -0800 (PST)
Date: Sat, 2 Dec 2017 14:19:10 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mmap.2: MAP_FIXED is no longer discouraged
Message-ID: <20171202221910.GA8228@bombadil.infradead.org>
References: <20171202021626.26478-1-jhubbard@nvidia.com>
 <20171202150554.GA30203@bombadil.infradead.org>
 <CAG48ez2u3fjBDCMH4x3EUhG6ZD6VUa=A1p441P9fg=wUdzwHNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez2u3fjBDCMH4x3EUhG6ZD6VUa=A1p441P9fg=wUdzwHNQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: john.hubbard@gmail.com, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, John Hubbard <jhubbard@nvidia.com>

On Sat, Dec 02, 2017 at 07:49:20PM +0100, Jann Horn wrote:
> On Sat, Dec 2, 2017 at 4:05 PM, Matthew Wilcox <willy@infradead.org> wrote:
> > On Fri, Dec 01, 2017 at 06:16:26PM -0800, john.hubbard@gmail.com wrote:
> >> MAP_FIXED has been widely used for a very long time, yet the man
> >> page still claims that "the use of this option is discouraged".
> >
> > I think we should continue to discourage the use of this option, but
> > I'm going to include some of your text in my replacement paragraph ...
> >
> > -Because requiring a fixed address for a mapping is less portable,
> > -the use of this option is discouraged.
> > +The use of this option is discouraged because it forcibly unmaps any
> > +existing mapping at that address.  Programs which use this option need
> > +to be aware that their memory map may change significantly from one run to
> > +the next, depending on library versions, kernel versions and random numbers.
> 
> How about adding something explicit about when it's okay to use MAP_FIXED?
> "This option should only be used to displace an existing mapping that is
> controlled by the caller, or part of such a mapping." or something like that?
> 
> > +In a threaded process, checking the existing mappings can race against
> > +a new dynamic library being loaded
> 
> malloc() and its various callers can also cause mmap() calls, which is probably
> more relevant than library loading.

That's a bit more expected though.  "I called malloc and my address
space changed".  Well, yeah.  But "I called getpwnam and my address
space changed" is a bit more surprising.  Don't you think?

Maybe that should be up front rather than buried at the end of the sentence.

"In a multi-threaded process, the address space can change in response to
virtually any library call.  This is because almost any library call may be
implemented by using dlopen(3) to load another shared library, which will be
mapped into the process's address space.  The PAM libraries are an excellent
example, as well as more obvious examples like brk(2), malloc(3) and even
pthread_create(3)."

What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

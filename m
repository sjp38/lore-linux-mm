Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5FE6B02B4
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:21:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h126so2942967wmf.10
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:21:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g10si5205062wrc.359.2017.08.10.06.21.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 06:21:13 -0700 (PDT)
Date: Thu, 10 Aug 2017 15:21:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Message-ID: <20170810132110.GU23863@dhcp22.suse.cz>
References: <20170806140425.20937-1-riel@redhat.com>
 <20170807132257.GH32434@dhcp22.suse.cz>
 <20170807134648.GI32434@dhcp22.suse.cz>
 <CAAF6GDcNoDUaDSxV6N12A_bOzo8phRUX5b8-OBteuN0AmeCv0g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAAF6GDcNoDUaDSxV6N12A_bOzo8phRUX5b8-OBteuN0AmeCv0g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colm =?iso-8859-1?Q?MacC=E1rthaigh?= <colm@allcosts.net>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, Florian Weimer <fweimer@redhat.com>, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com, linux-api@vger.kernel.org

On Mon 07-08-17 17:55:45, Colm MacCarthaigh wrote:
> On Mon, Aug 7, 2017 at 3:46 PM, Michal Hocko <mhocko@kernel.org> wrote:
> 
> >
> > > > The use case is libraries that store or cache information, and
> > > > want to know that they need to regenerate it in the child process
> > > > after fork.
> >
> > How do they know that they need to regenerate if they do not get SEGV?
> > Are they going to assume that a read of zeros is a "must init again"? Isn't
> > that too fragile? Or do they play other tricks like parse /proc/self/smaps
> > and read in the flag?
> >
> 
> Hi from a user space crypto maintainer :) Here's how we do exactly this it
> in s2n:
> 
> https://github.com/awslabs/s2n/blob/master/utils/s2n_random.c , lines 62 -
> 91
> 
> and here's how LibreSSL does it:
> 
> https://github.com/libressl-portable/openbsd/blob/57dcd4329d83bff3dd67a293d5c4a53b795c587e/src/lib/libc/crypt/arc4random.h
> (lines 37 on)
> https://github.com/libressl-portable/openbsd/blob/57dcd4329d83bff3dd67a293d5c4a53b795c587e/src/lib/libc/crypt/arc4random.c
> (Line 110)
> 
> OpenSSL and libc are in the process of adding similar DRBGs and would use a
> WIPEONFORK. BoringSSL's maintainers are also interested as it adds
> robustness.  I also recall it being a topic of discussion at the High
> Assurance Cryptography Symposium (HACS) where many crypto maintainers meet
> and several more maintainers there indicated it would be nice to have.
> 
> Right now on Linux we all either use pthread_atfork() to zero the memory on
> fork, or getpid() and getppid() guards. The former can be evaded by direct
> syscall() and other tricks (which things like Language VMs are prone to
> doing), and the latter check is probabilistic as pids can repeat, though if
> you use both getpid() and getppid() - which is slow! - the probability of
> both PIDs colliding is very low indeed.

Thanks, these references are really useful to build a picture. I would
probably use an unlinked fd with O_CLOEXEC to dect this but I can see
how this is not the greatest option for a library.

> The result at the moment on Linux there's no bulletproof way to detect a
> fork and erase a key or DRBG state. It would really be nice to be able to
> match what we can do with MAP_INHERIT_ZERO and minherit() on BSD.
>  madvise() does seem like the established idiom for behavior like this on
> Linux.  I don't imagine it will be hard to use in practice, we can fall
> back to existing behavior if the flag isn't accepted.

The reason why I dislike madvise, as already said, is that it should be
an advise rather than something correctness related. Sure we do have
some exceptions there but that doesn't mean we should repeat the same
error. If anything an mmap MAP_$FOO sounds like a better approach to me.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

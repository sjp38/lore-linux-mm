Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 77CEB6B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 10:06:57 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x43so5113791wrb.9
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 07:06:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y105si727970wrc.528.2017.08.11.07.06.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Aug 2017 07:06:55 -0700 (PDT)
Date: Fri, 11 Aug 2017 16:06:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Message-ID: <20170811140653.GO30811@dhcp22.suse.cz>
References: <20170806140425.20937-1-riel@redhat.com>
 <20170807132257.GH32434@dhcp22.suse.cz>
 <20170807134648.GI32434@dhcp22.suse.cz>
 <1502117991.6577.13.camel@redhat.com>
 <20170810130531.GS23863@dhcp22.suse.cz>
 <CAAF6GDc2hsj-XJj=Rx2ZF6Sh3Ke6nKewABXfqQxQjfDd5QN7Ug@mail.gmail.com>
 <20170810153639.GB23863@dhcp22.suse.cz>
 <CAAF6GDeno6RpHf1KORVSxUL7M-CQfbWFFdyKK8LAWd_6PcJ55Q@mail.gmail.com>
 <20170810170144.GA987@dhcp22.suse.cz>
 <CAAF6GDdFjS612mx1TXzaVk1J-Afz9wsAywTEijO2TG4idxabiw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAAF6GDdFjS612mx1TXzaVk1J-Afz9wsAywTEijO2TG4idxabiw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colm =?iso-8859-1?Q?MacC=E1rthaigh?= <colm@allcosts.net>
Cc: Florian Weimer <fweimer@redhat.com>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Rik van Riel <riel@redhat.com>, Will Drewry <wad@chromium.org>, akpm@linux-foundation.org, dave.hansen@intel.com, kirill@shutemov.name, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@amacapital.net, mingo@kernel.org

On Fri 11-08-17 00:09:57, Colm MacCarthaigh wrote:
> On Thu, Aug 10, 2017 at 7:01 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > Does anybody actually do that using the minherit BSD interface?
> 
> I can't find any OSS examples. I just thought of it in response to
> your question, but now that I have, I do want to use it that way in
> privsep code.
> 
> As a mere user, fwiw it would make /my/ code less complex (in
> Kolmogorov terms) to be an madvise option. Here's what that would look
> like in user space:
> 
> mmap()
> 
> #if MAP_INHERIT_ZERO
>     minherit() || pthread_atfork(workaround_fptr);
> #elif MADVISE_WIPEONFORK
>     madvise() || pthread_atfork(workaround_fptr);
> #else
>     pthread_atfork(workaround_fptr);
> #endif
> 
> Vs:
> 
> #if MAP_WIPEONFORK
>     mmap( ... WIPEONFORK) || pthread_atfork(workaround_fptr);
> #else
>     mmap()
> #endif
> 
> #if MAP_INHERIT_ZERO
>     madvise() || pthread_atfork(workaround_fptr);
> #endif
> 
> #if !defined(MAP_WIPEONFORK) && !defined(MAP_INHERIT_ZERO)
>     pthread_atfork(workaround_fptr);
> #endif
> 
> The former is neater, and also a lot easier to stay structured if the
> code is separated across different functional units. Allocation is
> often handled in special functions.

OK, I guess I see your point. Thanks for the clarification.
 
> For me, madvise() is the principle of least surprise, following
> existing DONTDUMP semantics.

I am sorry to look too insisting here (I have still hard time to reconcile
myself with the madvise (ab)use) but if we in fact want minherit like
interface why don't we simply add minherit and make the code which wants
to use that interface easier to port? Is the only reason that hooking
into madvise is less code? If yes is that a sufficient reason to justify
the (ab)use of madvise? If there is a general consensus on that part I
will shut up and won't object anymore. Arguably MADV_DONTFORK would fit
into minherit API better as well. MADV_DONTDUMP is a differnet storry of
course.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

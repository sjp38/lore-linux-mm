Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0206B02B4
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:05:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o201so2929894wmg.3
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:05:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r71si4616326wmf.263.2017.08.10.06.05.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 06:05:33 -0700 (PDT)
Date: Thu, 10 Aug 2017 15:05:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Message-ID: <20170810130531.GS23863@dhcp22.suse.cz>
References: <20170806140425.20937-1-riel@redhat.com>
 <20170807132257.GH32434@dhcp22.suse.cz>
 <20170807134648.GI32434@dhcp22.suse.cz>
 <1502117991.6577.13.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1502117991.6577.13.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com, linux-api@vger.kernel.org

On Mon 07-08-17 10:59:51, Rik van Riel wrote:
> On Mon, 2017-08-07 at 15:46 +0200, Michal Hocko wrote:
> > On Mon 07-08-17 15:22:57, Michal Hocko wrote:
> > > This is an user visible API so make sure you CC linux-api (added)
> > > 
> > > On Sun 06-08-17 10:04:23, Rik van Riel wrote:
> > > > 
> > > > A further complication is the proliferation of clone flags,
> > > > programs bypassing glibc's functions to call clone directly,
> > > > and programs calling unshare, causing the glibc pthread_atfork
> > > > hook to not get called.
> > > > 
> > > > It would be better to have the kernel take care of this
> > > > automatically.
> > > > 
> > > > This is similar to the OpenBSD minherit syscall with
> > > > MAP_INHERIT_ZERO:
> > > > 
> > > >     https://man.openbsd.org/minherit.2
> > 
> > I would argue that a MAP_$FOO flag would be more appropriate. Or do
> > you
> > see any cases where such a special mapping would need to change the
> > semantic and inherit the content over the fork again?
> > 
> > I do not like the madvise because it is an advise and as such it can
> > be
> > ignored/not implemented and that shouldn't have any correctness
> > effects
> > on the child process.
> 
> Too late for that. VM_DONTFORK is already implemented
> through MADV_DONTFORK & MADV_DOFORK, in a way that is
> very similar to the MADV_WIPEONFORK from these patches.

Yeah, those two seem to be breaking the "madvise as an advise" semantic as
well but that doesn't mean we should follow that pattern any further.

> I wonder if that was done because MAP_* flags are a
> bitmap, with a very limited number of values as a result,
> while MADV_* constants have an essentially unlimited
> numerical namespace available.

That might have been the reason or it could have been simply because it
is easier to put something into madvise than mmap...

So back to the question. Is there any real usecase where you want to
have this on/off like or would a simple MAP_ZERO_ON_FORK be sufficient.
There should be some bits left between from my quick grep over arch
mman.h.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

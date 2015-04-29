Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id E6DB86B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 03:52:41 -0400 (EDT)
Received: by wgso17 with SMTP id o17so18947654wgs.1
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 00:52:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bk4si22088251wib.6.2015.04.29.00.52.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Apr 2015 00:52:40 -0700 (PDT)
Date: Wed, 29 Apr 2015 09:52:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/3] mm: mmap make MAP_LOCKED really mlock semantic
Message-ID: <20150429075238.GA16097@dhcp22.suse.cz>
References: <20150114095019.GC4706@dhcp22.suse.cz>
 <1430223111-14817-1-git-send-email-mhocko@suse.cz>
 <1430223111-14817-2-git-send-email-mhocko@suse.cz>
 <20150428161001.e854fb3eaf82f738865130af@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150428161001.e854fb3eaf82f738865130af@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Cyril Hrubis <chrubis@suse.cz>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue 28-04-15 16:10:01, Andrew Morton wrote:
> On Tue, 28 Apr 2015 14:11:49 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > The man page however says
> > "
> > MAP_LOCKED (since Linux 2.5.37)
> >       Lock the pages of the mapped region into memory in the manner of
> >       mlock(2).  This flag is ignored in older kernels.
> > "
> 
> I'm trying to remember why we implemented MAP_LOCKED in the first
> place.  Was it better than mmap+mlock in some fashion?
> 
> afaict we had a #define MAP_LOCKED in the header file but it wasn't
> implemented, so we went and wired it up.  13 years ago:
> https://lkml.org/lkml/2002/9/18/108

Yeah I have encountered this one while digging though the history as
well but there was no real usecase described - except "it doesn't work
currently".

The only sensible usecase I was able to come up with was a userspace
fault handling when we need to mmap and lock the faulting address in an
atomic way so that other threads cannot possibly leak data to the swap.
These guys can live with the current implementation, though.

I do not really believe that 2 instead of 1 syscall really justifies the
complexity.

> Anyway...  the third way of doing this is to use plain old mmap() while
> mlockall(MCL_FUTURE) is in force.  Has anyone looked at that, checked
> that the behaviour is sane and compared it with the mmap+mlock
> behaviour, the MAP_LOCKED behaviour and the manpages?

AFAICS this will behave the same way as mmap(MAP_LOCKED). VMA will be
marked VM_LOCKED but the popullation might fail for the very same
reason.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

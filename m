Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 991176B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 14:35:39 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so114408577wic.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 11:35:39 -0700 (PDT)
Received: from mail-wg0-x22c.google.com (mail-wg0-x22c.google.com. [2a00:1450:400c:c00::22c])
        by mx.google.com with ESMTPS id bf4si19416125wib.67.2015.04.28.11.35.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 11:35:38 -0700 (PDT)
Received: by wgen6 with SMTP id n6so3780976wge.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 11:35:37 -0700 (PDT)
Date: Tue, 28 Apr 2015 20:35:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Should mmap MAP_LOCKED fail if mm_poppulate fails?
Message-ID: <20150428183535.GB30918@dhcp22.suse.cz>
References: <20150114095019.GC4706@dhcp22.suse.cz>
 <1430223111-14817-1-git-send-email-mhocko@suse.cz>
 <CA+55aFxzLXx=cC309h_tEc-Gkn_zH4ipR7PsefVcE-97Uj066g@mail.gmail.com>
 <20150428164302.GI2659@dhcp22.suse.cz>
 <CA+55aFydkG-BgZzry5DrTzueVh9VvEcVJdLV8iOyUphQk=0vpw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFydkG-BgZzry5DrTzueVh9VvEcVJdLV8iOyUphQk=0vpw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Cyril Hrubis <chrubis@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue 28-04-15 09:57:11, Linus Torvalds wrote:
> On Tue, Apr 28, 2015 at 9:43 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >
> > Hmm, no other thread has the address from the current mmap call except
> > for MAP_FIXED (more on that below).
> 
> With things like opportunistic SIGSEGV handlers that map/unmap things
> as the user takes faults, that's actually not at all guaranteed.
> 
> Yeah, it's unusual, but I've seen it, with threaded applications where
> people play games with user-space memory management, and do "demand
> allocation" with mmap() in response to signals.

I am still not sure I see the problem here. Let's say we have a
userspace page fault handler which would do mmap(fault_addr, MAP_FIXED),
right?

If we had a racy mmap(NULL, MAP_LOCKED) that could have mapped
fault_addr by the time handler does its work then this is buggy wrt. to
MAP_LOCKED semantic because the fault handler would discard the locked
part. This wouldn't lead to a data loss but still makes MAP_LOCKED usage
buggy IMO.

If the racing thread did mmap(around_fault_addr, MAP_FIXED|MAP_LOCKED)
then it would be broken as well, and even worse I would say, because the
original fault could have been discarded and data lost.

I would expect that user fault handlers would be synchronized with
other mmap activity otherwise I have hard time to see how this can all
have a well defined behavior. Especially when MAP_FIXED is involved.

> Admittedly we already do bad things in mmap(MAP_FIXED) for that case,
> since we dropped the vm lock. But at least it shouldn't be any worse
> than a thread speculatively touching the pages..

Actually we already allow to mmap(MAP_FIXED) to fail after
discarding an existing mmaped area (see mmap_region and e.g.
security_vm_enough_memory_mm or other failure cases).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id CD8586B0096
	for <linux-mm@kvack.org>; Sat, 12 Apr 2014 11:40:04 -0400 (EDT)
Received: by mail-yk0-f174.google.com with SMTP id 20so6012274yks.19
        for <linux-mm@kvack.org>; Sat, 12 Apr 2014 08:40:04 -0700 (PDT)
Received: from g5t1626.atlanta.hp.com (g5t1626.atlanta.hp.com. [15.192.137.9])
        by mx.google.com with ESMTPS id u69si11326896yhd.9.2014.04.12.08.40.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 12 Apr 2014 08:40:04 -0700 (PDT)
Message-ID: <1397317199.2686.12.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] ipc/shm: disable SHMALL, SHMMAX
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Sat, 12 Apr 2014 08:39:59 -0700
In-Reply-To: <1397303284-2216-1-git-send-email-manfred@colorfullife.com>
References: <1397303284-2216-1-git-send-email-manfred@colorfullife.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On Sat, 2014-04-12 at 13:48 +0200, Manfred Spraul wrote:
> Shared memory segment can be abused to trigger out-of-memory conditions and
> the standard measures against out-of-memory do not work:
> 
> - It is not possible to use setrlimit to limit the size of shm segments.
> 
> - Segments can exist without association with any processes, thus
>   the oom-killer is unable to free that memory.
> 
> Therefore Linux always limited the size of segments by default to 32 MB.
> As most systems do not need a protection against malicious user space apps,
> a default that forces most admins and distros to change it doesn't make
> sense.
> 
> The patch disables both limits by setting the limits to ULONG_MAX.
> 
> Admins who need a protection against out-of-memory conditions should
> reduce the limits again and/or enable shm_rmid_forced.
> 
> Davidlohr: What do you think?
> 
> I prefer this approach: No need to update the man pages, smaller change
> of the code, smaller risk of user space incompatibilities.

As I've mentioned before, both approaches are correct.

I still much prefer using 0 instead of ULONG_MAX, it's far easier to
understand. And considering the v2 which fixes the shmget(key, 0, flg)
usage, I _still_ don't see why it would cause legitimate user
incompatibilities.

Regarding the manpage, regardless the approach we end up taking, it
should still be updated. This is an important change for users, making
their life easier. We should inform them explicitly about them not
really needing to deal with the hassle of shm limits anymore.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

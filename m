Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 88C926B0099
	for <linux-mm@kvack.org>; Sat, 12 Apr 2014 12:22:30 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id uz6so7497975obc.29
        for <linux-mm@kvack.org>; Sat, 12 Apr 2014 09:22:29 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id me5si10404023obb.78.2014.04.12.09.22.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 12 Apr 2014 09:22:28 -0700 (PDT)
Message-ID: <1397319744.2686.16.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] ipc/shm: disable SHMALL, SHMMAX
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Sat, 12 Apr 2014 09:22:24 -0700
In-Reply-To: <1397317199.2686.12.camel@buesod1.americas.hpqcorp.net>
References: <1397303284-2216-1-git-send-email-manfred@colorfullife.com>
	 <1397317199.2686.12.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On Sat, 2014-04-12 at 08:39 -0700, Davidlohr Bueso wrote:
> On Sat, 2014-04-12 at 13:48 +0200, Manfred Spraul wrote:
> > Shared memory segment can be abused to trigger out-of-memory conditions and
> > the standard measures against out-of-memory do not work:
> > 
> > - It is not possible to use setrlimit to limit the size of shm segments.
> > 
> > - Segments can exist without association with any processes, thus
> >   the oom-killer is unable to free that memory.
> > 
> > Therefore Linux always limited the size of segments by default to 32 MB.
> > As most systems do not need a protection against malicious user space apps,
> > a default that forces most admins and distros to change it doesn't make
> > sense.
> > 
> > The patch disables both limits by setting the limits to ULONG_MAX.
> > 
> > Admins who need a protection against out-of-memory conditions should
> > reduce the limits again and/or enable shm_rmid_forced.
> > 
> > Davidlohr: What do you think?
> > 
> > I prefer this approach: No need to update the man pages, smaller change
> > of the code, smaller risk of user space incompatibilities.
> 
> As I've mentioned before, both approaches are correct.
> 
> I still much prefer using 0 instead of ULONG_MAX, it's far easier to
> understand. And considering the v2 which fixes the shmget(key, 0, flg)
> usage, I _still_ don't see why it would cause legitimate user
> incompatibilities.

Also, if the user overflows the variable (indicating that he/she wants
to increase it to reflect something 'unlimited') and it ends up being 0,
then it becomes a valid value, not something totally wrong as it is
today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

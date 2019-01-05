Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD548E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 18:09:06 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so35971483edm.18
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:09:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y4si2933971edr.395.2019.01.05.15.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 15:09:04 -0800 (PST)
Date: Sun, 6 Jan 2019 00:09:02 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
Message-ID: <nycvar.YFH.7.76.1901060001590.16954@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Sat, 5 Jan 2019, Jann Horn wrote:

> > Provide vm.mincore_privileged sysctl, which makes it possible to mincore()
> > start returning -EPERM in case it's invoked by a process lacking
> > CAP_SYS_ADMIN.
> >
> > The default behavior stays "mincore() can be used by anybody" in order to
> > be conservative with respect to userspace behavior.
> >
> > [1] https://www.theregister.co.uk/2019/01/05/boffins_beat_page_cache/
> 
> Just checking: I guess /proc/$pid/pagemap (iow, the pagemap_read()
> handler) is less problematic because it only returns data about the
> state of page tables, and doesn't query the address_space? In other
> words, it permits monitoring evictions, but non-intrusively detecting
> that something has been loaded into memory by another process is
> harder?

So I was just about to immediately reply that we don't expose pagemap 
anymore due to rowhammer, but apparently that's not true any more 
(this behavioud was originally introduced by ab676b7d6fbf, but then 
changed via 1c90308e7a77 (and further adjusted for swap entries in 
ab6ecf247a, but I guess that's not all that interesting).

Hmm.

But unless it has been mapped with MAP_POPULATE (whcih is outside the 
attacker's control), there is no guarantee that the mappings would 
actually be there, right?

-- 
Jiri Kosina
SUSE Labs

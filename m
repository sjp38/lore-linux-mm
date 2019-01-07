Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7387C8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 05:33:11 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e12so132446edd.16
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 02:33:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t26si9349995eds.246.2019.01.07.02.33.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 02:33:09 -0800 (PST)
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
References: <20190107043227.GA3325@nautica>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <151b4ac8-5cfc-ed30-db30-e4d67a324c4b@suse.cz>
Date: Mon, 7 Jan 2019 11:33:08 +0100
MIME-Version: 1.0
In-Reply-To: <20190107043227.GA3325@nautica>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominique Martinet <asmadeus@codewreck.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, daniel@gruss.cc

On 1/7/19 5:32 AM, Dominique Martinet wrote:
> Linus Torvalds wrote on Sat, Jan 05, 2019:
>> But I think my patch to just rip out all that page lookup, and just
>> base it on the page table state has the fundamental advantage that it
>> gets rid of code. Maybe I should jst commit it, and see if anything
>> breaks? We do have options in case things break, and then we'd at
>> least know who cares (and perhaps a lot more information of _why_ they
>> care).
> 
> There actually are many tools like fincore which depend on mincore to
> try to tell whether a file is "loaded in cache" or not (I personally use
> vmtouch[1], but I know of at least nocache[2] uses it as well to only
> try to evict used pages)

nocache could probably do fine without mincore. IIUC the point is to not
evict anything that was already resident prior to running some command
wrapped in nocache. Without the mincore checks,
posix_fadvise(POSIX_FADV_DONTNEED) will still not drop anything that
others have mapped. That means without mincore() it will drop data
that's in cache but not currently in use by anybody, which shouldn't
cause large performance regressions?

> [1] https://hoytech.com/vmtouch/
> [2] https://github.com/Feh/nocache
> 
> 
> I mostly use these to either fadvise(POSIX_FADV_DONTNEED) or
> prefetch/lock whole files so my "production" use-cases don't actually
> rely on the mincore part of them;

Ah so you seem to confirm my above point.

...

> FWIW I personally don't care much about "only for owner" or depending on
> mmap options; I don't understand much of the security implications
> honestly so I'm not sure how these limitations actually help.
> On the other hand, a simple CAP_SYS_ADMIN check making the call take
> either behaviour should be safe and would cover what I described above.

So without CAP_SYS_ADMIN, mincore() would return mapping status, and
with CAP_SYS_ADMIN, it would return cache residency status? Very clumsy
:( Maybe if we introduced mincore2() with flags similar to BSD mentioned
earlier in the thread, and the cache residency flag would require
CAP_SYS_ADMIN or something similar.
> (by the way, while we are discussing permissions, a regular user can use
> fadvise dontneed on files it doesn't own as well as long as it can open
> them for reading; I'm not sure if that would need restricting as well in
> the context of the security issue.

Probably not, as I've mentioned it won't evict what's mapped by somebody
else. And eviction is also possible via controlling LRU, which is what
the paper [1] does anyway (and also mentions that DONTNEED doesn't
work). Being able to evict somebody's page is AFAIU not sufficient for
attack, the side channel is about knowing that somebody brought that
page back to RAM by touching it.

> Frankly even with mincore someone
> could likely tell the difference through timing, if they just do it a
> few times. Do magic, probe, flush out, repeat until satisfied.)

That's my bigger concern here. In [1] there's described a remote attack
(on webserver) using the page fault timing differences for present/not
present page cache pages. Noisy but works, and I expect locally it to be
much less noisy. Yet the countermeasures section only mentions
restricting mincore() as if it was sufficient (and also how to make
evictions harder, but that's secondary IMHO).

[1] https://arxiv.org/abs/1901.01161

> 
> Thanks,
> 

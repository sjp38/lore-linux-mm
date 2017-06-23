Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C009F6B0374
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 07:38:40 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l34so11964612wrc.12
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:38:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r13si4335012wra.12.2017.06.23.04.38.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 04:38:39 -0700 (PDT)
Date: Fri, 23 Jun 2017 13:38:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
Message-ID: <20170623113837.GM5308@dhcp22.suse.cz>
References: <bug-196157-27@https.bugzilla.kernel.org/>
 <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
 <20170623071324.GD5308@dhcp22.suse.cz>
 <3541d6c3-6c41-8210-ee94-fef313ecd83d@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3541d6c3-6c41-8210-ee94-fef313ecd83d@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alkis Georgopoulos <alkisg@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 23-06-17 10:44:36, Alkis Georgopoulos wrote:
> IGBPI?I1I? 23/06/2017 10:13 I?I 1/4 , I? Michal Hocko I-I3I?I+-I?Iu:
> >On Thu 22-06-17 12:37:36, Andrew Morton wrote:
> >
> >What is your dirty limit configuration. Is your highmem dirtyable
> >(highmem_is_dirtyable)?
> >
> >>>This issue happens on systems with any 4.x kernel, i386 arch, 16+ GB RAM.
> >>>It doesn't happen if we use 3.x kernels (i.e. it's a regression) or any 64bit
> >>>kernels (i.e. it only affects i386).
> >
> >I remember we've had some changes in the way how the dirty memory is
> >throttled and 32b would be more sensitive to those changes. Anyway, I
> >would _strongly_ discourage you from using 32b kernels with that much of
> >memory. You are going to hit walls constantly and many of those issues
> >will be inherent. Some of them less so but rather non-trivial to fix
> >without regressing somewhere else. You can tune your system somehow but
> >this will be fragile no mater what.
> >
> >Sorry to say that but 32b systems with tons of memory are far from
> >priority of most mm people. Just use 64b kernel. There are more pressing
> >problems to deal with.
> >
> 
> 
> 
> Hi, I'm attaching below all my settings from /proc/sys/vm.
> 
> I think that the regression also affects 4 GB and 8 GB RAM i386 systems, but
> not in an exponential manner; i.e. copies there are appear only 2-3 times
> slower than they used to be in 3.x kernels.

If the regression shows with 4-8GB 32b systems then the priority for
fixing would be certainly much higher.

> Now I don't know the kernel internals, but if disk copies show up to be 2-3
> times slower, and the regression is in memory management, wouldn't that mean
> that the memory management is *hundreds* of times slower, to show up in disk
> writing benchmarks?

Well, it is hard to judge what the real problem is here but you have
to realize that 32b system has some fundamental issues which come from
how the memory has split between kernel (lowmem - 896MB at maximum) and
highmem. The more memory you have the more lowmem you consume by kernel
data structure. Just consider that ~160MB of this space is eaten by
struct pages to describe 16GB of memory. There are other data structures
which can only live in the low memory.

> I.e. I'm afraid that this regression doesn't affect 16+ GB RAM systems only;
> it just happens that it's clearly visible there.
> 
> And it might even affect 64bit systems with even more RAM; but I don't have
> any such system to test with.

Not really. 64b systems do not need kernel/usespace split because the
address space large enough. If there are any regressions since 3.0 then
we are certainly interested in hearing about them.
 
> root@pc:/proc/sys/vm# grep . *
> dirty_ratio:20
> highmem_is_dirtyable:0

this means that the highmem is not dirtyable and so only 20% of the free
lowmem (+ page cache in that region) is considered and writers might
get throttled quite early (this might be a really low number when the
lowmem is congested already). Do you see the same problem when enabling
highmem_is_dirtyable = 1?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

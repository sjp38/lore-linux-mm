Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CAD4E8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 15:43:06 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c34so35910199edb.8
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 12:43:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18-v6si3437041ejz.304.2019.01.05.12.43.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 12:43:05 -0800 (PST)
Date: Sat, 5 Jan 2019 21:43:02 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <CAHk-=whGmE4QVr6NbgHnrVGVENfM3s1y6GNbsfh8PcOg=6bpqw@mail.gmail.com>
Message-ID: <nycvar.YFH.7.76.1901052131480.16954@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com> <nycvar.YFH.7.76.1901052108390.16954@cbobk.fhfr.pm> <CAHk-=whGmE4QVr6NbgHnrVGVENfM3s1y6GNbsfh8PcOg=6bpqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Sat, 5 Jan 2019, Linus Torvalds wrote:

> > I am still not completely sure what to return in such cases though; we can
> > either blatantly lie and always pretend that the pages are resident
> 
> That's what my untested patch did. Or maybe just claim they are all
> not present?

Thinking about it a little bit more, I believe Vlastimil has a good point 
with 'non present' potentially causing more bogus activity in userspace in 
response (in an effort to actually make them present, and failing 
indefinitely).

IOW, I think it's a reasonable expectation that the common scenario is 
"check if it's present, and if not, try to fault it in" instead of "check 
if it's present, and if it is, try to evict it".

> And again, that patch was entirely untested, so it may be garbage and 
> have some fundamental problem. 

I will be travelling for next ~24 hours, but I have just asked our QA guys 
to run it through some basic battery of testing (which will probably 
happen on monday anyway).

> I also don't know exactly what rule might make most sense, but "you can 
> write to the file" certainly to me implies that you also could know what 
> parts of it are in-core.

I think it's reasonable; I can't really imagine any sidechannel to a 
global state be possibly mounted on valid R/W mappings. I'd guess that 
probably the most interesting here are the code segments of shared 
libraries, allowing to trace victim's execution.

> Who actually _uses_ mincore()? That's probably the best guide to what
> we should do. Maybe they open the file read-only even if they are the
> owner, and we really should look at file ownership instead.

Yeah, well

	https://codesearch.debian.net/search?q=mincore

is a bit too much mess to get some idea quickly I am afraid.

-- 
Jiri Kosina
SUSE Labs

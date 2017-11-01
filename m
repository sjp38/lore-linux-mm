Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE606B0275
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:15:37 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r25so2746534pgn.23
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:15:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t11si1206991pgp.715.2017.11.01.08.15.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 08:15:36 -0700 (PDT)
Date: Wed, 1 Nov 2017 16:15:34 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Message-ID: <20171101151534.GC28572@quack2.suse.cz>
References: <1509128538-50162-1-git-send-email-yang.s@alibaba-inc.com>
 <20171030124358.GF23278@quack2.suse.cz>
 <76a4d544-833a-5f42-a898-115640b6783b@alibaba-inc.com>
 <20171031101238.GD8989@quack2.suse.cz>
 <b218c7cd-0ec9-b020-4c47-eb15689dee76@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b218c7cd-0ec9-b020-4c47-eb15689dee76@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: Jan Kara <jack@suse.cz>, amir73il@gmail.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz

On Wed 01-11-17 00:44:18, Yang Shi wrote:
> On 10/31/17 3:12 AM, Jan Kara wrote:
> >On Tue 31-10-17 00:39:58, Yang Shi wrote:
> >>On 10/30/17 5:43 AM, Jan Kara wrote:
> >>>On Sat 28-10-17 02:22:18, Yang Shi wrote:
> >>>>If some process generates events into a huge or unlimit event queue, but no
> >>>>listener read them, they may consume significant amount of memory silently
> >>>>until oom happens or some memory pressure issue is raised.
> >>>>It'd better to account those slab caches in memcg so that we can get heads
> >>>>up before the problematic process consume too much memory silently.
> >>>>
> >>>>But, the accounting might be heuristic if the producer is in the different
> >>>>memcg from listener if the listener doesn't read the events. Due to the
> >>>>current design of kmemcg, who does the allocation, who gets the accounting.
> >>>>
> >>>>Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> >>>>---
> >>>>v1 --> v2:
> >>>>* Updated commit log per Amir's suggestion
> >>>
> >>>I'm sorry but I don't think this solution is acceptable. I understand that
> >>>in some cases (and you likely run one of these) the result may *happen* to
> >>>be the desired one but in other cases, you might be charging wrong memcg
> >>>and so misbehaving process in memcg A can effectively cause a DoS attack on
> >>>a process in memcg B.
> >>
> >>Yes, as what I discussed with Amir in earlier review, current memcg design
> >>just accounts memory to the allocation process, but has no idea who is
> >>consumer process.
> >>
> >>Although it is not desirable to DoS a memcg, it still sounds better than DoS
> >>the whole machine due to potential oom. This patch is aimed to avoid such
> >>case.
> >
> >Thinking about this even more, your solution may have even worse impact -
> >due to allocations failing, some applications may avoid generation of fs
> >notification events for actions they do. And that maybe a security issue in
> >case there are other applications using fanotify for security enforcement,
> >virus scanning, or whatever... In such cases it is better to take the
> >whole machine down than to let it run.
> 
> I guess (just guess) this might be able to be solved by Amir's patch, right?
> An overflow or error event will be queued, then the consumer applications
> could do nicer error handling/softer exit.

Well, Amir's patch solves the problem of visibility that something bad
(lost event) happened. But it does not address the fundamental issue that
you account the event to a wrong memcg and thus fail the allocation at
wrong times.

> Actually, the event is dropped when -ENOMEM regardless of my patch. As Amir
> said this patch may just amplify this problem if my understanding is right.

So currently, -ENOMEM cannot normally happen for such small allocation. The
kernel will rather go OOM and kill some process to free memory. So putting
memcgs into the picture changes the behavior.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

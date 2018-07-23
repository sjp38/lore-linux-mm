Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAC56B0006
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 09:02:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12-v6so385065edi.12
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 06:02:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2-v6si1990478edt.286.2018.07.23.06.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 06:02:36 -0700 (PDT)
Date: Mon, 23 Jul 2018 15:02:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 200105] High paging activity as soon as the swap is touched
 (with steps and code to reproduce it)
Message-ID: <20180723130235.GF31229@dhcp22.suse.cz>
References: <bug-200105-8545@https.bugzilla.kernel.org/>
 <bug-200105-8545-FomWhXSVhq@https.bugzilla.kernel.org/>
 <191624267.262238.1532074743289@mail.yahoo.com>
 <f20b1529-fcb9-8d0a-6259-fe76977e00d6@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f20b1529-fcb9-8d0a-6259-fe76977e00d6@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <lkmldmj@gmail.com>
Cc: john terragon <terragonjohn@yahoo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

[I am really sorry to be slow on responding]

On Sat 21-07-18 10:39:05, Daniel Jordan wrote:
> John's issue only happens using a LUKS encrypted swap partition,
> unencrypted swap or swap encrypted without LUKS works fine.
> 
> In one test (out5.txt) where most system memory is taken by anon pages
> beforehand, the heavy direct reclaim that Michal noticed lasts for 24
> seconds, during which on average if I've crunched my numbers right,
> John's test program was allocating at 4MiB/s, the system overall
> (pgalloc_normal) was allocating at 235MiB/s, and the system was
> swapping out (pswpout) at 673MiB/s. pgalloc_normal and pswpout stay
> roughly the same each second, no big swings.
>
> Is the disparity between allocation and swapout rate expected?
> 
> John ran perf during another test right before the last test program
> was started (this doesn't include the initial large allocation
> bringing the system close to swapping).  The top five allocators
> (kmem:mm_page_alloc):
> 
> # Overhead      Pid:Command
> # ........  .......................
> #
>     48.45%     2005:memeater     # the test program
>     32.08%       73:kswapd0
>      3.16%     1957:perf_4.17
>      1.41%     1748:watch
>      1.16%     2043:free

Huh, kswapd allocating memory sounds really wrong here. Is it possible
that the swap device driver is double buffering and allocating a new
page for each one to swap out?
-- 
Michal Hocko
SUSE Labs

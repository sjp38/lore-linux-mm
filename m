Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id D29E28E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 15:10:39 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id f5-v6so3057800ljj.17
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 12:10:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v6-v6sor6846517ljh.37.2018.12.10.12.10.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 12:10:38 -0800 (PST)
Date: Mon, 10 Dec 2018 23:10:36 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] ksm: React on changing "sleep_millisecs" parameter faster
Message-ID: <20181210201036.GC2342@uranus.lan>
References: <154445792450.3178.16241744401215933502.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154445792450.3178.16241744401215933502.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gorcunov@virtuozzo.com

On Mon, Dec 10, 2018 at 07:06:18PM +0300, Kirill Tkhai wrote:
> ksm thread unconditionally sleeps in ksm_scan_thread()
> after each iteration:
> 
> 	schedule_timeout_interruptible(
> 		msecs_to_jiffies(ksm_thread_sleep_millisecs))
> 
> The timeout is configured in /sys/kernel/mm/ksm/sleep_millisecs.
> 
> In case of user writes a big value by a mistake, and the thread
> enters into schedule_timeout_interruptible(), it's not possible
> to cancel the sleep by writing a new smaler value; the thread
> is just sleeping till timeout expires.
> 
> The patch fixes the problem by waking the thread each time
> after the value is updated.
> 
> This also may be useful for debug purposes; and also for userspace
> daemons, which change sleep_millisecs value in dependence of
> system load.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Kirill, can we rather reuse @ksm_thread variable from ksm_init
(by moving it to static file level variable). Also wakening up
unconditionally on write looks somehow suspicious to me
though I don't have a precise argument against.

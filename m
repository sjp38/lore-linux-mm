Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5548E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:20:02 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id x18-v6so3874095lji.0
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 07:20:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j81-v6sor8971604ljb.30.2018.12.11.07.20.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 07:20:00 -0800 (PST)
Date: Tue, 11 Dec 2018 18:19:57 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v3] ksm: React on changing "sleep_millisecs" parameter
 faster
Message-ID: <20181211151957.GJ2342@uranus.lan>
References: <2dd9cc7b-9384-df11-bb5a-3aed45cc914b@virtuozzo.com>
 <154454107680.3258.3558002210423531566.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154454107680.3258.3558002210423531566.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gorcunov@virtuozzo.com

On Tue, Dec 11, 2018 at 06:11:25PM +0300, Kirill Tkhai wrote:
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
> 
> v3: Do not use mutex: to acquire it may take much time in case long
>     list of ksm'able mm and pages.
> v2: Use wait_event_interruptible_timeout() instead of unconditional
>     schedule_timeout().
Looks ok to me, thanks!

Acked-by: Cyrill Gorcunov <gorcunov@gmail.com>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5383B6B0253
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 11:19:31 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p63so78115120wmp.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 08:19:31 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cd8si10968653wjc.91.2016.02.03.08.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 08:19:30 -0800 (PST)
Date: Wed, 3 Feb 2016 11:19:10 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: vmpressure: make vmpressure_window a tunable.
Message-ID: <20160203161910.GA10440@cmpxchg.org>
References: <001a114b360c7fdb9b052adb91d6@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001a114b360c7fdb9b052adb91d6@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martijn Coenen <maco@google.com>
Cc: linux-mm@kvack.org, Anton Vorontsov <anton@enomsg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>

On Wed, Feb 03, 2016 at 11:06:20AM +0100, Martijn Coenen wrote:
> The window size used for calculating vm pressure
> events was previously fixed at 512 pages. The
> window size has a big impact on the rate of notifications
> sent off to userspace, in particular when using the
> "low" level. On machines with a lot of memory, the
> current value may be excessive.
> 
> On the other hand, making the window size depend on
> machine size does not allow userspace to change the
> notification rate based on the current state of the
> system. For example, when a lot of memory is still
> available, userspace may want to increase the window
> since it's not interested in receiving notifications
> for every 2MB scanned.
>
> This patch makes vmpressure_window a sysctl tunable.

If the machine is just cleaning up use-once cache, frequent events
make no sense. And if the machine is struggling, the notifications
better be in time.

That's hardly a tunable. It's a factor that needs constant dynamic
adjustment depending on VM state. The same state this mechanism is
supposed to report. If we can't get this right, how will userspace?

A better approach here would be to 1) find a minimum window size that
makes us confident that there are no false positives - this is likely
to be based on machine size, maybe the low watermark? - and 2) limit
reporting of lower levels, so you're not flooded with ALLGOOD! events.

VMPRESSURE_CRITICAL: report every vmpressure_win
VMPRESSURE_MEDIUM: report every vmpressure_win*2
VMPRESSURE_LOW: report every vmpressure_win*4

Pick your favorite scaling factor here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

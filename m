Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id D153E6B0033
	for <linux-mm@kvack.org>; Thu, 30 May 2013 16:00:14 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id wo10so1476626obc.31
        for <linux-mm@kvack.org>; Thu, 30 May 2013 13:00:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2434dea05a7fda7e7ccf48f70124bd65f2556b2d.1369935749.git.aquini@redhat.com>
References: <2434dea05a7fda7e7ccf48f70124bd65f2556b2d.1369935749.git.aquini@redhat.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 30 May 2013 15:59:53 -0400
Message-ID: <CAHGf_=qdow5GNHG+AQyfoKgga=Bqf5-x8ir4JmHrzaJs9pX2NQ@mail.gmail.com>
Subject: Re: [PATCH] swap: avoid read_swap_cache_async() race to deadlock
 while waiting on discard I/O compeletion
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, shli@kernel.org, "riel@redhat.com" <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, stable@vger.kernel.org

On Thu, May 30, 2013 at 2:05 PM, Rafael Aquini <aquini@redhat.com> wrote:
> read_swap_cache_async() can race against get_swap_page(), and stumble across
> a SWAP_HAS_CACHE entry in the swap map whose page wasn't brought into the
> swapcache yet. This transient swap_map state is expected to be transitory,
> but the actual placement of discard at scan_swap_map() inserts a wait for
> I/O completion thus making the thread at read_swap_cache_async() to loop
> around its -EEXIST case, while the other end at get_swap_page()
> is scheduled away at scan_swap_map(). This can leave the system deadlocked
> if the I/O completion happens to be waiting on the CPU workqueue where
> read_swap_cache_async() is busy looping and !CONFIG_PREEMPT.
>
> This patch introduces a cond_resched() call to make the aforementioned
> read_swap_cache_async() busy loop condition to bail out when necessary,
> thus avoiding the subtle race window.
>
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

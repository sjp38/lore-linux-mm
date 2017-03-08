Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 125498320D
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 18:11:43 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q126so83005868pga.0
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 15:11:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g5si510186pfj.241.2017.03.08.15.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 15:11:42 -0800 (PST)
Date: Wed, 8 Mar 2017 15:11:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kasan: fix races in quarantine_remove_cache()
Message-Id: <20170308151141.2ccdd5cb9e82a56cd25562cc@linux-foundation.org>
In-Reply-To: <20170308151532.5070-1-dvyukov@google.com>
References: <20170308151532.5070-1-dvyukov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: aryabinin@virtuozzo.com, linux-mm@kvack.org, kasan-dev@googlegroups.com, Greg Thelen <gthelen@google.com>

On Wed,  8 Mar 2017 16:15:32 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:

> quarantine_remove_cache() frees all pending objects that belong to the
> cache, before we destroy the cache itself. However there are currently
> two possibilities how it can fail to do so.
> 
> First, another thread can hold some of the objects from the cache in
> temp list in quarantine_put(). quarantine_put() has a windows of enabled
> interrupts, and on_each_cpu() in quarantine_remove_cache() can finish
> right in that window. These objects will be later freed into the
> destroyed cache.
> 
> Then, quarantine_reduce() has the same problem. It grabs a batch of
> objects from the global quarantine, then unlocks quarantine_lock and
> then frees the batch. quarantine_remove_cache() can finish while some
> objects from the cache are still in the local to_free list in
> quarantine_reduce().
> 
> Fix the race with quarantine_put() by disabling interrupts for the
> whole duration of quarantine_put(). In combination with on_each_cpu()
> in quarantine_remove_cache() it ensures that quarantine_remove_cache()
> either sees the objects in the per-cpu list or in the global list.
> 
> Fix the race with quarantine_reduce() by protecting quarantine_reduce()
> with srcu critical section and then doing synchronize_srcu() at the end
> of quarantine_remove_cache().
> 
> ...
>
> I suspect that these races are the root cause of some GPFs that
> I episodically hit. Previously I did not have any explanation for them.

The changelog doesn't convey a sense of how serious this bug is, so I'm
not in a good position to decide whether this fix should be backported.
The patch looks fairly intrusive so I tentatively decided that it
needn't be backported.  Perhaps that was wrong.

Please be more careful in describing the end-user visible impact of
bugs when fixing them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

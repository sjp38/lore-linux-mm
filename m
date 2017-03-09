Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7CA2808BC
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 06:09:08 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id k133so85350563oia.6
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 03:09:08 -0800 (PST)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40102.outbound.protection.outlook.com. [40.107.4.102])
        by mx.google.com with ESMTPS id p75si2837455oic.167.2017.03.09.03.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 03:09:07 -0800 (PST)
Subject: Re: [PATCH v2] kasan: fix races in quarantine_remove_cache()
References: <20170309094028.51088-1-dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <111f044a-2646-2a50-d848-dabfbb01ab4a@virtuozzo.com>
Date: Thu, 9 Mar 2017 14:10:14 +0300
MIME-Version: 1.0
In-Reply-To: <20170309094028.51088-1-dvyukov@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, Greg Thelen <gthelen@google.com>



On 03/09/2017 12:40 PM, Dmitry Vyukov wrote:
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
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: kasan-dev@googlegroups.com
> Cc: linux-mm@kvack.org
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Greg Thelen <gthelen@google.com>
> 

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

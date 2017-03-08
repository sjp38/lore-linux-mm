Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 983598320D
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 18:06:00 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f21so82588965pgi.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 15:06:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d23si4545352plj.83.2017.03.08.15.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 15:05:59 -0800 (PST)
Date: Wed, 8 Mar 2017 15:05:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kasan: resched in quarantine_remove_cache()
Message-Id: <20170308150558.15e44d3f10b4a9f9215b33c8@linux-foundation.org>
In-Reply-To: <20170308154239.25440-1-dvyukov@google.com>
References: <20170308154239.25440-1-dvyukov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: aryabinin@virtuozzo.com, linux-mm@kvack.org, kasan-dev@googlegroups.com, Greg Thelen <gthelen@google.com>

On Wed,  8 Mar 2017 16:42:39 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:

> We see reported stalls/lockups in quarantine_remove_cache() on machines
> with large amounts of RAM. quarantine_remove_cache() needs to scan whole
> quarantine in order to take out all objects belonging to the cache.
> Quarantine is currently 1/32-th of RAM, e.g. on a machine with 256GB
> of memory that will be 8GB. Moreover quarantine scanning is a walk
> over uncached linked list, which is slow.
> 
> Add cond_resched() after scanning of each non-empty batch of objects.
> Batches are specifically kept of reasonable size for quarantine_put().
> On a machine with 256GB of RAM we should have ~512 non-empty batches,
> each with 16MB of objects.

I'll add cc:stable to this one - softlockup reports on large machines
is a pretty significant issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

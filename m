Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 23C216B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 17:37:05 -0400 (EDT)
Received: from akpm.mtv.corp.google.com (216-239-45-4.google.com [216.239.45.4])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 7760E280
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 21:37:04 +0000 (UTC)
Date: Tue, 26 Jun 2012 14:37:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: needed lru_add_drain_all() change
Message-Id: <20120626143703.396d6d66.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

https://bugzilla.kernel.org/show_bug.cgi?id=43811

lru_add_drain_all() uses schedule_on_each_cpu().  But
schedule_on_each_cpu() hangs if a realtime thread is spinning, pinned
to a CPU.  There's no intention to change the scheduler behaviour, so I
think we should remove schedule_on_each_cpu() from the kernel.

The biggest user of schedule_on_each_cpu() is lru_add_drain_all().

Does anyone have any thoughts on how we can do this?  The obvious
approach is to declare these:

static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);

to be irq-safe and use on_each_cpu().  lru_rotate_pvecs is already
irq-safe and converting lru_add_pvecs and lru_deactivate_pvecs looks
pretty simple.

Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

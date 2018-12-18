Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id F11E78E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 10:07:50 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id q23so9687446otn.3
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 07:07:50 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j9si1304748oih.55.2018.12.18.07.07.49
        for <linux-mm@kvack.org>;
        Tue, 18 Dec 2018 07:07:49 -0800 (PST)
Date: Tue, 18 Dec 2018 15:07:45 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
Message-ID: <20181218150744.GB20197@arrakis.emea.arm.com>
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
 <20181123095314.hervxkxtqoixovro@linutronix.de>
 <40a63aa5-edb6-4673-b4cc-1bc10e7b3953@windriver.com>
 <20181130181956.eewrlaabtceekzyu@linutronix.de>
 <e7795912-7d93-8f4e-b997-67c4ac1f3549@windriver.com>
 <20181205191400.qrhim3m3ak5hcsuh@linutronix.de>
 <16ac893a-a080-18a5-e636-7b7668d978b0@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16ac893a-a080-18a5-e636-7b7668d978b0@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: He Zhe <zhe.he@windriver.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org

On Tue, Dec 18, 2018 at 06:51:41PM +0800, He Zhe wrote:
> On 2018/12/6 03:14, Sebastian Andrzej Siewior wrote:
> > With raw locks you wouldn't have multiple readers at the same time.
> > Maybe you wouldn't have recursion but since you can't have multiple
> > readers you would add lock contention where was none (because you could
> > have two readers at the same time).
> 
> OK. I understand your concern finally. At the commit log said, I wanted to use raw
> rwlock but didn't find the DEFINE helper for it. Thinking it would not be expected to
> have great performance, I turn to use raw spinlock instead. And yes, this would
> introduce worse performance.

Looking through the kmemleak code, I can't really find significant
reader contention. The longest holder of this lock (read) is the scan
thread which is also protected by a scan_mutex, so can't run
concurrently with another scanner (triggered through debugfs). The other
read_lock(&kmemleak_lock) user is find_and_get_object() called from a
few places. However, all such places normally follow a create_object()
call (kmemleak_alloc() and friends) which already performs a
write_lock(&kmemleak_lock), so it needs to wait for the scan thread to
release the kmemleak_lock.

It may be worth running some performance/latency tests during kmemleak
scanning (echo scan > /sys/kernel/debug/kmemleak) but at a quick look,
I don't think we'd see any difference with a raw_spin_lock_t.

With a bit more thinking (though I'll be off until the new year), we
could probably get rid of the kmemleak_lock entirely in scan_block() and
make lookup_object() and the related rbtree code in kmemleak RCU-safe.

-- 
Catalin

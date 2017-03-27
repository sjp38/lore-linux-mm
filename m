Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 08B7C6B0343
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 10:31:20 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e188so40342572oif.18
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 07:31:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w82si418779oig.47.2017.03.27.07.31.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Mar 2017 07:31:19 -0700 (PDT)
Subject: Re: [PATCH] mm: Remove pointless might_sleep() in remove_vm_area().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201703242140.CHJ64587.LFSFQOJOOMtFHV@I-love.SAKURA.ne.jp>
	<fe511b26-f2e5-0a0e-09cc-303d38d2ad05@virtuozzo.com>
	<20170324161732.GA23110@bombadil.infradead.org>
	<0eceef23-a20c-bca7-2153-b9b5baf1f1d8@virtuozzo.com>
	<f1c0b9ec-c0c8-502c-c7f0-fe692c73ab04@vmware.com>
In-Reply-To: <f1c0b9ec-c0c8-502c-c7f0-fe692c73ab04@vmware.com>
Message-Id: <201703272329.AIE32232.LtVSOOOFFQJFHM@I-love.SAKURA.ne.jp>
Date: Mon, 27 Mar 2017 23:29:44 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: thellstrom@vmware.com, aryabinin@virtuozzo.com, willy@infradead.org
Cc: linux-mm@kvack.org, hch@lst.de, jszhang@marvell.com, joelaf@google.com, chris@chris-wilson.co.uk, joaodias@google.com, tglx@linutronix.de, hpa@zytor.com, mingo@elte.hu, dri-devel@lists.freedesktop.org, airlied@linux.ie, linux-security-module@vger.kernel.org

Thomas Hellstrom wrote:
> So to summarize. Yes, the drm callers can be fixed up, but IMO requiring
> vfree() to be non-atomic is IMO not a good idea if avoidable.

I agree.

I don't know about drm code. But I can find AppArmor code doing
kvfree() from dfa_free() from aa_dfa_free_kref() from kref_put() from
aa_put_dfa() from aa_free_profile() which says

 * If the profile was referenced from a task context, free_profile() will
 * be called from an rcu callback routine, so we must not sleep here.

which means that below changes broke things without properly auditing
all vfree()/kvfree() users.

  commit bf22e37a641327e3 ("mm: add vfree_atomic()")
  commit 0f110a9b956c1678 ("kernel/fork: use vfree_atomic() to free thread stack")
  commit 8d5341a6260a59cf ("x86/ldt: use vfree_atomic() to free ldt entries")
  commit 5803ed292e63a1bf ("mm: mark all calls into the vmalloc subsystem as potentially sleeping")
  commit f9e09977671b618a ("mm: turn vmap_purge_lock into a mutex")
  commit 763b218ddfaf5676 ("mm: add preempt points into __purge_vmap_area_lazy()")

Since above commits did not take appropriate proceedure for changing
non-blocking API to blocking API, we must fix vfree() part for 4.10 and 4.11.

Updated patch is at
http://lkml.kernel.org/r/201703271916.FBI69340.SQFtOFVJHOLOMF@I-love.SAKURA.ne.jp .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

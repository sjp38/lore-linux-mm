Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id ADC558E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 06:48:11 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id n196so3342557oig.15
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 03:48:11 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id i41si34505144ota.323.2019.01.09.03.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 03:48:10 -0800 (PST)
Subject: Re: [PATCH] lockdep: Add debug printk() for downgrade_write()
 warning.
References: <1546771139-9349-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <e1a38e21-d5fe-dee3-7081-bc1a12965a68@i-love.sakura.ne.jp>
 <20190106201941.49f6dc4a4d2e9d15b575f88a@linux-foundation.org>
 <CACT4Y+Y=V-yRQN6YV_wXT0gejbQKTtUu7wrRmuPVojaVv6NFsQ@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <162036ee-81f1-36b1-7658-15a5f98c7d29@i-love.sakura.ne.jp>
Date: Wed, 9 Jan 2019 20:47:43 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Y=V-yRQN6YV_wXT0gejbQKTtUu7wrRmuPVojaVv6NFsQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>

Hello, Peter.

We got two reports. Neither RWSEM_READER_OWNED nor RWSEM_ANONYMOUSLY_OWNED is set, and
(presumably) sem->owner == current is true, but count is -1. What does this mean?

https://syzkaller.appspot.com/text?tag=CrashLog&x=169dbb9b400000

[ 2580.337550][ T3645] mmap_sem: hlock->read=1 count=-4294967295 current=ffff888050e04140, owner=ffff888050e04140
[ 2580.353526][ T3645] ------------[ cut here ]------------
[ 2580.367859][ T3645] downgrading a read lock
[ 2580.367935][ T3645] WARNING: CPU: 1 PID: 3645 at kernel/locking/lockdep.c:3572 lock_downgrade+0x35d/0xbe0
[ 2580.382206][ T3645] Kernel panic - not syncing: panic_on_warn set ...

https://syzkaller.appspot.com/text?tag=CrashLog&x=1542da4f400000

[  386.342585][T16698] mmap_sem: hlock->read=1 count=-4294967295 current=ffff8880512ae180, owner=ffff8880512ae180
[  386.348586][T16698] ------------[ cut here ]------------
[  386.357203][T16698] downgrading a read lock
[  386.357294][T16698] WARNING: CPU: 1 PID: 16698 at kernel/locking/lockdep.c:3572 lock_downgrade+0x35d/0xbe0
[  386.372148][T16698] Kernel panic - not syncing: panic_on_warn set ...

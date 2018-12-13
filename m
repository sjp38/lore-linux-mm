Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 607FD8E0014
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 14:46:18 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y83so2589163qka.7
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 11:46:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g187si1761718qka.218.2018.12.13.11.46.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 11:46:17 -0800 (PST)
Subject: Re: WARNING: locking bug in lock_downgrade
References: <00000000000043ae20057b974f14@google.com>
 <f0acc6af-cdd5-0e46-bca5-2e2a9a4c983e@linux.alibaba.com>
From: Waiman Long <longman@redhat.com>
Message-ID: <69273d51-c129-6b0f-35eb-d98655476ff9@redhat.com>
Date: Thu, 13 Dec 2018 14:46:13 -0500
MIME-Version: 1.0
In-Reply-To: <f0acc6af-cdd5-0e46-bca5-2e2a9a4c983e@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, syzbot <syzbot+53383ae265fb161ef488@syzkaller.appspotmail.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, peterz@infradead.org, "mingo@redhat.com" <mingo@redhat.com>, boqun.feng@gmail.com

On 12/12/2018 08:14 PM, Yang Shi wrote:
> Cc'ed Peter, Ingo and Waiman.
>
>
> It took me a few days to look into this warning, but I got lost in
> lockdep code.
>
>
> The problem is the commit dd2283f2605e ("mm: mmap: zap pages with read
> mmap_sem in munmap") does an optimization for munmap by downgrading
> write mmap_sem to read before zapping pages. But, lockdep reports
> downgrading a read lock.
>
>
> I'm pretty sure mmap_sem is held as write before downgrade_write() is
> called in the patch. And, there are 4 places which may downgrade a
> mmap_sem:
>
>     - munmap
>
>     - mremap
>
>     - brk
>
>     - clear_refs_write (fs/proc/task_mmu.c)
>
>
> The first three come from my patches, and they just do:
> down_write_killable() -> .. -> downgrade_write().
>
> But the last one is a little bit more complicated, it does down_read()
> ->.. -> up_read() ->.. -> down_write_killable() ->.. ->
> downgrade_write().
>
> And, the last one may be called from any process to touch the other
> processes' mmap_sem.
>
>
> By looking into lockdep code, I'm not sure if lockdep may get confused
> by such sequence or not?
>
>
> Any hint is appreciated.
>
>
> Regards,
>
> Yang 

The warning was printed because hlock->read was set when doing the
downgrade_write(). So it is either downgrade_write() was called a second
time or a read lock was held originally. It is hard to tell what is the
root cause without a reproducer.

Cheers,
Longman

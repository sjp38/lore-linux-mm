Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 91E41828E6
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:18:59 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l66so163261487wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:18:59 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id js4si9898758wjc.164.2016.02.03.05.18.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 05:18:58 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id l66so163260972wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:18:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1602031409520.22727@cbobk.fhfr.pm>
References: <CACT4Y+ZqQte+9Uk2FsixfWw7sAR7E5rK_BBr8EJe1M+Sv-i_RQ@mail.gmail.com>
 <alpine.LNX.2.00.1602031409520.22727@cbobk.fhfr.pm>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 3 Feb 2016 14:18:38 +0100
Message-ID: <CACT4Y+Z7rGfBoKPWc1SpBoxhX2NhBoffu7KAtodXQj9ROYOGTQ@mail.gmail.com>
Subject: Re: mm: uninterruptable tasks hanged on mmap_sem
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Takashi Iwai <tiwai@suse.de>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Wed, Feb 3, 2016 at 2:11 PM, Jiri Kosina <jikos@kernel.org> wrote:
> On Tue, 2 Feb 2016, Dmitry Vyukov wrote:
>
>> Hello,
>>
>> If the following program run in a parallel loop, eventually it leaves
>> hanged uninterruptable tasks on mmap_sem.
>>
>> [ 4074.740298] sysrq: SysRq : Show Locks Held
>> [ 4074.740780] Showing all locks held in the system:
>> ...
>> [ 4074.762133] 1 lock held by a.out/1276:
>> [ 4074.762427]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816df89c>]
>> __mm_populate+0x25c/0x350
>> [ 4074.763149] 1 lock held by a.out/1147:
>> [ 4074.763438]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816b3bbc>]
>> vm_mmap_pgoff+0x12c/0x1b0
>> [ 4074.764164] 1 lock held by a.out/1284:
>> [ 4074.764447]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816df89c>]
>> __mm_populate+0x25c/0x350
>> [ 4074.765287]
>
> I've now tried to reproduce this on 4.5-rc1 (with the lock_fdc() fix
> applied), and I am not seeing any stuck tasks so far.
>
> Could you please provide more details about the reproduction scenario?
> Namely, how many parallel invocations are you typically running (and how
> many cores does the system in question have), and what is the typical time
> that you need for the problem to appear?


Qemu with 4 cores, 32 parallel processes, it took 20 seconds (2409
program executions) to hang 2 of them just now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

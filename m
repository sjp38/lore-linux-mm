Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF416B0253
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:11:21 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id bc4so11706589lbc.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:11:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qw9si3946198lbb.47.2016.02.03.05.11.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 05:11:19 -0800 (PST)
Date: Wed, 3 Feb 2016 14:11:17 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: mm: uninterruptable tasks hanged on mmap_sem
In-Reply-To: <CACT4Y+ZqQte+9Uk2FsixfWw7sAR7E5rK_BBr8EJe1M+Sv-i_RQ@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1602031409520.22727@cbobk.fhfr.pm>
References: <CACT4Y+ZqQte+9Uk2FsixfWw7sAR7E5rK_BBr8EJe1M+Sv-i_RQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Takashi Iwai <tiwai@suse.de>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Tue, 2 Feb 2016, Dmitry Vyukov wrote:

> Hello,
> 
> If the following program run in a parallel loop, eventually it leaves
> hanged uninterruptable tasks on mmap_sem.
> 
> [ 4074.740298] sysrq: SysRq : Show Locks Held
> [ 4074.740780] Showing all locks held in the system:
> ...
> [ 4074.762133] 1 lock held by a.out/1276:
> [ 4074.762427]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816df89c>]
> __mm_populate+0x25c/0x350
> [ 4074.763149] 1 lock held by a.out/1147:
> [ 4074.763438]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816b3bbc>]
> vm_mmap_pgoff+0x12c/0x1b0
> [ 4074.764164] 1 lock held by a.out/1284:
> [ 4074.764447]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816df89c>]
> __mm_populate+0x25c/0x350
> [ 4074.765287]

I've now tried to reproduce this on 4.5-rc1 (with the lock_fdc() fix 
applied), and I am not seeing any stuck tasks so far.

Could you please provide more details about the reproduction scenario? 
Namely, how many parallel invocations are you typically running (and how 
many cores does the system in question have), and what is the typical time 
that you need for the problem to appear?

Thanks,

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

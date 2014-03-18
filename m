Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id E9A276B010A
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 12:38:07 -0400 (EDT)
Received: by mail-oa0-f44.google.com with SMTP id n16so7337964oag.3
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 09:38:07 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id so6si18608232obb.53.2014.03.18.09.38.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 09:38:07 -0700 (PDT)
Message-ID: <1395160684.2474.47.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [BUG -next] "mm: per-thread vma caching fix 5" breaks s390
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 18 Mar 2014 09:38:04 -0700
In-Reply-To: <20140318124107.GA24890@osiris>
References: <20140318124107.GA24890@osiris>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue, 2014-03-18 at 13:41 +0100, Heiko Carstens wrote:
> Hi Andrew,
> 
> your patch "mm-per-thread-vma-caching-fix-5" in linux-next (see below) breaks s390:
> 
> [   10.101173] kernel BUG at mm/vmacache.c:76!
> [   10.101206] illegal operation: 0001 [#1] SMP DEBUG_PAGEALLOC
> [   10.101210] Modules linked in:
> [   10.101212] CPU: 3 PID: 2286 Comm: ifup-eth Not tainted 3.14.0-rc6-00193-g7f31667faba3 #20
> [   10.101214] task: 000000003f65cb90 ti: 000000003db30000 task.ti: 000000003db30000
> [   10.101220] Krnl PSW : 0704d00180000000 000000000025df40 (vma_interval_tree_augment_rotate+0x0/0x64)
> [   10.101222]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:1 PM:0 EA:3
>                Krnl GPRS: 0000000000000000 0000000000000018 000000003a42cfd0 00000000800fb000
> [   10.101225]            0000000000000001 000000003f65cb90 0000000000000000 000000003dbacba8
> [   10.101226]            0705100180000000 000000003dbacb00 000000003f65cb90 000000003dbacb00
> [   10.101227]            000000003a42cfd0 00000000800fb000 0000000000269e54 000000003db33d80
> [   10.101235] Krnl Code: 000000000025df32: e3b0c0400020        cg      %r11,64(%r12)
>                           000000000025df38: a784ffd1            brc     8,25deda
>                          #000000000025df3c: a7f40001            brc     15,25df3e
>                          >000000000025df40: e31020180004        lg      %r1,24(%r2)
>                           000000000025df46: e31030180024        stg     %r1,24(%r3)
>                           000000000025df4c: e3302fb0ff04        lg      %r3,-80(%r2)
>                           000000000025df52: e31020400004        lg      %r1,64(%r2)
>                           000000000025df58: e3302fa8ff09        sg      %r3,-88(%r2)
> [   10.101251] Call Trace:
> [   10.101253] ([<000000003dbacb00>] 0x3dbacb00)
> [   10.101256]  [<00000000007a62da>] do_protection_exception+0x12a/0x3b4
> [   10.101258]  [<00000000007a4862>] pgm_check_handler+0x17a/0x17e
> [   10.101259]  [<0000000080086806>] 0x80086806
> [   10.101260] INFO: lockdep is turned off.
> [   10.101261] Last Breaking-Event-Address:
> [   10.101262]  [<000000000025df3c>] vmacache_find+0x80/0x84
> [   10.101264]  
> [   10.101265] Kernel panic - not syncing: Fatal exception: panic_on_oops
> 
> Given that this is just an addon patch to Davidlohr's "mm: per-thread
> vma caching" patch I was wondering if something in there is architecture
> specific.
> But it doesn't look like that. So I'm wondering if this only breaks on
> s390?

No, there isn't anything arch specific. Please note that there are a few
other patches in -mm that fix the actual issue that triggers that
BUG_ON(), so you'll want to try those.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

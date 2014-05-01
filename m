Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 345CE6B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 23:57:56 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hl10so70668igb.3
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 20:57:55 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id a5si3863935icf.95.2014.04.30.20.57.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 20:57:55 -0700 (PDT)
Received: by mail-ie0-f171.google.com with SMTP id to1so3092169ieb.16
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 20:57:55 -0700 (PDT)
Date: Wed, 30 Apr 2014 20:56:40 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
In-Reply-To: <53614BFE.9090804@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1404302030260.11435@eggly.anvils>
References: <535EA976.1080402@linux.vnet.ibm.com> <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com> <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com> <alpine.LSU.2.11.1404281500180.2861@eggly.anvils>
 <1398723290.25549.20.camel@buesod1.americas.hpqcorp.net> <CA+55aFwGjYS7PqsD6A-q+Yp9YZmiM6mB4MUYmfR7ro02poxxCQ@mail.gmail.com> <535F77E8.2040000@linux.vnet.ibm.com> <53614BFE.9090804@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <davidlohr@hp.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Dave Jones <davej@redhat.com>

On Thu, 1 May 2014, Srivatsa S. Bhat wrote:
> 
> I tried to recall the *exact* steps that I had carried out when I first
> hit the bug. I realized that I had actually used kexec to boot the new
> kernel. I had originally booted into a 3.7.7 kernel that happens to be
> on that machine, and then kexec()'ed 3.15-rc3 on it. And that had caused
> the kernel crash. Fresh boots of 3.15-rc3, as well as kexec from 3.15+
> to itself, seems to be pretty robust and has never resulted in any bad
> behavior (this is why I couldn't reproduce the issue earlier, since I was
> doing fresh boots of 3.15-rc).
> 
> So I tried the same recipe again (boot into 3.7.7 and kexec into 3.15-rc3+)
> and I got totally random crashes so far, once in sys_kill and two times in
> exit_mmap. So I guess the bug is in 3.7.x and probably 3.15-rc is fine after
> all...

I don't know if we can conclude the bug is in 3.7 rather than 3.15.

I spent a little while yesterday looking at your register dumps,
and applying scripts/decodecode to your Code lines.  I did notice a
pattern to the general protection faulting addresses, and the dumps
you show today confirm that pattern (but with "1e000000" at the top
instead of yesterday's "9e000000").

Sorry, I really cannot spend more time on this, but thought I should
at least throw out my observation before moving on.  Here I've simply
grepped out the lines with the significant pattern (and at least one
of these lines is essentially a repetition of the line before, value
moved from one register to another with offset subtracted; oh, and
that R12 line, "it" has been added on to the vsize acct_collect()
already accumulated).

RAX: 9e00000005f9e8fd RBX: 000000000000000b RCX: 0000000000000001
RAX: 9e00000005f9e5fd RBX: ffff881031a0c2f8 RCX: ffff88203d52ba40
RDX: 000000000000001e RSI: 9e00000005f9e5a5 RDI: ffff881031a0c2f8
R10: 0000000000000000 R11: 00000000000027d5 R12: 9e000000069d62fd
BUG: Bad page map in process kdump  pte:1e00000005f98701 pmd:1031489067
BUG: Bad page map in process kdump  pte:1e00000005f98701 pmd:103420b067
R13: 0000000000000004 R14: 1e00000005f93403 R15: 000000000000000a

That this corruption likes to attack mm structures (vmas yesterday,
page tables today) does make me wonder whether mm is to blame.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

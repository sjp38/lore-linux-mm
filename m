Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7CA6B0033
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 22:29:59 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id d6so16142446pfb.3
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 19:29:59 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t63sor669292pfg.103.2017.11.22.19.29.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 19:29:57 -0800 (PST)
MIME-Version: 1.0
From: Hao Lee <haolee.swjtu@gmail.com>
Date: Thu, 23 Nov 2017 11:29:56 +0800
Message-ID: <CA+PpKPmSasSKfZosJznAVsheciOmdGM_c8aU8jkctFggTjQkdQ@mail.gmail.com>
Subject: Why does the kernel still boot normally even though the identity
 mapping is not set up?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

I'm currently reading the code of identity mapping and have found a
strange problem.

In head64.c, kernel sets up identity mapping[1] for the switchover, or
more precisely, this temporary mapping is used by the following two
instructions in head_64.S[2]:

    /* Ensure I am executing from virtual addresses */
    movq $1f, %rax
    jmp *%rax

I delete all the code of identity mapping[1] and recompile my kernel
and then test it in Bochs. To my surprise, this kernel can still boot
normally. I also test it in VMware(with Fedora 25) and QEMU. Vmware
can boot without any problem but QEMU can't. However, others have
reported[3] that QEMU can boot normally too if kvm is enabled with
--enable-kvm. Then I want to find out what happened, so I debug these
code in Bochs line by line. When the above two instructions are being
executed, Bochs prints warnings:

??? (physical address not available)
??? (physical address not available)

I ignore these warnings and make the kernel continue running. I find
the kernel can reach the next instruction (movl $0x80000001, %eax)
successfully and the RIP register is set to the correct virtual
address as if the identity mapping code was not deleted.

My question is why the kernel can still boot normally even though the
identity mapping is not set up. This question is first raised in a
GitHub issue: https://github.com/0xAX/linux-insides/issues/544

Could someone give us some hints? Many Thanks!

[1] https://github.com/torvalds/linux/blob/0c86a6bd85ff0629cd2c5141027fc1c8bb6cde9c/arch/x86/kernel/head64.c#L98-L138
[2] https://github.com/torvalds/linux/blob/0c86a6bd85ff0629cd2c5141027fc1c8bb6cde9c/arch/x86/kernel/head_64.S#L135-L137
[3] https://www.spinics.net/lists/kvm/msg159168.html

Regards,
Hao Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

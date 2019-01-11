Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F89E8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:53:02 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id u32so14974712qte.1
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 20:53:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l11sor69394074qvr.48.2019.01.10.20.53.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 20:53:01 -0800 (PST)
Subject: Re: PROBLEM: syzkaller found / pool corruption-overwrite / page in
 user-area or NULL
References: <t78EEfgpy3uIwPUvqvmuQEYEWKG9avWzjUD3EyR93Qaf_tfx1gqt4XplrqMgdxR1U9SsrVdA7G9XeUZacgUin0n6lBzoxJHVJ9Ko0yzzrxI=@protonmail.ch>
 <1547150339.2814.9.camel@linux.ibm.com> <1547153074.6911.8.camel@lca.pw>
 <4u36JfbOrbu9CXLDErzQKvorP0gc2CzyGe60rBmZsGAGIw6RacZnIfoSsAF0I0TCnVx0OvcqCZFN6ntbgicJ66cWew9cOXRgcuWxSPdL3ko=@protonmail.ch>
 <1547154231.6911.10.camel@lca.pw>
 <hFmbfypBKySVyM6ITf55xUsPWifgqJy6MZ-kFJcYna61S-u2hoClrqr87QTF4F2LhW-K42T2lcCbvsEyGAL0dJTq5CndQBiMT6JnlW4xmdc=@protonmail.ch>
 <1547159604.6911.12.camel@lca.pw>
 <olV6qm38nrHhMMH3bq9cY3h60MaHsW5U9n6xn3_PVP1UkFNJBNbVuS-8P_FdCazGJX6GZX_Qqe2Nj8_hbLJsgto76Xo-gLQ8We-hsc_vRKk=@protonmail.ch>
 <7416c812-f452-9c23-9d0c-37eac0174231@lca.pw>
 <fkYi1Hgt2t5U6zQt5Kz4ej-TFyVsn2Qp2OLrMbmt2418U1rn20DPZGqgCN-rmCZgFgGKXhl3-IGciCJ-G9fV_lkBuy_Vb7QFouBhwBE--Eo=@protonmail.ch>
From: Qian Cai <cai@lca.pw>
Message-ID: <3b3184e0-d913-6519-0f9d-2f01ef795650@lca.pw>
Date: Thu, 10 Jan 2019 23:52:58 -0500
MIME-Version: 1.0
In-Reply-To: <fkYi1Hgt2t5U6zQt5Kz4ej-TFyVsn2Qp2OLrMbmt2418U1rn20DPZGqgCN-rmCZgFgGKXhl3-IGciCJ-G9fV_lkBuy_Vb7QFouBhwBE--Eo=@protonmail.ch>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Esme <esploit@protonmail.ch>
Cc: James Bottomley <jejb@linux.ibm.com>, "dgilbert@interlog.com" <dgilbert@interlog.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 1/10/19 10:15 PM, Esme wrote:
>>> [ 75.793150] RIP: 0010:rb_insert_color+0x189/0x1480
>>
>> What's in that line? Try,
>>
>> $ ./scripts/faddr2line vmlinux rb_insert_color+0x189/0x1480
> 
> rb_insert_color+0x189/0x1480:
> __rb_insert at /home/files/git/linux/lib/rbtree.c:131
> (inlined by) rb_insert_color at /home/files/git/linux/lib/rbtree.c:452
> 

gparent = rb_red_parent(parent);

tmp = gparent->rb_right; <-- GFP triggered here.

It suggests gparent is NULL. Looks like it misses a check there because parent
is the top node.

>>
>> What's steps to reproduce this?
> 
> The steps is the kernel config provided (proc.config) and I double checked the attached C code from the qemu image (attached here).  If the kernel does not immediately crash, a ^C will cause the fault to be noticed.  The report from earlier is the report from the same code, my assumption was that the possible pool/redzone corruption is making it a bit tricky to pin down.
> 
> If you would like alternative kernel settings please let me know, I can do that, also, my current test-bench has about 256 core's on x64, 64 of them are bare metal and 32 are arm64.  Any possible preferred configuration tweaks I'm all ears, I'll be including some of these steps you suggested to me in any/additional upcoming threads (Thank you for that so far and future suggestions).
> 
> Also, there is some occasionally varying stacks depending on the corruption, so this stack just now (another execution of test3.c);

I am unable to reproduce any of those here. What's is the output of
/proc/cmdline in your guest when this happens?

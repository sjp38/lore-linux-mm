Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4D036B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 05:44:27 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p12-v6so16331400qtg.5
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 02:44:27 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0119.outbound.protection.outlook.com. [104.47.1.119])
        by mx.google.com with ESMTPS id o22-v6si5421122qka.72.2018.06.19.02.44.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Jun 2018 02:44:26 -0700 (PDT)
Subject: Re: [Bug 200095] New: kasan: GPF could be caused by NULL-ptr deref or
 user memory access
References: <bug-200095-27@https.bugzilla.kernel.org/>
 <20180618162545.521b8da29637cf7ec7608fa6@linux-foundation.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <564ac5ca-ff1c-c955-b8fe-9f44fc6a4e00@virtuozzo.com>
Date: Tue, 19 Jun 2018 12:45:51 +0300
MIME-Version: 1.0
In-Reply-To: <20180618162545.521b8da29637cf7ec7608fa6@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, icytxw@gmail.com, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>



On 06/19/2018 02:25 AM, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> Could the KASAN people please help interpret this one?
> 

[  274.337561] RAX: 1ffff1000d80fd40 RBX: 0000041600000406 RCX: ffffffff8324e1de
[  274.339796] RDX: 00000082c000007e RSI: ffffffff814d6dd8 RDI: 00000416000003f6
[  274.342043] RBP: dffffc0000000000 R08: 1ffffffff08cf184 R09: fffffbfff08cf184
[  274.344269] R10: 0000000000000001 R11: fffffbfff08cf184 R12: ffff88006c07ea00
[  274.346529] R13: 00000416000003ee R14: ffffed000d80fd41 R15: ffffc90000712000


All code
========
   0:   76 e8                   jbe    0xffffffffffffffea
   2:   78 3f                   js     0x43
   4:   e5 ff                   in     $0xff,%eax
   6:   4c 89 e0                mov    %r12,%rax
   9:   48 c1 e8 03             shr    $0x3,%rax
   d:   80 3c 28 00             cmpb   $0x0,(%rax,%rbp,1)
  11:   0f 85 c7 02 00 00       jne    0x2de
  17:   4c 8d 6b e8             lea    -0x18(%rbx),%r13
  1b:   4d 8b 3c 24             mov    (%r12),%r15
  1f:   49 8d 7d 08             lea    0x8(%r13),%rdi
  23:   48 89 fa                mov    %rdi,%rdx
  26:   48 c1 ea 03             shr    $0x3,%rdx
  2a:*  80 3c 2a 00             cmpb   $0x0,(%rdx,%rbp,1)               <-- trapping instruction
  2e:   0f 85 a0 02 00 00       jne    0x2d4
  34:   4c 3b 7b f0             cmp    -0x10(%rbx),%r15
  38:   72 9d                   jb     0xffffffffffffffd7
  3a:   e8 3f 3f e5 ff          callq  0xffffffffffe53f7e
  3f:   41                      rex.B


cmpb   $0x0,(%rdx,%rbp,1) is shadow check for  -0x10(%rbx) address (this address is also in %rdi).
So this is attempt to dereference 0x00000416000003f6 address.

%rbx seems contains 'parent' pointer, -0x10(%rbx) is tmp_va->va_end

		tmp_va = rb_entry(parent, struct vmap_area, rb_node);
		if (va->va_start < tmp_va->va_end)

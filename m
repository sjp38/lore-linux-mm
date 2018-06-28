Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7F26B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 23:48:12 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id p91-v6so2321747plb.12
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 20:48:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d10-v6si4802873pgo.630.2018.06.27.20.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 20:48:10 -0700 (PDT)
Date: Wed, 27 Jun 2018 20:48:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Message-Id: <20180627204808.99988d94180dd144b14aa38b@linux-foundation.org>
In-Reply-To: <bug-200209-27@https.bugzilla.kernel.org/>
References: <bug-200209-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: icytxw@gmail.com
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 22 Jun 2018 23:37:27 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=200209
> 
>             Bug ID: 200209
>            Summary: UBSAN: Undefined behaviour in mm/fadvise.c:LINE
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: v4.18-rc2
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: icytxw@gmail.com
>         Regression: No
> 
> Hi,
> This bug was found in Linux Kernel v4.18-rc2
> 
> $ cat report0 
> ================================================================================
> UBSAN: Undefined behaviour in mm/fadvise.c:76:10
> signed integer overflow:
> 4 + 9223372036854775805 cannot be represented in type 'long long int'
> CPU: 0 PID: 13477 Comm: syz-executor1 Not tainted 4.18.0-rc1 #2
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
> Call Trace:
>  __dump_stack lib/dump_stack.c:77 [inline]
>  dump_stack+0x122/0x1c8 lib/dump_stack.c:113
>  ubsan_epilogue+0x12/0x86 lib/ubsan.c:159
>  handle_overflow+0x1c2/0x21f lib/ubsan.c:190
>  __ubsan_handle_add_overflow+0x2a/0x31 lib/ubsan.c:198
>  ksys_fadvise64_64+0xbf0/0xd10 mm/fadvise.c:76
>  __do_sys_fadvise64 mm/fadvise.c:198 [inline]
>  __se_sys_fadvise64 mm/fadvise.c:196 [inline]
>  __x64_sys_fadvise64+0xa9/0x120 mm/fadvise.c:196
>  do_syscall_64+0xb8/0x3a0 arch/x86/entry/common.c:290

That overflow is deliberate:

	endbyte = offset + len;
	if (!len || endbyte < len)
		endbyte = -1;
	else
		endbyte--;		/* inclusive */

Or is there a hole in this logic?

If not, I guess ee can do this another way to keep the checker happy.

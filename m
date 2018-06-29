Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 690516B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:43:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f81-v6so1293895pfd.7
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:43:15 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50106.outbound.protection.outlook.com. [40.107.5.106])
        by mx.google.com with ESMTPS id x5-v6si192233pgc.210.2018.06.29.11.43.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Jun 2018 11:43:14 -0700 (PDT)
Subject: Re:
References: <bug-200209-27@https.bugzilla.kernel.org/>
 <20180627204808.99988d94180dd144b14aa38b@linux-foundation.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <61b427f0-978c-fdbf-8b16-226705131220@virtuozzo.com>
Date: Fri, 29 Jun 2018 21:44:44 +0300
MIME-Version: 1.0
In-Reply-To: <20180627204808.99988d94180dd144b14aa38b@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, icytxw@gmail.com
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>



On 06/28/2018 06:48 AM, Andrew Morton wrote:

>> Hi,
>> This bug was found in Linux Kernel v4.18-rc2
>>
>> $ cat report0 
>> ================================================================================
>> UBSAN: Undefined behaviour in mm/fadvise.c:76:10
>> signed integer overflow:
>> 4 + 9223372036854775805 cannot be represented in type 'long long int'
>> CPU: 0 PID: 13477 Comm: syz-executor1 Not tainted 4.18.0-rc1 #2
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:77 [inline]
>>  dump_stack+0x122/0x1c8 lib/dump_stack.c:113
>>  ubsan_epilogue+0x12/0x86 lib/ubsan.c:159
>>  handle_overflow+0x1c2/0x21f lib/ubsan.c:190
>>  __ubsan_handle_add_overflow+0x2a/0x31 lib/ubsan.c:198
>>  ksys_fadvise64_64+0xbf0/0xd10 mm/fadvise.c:76
>>  __do_sys_fadvise64 mm/fadvise.c:198 [inline]
>>  __se_sys_fadvise64 mm/fadvise.c:196 [inline]
>>  __x64_sys_fadvise64+0xa9/0x120 mm/fadvise.c:196
>>  do_syscall_64+0xb8/0x3a0 arch/x86/entry/common.c:290
> 
> That overflow is deliberate:
> 
> 	endbyte = offset + len;
> 	if (!len || endbyte < len)
> 		endbyte = -1;
> 	else
> 		endbyte--;		/* inclusive */
> 
> Or is there a hole in this logic?
> 
> If not, I guess ee can do this another way to keep the checker happy.
 
It should be enough to make overflow unsigned. Unsigned overflow is defined by the C standard.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id B0F376B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 03:07:04 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so2792496pbc.20
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 00:07:04 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id fl3si8661624pab.165.2014.06.20.00.07.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 00:07:03 -0700 (PDT)
Message-ID: <53A3DD82.3070208@huawei.com>
Date: Fri, 20 Jun 2014 15:06:42 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Why we echo a invalid  start_address_of_new_memory succeeded ?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: wangnan0@huawei.com, xiaofeng.yan@huawei.com, linux-mm@kvack.org

Hi,

I am testing mem-hotplug on a qemu virtual machine. I executed the following command
to notify memory hot-add event by hand.

% echo start_address_of_new_memory > /sys/devices/system/memory/probe

To a different start_address_of_new_memory I got different results.
The results are as follows:

MBSC-x86_64 /sys/devices/system/memory # ls
block_size_bytes  memory2           memory5           power
memory0           memory3           memory6           probe
memory1           memory4           memory7           uevent
MBSC-x86_64 /sys/devices/system/memory # echo 0x70000000 > probe
MBSC-x86_64 /sys/devices/system/memory # echo 0x78000000 > probe
-sh: echo: write error: File exists
MBSC-x86_64 /sys/devices/system/memory # echo 0x80000000 > probe
-sh: echo: write error: File exists
MBSC-x86_64 /sys/devices/system/memory # echo 0x88000000 > probe
-sh: echo: write error: File exists
MBSC-x86_64 /sys/devices/system/memory # echo 0x8f000000 > probe
-sh: echo: write error: Invalid argument
MBSC-x86_64 /sys/devices/system/memory # echo 0x90000000 > probe
-sh: echo: write error: File exists
MBSC-x86_64 /sys/devices/system/memory # echo 0xff0000000 > probe
MBSC-x86_64 /sys/devices/system/memory # ls
block_size_bytes  memory2           memory510         probe
memory0           memory3           memory6           uevent
memory1           memory4           memory7
memory14          memory5           power
MBSC-x86_64 /sys/devices/system/memory # echo 0xfff0000000 > probe
MBSC-x86_64 /sys/devices/system/memory # ls
block_size_bytes  memory2           memory510         power
memory0           memory3           memory6           probe
memory1           memory4           memory7           uevent
memory14          memory5           memory8190

The qemu virtual machine's physical memory size is 2048M, and the boot memory is 1024M.

MBSC-x86_64 / # cat /proc/meminfo
MemTotal:        1018356 kB
MBSC-x86_64 / # cat /sys/devices/system/memory/block_size_bytes
8000000

Three questions:
1. The machine's physical memory size is 2048M, why echo 0x78000000 as the start_address_of_new_memory failed ?

2. Why echo 0x8f000000 as the start_address_of_new_memory, the error message is different ?

3. Why echo 0xfff0000000 as the start_address_of_new_memory succeeded ? 0xfff0000000 has exceeded the machine's physical memory size.

Best regards!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

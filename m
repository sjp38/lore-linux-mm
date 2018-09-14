Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 667868E0006
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 10:28:15 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id g71-v6so1459385vke.15
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 07:28:15 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j89-v6sor1811169vsi.51.2018.09.14.07.28.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Sep 2018 07:28:13 -0700 (PDT)
MIME-Version: 1.0
From: Pintu Kumar <pintu.ping@gmail.com>
Date: Fri, 14 Sep 2018 19:58:01 +0530
Message-ID: <CAOuPNLj1wx4sznrtLdKjcvuTf0dECPWzPaR946FoYRXB6YAGCw@mail.gmail.com>
Subject: KSM not working in 4.9 Kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: open list <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Hi All,

Board: Hikey620 ARM64
Kernel: 4.9.20

I am trying to verify KSM (Kernel Same Page Merging) functionality on
4.9 Kernel using "mmap" and madvise user space test utility.
But to my observation, it seems KSM is not working for me.
CONFIG_KSM=y is enabled in kernel.
ksm_init is also called during boot up.
  443 ?        SN     0:00 [ksmd]

ksmd thread is also running.

However, when I see the sysfs, no values are written.
~ # grep -H '' /sys/kernel/mm/ksm/*
/sys/kernel/mm/ksm/pages_hashed:0
/sys/kernel/mm/ksm/pages_scanned:0
/sys/kernel/mm/ksm/pages_shared:0
/sys/kernel/mm/ksm/pages_sharing:0
/sys/kernel/mm/ksm/pages_to_scan:200
/sys/kernel/mm/ksm/pages_unshared:0
/sys/kernel/mm/ksm/pages_volatile:0
/sys/kernel/mm/ksm/run:1
/sys/kernel/mm/ksm/sleep_millisecs:1000

So, please let me know if I am doing any thing wrong.

This is the test utility:
int main(int argc, char *argv[])
{
        int i, n, size;
        char *buffer;
        void *addr;

        n = 100;
        size = 100 * getpagesize();
        for (i = 0; i < n; i++) {
                buffer = (char *)malloc(size);
                memset(buffer, 0xff, size);
                addr =  mmap(NULL, size,
                           PROT_READ | PROT_EXEC | PROT_WRITE,
MAP_PRIVATE | MAP_ANONYMOUS,
                           -1, 0);
                madvise(addr, size, MADV_MERGEABLE);
                sleep(1);
        }
        printf("Done....press ^C\n");

        pause();

        return 0;
}



Thanks,
Pintu

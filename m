Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 964916B0268
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 11:50:01 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 14so1796042oii.6
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 08:50:01 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p52sor4204693otd.328.2017.10.11.08.49.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 08:49:59 -0700 (PDT)
MIME-Version: 1.0
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Wed, 11 Oct 2017 18:49:18 +0300
Message-ID: <CAGqmi76Oc89W6YpNXngOpJA7ArcUGA-8M=mXP35dTR7CLFzZCQ@mail.gmail.com>
Subject: Re: [PATCH] mm/ksm : Checksum calculation function change (jhash2 -> crc32)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi, my 2 cents,

(I miss some CC because i don't have a copy of mail
i found conversation on: http://www.spinics.net/lists/linux-mm/msg132431.html)

(Fix me if i'm wrong, may be i miss something)

So, I have a Skylake with HW SHA1/256
And i use openssl 1.1.0.f for testing
Hash 1GiB file for throughput testing.
  No HW sha1 (Intel(R) Xeon(R) CPU E5-2620 0 @ 2.00GHz)
    - sha1 - ~300 MiB/s
    - sha256 - ~128 MiB/s
  Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz
    - sha1 - ~900 MiB/s
    - sha256 - ~350 MiB/s

CRC32C for example below show about 13650.720367 MiB/s

I'm also afraid about possible collisions, but AFAIK:
http://cyan4973.github.io/xxHash/ (I copy part of table from that page)
Name      Speed    Quality Author
xxHash    5.4 GB/s 10 Y.C.
Lookup3   1.2 GB/s  9 Bob Jenkins
CRC32    0.43 GB/s 9  (that a SW implementationt, let's ignore speed)

So (in theory of course) jhash2 and crc32 have a same problems with collisions.

Info from my patch set (replace jhash2 with xxhash)

  x86_64 host:
    CPU: Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz
    PAGE_SIZE: 4096, loop count: 1048576
    jhash2:   0xacbc7a5b            time: 1907 ms,  th:  2251.9 MiB/s
    xxhash32: 0x570da981            time: 739 ms,   th:  5809.4 MiB/s
    xxhash64: 0xa1fa032ab85bbb62    time: 371 ms,   th: 11556.6 MiB/s

    CPU: Intel(R) Xeon(R) CPU E5-2420 0 @ 1.90GHz
    PAGE_SIZE: 4096, loop count: 1048576
    jhash2:   0xe680b382            time: 3722 ms,  th: 1153.896680 MiB/s
    xxhash32: 0x56d00be4            time: 1183 ms,  th: 3629.130689 MiB/s
    xxhash64: 0x8c194cff29cc4dee    time: 725 ms,   th: 5918.003401 MiB/s

So i really not believe in sha1 for KSM, it's just to slow

Thanks.

-- 
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC6A96B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 11:16:42 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o68so67297400qkf.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 08:16:42 -0700 (PDT)
Received: from mail-yw0-f176.google.com (mail-yw0-f176.google.com. [209.85.161.176])
        by mx.google.com with ESMTPS id u76si5698047ywu.420.2016.09.16.08.16.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 08:16:42 -0700 (PDT)
Received: by mail-yw0-f176.google.com with SMTP id u82so85222284ywc.2
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 08:16:42 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [REGRESSION] RLIMIT_DATA crashes named
Message-ID: <33304dd8-8754-689d-11f3-751833b4a288@redhat.com>
Date: Fri, 16 Sep 2016 08:16:38 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi,

Fedora received a bug report[1] after pushing 4.7.2 that named
was segfaulting with named-chroot. With some help (thank you
tibbs!), it was noted that on older kernels named was spitting
out

mmap: named (671): VmData 27566080 exceed data ulimit 23068672.
Will be forbidden soon.

and with f4fcd55841fc ("mm: enable RLIMIT_DATA by default with
workaround for valgrind") it now spits out

mmap: named (593): VmData 27566080 exceed data ulimit 20971520.
Update limits or use boot option ignore_rlimit_data.

Apparently the segfault goes away when dropping datasize=size.
I haven't looked into the named code yet but what I'm
suspecting is named is not setting its limits correctly and
then corrupting itself. This may have existed for much longer
but the rlimit is only now exposing it.

I'd like to propose reverting f4fcd55841fc ("mm: enable RLIMIT_DATA
by default with workaround for valgrind") or default to setting
ignore_rlimit_data to true and spitting out a warning until
named can be fixed.

Thanks,
Laura


[1] https://bugzilla.redhat.com/show_bug.cgi?id=1374917

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20D7C6B0261
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 13:05:24 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j126so3387294oib.9
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 10:05:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u63si3251833oib.316.2017.11.03.10.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 10:05:23 -0700 (PDT)
From: Florian Weimer <fweimer@redhat.com>
Subject: POWER: Unexpected fault when writing to brk-allocated memory
Message-ID: <f251fc3e-c657-ebe8-acc8-f55ab4caa667@redhat.com>
Date: Fri, 3 Nov 2017 18:05:20 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>

We are seeing an issue on ppc64le and ppc64 (and perhaps on some arm 
variant, but I have not seen it on our own builders) where running 
localedef as part of the glibc build crashes with a segmentation fault.

Kernel version is 4.13.9 (Fedora 26 variant).

I have only seen this with an explicit loader invocation, like this:

while I18NPATH=. /lib64/ld64.so.1 /usr/bin/localedef 
--alias-file=../intl/locale.alias --no-archive -i locales/nl_AW -c -f 
charmaps/UTF-8 
--prefix=/builddir/build/BUILDROOT/glibc-2.26-16.fc27.ppc64 nl_AW ; do : 
; done

To be run in the localedata subdirectory of a glibc *source* tree, after 
a build.  You may have to create the 
/builddir/build/BUILDROOT/glibc-2.26-16.fc27.ppc64/usr/lib/locale 
directory.  I have only reproduced this inside a Fedora 27 chroot on a 
Fedora 26 host, but there it does not matter if you run the old (chroot) 
or newly built binary.

I filed this as a glibc bug for tracking:

   https://sourceware.org/bugzilla/show_bug.cgi?id=22390

There's an strace log and a coredump from the crash.

I think the data shows that the address in question should be writable.

The crossed 0x0000800000000000 binary is very suggestive.  I think that 
based on the operation of glibc's malloc, this write would be the first 
time this happens during the lifetime of the process.

Does that ring any bells?  Is there anything I can do to provide more 
data?  The host is an LPAR with a stock Fedora 26 kernel, so I can use 
any diagnostics tool which is provided by Fedora.

I can try to come up with a better reproducer, but that appears to be 
difficult.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

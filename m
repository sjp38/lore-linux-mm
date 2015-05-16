Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id B7EED6B006E
	for <linux-mm@kvack.org>; Sat, 16 May 2015 13:01:56 -0400 (EDT)
Received: by wguv19 with SMTP id v19so84191418wgu.1
        for <linux-mm@kvack.org>; Sat, 16 May 2015 10:01:56 -0700 (PDT)
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id el1si3744219wib.120.2015.05.16.10.01.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 May 2015 10:01:55 -0700 (PDT)
Received: by wgbhc8 with SMTP id hc8so112533506wgb.3
        for <linux-mm@kvack.org>; Sat, 16 May 2015 10:01:54 -0700 (PDT)
MIME-Version: 1.0
From: Leon Romanovsky <leon@leon.nu>
Date: Sat, 16 May 2015 20:01:33 +0300
Message-ID: <CALq1K=KSkPB9LY__rh04ic_rv2H0rGCLNfeKoY-+U2=EF32sBg@mail.gmail.com>
Subject: [RFC] Refactor kenter/kleave/kdebug macros
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-cachefs@redhat.com, linux-afs@lists.infradead.org

Dear David,

During my work on NOMMU system (mm/nommu.c), I saw definition and
usage of kenter/kleave/kdebug macros. These macros are compiled as
empty because of "#if 0" construction.
  45 #if 0
  46 #define kenter(FMT, ...) \
  47         printk(KERN_DEBUG "==> %s("FMT")\n", __func__, ##__VA_ARGS__)
  48 #define kleave(FMT, ...) \
  49         printk(KERN_DEBUG "<== %s()"FMT"\n", __func__, ##__VA_ARGS__)
  50 #define kdebug(FMT, ...) \
  51         printk(KERN_DEBUG "xxx" FMT"yyy\n", ##__VA_ARGS__)
  52 #else
  53 #define kenter(FMT, ...) \
  54         no_printk(KERN_DEBUG "==> %s("FMT")\n", __func__, ##__VA_ARGS__)
  55 #define kleave(FMT, ...) \
  56         no_printk(KERN_DEBUG "<== %s()"FMT"\n", __func__, ##__VA_ARGS__)
  57 #define kdebug(FMT, ...) \
  58         no_printk(KERN_DEBUG FMT"\n", ##__VA_ARGS__)
  59 #endif

This code was changed in 2009 [1] and similar definitions can be found
in 9 other files [2]. The protection of these definitions is slightly
different. There are places with "#if 0" protection and others with
"#if defined(__KDEBUG)" protection. __KDEBUG is supposed to be
inserted by GCC.

My question is how we should handle such duplicated debug print code?
As possible solutions, I see five options:
1. Leave it as is.
2. Move it to general include file (for example linux/printk.h) and
commonize the output to be consistent between different kdebug users.
3. Add CONFIG_*_DEBUG definition for every kdebug user.
4. Move everything to "#if 0" construction.
5. Move everything to "#if defined(__KDEBUG)" construction.

What do you think?

[1]     commit 8feae13110d60cc6287afabc2887366b0eb226c2
        Author: David Howells <dhowells@redhat.com>
        Date:   Thu Jan 8 12:04:47 2009 +0000

[2] List of all files there kdebug was defined:
* arch/mn10300/kernel/mn10300-serial.c
* arch/mn10300/mm/misalignment.c
* fs/cachefiles/internal.h
* fs/afs/internal.h
* fs/fscache/internal.h
* fs/binfmt_elf_fdpic.c
* kernel/cred.c
* mm/nommu.c
* net/rxrpc/ar-internal.h
* security/keys/internal.h

Thank you.

-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

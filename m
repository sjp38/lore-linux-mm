Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 35E7E6B0032
	for <linux-mm@kvack.org>; Sat, 13 Dec 2014 11:06:09 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id uy5so12404763obc.4
        for <linux-mm@kvack.org>; Sat, 13 Dec 2014 08:06:08 -0800 (PST)
Received: from mail-ob0-x232.google.com (mail-ob0-x232.google.com. [2607:f8b0:4003:c01::232])
        by mx.google.com with ESMTPS id i1si2821160oej.88.2014.12.13.08.06.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 13 Dec 2014 08:06:08 -0800 (PST)
Received: by mail-ob0-f178.google.com with SMTP id gq1so12355852obb.9
        for <linux-mm@kvack.org>; Sat, 13 Dec 2014 08:06:07 -0800 (PST)
MIME-Version: 1.0
Date: Sun, 14 Dec 2014 00:06:07 +0800
Message-ID: <CAAh6nknX5=8ucX_ObxB+_Dy9NCmTgNH1QRhQFKxJ+pgbDsRRaw@mail.gmail.com>
Subject: [Question] Crash of kmem_cache_cpu->freelist access
From: Gavin Guo <tuffkidtt@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, penberg@kernel.org, cl@linux.com, mpm@selenic.com

Hi all,

I'm currently debugging a bug and found out the problem is the general
protection fault of the following access:

static inline void *get_freepointer(struct kmem_cache *s, void *object)
{
        return *(void **)(object + s->offset);
}

I tried to disassembly and found that the object is from c->freelist
and it has an abnormal value which caused the fault. My first thought
is to try to add slub_debug in the kernel command line. But, the
kernel is a production kernel and may not have the chance to add
kernel parameters. The other way is to "echo 1 >
/sys/kernel/slab/<object name>/poison." But, I found the allocation is
bound to kmalloc-1024. So, it may not have a chance to enable the
sysfs poison debugging.

I tried to debug for a long time and can't find any clue. Is there
anyone has efficient debugging methods to deal with the c->freelist
crashing if the slub_debug doesn't have a chance to be added to kernel
parameters.

Really thanks for your time reading the mail.

Thanks,
Tuffkid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

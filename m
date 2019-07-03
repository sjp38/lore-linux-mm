Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA565C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 19:30:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E03121882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 19:30:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YQyWD/vN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E03121882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E261A8E001C; Wed,  3 Jul 2019 15:30:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD6B58E0019; Wed,  3 Jul 2019 15:30:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC5808E001C; Wed,  3 Jul 2019 15:30:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 647E88E0019
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 15:30:46 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id r16so836562lja.9
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 12:30:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9CmDxCKQYXxEUXl00mBOezRpaXCu6nbIOQWdySvPJK4=;
        b=bnfLrTKJIzMT4DMcricSmtZ/WHGjmDSSrRsGW3hL8K3d8FAzReGp5DHdRzqUnGjRYi
         yC8eDFKyooVtv9DLhevO1VglMlrx285/iGaVeJ2gDZvZ48yR8xHD3PIekmpxlhDYVVqx
         7sgP1VZKmcfxYxatyRfKUNC8w7UZ5wRoNCJqGmRONFJ8DnEP6liQl0FTK7t45TOPkUs0
         uA0MzeVyXedXXyfAk8P+nvS7x+THfRy96nSGd7wqbkdazZURLj/Kc0Mmz41GDPBwvoA/
         xLe423WM1KwjluVDwSZvdYcw+AQuH4h7b4ne99b+2hhvuJXKxs9aPb8+nxdeyoppCDwp
         I9tA==
X-Gm-Message-State: APjAAAWtQtw+obxbCRW6Wg7d4XvkeMrVfluhyeR5j00UgRVZP1G+YtjG
	F90r2vETevJRdT0dfAINq8S+XKbtLQ8Dfg8PH79vkNi+ZkGBUvw6+UgOusD/I+PlTbER9VdEP5u
	kM6tsfgFbvmbLxPvmeamgk1SVuHc1daI5XCOflBYlSwVXLwnyZiRiKkj9BLvR+FANWA==
X-Received: by 2002:ac2:4202:: with SMTP id y2mr18669009lfh.178.1562182245598;
        Wed, 03 Jul 2019 12:30:45 -0700 (PDT)
X-Received: by 2002:ac2:4202:: with SMTP id y2mr18668981lfh.178.1562182244412;
        Wed, 03 Jul 2019 12:30:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562182244; cv=none;
        d=google.com; s=arc-20160816;
        b=XjKNMXmaXNqIH8aNFRzU3v+UrqALNLSQ+5QS3ZMAYHsCG7ROBvSU25aKIM0sr+ierS
         U7zrrw9Co2rNx6SIoPRxpFcB8550d12sy5c+LzF1V8a6FHMwOJJqmnAraEjqLT1vc3nM
         EWOoEMqVo9GU4j/+aN9MLXPPcydxG5lCNrJHJgrjWr95pVNaOnDPBzQXnlli7ytUkTwe
         DOOxKZxt0gJLjR8nzFhyffb9b84AYpyu9imKerWHUzKI33v+a55zjx456AOefLRIkWHa
         4p1uNVZXgjXPq+rZT8tRXaf7iUX3amEjYdg25S0RQo1nenNG38FpQGuC90cNADO0/ImQ
         IrUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=9CmDxCKQYXxEUXl00mBOezRpaXCu6nbIOQWdySvPJK4=;
        b=MH0DolVuxsW7EaqKmIiyDQ+1781SNVhA7w1iJk1GfpY0GwlRoiuV5DdTZm7SamisQl
         73cgENCWB2IenyG1VzvXnJF9hF/Qu8VIFfBTBRxip2kDq4e3EcxX+6QKRLE7FIbbZYLl
         HL5IxE1AmayjjV5HT31Cil7OI1DzN4AGRiQWDcIeJb2cMrZiH8C0QalCbfHkhaQDaDTD
         p8dVW9Tb/00rEso2LXfNEURcBo88/BDVlA+YV0AIqgIr/yDnjna07Riw7nMpX5bhQtwm
         JVF44h2yHep311db/3NaX6jqqHEmqn+ntcViy03AfLRbI+TePIU6JOjEUdQPCtn2GE07
         8TIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="YQyWD/vN";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17sor2021781lji.23.2019.07.03.12.30.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 12:30:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="YQyWD/vN";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9CmDxCKQYXxEUXl00mBOezRpaXCu6nbIOQWdySvPJK4=;
        b=YQyWD/vNgsVrsv6QlOobbz8ejlwTlhBqfvpirCdpa2xlgKKnJ8YphGsHkB+XnBdN2z
         +FfwEZlhwEk5DIX23BhDSsi0lBorULxuJkBhL4Ixtry5eu8OeN91Lwbm+HSPT+dMP6wt
         /svvtLLAEeHAG4IWsUujrqkWn3EkyU1D+Lw4OPZa81piIPRwv3yBtyBWqiTeawCN4O/q
         fW87jJr0ohQ2yozuZiXvEK4YY9nGofwJHTw4qfRBXD+qdHOZs7havgR11/Y5WJJb2JBz
         5SRybwL6XPNBjdYKrpiZ+BpsTfOtYfAbuhoZVCcUskiP6ToINDRfymIURYRz2bjjoTi5
         ogzA==
X-Google-Smtp-Source: APXvYqw44hXYdu3Xcop44tGS7RQFAqW4AGPiwHHgE5Rihlhmh4wp+rmCIel3wwsgfmK35sbQ0aqUJA==
X-Received: by 2002:a2e:9b03:: with SMTP id u3mr22187395lji.15.1562182243894;
        Wed, 03 Jul 2019 12:30:43 -0700 (PDT)
Received: from pc636 (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id y5sm635525ljj.5.2019.07.03.12.30.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Jul 2019 12:30:43 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Wed, 3 Jul 2019 21:30:35 +0200
To: Pengfei Li <lpf.vector@gmail.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, urezki@gmail.com,
	rpenyaev@suse.de, mhocko@suse.com, guro@fb.com,
	aryabinin@virtuozzo.com, rppt@linux.ibm.com, mingo@kernel.org,
	rick.p.edgecombe@intel.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/5] mm/vmalloc.c: improve readability and rewrite
 vmap_area
Message-ID: <20190703193035.xsbdspgeiwzoo7aa@pc636>
References: <20190702141541.12635-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190702141541.12635-1-lpf.vector@gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Li.

> 
> v1 -> v2:
> * patch 3: Rename __find_vmap_area to __search_va_in_busy_tree
>            instead of __search_va_from_busy_tree.
> * patch 5: Add motivation and necessary test data to the commit
>            message.
> * patch 5: Let va->flags use only some low bits of va_start
>            instead of completely overwriting va_start.
> 
> 
> The current implementation of struct vmap_area wasted space. At the
> determined stage, not all members of the structure will be used.
> 
> For this problem, this commit places multiple structural members that
> are not being used at the same time into a union to reduce the size
> of the structure.
> 
> And local test results show that this commit will not hurt performance.
> 
> After applying this commit, sizeof(struct vmap_area) has been reduced
> from 11 words to 8 words.
> 
> Pengfei Li (5):
>   mm/vmalloc.c: Introduce a wrapper function of insert_vmap_area()
>   mm/vmalloc.c: Introduce a wrapper function of
>     insert_vmap_area_augment()
>   mm/vmalloc.c: Rename function __find_vmap_area() for readability
>   mm/vmalloc.c: Modify function merge_or_add_vmap_area() for readability
>   mm/vmalloc.c: Rewrite struct vmap_area to reduce its size
> 
>  include/linux/vmalloc.h |  28 +++++---
>  mm/vmalloc.c            | 139 ++++++++++++++++++++++++++++------------
>  2 files changed, 118 insertions(+), 49 deletions(-)
> 
> -- 
> 2.21.0
> 
I do not think that it is worth to reduce the struct size the way
this series does. I mean the union around flags/va_start. Simply saying
if we need two variables: flags and va_start let's have them. Otherwise
everybody has to think what he/she access at certain moment of time.

So it would be easier to make mistakes, also that conversion looks strange
to me. That is IMHO.

If we want to reduce the size to L1-cache-line(64 bytes), i would propose to
eliminate the "flags" variable from the structure. We could do that if apply
below patch(as an example) on top of https://lkml.org/lkml/2019/7/3/661:

<snip>
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 51e131245379..49bb82863d5b 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -51,15 +51,22 @@ struct vmap_area {
        unsigned long va_start;
        unsigned long va_end;

-       /*
-        * Largest available free size in subtree.
-        */
-       unsigned long subtree_max_size;
-       unsigned long flags;
        struct rb_node rb_node;         /* address sorted rbtree */
        struct list_head list;          /* address sorted list */
-       struct llist_node purge_list;    /* "lazy purge" list */
-       struct vm_struct *vm;
+
+       /*
+        * Below three variables can be packed, because vmap_area
+        * object can be only in one of the three different states:
+        *
+        * - when an object is in "free" tree only;
+        * - when an object is in "purge list" only;
+        * - when an object is in "busy" tree only.
+        */
+       union {
+               unsigned long subtree_max_size;
+               struct llist_node purge_list;
+               struct vm_struct *vm;
+       };
 };

 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 6f1b6a188227..e389a6db222b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -329,8 +329,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
 #define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0

-#define VM_VM_AREA     0x04
-
 static DEFINE_SPINLOCK(vmap_area_lock);
 /* Export for kexec only */
 LIST_HEAD(vmap_area_list);
@@ -1108,7 +1106,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,

        va->va_start = addr;
        va->va_end = addr + size;
-       va->flags = 0;
+       va->vm = NULL;
        insert_vmap_area(va, &vmap_area_root, &vmap_area_list);

        spin_unlock(&vmap_area_lock);
@@ -1912,7 +1910,6 @@ void __init vmalloc_init(void)
                if (WARN_ON_ONCE(!va))
                        continue;

-               va->flags = VM_VM_AREA;
                va->va_start = (unsigned long)tmp->addr;
                va->va_end = va->va_start + tmp->size;
                va->vm = tmp;
@@ -2010,7 +2007,6 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
        vm->size = va->va_end - va->va_start;
        vm->caller = caller;
        va->vm = vm;
-       va->flags |= VM_VM_AREA;
        spin_unlock(&vmap_area_lock);
 }

@@ -2115,7 +2111,7 @@ struct vm_struct *find_vm_area(const void *addr)
        struct vmap_area *va;

        va = find_vmap_area((unsigned long)addr);
-       if (va && va->flags & VM_VM_AREA)
+       if (va && va->vm)
                return va->vm;

        return NULL;
@@ -2139,11 +2135,10 @@ struct vm_struct *remove_vm_area(const void *addr)

        spin_lock(&vmap_area_lock);
        va = __find_vmap_area((unsigned long)addr);
-       if (va && va->flags & VM_VM_AREA) {
+       if (va && va->vm) {
                struct vm_struct *vm = va->vm;

                va->vm = NULL;
-               va->flags &= ~VM_VM_AREA;
                spin_unlock(&vmap_area_lock);

                kasan_free_shadow(vm);
@@ -2854,7 +2849,7 @@ long vread(char *buf, char *addr, unsigned long count)
                if (!count)
                        break;

-               if (!(va->flags & VM_VM_AREA))
+               if (!va->vm)
                        continue;

                vm = va->vm;
@@ -2934,7 +2929,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
                if (!count)
                        break;

-               if (!(va->flags & VM_VM_AREA))
+               if (!va->vm)
                        continue;

                vm = va->vm;
@@ -3464,10 +3459,10 @@ static int s_show(struct seq_file *m, void *p)
        va = list_entry(p, struct vmap_area, list);

        /*
-        * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
-        * behalf of vmap area is being tear down or vm_map_ram allocation.
+        * s_show can encounter race with remove_vm_area, !vm on behalf
+        * of vmap area is being tear down or vm_map_ram allocation.
         */
-       if (!(va->flags & VM_VM_AREA)) {
+       if (!va->vm) {
                seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
                        (void *)va->va_start, (void *)va->va_end,
                        va->va_end - va->va_start);
<snip>

urezki@pc636:~/data/ssd/coding/linux-stable$ pahole -C vmap_area mm/vmalloc.o
die__process_function: tag not supported (INVALID)!
struct vmap_area {
        long unsigned int          va_start;             /*     0     8 */
        long unsigned int          va_end;               /*     8     8 */
        struct rb_node             rb_node;              /*    16    24 */
        struct list_head           list;                 /*    40    16 */
        union {
                long unsigned int  subtree_max_size;     /*           8 */
                struct llist_node  purge_list;           /*           8 */
                struct vm_struct * vm;                   /*           8 */
        };                                               /*    56     8 */
        /* --- cacheline 1 boundary (64 bytes) --- */

        /* size: 64, cachelines: 1, members: 5 */
};
urezki@pc636:~/data/ssd/coding/linux-stable$

--
Vlad Rezki


Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B0CFC06517
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 09:31:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27F7B218A3
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 09:31:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PRsVmLHY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27F7B218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 741756B0003; Thu,  4 Jul 2019 05:31:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CB608E0003; Thu,  4 Jul 2019 05:31:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56B2F8E0001; Thu,  4 Jul 2019 05:31:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA216B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 05:31:18 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id l7so2504956otj.16
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 02:31:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=81qzDNnuUWXeeKG5ggbworMMEY0MTN6GujxFNt/FSKY=;
        b=WN0slCb22b+OGxtfYxJjQH26YeU/DHNhuIR654JLOEZvvhmp/p3aU8X/k3IZ/uk2lK
         JuRHMmugxyQTHvZ6k0LzXH9sifZsfshrs0IX/dZn9UaAy9ekbS4L43lKUSK2c1vVTK2p
         i9vnn5002RVNFMwEa+qs4zfHAesIDFOt4UVP/fYjp00TzAXGvwTwFa5pfskmfoyCIHma
         jAtUIsacv82hYmOFCSJDgVUYMIq2/+ydx4nR2hYOTEnCmLb2O17V3muB9/qdZJ423jtO
         q6n2GEw2QgZMUpQnAeOa0M3eIAlBwJXya8MceDqDVjS78cK9KTWd9Dh3hC0hzAi8cd9V
         w5/w==
X-Gm-Message-State: APjAAAWnmuqaNAWwYGYO8xx8JtYRg/txEObDJI8m+/fOmmwlSH0cnukw
	DH/AvJsxhY5+OpraMXMcLwq5xqpMZUf0YUwXooy1BMZ6Ko3SR9MMKQWgkKTMAzBRhqNZ+Og4R9H
	1fKtBbSQ6RWi/YTLIe5NSIpVXouEJnHyON5WfnHBP7emQvOZwvj3ToO0UClEHWz/ALQ==
X-Received: by 2002:a54:4109:: with SMTP id l9mr1349496oic.93.1562232677661;
        Thu, 04 Jul 2019 02:31:17 -0700 (PDT)
X-Received: by 2002:a54:4109:: with SMTP id l9mr1349437oic.93.1562232676412;
        Thu, 04 Jul 2019 02:31:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562232676; cv=none;
        d=google.com; s=arc-20160816;
        b=jKe6HgfjWcswth2LtukBuhzMb7+/Mt1zqtN2xri3X73RfS/ZSFn5FWQ7vGVgVCC6EB
         D527LPbF/3iM7niTEQjcWHqgC1XOZFkZy47U9bP/xxsU5o+3NOp0207nIK7puOEtb9tc
         ddEfa5UHjOGi1Aj0JIDGkH29oVbfKSmKq5MhUo67cp29wiE/o3jxQsGDzoAI3Own/Hfp
         mbDa/MCeHW8StHCSt7dRbUHZEu7wLA3a/LctgbSvYYADgIS9TrmznnFc49jetpAbhiEf
         gCy5L1ya67wlmYwhNwbKRcH8x2HjS6YHOSA7pUhcxpiYkppzJRgyYpAC41UqGOLuHQnq
         u0oQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=81qzDNnuUWXeeKG5ggbworMMEY0MTN6GujxFNt/FSKY=;
        b=Ph7Kuk4QHXQAgeNDfP6K99mEd8OS7rlZvwfqm0m7JVglmE/YZs3v+o7R81+QX1zt6k
         vRpcvE8LqgyA9nOgEPvi7rWv8mSIfCCYHma+cEILOCWXBbDzAk4ztRmwlnlpoj1vbwpH
         eGs6IX8U2fsWIWPbaCux0cwhqmIpBFVHBFoTp5fZWJnYT7TQYUeKCkyNx+KmgOAqxRxR
         dCBrOOYcbchIC9ppDeG11Vq76lle+2ghIUecs+PcnOa4cD9IGKOjVnHTZGlNmCDmOIFS
         u8lt5gRvLdgy0t5mCBZM72MWNX1yWfljSUxxZNeMNxugrdiI/6MAQ4XMqYRYwEQJJsmf
         UgsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PRsVmLHY;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p5sor2629787otk.184.2019.07.04.02.31.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Jul 2019 02:31:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PRsVmLHY;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=81qzDNnuUWXeeKG5ggbworMMEY0MTN6GujxFNt/FSKY=;
        b=PRsVmLHYYokfq1dAWNfZbXfAw/fqsNWpYh3uV3l/g68KONC8Oig3Sq4ok+8fTFtb5U
         m+mMKk5caDAp/3QjJdljekiK+pC03tUk9uzWYWGlbECBUWbnXDWLCrWKkjj6hsOFkJPl
         ZTIyCBDVxixFNks3FPtXldjqjaKC1fuAa4yZvkt0NAA/xnnSLgKbQfFc/SpDLKLp3yCa
         ZAprvC57Z2fcGxs5K5pTV/11h4CUBUOSKL2Snp4snyHsIzWabfThd2nU2EZ0v8sIKfqd
         Gif5b2UOxVPVAFJfMdsNCR0MMcPcidSeRlU8w86XXkIkEHtNxOT2tptV5Ajrr1flg7Gd
         qmYQ==
X-Google-Smtp-Source: APXvYqze2xsXujbeNbNbw8cpCmEutfUMYGbnvnrymsCSndKtBHHCMeJ+vzrksgLBW9mRoeVoAJvFhadPs958WKD3LiY=
X-Received: by 2002:a9d:73c4:: with SMTP id m4mr15813610otk.369.1562232675969;
 Thu, 04 Jul 2019 02:31:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190702141541.12635-1-lpf.vector@gmail.com> <20190703193035.xsbdspgeiwzoo7aa@pc636>
In-Reply-To: <20190703193035.xsbdspgeiwzoo7aa@pc636>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Thu, 4 Jul 2019 17:31:04 +0800
Message-ID: <CAD7_sbFi+KY-pH+2RZTq29qpBukvqZcC0xuB-7EJ_WNPP84bjQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/5] mm/vmalloc.c: improve readability and rewrite vmap_area
To: Uladzislau Rezki <urezki@gmail.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, rpenyaev@suse.de, 
	mhocko@suse.com, guro@fb.com, aryabinin@virtuozzo.com, rppt@linux.ibm.com, 
	mingo@kernel.org, rick.p.edgecombe@intel.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 4, 2019 at 3:30 AM Uladzislau Rezki <urezki@gmail.com> wrote:
>
> Hello, Li.
>
> I do not think that it is worth to reduce the struct size the way
> this series does. I mean the union around flags/va_start. Simply saying
> if we need two variables: flags and va_start let's have them. Otherwise
> everybody has to think what he/she access at certain moment of time.
>
> So it would be easier to make mistakes, also that conversion looks strange
> to me. That is IMHO.
>
> If we want to reduce the size to L1-cache-line(64 bytes), i would propose to
> eliminate the "flags" variable from the structure. We could do that if apply
> below patch(as an example) on top of https://lkml.org/lkml/2019/7/3/661:
>

Hi, Vlad

Thank you for your detailed comments!

What you said inspired me. I really have no reason to stubbornly
keep the "flags" in vmap_area since it can be eliminated.

I will eliminate the "flags" from vmap_area as you suggested, and
the next version will be based on top of your commit
https://lkml.org/lkml/2019/7/3/661.


-- 
Pengfei

> <snip>
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 51e131245379..49bb82863d5b 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -51,15 +51,22 @@ struct vmap_area {
>         unsigned long va_start;
>         unsigned long va_end;
>
> -       /*
> -        * Largest available free size in subtree.
> -        */
> -       unsigned long subtree_max_size;
> -       unsigned long flags;
>         struct rb_node rb_node;         /* address sorted rbtree */
>         struct list_head list;          /* address sorted list */
> -       struct llist_node purge_list;    /* "lazy purge" list */
> -       struct vm_struct *vm;
> +
> +       /*
> +        * Below three variables can be packed, because vmap_area
> +        * object can be only in one of the three different states:
> +        *
> +        * - when an object is in "free" tree only;
> +        * - when an object is in "purge list" only;
> +        * - when an object is in "busy" tree only.
> +        */
> +       union {
> +               unsigned long subtree_max_size;
> +               struct llist_node purge_list;
> +               struct vm_struct *vm;
> +       };
>  };
>
>  /*
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 6f1b6a188227..e389a6db222b 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -329,8 +329,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
>  #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
>  #define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
>
> -#define VM_VM_AREA     0x04
> -
>  static DEFINE_SPINLOCK(vmap_area_lock);
>  /* Export for kexec only */
>  LIST_HEAD(vmap_area_list);
> @@ -1108,7 +1106,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>
>         va->va_start = addr;
>         va->va_end = addr + size;
> -       va->flags = 0;
> +       va->vm = NULL;
>         insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
>
>         spin_unlock(&vmap_area_lock);
> @@ -1912,7 +1910,6 @@ void __init vmalloc_init(void)
>                 if (WARN_ON_ONCE(!va))
>                         continue;
>
> -               va->flags = VM_VM_AREA;
>                 va->va_start = (unsigned long)tmp->addr;
>                 va->va_end = va->va_start + tmp->size;
>                 va->vm = tmp;
> @@ -2010,7 +2007,6 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
>         vm->size = va->va_end - va->va_start;
>         vm->caller = caller;
>         va->vm = vm;
> -       va->flags |= VM_VM_AREA;
>         spin_unlock(&vmap_area_lock);
>  }
>
> @@ -2115,7 +2111,7 @@ struct vm_struct *find_vm_area(const void *addr)
>         struct vmap_area *va;
>
>         va = find_vmap_area((unsigned long)addr);
> -       if (va && va->flags & VM_VM_AREA)
> +       if (va && va->vm)
>                 return va->vm;
>
>         return NULL;
> @@ -2139,11 +2135,10 @@ struct vm_struct *remove_vm_area(const void *addr)
>
>         spin_lock(&vmap_area_lock);
>         va = __find_vmap_area((unsigned long)addr);
> -       if (va && va->flags & VM_VM_AREA) {
> +       if (va && va->vm) {
>                 struct vm_struct *vm = va->vm;
>
>                 va->vm = NULL;
> -               va->flags &= ~VM_VM_AREA;
>                 spin_unlock(&vmap_area_lock);
>
>                 kasan_free_shadow(vm);
> @@ -2854,7 +2849,7 @@ long vread(char *buf, char *addr, unsigned long count)
>                 if (!count)
>                         break;
>
> -               if (!(va->flags & VM_VM_AREA))
> +               if (!va->vm)
>                         continue;
>
>                 vm = va->vm;
> @@ -2934,7 +2929,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
>                 if (!count)
>                         break;
>
> -               if (!(va->flags & VM_VM_AREA))
> +               if (!va->vm)
>                         continue;
>
>                 vm = va->vm;
> @@ -3464,10 +3459,10 @@ static int s_show(struct seq_file *m, void *p)
>         va = list_entry(p, struct vmap_area, list);
>
>         /*
> -        * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
> -        * behalf of vmap area is being tear down or vm_map_ram allocation.
> +        * s_show can encounter race with remove_vm_area, !vm on behalf
> +        * of vmap area is being tear down or vm_map_ram allocation.
>          */
> -       if (!(va->flags & VM_VM_AREA)) {
> +       if (!va->vm) {
>                 seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
>                         (void *)va->va_start, (void *)va->va_end,
>                         va->va_end - va->va_start);
> <snip>
>
> urezki@pc636:~/data/ssd/coding/linux-stable$ pahole -C vmap_area mm/vmalloc.o
> die__process_function: tag not supported (INVALID)!
> struct vmap_area {
>         long unsigned int          va_start;             /*     0     8 */
>         long unsigned int          va_end;               /*     8     8 */
>         struct rb_node             rb_node;              /*    16    24 */
>         struct list_head           list;                 /*    40    16 */
>         union {
>                 long unsigned int  subtree_max_size;     /*           8 */
>                 struct llist_node  purge_list;           /*           8 */
>                 struct vm_struct * vm;                   /*           8 */
>         };                                               /*    56     8 */
>         /* --- cacheline 1 boundary (64 bytes) --- */
>
>         /* size: 64, cachelines: 1, members: 5 */
> };
> urezki@pc636:~/data/ssd/coding/linux-stable$
>
> --
> Vlad Rezki


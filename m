Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17E77C76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:58:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF1D920880
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:58:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bDj3lwrm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF1D920880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47A078E0007; Tue, 16 Jul 2019 11:58:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 402D78E0006; Tue, 16 Jul 2019 11:58:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CAF28E0007; Tue, 16 Jul 2019 11:58:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD0AC8E0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 11:58:39 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id v13so1850416lfa.20
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:58:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XQ410IUsZxin0lRODEmBFRGZWq/RPTQwE6XaaTIWCEA=;
        b=DK17SPsduvL21Pe3SdRNkjx3mHc5jyI/DXNjiRs1cjAksF7etXxBy0qnIbNVRO1L79
         V5aHfW3tUvnnLADaoVjMPlcaMUytJeMPlG2Kn6NgkMqZiy9dAHlcKvvWnJOJiWVlWOdv
         IYkHMOUjbIZmmlR07IVgg2xgFPZCdo+6J34kevHri7if3VmIf7iTnoY6t9a16LA4uDCw
         pvi0ixjYUpFoycGKdt3ClPhSSJGXFM7q4erRcZmB+GFZmw2CNmwSxyjekUotkxomeoSo
         oVSRERW5+7tYKLgBEeH/xk/c8MQNGjvk0a/1rupurWtCQK9cE7cRNzuaeZ/DYBB10c3Y
         TXOQ==
X-Gm-Message-State: APjAAAV8Z72GrNuelJ4Q7xxBbxsD2lprOewpNpEWZDQKX1m+ym7l3zvB
	eAtyLADNwcXyHGkXC+t90abEAmwr9yg5WWXQY/i1jrh3+rVBIopcqFFe8EaInchpVNg+taBl+e+
	3Q7EB9AFWYAsSx/jfUkeN4t9JaPJt97nqcfOsnyuf9uyqV2sgDnKI+zNrqPF+UMK8YA==
X-Received: by 2002:a2e:3013:: with SMTP id w19mr17998313ljw.73.1563292718794;
        Tue, 16 Jul 2019 08:58:38 -0700 (PDT)
X-Received: by 2002:a2e:3013:: with SMTP id w19mr17998273ljw.73.1563292717859;
        Tue, 16 Jul 2019 08:58:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563292717; cv=none;
        d=google.com; s=arc-20160816;
        b=o4GV6oyJPUIVgin5LpHtIbL8kOzqOHjGv6j0LBMImQXMFID8Xw0u+2eVa1DDE7H/X1
         +KupzH2pRlEHazG5WbWjjeaAXo4EmXD5vn/sVKvutGKk7fm6gSJ3lPijYrdxzecAH7fE
         LqABUtDd+Te5i0chsMh0y5W3a7g4USrA8H7lU8kIUPlXUt3umRbkXyGsiWlwa+0wYgC4
         g7I0TAtV8FMyKGO89ChiNsbNWdZ+2oUWHT92uAtD5UnK0qRNW3Gez34qK6kN2fKP0RcF
         AYVYClWnA73fCxFjaRVsoW9x08uiLZNF0z9IGCoQxS1MTd4h8T8c+dKOBfI6xq51heKQ
         9ezQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=XQ410IUsZxin0lRODEmBFRGZWq/RPTQwE6XaaTIWCEA=;
        b=g7ux6Oy86sEQ2vFRx3RG7JaNhqVtkGCpweiULfB4jtfstbmJfGsmYGKjrzQMiVuhnz
         AxQJIC0vXQOYDdfJ0Z4h+1xWBhpeGlqJEV+nXx87KNrsYh/VafvczBwoeb2DgdnoIq/3
         vGLvLmbQFOufh3gKT8c2RTTkD3/SRCnajOjyUWHboqUpCFXHkIDpaiZdF2Q08rjQHk6x
         EIzwlUKKjEuKUr+18S1F/4wiInWAA5+Q6Z9ne6AbeCoBk9VUyDmWGIBh5RHF6YRQP0On
         OF85kJPga6Sr2eavoJShhsCsspYWCyhpEuy3hy9MhzooQdbuiIrx51xkK92tFlU/Henn
         xjyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bDj3lwrm;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k90sor11769153lje.4.2019.07.16.08.58.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 08:58:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bDj3lwrm;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=XQ410IUsZxin0lRODEmBFRGZWq/RPTQwE6XaaTIWCEA=;
        b=bDj3lwrmaFpxNyQK2qAgblH+qScOy6wvDRBKuQmIo9xXYIIRIKYe8yCti20qp+sBMQ
         vR5gcelSC96/R8Nw9+lAF3K5OXHJHj/567AJx8Maoz9lw4K5kzwSNskmjRRxVoGeVjCA
         Q5nIRbojMw5Xj4WrZzTvc+i9ujglezIdEHC42amyCVAWlV8jsCs/DeeSgklmmOm7QlyS
         /n5dfkqhNjeyRRkGKjS+/amF7qdf6kPz85pY4J00exm0lSe7gDO6oNO/hprM6dPE2ZmS
         QZjYWNoz5Kd8ztvkSpTgTcENkVCBWXejmoEPb0mExP25awBR7Y3bfpYtm3iqB+UpHHXw
         hJPQ==
X-Google-Smtp-Source: APXvYqx4O4YL/HwVrYmVuGlLH9FEYLvY42UH1KiM+psjSzG/ll6t382D5c9edjlsPR08mwxaUrWfBg==
X-Received: by 2002:a05:651c:21c:: with SMTP id y28mr1031225ljn.187.1563292717243;
        Tue, 16 Jul 2019 08:58:37 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id z12sm2922304lfg.67.2019.07.16.08.58.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Jul 2019 08:58:36 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Tue, 16 Jul 2019 17:58:29 +0200
To: Pengfei Li <lpf.vector@gmail.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, urezki@gmail.com,
	rpenyaev@suse.de, peterz@infradead.org, guro@fb.com,
	rick.p.edgecombe@intel.com, rppt@linux.ibm.com,
	aryabinin@virtuozzo.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v6 2/2] mm/vmalloc: modify struct vmap_area to reduce its
 size
Message-ID: <20190716155829.zdrzadrmwxrkfkro@pc636>
References: <20190716152656.12255-1-lpf.vector@gmail.com>
 <20190716152656.12255-3-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190716152656.12255-3-lpf.vector@gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 11:26:56PM +0800, Pengfei Li wrote:
> Objective
> ---------
> The current implementation of struct vmap_area wasted space.
> 
> After applying this commit, sizeof(struct vmap_area) has been
> reduced from 11 words to 8 words.
> 
> Description
> -----------
> 1) Pack "subtree_max_size", "vm" and "purge_list".
> This is no problem because
>     A) "subtree_max_size" is only used when vmap_area is in
>        "free" tree
>     B) "vm" is only used when vmap_area is in "busy" tree
>     C) "purge_list" is only used when vmap_area is in
>        vmap_purge_list
> 
> 2) Eliminate "flags".
> Since only one flag VM_VM_AREA is being used, and the same
> thing can be done by judging whether "vm" is NULL, then the
> "flags" can be eliminated.
> 
> Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
> Suggested-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> ---
>  include/linux/vmalloc.h | 20 +++++++++++++-------
>  mm/vmalloc.c            | 24 ++++++++++--------------
>  2 files changed, 23 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 9b21d0047710..a1334bd18ef1 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -51,15 +51,21 @@ struct vmap_area {
>  	unsigned long va_start;
>  	unsigned long va_end;
>  
> -	/*
> -	 * Largest available free size in subtree.
> -	 */
> -	unsigned long subtree_max_size;
> -	unsigned long flags;
>  	struct rb_node rb_node;         /* address sorted rbtree */
>  	struct list_head list;          /* address sorted list */
> -	struct llist_node purge_list;    /* "lazy purge" list */
> -	struct vm_struct *vm;
> +
> +	/*
> +	 * The following three variables can be packed, because
> +	 * a vmap_area object is always one of the three states:
> +	 *    1) in "free" tree (root is vmap_area_root)
> +	 *    2) in "busy" tree (root is free_vmap_area_root)
> +	 *    3) in purge list  (head is vmap_purge_list)
> +	 */
> +	union {
> +		unsigned long subtree_max_size; /* in "free" tree */
> +		struct vm_struct *vm;           /* in "busy" tree */
> +		struct llist_node purge_list;   /* in purge list */
> +	};
>  };
>  
>  /*
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 71d8040a8a0b..2f7edc0466e7 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -329,7 +329,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
>  #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
>  #define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
>  
> -#define VM_VM_AREA	0x04
>  
>  static DEFINE_SPINLOCK(vmap_area_lock);
>  /* Export for kexec only */
> @@ -1115,7 +1114,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>  
>  	va->va_start = addr;
>  	va->va_end = addr + size;
> -	va->flags = 0;
> +	va->vm = NULL;
>  	insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
>  
>  	spin_unlock(&vmap_area_lock);
> @@ -1922,7 +1921,6 @@ void __init vmalloc_init(void)
>  		if (WARN_ON_ONCE(!va))
>  			continue;
>  
> -		va->flags = VM_VM_AREA;
>  		va->va_start = (unsigned long)tmp->addr;
>  		va->va_end = va->va_start + tmp->size;
>  		va->vm = tmp;
> @@ -2020,7 +2018,6 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
>  	vm->size = va->va_end - va->va_start;
>  	vm->caller = caller;
>  	va->vm = vm;
> -	va->flags |= VM_VM_AREA;
>  	spin_unlock(&vmap_area_lock);
>  }
>  
> @@ -2125,10 +2122,10 @@ struct vm_struct *find_vm_area(const void *addr)
>  	struct vmap_area *va;
>  
>  	va = find_vmap_area((unsigned long)addr);
> -	if (va && va->flags & VM_VM_AREA)
> -		return va->vm;
> +	if (!va)
> +		return NULL;
>  
> -	return NULL;
> +	return va->vm;
>  }
>  
>  /**
> @@ -2149,11 +2146,10 @@ struct vm_struct *remove_vm_area(const void *addr)
>  
>  	spin_lock(&vmap_area_lock);
>  	va = __find_vmap_area((unsigned long)addr);
> -	if (va && va->flags & VM_VM_AREA) {
> +	if (va && va->vm) {
>  		struct vm_struct *vm = va->vm;
>  
>  		va->vm = NULL;
> -		va->flags &= ~VM_VM_AREA;
>  		spin_unlock(&vmap_area_lock);
>  
>  		kasan_free_shadow(vm);
> @@ -2856,7 +2852,7 @@ long vread(char *buf, char *addr, unsigned long count)
>  		if (!count)
>  			break;
>  
> -		if (!(va->flags & VM_VM_AREA))
> +		if (!va->vm)
>  			continue;
>  
>  		vm = va->vm;
> @@ -2936,7 +2932,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
>  		if (!count)
>  			break;
>  
> -		if (!(va->flags & VM_VM_AREA))
> +		if (!va->vm)
>  			continue;
>  
>  		vm = va->vm;
> @@ -3466,10 +3462,10 @@ static int s_show(struct seq_file *m, void *p)
>  	va = list_entry(p, struct vmap_area, list);
>  
>  	/*
> -	 * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
> -	 * behalf of vmap area is being tear down or vm_map_ram allocation.
> +	 * s_show can encounter race with remove_vm_area, !vm on behalf
> +	 * of vmap area is being tear down or vm_map_ram allocation.
>  	 */
> -	if (!(va->flags & VM_VM_AREA)) {
> +	if (!va->vm) {
>  		seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
>  			(void *)va->va_start, (void *)va->va_end,
>  			va->va_end - va->va_start);
> -- 
> 2.21.0
> 

This patch depends on https://lkml.org/lkml/2019/7/16/276 and looks ok
to me, so

Reviewed-by: Uladzislau Rezki (Sony) <urezki@gmail.com>

Thanks!

--
Vlad Rezki


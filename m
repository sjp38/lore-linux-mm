Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 876ADC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 11:52:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3725A21850
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 11:52:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3725A21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7ECB6B0010; Thu, 18 Apr 2019 07:52:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2E576B0266; Thu, 18 Apr 2019 07:52:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F5256B0269; Thu, 18 Apr 2019 07:52:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E53A6B0010
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:52:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id q17so1101650eda.13
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 04:52:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=gaM4oTfKphOXZKt5su/wmA6gFjIrGMw/inSv6FdYg0g=;
        b=JIa8cYd6MF7YexQl6z0N0n+x4FxmnrI3OZzKZHpKCryjxqaozu64YwfLKBQl/aRpLt
         x6uOZ+yBXA/h8umJnEOC/+GGVI1ZWagYJXFVtMYCAR50N1pYimG97O8GmFnNDaKJoRKw
         UKrtW6Xlq5XsnuDElUZpCBsqJb2Jjo5+Fx2Xv+Mrxlyx9wnvdWqu1gcmpRlBRjvXuqhP
         JlVmipKDV8d92OI5/K6Le00yBo6yE1kwov0ES+YQVhpi31VQ6N6Zxqo6MAny4mi3xMkC
         o/caqvkgEi4vk3L6/YjVugIfgcmm+c9Z0FdcgXvq/uqOeE+ae5CG7nPd0CL8cyWHZDJ2
         Znnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWOtBXivyAu4FJ7OyW/THvhTs0/aiWJOC7Lxc2GwF4Pat5Du3XL
	nNcSoXOhab464mxhPdAaqk1HmselZkB85qaxkSCg8wNxcHbN2MqupEvXE+56NgVgiw6iWAlTfq6
	WyJHQyLLCNArG3sVVSp8uFX/JzrjUpKCDlq0Bb5NiChKOIWiSD783PP3SgTb7sWSErQ==
X-Received: by 2002:a50:c201:: with SMTP id n1mr60643920edf.244.1555588333720;
        Thu, 18 Apr 2019 04:52:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjJYq4smdqVOsZu8UjoFKl7URn4Xz9uda7NHKo9ETWsCghhJoNtUxqYCZbQc+CRhenBcn6
X-Received: by 2002:a50:c201:: with SMTP id n1mr60643867edf.244.1555588332499;
        Thu, 18 Apr 2019 04:52:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555588332; cv=none;
        d=google.com; s=arc-20160816;
        b=0h9/n56s93OoAWq8XzD7PKSOICIrU3hbWt00ezk7lRi0E650vShlka4DDRvdU0Wj4x
         ocQHsWYXfgwi+C0otPKcS9vx0wZmEbgV+suWSYB7btP665ALDGE1LUNWd36P2IbXza2z
         Uvnjz9+B8LHSePevfUG/+ne+x5JNYB78FPYH333U9vjnofA07pXkpu4iq+pI/VAJnt73
         JUh/ITZlwBB7xl8oL9emhSWoeiH9xn+clPyGjwcNlG9e8TRJ1mVnd0Vtjh1X+sqb1V/m
         lzEMI39R5GXatoWZ0sTMya35fKim1h/SIxPKkOAAJ7V1qlLkkb9cTKTG3ALdRaKGBTgB
         3YyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=gaM4oTfKphOXZKt5su/wmA6gFjIrGMw/inSv6FdYg0g=;
        b=Mm0xQi1jZ3uGBbLTzaeLzFHzYe471iUbcuFc1egpWU9v9w8Qs8U5S9Ag0xuZRWc9Gn
         zZAxJfh7eWC19NB7PCEp1BY1fyyjC2p3YMY6wHx2HAEX9jnK9JhUR1ELWbC7V5BCF/Qx
         iVCqoVUbT91dqRwZCIRf0vzHzfGNpImLRqqMer+ASuLAOf3jfe+9WAxIPmtPUGUyTZE2
         7QnhVePF/9IQ0t98P9efFNKfkfkSi3cZU7QGGRP7Cpzz6myFJ+ywvKhTI+2CwVWv5qJy
         9XkLVxAWeWFjbBa2qPAbknYTfT1G+ZFs6elXHcNEvZSkQ0Jrd+AsZk/6Q7zWeYcje/jT
         qe0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u4si750176edl.359.2019.04.18.04.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 04:52:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3IBmTvd037697
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:52:11 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rxqyt257v-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:52:10 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 18 Apr 2019 12:52:07 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 18 Apr 2019 12:51:58 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3IBpvT627525222
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 18 Apr 2019 11:51:57 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 58BF2A4051;
	Thu, 18 Apr 2019 11:51:57 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AB49FA4040;
	Thu, 18 Apr 2019 11:51:54 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 18 Apr 2019 11:51:54 +0000 (GMT)
Date: Thu, 18 Apr 2019 14:51:53 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
        x86@kernel.org, Andy Lutomirski <luto@kernel.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Alexander Potapenko <glider@google.com>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
        David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Akinobu Mita <akinobu.mita@gmail.com>,
        iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
        Christoph Hellwig <hch@lst.de>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Johannes Thumshirn <jthumshirn@suse.de>,
        David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
        Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
        dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
        Alasdair Kergon <agk@redhat.com>, intel-gfx@lists.freedesktop.org,
        Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
        Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
        dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
        Jani Nikula <jani.nikula@linux.intel.com>,
        Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
        linux-arch@vger.kernel.org
Subject: Re: [patch V2 03/29] lib/stackdepot: Provide functions which operate
 on plain storage arrays
References: <20190418084119.056416939@linutronix.de>
 <20190418084253.337266121@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418084253.337266121@linutronix.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19041811-0012-0000-0000-000003103330
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041811-0013-0000-0000-000021487584
Message-Id: <20190418115152.GA13304@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-18_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=585 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904180084
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 10:41:22AM +0200, Thomas Gleixner wrote:
> The struct stack_trace indirection in the stack depot functions is a truly
> pointless excercise which requires horrible code at the callsites.
> 
> Provide interfaces based on plain storage arrays.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Acked-by: Alexander Potapenko <glider@google.com>
> ---
>  include/linux/stackdepot.h |    4 ++
>  lib/stackdepot.c           |   66 ++++++++++++++++++++++++++++++++-------------
>  2 files changed, 51 insertions(+), 19 deletions(-)
> 
> --- a/include/linux/stackdepot.h
> +++ b/include/linux/stackdepot.h
> @@ -26,7 +26,11 @@ typedef u32 depot_stack_handle_t;
>  struct stack_trace;
> 
>  depot_stack_handle_t depot_save_stack(struct stack_trace *trace, gfp_t flags);
> +depot_stack_handle_t stack_depot_save(unsigned long *entries,
> +				      unsigned int nr_entries, gfp_t gfp_flags);
> 
>  void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace);
> +unsigned int stack_depot_fetch(depot_stack_handle_t handle,
> +			       unsigned long **entries);
> 
>  #endif
> --- a/lib/stackdepot.c
> +++ b/lib/stackdepot.c
> @@ -194,40 +194,56 @@ static inline struct stack_record *find_
>  	return NULL;
>  }
> 
> -void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace)
> +/**
> + * stack_depot_fetch - Fetch stack entries from a depot
> + *

Nit: kernel-doc will complain about missing description of @handle.

> + * @entries:		Pointer to store the entries address
> + */
> +unsigned int stack_depot_fetch(depot_stack_handle_t handle,
> +			       unsigned long **entries)
>  {
>  	union handle_parts parts = { .handle = handle };
>  	void *slab = stack_slabs[parts.slabindex];
>  	size_t offset = parts.offset << STACK_ALLOC_ALIGN;
>  	struct stack_record *stack = slab + offset;
> 
> -	trace->nr_entries = trace->max_entries = stack->size;
> -	trace->entries = stack->entries;
> -	trace->skip = 0;
> +	*entries = stack->entries;
> +	return stack->size;
> +}
> +EXPORT_SYMBOL_GPL(stack_depot_fetch);
> +
> +void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace)
> +{
> +	unsigned int nent = stack_depot_fetch(handle, &trace->entries);
> +
> +	trace->max_entries = trace->nr_entries = nent;
>  }
>  EXPORT_SYMBOL_GPL(depot_fetch_stack);
> 
>  /**
> - * depot_save_stack - save stack in a stack depot.
> - * @trace - the stacktrace to save.
> - * @alloc_flags - flags for allocating additional memory if required.
> + * stack_depot_save - Save a stack trace from an array
>   *
> - * Returns the handle of the stack struct stored in depot.
> + * @entries:		Pointer to storage array
> + * @nr_entries:		Size of the storage array
> + * @alloc_flags:	Allocation gfp flags
> + *
> + * Returns the handle of the stack struct stored in depot

Can you please s/Returns/Return:/ so that kernel-doc will recognize this as
return section.

>   */
> -depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
> -				    gfp_t alloc_flags)
> +depot_stack_handle_t stack_depot_save(unsigned long *entries,
> +				      unsigned int nr_entries,
> +				      gfp_t alloc_flags)
>  {
> -	u32 hash;
> -	depot_stack_handle_t retval = 0;
>  	struct stack_record *found = NULL, **bucket;
> -	unsigned long flags;
> +	depot_stack_handle_t retval = 0;
>  	struct page *page = NULL;
>  	void *prealloc = NULL;
> +	unsigned long flags;
> +	u32 hash;
> 
> -	if (unlikely(trace->nr_entries == 0))
> +	if (unlikely(nr_entries == 0))
>  		goto fast_exit;
> 
> -	hash = hash_stack(trace->entries, trace->nr_entries);
> +	hash = hash_stack(entries, nr_entries);
>  	bucket = &stack_table[hash & STACK_HASH_MASK];
> 
>  	/*
> @@ -235,8 +251,8 @@ depot_stack_handle_t depot_save_stack(st
>  	 * The smp_load_acquire() here pairs with smp_store_release() to
>  	 * |bucket| below.
>  	 */
> -	found = find_stack(smp_load_acquire(bucket), trace->entries,
> -			   trace->nr_entries, hash);
> +	found = find_stack(smp_load_acquire(bucket), entries,
> +			   nr_entries, hash);
>  	if (found)
>  		goto exit;
> 
> @@ -264,10 +280,10 @@ depot_stack_handle_t depot_save_stack(st
> 
>  	spin_lock_irqsave(&depot_lock, flags);
> 
> -	found = find_stack(*bucket, trace->entries, trace->nr_entries, hash);
> +	found = find_stack(*bucket, entries, nr_entries, hash);
>  	if (!found) {
>  		struct stack_record *new =
> -			depot_alloc_stack(trace->entries, trace->nr_entries,
> +			depot_alloc_stack(entries, nr_entries,
>  					  hash, &prealloc, alloc_flags);
>  		if (new) {
>  			new->next = *bucket;
> @@ -297,4 +313,16 @@ depot_stack_handle_t depot_save_stack(st
>  fast_exit:
>  	return retval;
>  }
> +EXPORT_SYMBOL_GPL(stack_depot_save);
> +
> +/**
> + * depot_save_stack - save stack in a stack depot.
> + * @trace - the stacktrace to save.
> + * @alloc_flags - flags for allocating additional memory if required.
> + */
> +depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
> +				      gfp_t alloc_flags)
> +{
> +	return stack_depot_save(trace->entries, trace->nr_entries, alloc_flags);
> +}
>  EXPORT_SYMBOL_GPL(depot_save_stack);
> 
> 

-- 
Sincerely yours,
Mike.


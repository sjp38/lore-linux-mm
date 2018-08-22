Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E979F6B2415
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 07:20:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l16-v6so777816edq.18
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 04:20:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7-v6si542191edh.451.2018.08.22.04.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 04:20:01 -0700 (PDT)
Subject: Re: [RFC v8 PATCH 3/5] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
 <1534358990-85530-4-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e691d054-f807-80ad-9934-a1917d8e2e77@suse.cz>
Date: Wed, 22 Aug 2018 13:19:59 +0200
MIME-Version: 1.0
In-Reply-To: <1534358990-85530-4-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/15/2018 08:49 PM, Yang Shi wrote:
> +	downgrade_write(&mm->mmap_sem);
> +
> +	/* Zap mappings with read mmap_sem */
> +	unmap_region(mm, start_vma, prev, start, end);
> +
> +	arch_unmap(mm, start_vma, start, end);

Hmm, did you check that all architectures' arch_unmap() is safe with
read mmap_sem instead of write mmap_sem? E.g. x86 does
mpx_notify_unmap() there where I would be far from sure at first glance...

> +	remove_vma_list(mm, start_vma);
> +	up_read(&mm->mmap_sem);

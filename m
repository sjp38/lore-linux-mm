Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5DBAF8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 14:36:06 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id g12so2677826pll.22
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 11:36:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v69si66136732pgb.3.2019.01.08.11.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 11:36:05 -0800 (PST)
Date: Tue, 8 Jan 2019 11:36:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm/vmalloc: Make vmalloc_32_user() align base
 kernel virtual address to SHMLBA
Message-Id: <20190108113603.ea664e55869346bcb30c1433@linux-foundation.org>
In-Reply-To: <20190108110944.23591-1-rpenyaev@suse.de>
References: <20190108110944.23591-1-rpenyaev@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Penyaev <rpenyaev@suse.de>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, "David S . Miller" <davem@davemloft.net>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue,  8 Jan 2019 12:09:44 +0100 Roman Penyaev <rpenyaev@suse.de> wrote:

> This patch repeats the original one from David S. Miller:
> 
>   2dca6999eed5 ("mm, perf_event: Make vmalloc_user() align base kernel virtual address to SHMLBA")
> 
> but for missed vmalloc_32_user() case, which also requires correct
> alignment of virtual address on kernel side to avoid D-caches
> aliases.  A bit of copy-paste from original patch to recover in
> memory of what is all about:
> 
>   When a vmalloc'd area is mmap'd into userspace, some kind of
>   co-ordination is necessary for this to work on platforms with cpu
>   D-caches which can have aliases.
> 
>   Otherwise kernel side writes won't be seen properly in userspace
>   and vice versa.
> 
>   If the kernel side mapping and the user side one have the same
>   alignment, modulo SHMLBA, this can work as long as VM_SHARED is
>   shared of VMA and for all current users this is true.  VM_SHARED
>   will force SHMLBA alignment of the user side mmap on platforms with
>   D-cache aliasing matters.

What are the user-visible runtime effects of this change?

Is a -stable backport needed?

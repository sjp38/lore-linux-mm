Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 520D26B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 09:24:19 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u63so25687904wmu.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 06:24:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 107si5206526wra.205.2017.02.07.06.24.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 06:24:18 -0800 (PST)
Subject: Re: [RFC PATCH] mm, vmalloc: use __GFP_HIGHMEM implicitly
References: <20170201140530.1325-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <772f9b64-8f03-a4ce-e56b-779d081ebb6d@suse.cz>
Date: Tue, 7 Feb 2017 15:24:14 +0100
MIME-Version: 1.0
In-Reply-To: <20170201140530.1325-1-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Cristopher Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 02/01/2017 03:05 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> __vmalloc* allows users to provide gfp flags for the underlying
> allocation. This API is quite popular
> $ git grep "=[[:space:]]__vmalloc\|return[[:space:]]*__vmalloc" | wc -l
> 77
>
> the only problem is that many people are not aware that they really want
> to give __GFP_HIGHMEM along with other flags because there is really no
> reason to consume precious lowmemory on CONFIG_HIGHMEM systems for pages
> which are mapped to the kernel vmalloc space. About half of users don't
> use this flag, though. This signals that we make the API unnecessarily
> too complex.
>
> This patch simply uses __GFP_HIGHMEM implicitly when allocating pages to
> be mapped to the vmalloc space. Current users which add __GFP_HIGHMEM
> are simplified and drop the flag.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> Hi,
> this is based on top of [1]. I believe it was Al who has brought this
> up quite some time ago (or maybe I just misremember). The explicit
> usage of __GFP_HIGHMEM in __vmalloc* seems to be too much to ask from
> users. I believe there is no user which doesn't want vmalloc pages be
> in the highmem but I might be missing something. There is vmalloc_32*
> API but that uses GFP_DMA* explicitly which overrides __GFP_HIGHMEM. So
> all current users _should_ be safe to use __GFP_HIGHMEM unconditionally.
> This patch should simplify things and fix many users which consume
> lowmem for no good reason.
>
> I am sending this as an RFC to get some feedback, I even haven't compile
> tested it yet.
>
> Any comments are welcome.

The idea sounds good. What are the potential dangers? That somebody of the 
current callers without __GFP_HIGHMEM would take a physical address of the page 
and then tried to access it via direct mapping?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

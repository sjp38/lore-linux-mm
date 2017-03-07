Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AD7236B038A
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 18:08:47 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g2so28413276pge.7
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 15:08:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o6si1320324plh.59.2017.03.07.15.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 15:08:46 -0800 (PST)
Date: Tue, 7 Mar 2017 15:08:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, vmalloc: use __GFP_HIGHMEM implicitly
Message-Id: <20170307150845.075cceea71647bfeba3c5e22@linux-foundation.org>
In-Reply-To: <20170307141020.29107-1-mhocko@kernel.org>
References: <20170307141020.29107-1-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Cristopher Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue,  7 Mar 2017 15:10:20 +0100 Michal Hocko <mhocko@kernel.org> wrote:

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

hm.  What happens if a caller wants only lowmem pages?  Drivers do
weird stuff...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF9D6B0003
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 04:25:16 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id u2-v6so1091980pls.7
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 01:25:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l5-v6si3377992pff.304.2018.08.08.01.25.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 01:25:15 -0700 (PDT)
Date: Wed, 8 Aug 2018 10:25:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] netfilter/x_tables: do not fail xt_alloc_table_info too
 easilly
Message-ID: <20180808082511.GF27972@dhcp22.suse.cz>
References: <20180807195400.23687-1-mhocko@kernel.org>
 <a060e57c-dbcd-d3bc-c975-ac8a66468666@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a060e57c-dbcd-d3bc-c975-ac8a66468666@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Florian Westphal <fw@strlen.de>, Georgi Nikolov <gnikolov@icdsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 08-08-18 10:16:01, Vlastimil Babka wrote:
> On 08/07/2018 09:54 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > eacd86ca3b03 ("net/netfilter/x_tables.c: use kvmalloc()
> > in xt_alloc_table_info()") has unintentionally fortified
> > xt_alloc_table_info allocation when __GFP_RETRY has been dropped from
> > the vmalloc fallback. Later on there was a syzbot report that this
> > can lead to OOM killer invocations when tables are too large and
> > 0537250fdc6c ("netfilter: x_tables: make allocation less aggressive")
> > has been merged to restore the original behavior. Georgi Nikolov however
> > noticed that he is not able to install his iptables anymore so this can
> > be seen as a regression.
> > 
> > The primary argument for 0537250fdc6c was that this allocation path
> > shouldn't really trigger the OOM killer and kill innocent tasks. On the
> > other hand the interface requires root and as such should allow what the
> > admin asks for. Root inside a namespaces makes this more complicated
> > because those might be not trusted in general. If they are not then such
> > namespaces should be restricted anyway. Therefore drop the __GFP_NORETRY
> > and replace it by __GFP_ACCOUNT to enfore memcg constrains on it.
> > 
> > Fixes: 0537250fdc6c ("netfilter: x_tables: make allocation less aggressive")
> > Reported-by: Georgi Nikolov <gnikolov@icdsoft.com>
> > Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> > Acked-by: Florian Westphal <fw@strlen.de>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> IIRC According to Florian there are more places like this in the
> netfilter code?

Well, this is more for netfilter guys. I can only give a general
guidance that generally untrusted allocations triggered from userspace
should be a subject of kmem accounting.

-- 
Michal Hocko
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D7DF16B028C
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 12:41:17 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id q1-v6so3638239wru.18
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 09:41:17 -0700 (PDT)
Received: from mail.us.es (mail.us.es. [193.147.175.20])
        by mx.google.com with ESMTPS id n6-v6si1223427wma.39.2018.08.16.09.41.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 09:41:15 -0700 (PDT)
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 12B7F249F5
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 18:38:51 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 00DAFDA727
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 18:38:51 +0200 (CEST)
Date: Thu, 16 Aug 2018 18:41:10 +0200
From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter/x_tables: do not fail xt_alloc_table_info too
 easilly
Message-ID: <20180816164110.g2dedcm7nh75zjms@salvia>
References: <20180807195400.23687-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180807195400.23687-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Florian Westphal <fw@strlen.de>, Vlastimil Babka <vbabka@suse.cz>, Georgi Nikolov <gnikolov@icdsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On Tue, Aug 07, 2018 at 09:54:00PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> eacd86ca3b03 ("net/netfilter/x_tables.c: use kvmalloc()
> in xt_alloc_table_info()") has unintentionally fortified
> xt_alloc_table_info allocation when __GFP_RETRY has been dropped from
> the vmalloc fallback. Later on there was a syzbot report that this
> can lead to OOM killer invocations when tables are too large and
> 0537250fdc6c ("netfilter: x_tables: make allocation less aggressive")
> has been merged to restore the original behavior. Georgi Nikolov however
> noticed that he is not able to install his iptables anymore so this can
> be seen as a regression.
> 
> The primary argument for 0537250fdc6c was that this allocation path
> shouldn't really trigger the OOM killer and kill innocent tasks. On the
> other hand the interface requires root and as such should allow what the
> admin asks for. Root inside a namespaces makes this more complicated
> because those might be not trusted in general. If they are not then such
> namespaces should be restricted anyway. Therefore drop the __GFP_NORETRY
> and replace it by __GFP_ACCOUNT to enfore memcg constrains on it.

Applied, thanks.

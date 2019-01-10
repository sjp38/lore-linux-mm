Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id D4B8F8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 19:44:34 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id e17so2645955wrw.13
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 16:44:34 -0800 (PST)
Received: from mail.us.es (mail.us.es. [193.147.175.20])
        by mx.google.com with ESMTPS id a124si9873899wmf.38.2019.01.09.16.44.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 16:44:33 -0800 (PST)
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 314411E8F9F
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 01:44:31 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1EF24DA7FC
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 01:44:31 +0100 (CET)
Date: Thu, 10 Jan 2019 01:44:26 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] netfilter: account ebt_table_info to kmemcg
Message-ID: <20190110004426.p4n4lrpnnvv4czir@salvia>
References: <20190103031431.247970-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190103031431.247970-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Florian Westphal <fw@strlen.de>, Kirill Tkhai <ktkhai@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org

On Wed, Jan 02, 2019 at 07:14:31PM -0800, Shakeel Butt wrote:
> The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
> memory is already accounted to kmemcg. Do the same for ebtables. The
> syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
> whole system from a restricted memcg, a potential DoS.
> 
> By accounting the ebt_table_info, the memory used for ebt_table_info can
> be contained within the memcg of the allocating process. However the
> lifetime of ebt_table_info is independent of the allocating process and
> is tied to the network namespace. So, the oom-killer will not be able to
> relieve the memory pressure due to ebt_table_info memory. The memory for
> ebt_table_info is allocated through vmalloc. Currently vmalloc does not
> handle the oom-killed allocating process correctly and one large
> allocation can bypass memcg limit enforcement. So, with this patch,
> at least the small allocations will be contained. For large allocations,
> we need to fix vmalloc.

Fine with this -mm?

If no objections, I'll apply this to the netfilter tree. Thanks.

> Reported-by: syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Cc: Florian Westphal <fw@strlen.de>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linux MM <linux-mm@kvack.org>
> Cc: netfilter-devel@vger.kernel.org
> Cc: coreteam@netfilter.org
> Cc: bridge@lists.linux-foundation.org
> Cc: LKML <linux-kernel@vger.kernel.org>
> ---
> Changelog since v1:
> - More descriptive commit message.
> 
>  net/bridge/netfilter/ebtables.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
> index 491828713e0b..5e55cef0cec3 100644
> --- a/net/bridge/netfilter/ebtables.c
> +++ b/net/bridge/netfilter/ebtables.c
> @@ -1137,14 +1137,16 @@ static int do_replace(struct net *net, const void __user *user,
>  	tmp.name[sizeof(tmp.name) - 1] = 0;
>  
>  	countersize = COUNTER_OFFSET(tmp.nentries) * nr_cpu_ids;
> -	newinfo = vmalloc(sizeof(*newinfo) + countersize);
> +	newinfo = __vmalloc(sizeof(*newinfo) + countersize, GFP_KERNEL_ACCOUNT,
> +			    PAGE_KERNEL);
>  	if (!newinfo)
>  		return -ENOMEM;
>  
>  	if (countersize)
>  		memset(newinfo->counters, 0, countersize);
>  
> -	newinfo->entries = vmalloc(tmp.entries_size);
> +	newinfo->entries = __vmalloc(tmp.entries_size, GFP_KERNEL_ACCOUNT,
> +				     PAGE_KERNEL);
>  	if (!newinfo->entries) {
>  		ret = -ENOMEM;
>  		goto free_newinfo;
> -- 
> 2.20.1.415.g653613c723-goog
> 

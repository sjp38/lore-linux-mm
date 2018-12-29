Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6377C8E0001
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 02:33:30 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m19so27300411edc.6
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 23:33:30 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k23-v6si283073ejd.180.2018.12.28.23.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 23:33:28 -0800 (PST)
Date: Sat, 29 Dec 2018 08:33:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] netfilter: account ebt_table_info to kmemcg
Message-ID: <20181229073325.GZ16738@dhcp22.suse.cz>
References: <20181229015524.222741-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181229015524.222741-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com

On Fri 28-12-18 17:55:24, Shakeel Butt wrote:
> The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
> memory is already accounted to kmemcg. Do the same for ebtables. The
> syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
> whole system from a restricted memcg, a potential DoS.

What is the lifetime of these objects? Are they bound to any process?

> Reported-by: syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
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

-- 
Michal Hocko
SUSE Labs

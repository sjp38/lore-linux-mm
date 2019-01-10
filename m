Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB8818E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 04:41:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b3so4167039edi.0
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 01:41:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fy4-v6si2252872ejb.223.2019.01.10.01.41.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 01:41:44 -0800 (PST)
Date: Thu, 10 Jan 2019 10:41:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] netfilter: account ebt_table_info to kmemcg
Message-ID: <20190110094142.GI31793@dhcp22.suse.cz>
References: <20190103031431.247970-1-shakeelb@google.com>
 <5cc8efad-9d3d-3136-3ddc-1f8a640cb1f8@virtuozzo.com>
 <2d8f28cb-8620-be05-21bc-dcf3009b2774@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2d8f28cb-8620-be05-21bc-dcf3009b2774@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, Florian Westphal <fw@strlen.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org

On Thu 10-01-19 12:22:09, Kirill Tkhai wrote:
[...]
> >> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
> >> index 491828713e0b..5e55cef0cec3 100644
> >> --- a/net/bridge/netfilter/ebtables.c
> >> +++ b/net/bridge/netfilter/ebtables.c
> >> @@ -1137,14 +1137,16 @@ static int do_replace(struct net *net, const void __user *user,
> >>  	tmp.name[sizeof(tmp.name) - 1] = 0;
> >>  
> >>  	countersize = COUNTER_OFFSET(tmp.nentries) * nr_cpu_ids;
> >> -	newinfo = vmalloc(sizeof(*newinfo) + countersize);
> >> +	newinfo = __vmalloc(sizeof(*newinfo) + countersize, GFP_KERNEL_ACCOUNT,
> >> +			    PAGE_KERNEL);
> 
> Do we need GFP_HIGHMEM here?

No. vmalloc adds __GPF_HIGHMEM implicitly (see __vmalloc_area_node).

-- 
Michal Hocko
SUSE Labs

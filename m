Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF066B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 08:50:27 -0500 (EST)
Received: by wmec201 with SMTP id c201so118628331wme.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 05:50:26 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id g9si12225791wmd.74.2015.11.19.05.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 05:50:25 -0800 (PST)
Received: by wmvv187 with SMTP id v187so26528483wmv.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 05:50:25 -0800 (PST)
Date: Thu, 19 Nov 2015 14:50:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 13/14] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Message-ID: <20151119135023.GH8494@dhcp22.suse.cz>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-14-git-send-email-hannes@cmpxchg.org>
 <20151116155923.GH14116@dhcp22.suse.cz>
 <20151116181810.GB32544@cmpxchg.org>
 <20151118162256.GK19145@dhcp22.suse.cz>
 <20151118214822.GA1365@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151118214822.GA1365@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed 18-11-15 16:48:22, Johannes Weiner wrote:
[...]
> So I ran perf record -g -a netperf -t TCP_STREAM multiple times inside
> a memory-controlled cgroup, but mostly mem_cgroup_charge_skmem() does
> not show up in the profile at all. Once it was there with 0.00%.

OK, this sounds very good! This means that most workloads which are not
focusing solely on the network traffic shouldn't even notice. I can
imagine that workloads with high throughput demands would notice but I
would also expect them to disable the feature.

Could you add this information to the changelog, please?

> I ran another test that downloads the latest kernel image from
> kernel.org at 13MB/s (on my i5 laptop) and it looks like this:
> 
>      0.02%     0.01%  irq/44-iwlwifi   [kernel.kallsyms]           [k] mem_cgroup_charge_skmem
>              |
>              ---mem_cgroup_charge_skmem
>                 __sk_mem_schedule
>                 tcp_try_rmem_schedule
>                 tcp_data_queue
>                 tcp_rcv_established
>                 tcp_v4_do_rcv
>                 tcp_v4_rcv
>                 ip_local_deliver
>                 ip_rcv
>                 __netif_receive_skb_core
>                 __netif_receive_skb
>                 netif_receive_skb_internal
>                 napi_gro_complete
> 
> The runs vary too much for this to be measurable in elapsed time.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

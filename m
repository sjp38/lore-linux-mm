Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8CBDF6B0253
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 16:48:38 -0500 (EST)
Received: by wmdw130 with SMTP id w130so216839176wmd.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 13:48:38 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i129si7729412wma.2.2015.11.18.13.48.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 13:48:37 -0800 (PST)
Date: Wed, 18 Nov 2015 16:48:22 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 13/14] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Message-ID: <20151118214822.GA1365@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-14-git-send-email-hannes@cmpxchg.org>
 <20151116155923.GH14116@dhcp22.suse.cz>
 <20151116181810.GB32544@cmpxchg.org>
 <20151118162256.GK19145@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151118162256.GK19145@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Nov 18, 2015 at 05:22:56PM +0100, Michal Hocko wrote:
> On Mon 16-11-15 13:18:10, Johannes Weiner wrote:
> > What load would you test and what would be the baseline to compare it
> > to?
> 
> It seems like netperf with a stream load running in a memcg with no
> limits vs. in root memcg (and no other cgroups) should give at least a
> hint about the runtime overhead, no?

Comparing root vs. dedicated group generally doesn't make sense since
you either need containment or you don't. It makes more sense to test
both times inside a memory-controlled cgroup, one with a regular boot,
one with cgroup.memory=nosocket.

So I ran perf record -g -a netperf -t TCP_STREAM multiple times inside
a memory-controlled cgroup, but mostly mem_cgroup_charge_skmem() does
not show up in the profile at all. Once it was there with 0.00%.

I ran another test that downloads the latest kernel image from
kernel.org at 13MB/s (on my i5 laptop) and it looks like this:

     0.02%     0.01%  irq/44-iwlwifi   [kernel.kallsyms]           [k] mem_cgroup_charge_skmem
             |
             ---mem_cgroup_charge_skmem
                __sk_mem_schedule
                tcp_try_rmem_schedule
                tcp_data_queue
                tcp_rcv_established
                tcp_v4_do_rcv
                tcp_v4_rcv
                ip_local_deliver
                ip_rcv
                __netif_receive_skb_core
                __netif_receive_skb
                netif_receive_skb_internal
                napi_gro_complete

The runs vary too much for this to be measurable in elapsed time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 99C5B6B0038
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 11:52:39 -0500 (EST)
Received: by wmdw130 with SMTP id w130so248417665wmd.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 08:52:39 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bw7si12423436wjb.40.2015.11.19.08.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 08:52:38 -0800 (PST)
Date: Thu, 19 Nov 2015 11:52:25 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 13/14] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Message-ID: <20151119165225.GA1949@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-14-git-send-email-hannes@cmpxchg.org>
 <20151116155923.GH14116@dhcp22.suse.cz>
 <20151116181810.GB32544@cmpxchg.org>
 <20151118162256.GK19145@dhcp22.suse.cz>
 <20151118214822.GA1365@cmpxchg.org>
 <20151119135023.GH8494@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151119135023.GH8494@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 19, 2015 at 02:50:24PM +0100, Michal Hocko wrote:
> On Wed 18-11-15 16:48:22, Johannes Weiner wrote:
> [...]
> > So I ran perf record -g -a netperf -t TCP_STREAM multiple times inside
> > a memory-controlled cgroup, but mostly mem_cgroup_charge_skmem() does
> > not show up in the profile at all. Once it was there with 0.00%.
> 
> OK, this sounds very good! This means that most workloads which are not
> focusing solely on the network traffic shouldn't even notice. I can
> imagine that workloads with high throughput demands would notice but I
> would also expect them to disable the feature.

Even for high throughput, the cost of this is a function of number of
packets sent. E.g. the 13MB/s over wifi showed the socket charging at
0.02%. But I just did an http transfer over 1Gbit ethernet at around
110MB/s, ten times the bandwidth, and the charge function is at 0.00%.

> Could you add this information to the changelog, please?

Sure, but which information exactly?

If we had found a realistic networking workload that is expected to be
containerized and had shown that load to be negatively affected by the
charging calls, that would have been worth bringing up in conjunction
with the boot-time flag. But what do we have to say here? People care
about cost. It seems unnecessary to point out the absence of it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

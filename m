Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id F30838E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:57:52 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id l1so3925592wrn.3
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 15:57:52 -0800 (PST)
Received: from mail.us.es (mail.us.es. [193.147.175.20])
        by mx.google.com with ESMTPS id i9si24242419wrc.335.2019.01.10.15.57.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 15:57:51 -0800 (PST)
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 9EF2361E8D
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 00:57:49 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 8F7E1DA84C
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 00:57:49 +0100 (CET)
Date: Fri, 11 Jan 2019 00:57:46 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] netfilter: account ebt_table_info to kmemcg
Message-ID: <20190110235746.65mp4kgyscgjhktl@salvia>
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

OK, patch is applied, thanks.

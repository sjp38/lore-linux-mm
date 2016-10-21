Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id C727A6B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 06:05:29 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id i187so24373725lfe.4
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 03:05:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id ue16si1848579wjb.134.2016.10.21.03.05.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Oct 2016 03:05:28 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9LA4QGZ122267
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 06:05:26 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 267eth5y8c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 06:05:26 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Fri, 21 Oct 2016 11:05:24 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id BF18B17D805F
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 11:07:33 +0100 (BST)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9LA5LgP12386802
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 10:05:21 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9LA5KkX004513
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 06:05:21 -0400
Subject: Re: [PATCH v2 0/8] mm/swap: Regular page swap optimizations
References: <cover.1477004978.git.tim.c.chen@linux.intel.com>
 <fe4d056b-5a96-c208-f6bd-32a265482c56@de.ibm.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Fri, 21 Oct 2016 12:05:19 +0200
MIME-Version: 1.0
In-Reply-To: <fe4d056b-5a96-c208-f6bd-32a265482c56@de.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <ffa08555-c170-7c6b-0c7e-798e9988adba@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

On 10/21/2016 10:16 AM, Christian Borntraeger wrote:
> On s390 4.9-rc1 + this patch set
> I get the following on swapon
> 
> [  308.206195] ------------[ cut here ]------------
> [  308.206203] WARNING: CPU: 5 PID: 20745 at mm/page_alloc.c:3511 __alloc_pages_nodemask+0x884/0xdf8
> [  308.206205] Modules linked in: xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ipt_REJECT nf_reject_ipv4 bridge stp llc ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter btrfs raid6_pq xor dm_service_time ghash_s390 prng aes_s390 des_s390 des_generic qeth_l2 sha512_s390 sha256_s390 sha1_s390 sha_common nfsd eadm_sch auth_rpcgss qeth ccwgroup oid_registry nfs_acl lockd grace vhost_net vhost sunrpc macvtap macvlan kvm sch_fq_codel dm_multipath ip_tables
> [  308.206240] CPU: 5 PID: 20745 Comm: swapon Tainted: G        W       4.9.0-rc1+ #23
> [  308.206241] Hardware name: IBM              2964 NC9              704              (LPAR)
> [  308.206243] task: 00000000e3bb8000 task.stack: 00000000d4270000
> [  308.206244] Krnl PSW : 0704c00180000000 000000000025db3c
> [  308.206246]  (__alloc_pages_nodemask+0x884/0xdf8)
> 
> [  308.206248]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:0 PM:0
> [  308.206250]  RI:0 EA:3
> [  308.206251] 
>                Krnl GPRS: 000000000000000a 0000000000b2b0ec 0000000100000312 0000000000000001
> [  308.206267]            000000000025d3ec 0000000000000008 0000000000000075 000000000240c0c0
> [  308.206269]            0000000000000001 0000000000000000 000000000000000a 0000000000000000
> [  308.206270]            000000000000000a 000000000079d8c8 000000000025d3ec 00000000d4273ba0
> [  308.206280] Krnl Code: 000000000025db30: a774fd27		brc	7,25d57e
> [  308.206282] 
>                           000000000025db34: 92011000		mvi	0(%r1),1
> [  308.206285] 
>                          #000000000025db38: a7f40001		brc	15,25db3a
> [  308.206286] 
>                          >000000000025db3c: a7f4fd21		brc	15,25d57e
> [  308.206289] 
>                           000000000025db40: 4130f150		la	%r3,336(%r15)
> [  308.206291] 
>                           000000000025db44: b904002c		lgr	%r2,%r12
> [  308.206293] 
>                           000000000025db48: c0e5ffffe11c	brasl	%r14,259d80
> [  308.206294] 
>                           000000000025db4e: a7f4fda3		brc	15,25d694
> [  308.206297] Call Trace:
> [  308.206299] ([<000000000025d3ec>] __alloc_pages_nodemask+0x134/0xdf8)
> [  308.206303] ([<0000000000280d6a>] kmalloc_order+0x42/0x70)
> [  308.206305] ([<0000000000280dd8>] kmalloc_order_trace+0x40/0xf0)
> [  308.206310] ([<00000000002a7090>] init_swap_address_space+0x68/0x138)
> [  308.206312] ([<00000000002ac858>] SyS_swapon+0xbd0/0xf80)
> [  308.206317] ([<0000000000785476>] system_call+0xd6/0x264)
> [  308.206318] Last Breaking-Event-Address:
> [  308.206319]  [<000000000025db38>] __alloc_pages_nodemask+0x880/0xdf8
> [  308.206320] ---[ end trace aaeca736f47ac05b ]---
> 

Looks like that 1TB of swap is just too big for your logic (you try kmalloc without checking the size).





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

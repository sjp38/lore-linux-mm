Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F23628E00BD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 03:03:18 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id a9so5880606pla.2
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 00:03:18 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g63si23843881pfc.60.2019.01.25.00.03.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 00:03:17 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0P7weXn073647
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 03:03:17 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q7vy4mk2w-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 03:03:16 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Fri, 25 Jan 2019 08:03:14 -0000
Date: Fri, 25 Jan 2019 09:03:07 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [-next 20190118] "kernel BUG at mm/page_alloc.c:3112!"
References: <20190121154312.GH4020@osiris>
 <20190121160607.GV4087@dhcp22.suse.cz>
 <20190121163747.GL28934@suse.de>
MIME-Version: 1.0
In-Reply-To: <20190121163747.GL28934@suse.de>
Message-Id: <20190125080307.GA3561@osiris>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, Michael Holzheu <holzheu@linux.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Jan 21, 2019 at 04:37:47PM +0000, Mel Gorman wrote:
> On Mon, Jan 21, 2019 at 05:06:07PM +0100, Michal Hocko wrote:
> > This sounds familiar. Cc Mel and Vlastimil.
> > 
> 
> There is a series sitting in Andrew's inbox that replaces a compaction
> series. A patch is dropped in the new version that deals with pages
> getting freed during compaction that *may* be allowing active pages to
> reach the free list and not tripping a warning like it should. I'm hoping
> it'll be picked up soon to see if this particular bug persists or if it's
> something else.

Has this been picked up already? With linux next 20190124 I still get this:

[ 2529.576230] kernel BUG at mm/page_alloc.c:3112!
[ 2529.576263] illegal operation: 0001 ilc:1 [#1] SMP
[ 2529.576265] Modules linked in: loop kvm xt_tcpudp ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat_ipv4 nf_nat iptable_mangle iptable_raw iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 ip_set nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables x_tables pkey zcrypt s390_trng rng_core ghash_s390 prng aes_s390 des_s390 des_generic sha512_s390 sha1_s390 sch_fq_codel sha256_s390 sha_common autofs4
[ 2529.576287] CPU: 5 PID: 57 Comm: kcompactd0 Not tainted 5.0.0-20190125.rc3.git0.755d01d17697.300.fc29.s390x+next #1
[ 2529.576289] Hardware name: IBM 3906 M04 704 (z/VM 6.4.0)
[ 2529.576292] Krnl PSW : 0404d00180000000 00000000002bf5d2 (__isolate_free_page+0x212/0x218)
[ 2529.576302]            R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:3 CC:1 PM:0 RI:0 EA:3
[ 2529.576310] Krnl GPRS: 0000000000142c00 000003e0f0000080 000003d084cb2400 00000000f0000000
[ 2529.576312]            000003d084cb2408 00000000000002d8 0000000000000007 000003d084cb2400
[ 2529.576312]            0000000000000007 000000017fbfe8c0 000003d000000000 000003d000000007
[ 2529.576313]            000003e001453dc0 000000000014a800 000003e001453ae0 000003e001453a80
[ 2529.576323] Krnl Code: 00000000002bf5c4: f0a8000407fe        srp     4(11,%r0),2046,8
			  00000000002bf5ca: 47000700            bc      0,1792
                         #00000000002bf5ce: a7f40001            brc     15,2bf5d0
                         >00000000002bf5d2: 0707                bcr     0,%r7
                          00000000002bf5d4: 0707                bcr     0,%r7
                          00000000002bf5d6: 0707                bcr     0,%r7
                          00000000002bf5d8: c00400000000        brcl    0,2bf5d8
                          00000000002bf5de: eb6ff0480024        stmg    %r6,%r15,72(%r15)
[ 2529.576333] Call Trace:
[ 2529.576335] ([<000003d084cde000>] 0x3d084cde000)
[ 2529.576339]  [<00000000002f0fd4>] compaction_alloc+0x394/0x9c8
[ 2529.576344]  [<000000000034387e>] migrate_pages+0x1ce/0xaf0
[ 2529.576385]  [<00000000002f2e00>] compact_zone+0x620/0xf20
[ 2529.576388]  [<00000000002f3a60>] kcompactd_do_work+0x130/0x268
[ 2529.576389]  [<00000000002f3c30>] kcompactd+0x98/0x1d0
[ 2529.576393]  [<0000000000168500>] kthread+0x140/0x160
[ 2529.576397]  [<0000000000a913c6>] kernel_thread_starter+0x6/0x10
[ 2529.576398]  [<0000000000a913c0>] kernel_thread_starter+0x0/0x10
[ 2529.576400] Last Breaking-Event-Address:
[ 2529.576402]  [<00000000002bf5ce>] __isolate_free_page+0x20e/0x218
[ 2529.576408] Kernel panic - not syncing: Fatal exception: panic_on_oops

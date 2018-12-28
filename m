Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 386F78E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 21:32:05 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 202so18929818pgb.6
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 18:32:05 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 3si36480674plx.33.2018.12.27.18.32.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 18:32:03 -0800 (PST)
Date: Fri, 28 Dec 2018 10:31:58 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH v2 08/21] mm: introduce and export pgdat peer_node
Message-ID: <20181228023158.v3zvbp3k7coodctv@wfg-t540p.sh.intel.com>
References: <20181226131446.330864849@intel.com>
 <20181226133351.521151384@intel.com>
 <01000167f14761d6-b1564081-0d5f-4752-86be-2e99c8375866-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <01000167f14761d6-b1564081-0d5f-4752-86be-2e99c8375866-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 27, 2018 at 08:07:26PM +0000, Christopher Lameter wrote:
>On Wed, 26 Dec 2018, Fengguang Wu wrote:
>
>> Each CPU socket can have 1 DRAM and 1 PMEM node, we call them "peer nodes".
>> Migration between DRAM and PMEM will by default happen between peer nodes.
>
>Which one does numa_node_id() point to? I guess that is the DRAM node and

Yes. In our test machine, PMEM nodes show up as memory-only nodes, so
numa_node_id() points to DRAM node.

Here is numactl --hardware output on a 2S test machine.

available: 4 nodes (0-3)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77
node 0 size: 257712 MB
node 0 free: 178251 MB
node 1 cpus: 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102
103
node 1 size: 258038 MB
node 1 free: 174796 MB
node 2 cpus:
node 2 size: 503999 MB
node 2 free: 438349 MB
node 3 cpus:
node 3 size: 503999 MB
node 3 free: 438349 MB
node distances:
node   0   1   2   3
  0:  10  21  20  20
  1:  21  10  20  20
  2:  20  20  10  20
  3:  20  20  20  10

>then we fall back to the PMEM node?

Fall back is possible but not the scope of this patchset. We modified
fallback zonelists in patch 10 to simplify PMEM usage. With that
patch, page allocations on DRAM nodes won't fallback to PMEM nodes.
Instead, PMEM nodes will mainly be used by explicit numactl placement
and as migration target. When there is memory pressure in DRAM node,
LRU cold pages there will be demote migrated to its peer PMEM node on
the same socket by patch 20.

Thanks,
Fengguang

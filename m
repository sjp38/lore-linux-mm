Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D046C8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 02:56:58 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id i3so4219904pfj.4
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 23:56:58 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id q18si20284482pls.30.2018.12.20.23.56.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 23:56:56 -0800 (PST)
Date: Fri, 21 Dec 2018 15:56:39 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCHv2 1/3] mm/numa: change the topo of build_zonelist_xx()
Message-ID: <201812211505.W391FoVW%fengguang.wu@intel.com>
References: <1545299439-31370-2-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="huq684BweRXVnRxX"
Content-Disposition: inline
In-Reply-To: <1545299439-31370-2-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Pingfan,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.20-rc7 next-20181220]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Pingfan-Liu/mm-bugfix-for-NULL-reference-in-mm-on-all-archs/20181221-152625
config: riscv-tinyconfig (attached as .config)
compiler: riscv64-linux-gcc (GCC) 8.1.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        GCC_VERSION=8.1.0 make.cross ARCH=riscv 

All errors (new ones prefixed by >>):

   mm/page_alloc.c: In function 'build_zonelists':
>> mm/page_alloc.c:5288:12: error: 'local_node' redeclared as different kind of symbol
     int node, local_node;
               ^~~~~~~~~~
   mm/page_alloc.c:5286:66: note: previous definition of 'local_node' was here
    static void build_zonelists(struct zonelist *node_zonelists, int local_node)
                                                                 ~~~~^~~~~~~~~~

vim +/local_node +5288 mm/page_alloc.c

^1da177e4 Linus Torvalds    2005-04-16  5285  
e6ee0d8bd Pingfan Liu       2018-12-20  5286  static void build_zonelists(struct zonelist *node_zonelists, int local_node)
^1da177e4 Linus Torvalds    2005-04-16  5287  {
19655d348 Christoph Lameter 2006-09-25 @5288  	int node, local_node;
9d3be21bf Michal Hocko      2017-09-06  5289  	struct zoneref *zonerefs;
9d3be21bf Michal Hocko      2017-09-06  5290  	int nr_zones;
^1da177e4 Linus Torvalds    2005-04-16  5291  
e6ee0d8bd Pingfan Liu       2018-12-20  5292  	zonerefs = node_zonelists[ZONELIST_FALLBACK]._zonerefs;
e6ee0d8bd Pingfan Liu       2018-12-20  5293  	nr_zones = build_zonerefs_node(local_node, zonerefs);
9d3be21bf Michal Hocko      2017-09-06  5294  	zonerefs += nr_zones;
^1da177e4 Linus Torvalds    2005-04-16  5295  
^1da177e4 Linus Torvalds    2005-04-16  5296  	/*
^1da177e4 Linus Torvalds    2005-04-16  5297  	 * Now we build the zonelist so that it contains the zones
^1da177e4 Linus Torvalds    2005-04-16  5298  	 * of all the other nodes.
^1da177e4 Linus Torvalds    2005-04-16  5299  	 * We don't want to pressure a particular node, so when
^1da177e4 Linus Torvalds    2005-04-16  5300  	 * building the zones for node N, we make sure that the
^1da177e4 Linus Torvalds    2005-04-16  5301  	 * zones coming right after the local ones are those from
^1da177e4 Linus Torvalds    2005-04-16  5302  	 * node N+1 (modulo N)
^1da177e4 Linus Torvalds    2005-04-16  5303  	 */
^1da177e4 Linus Torvalds    2005-04-16  5304  	for (node = local_node + 1; node < MAX_NUMNODES; node++) {
^1da177e4 Linus Torvalds    2005-04-16  5305  		if (!node_online(node))
^1da177e4 Linus Torvalds    2005-04-16  5306  			continue;
e6ee0d8bd Pingfan Liu       2018-12-20  5307  		nr_zones = build_zonerefs_node(node, zonerefs);
9d3be21bf Michal Hocko      2017-09-06  5308  		zonerefs += nr_zones;
^1da177e4 Linus Torvalds    2005-04-16  5309  	}
^1da177e4 Linus Torvalds    2005-04-16  5310  	for (node = 0; node < local_node; node++) {
^1da177e4 Linus Torvalds    2005-04-16  5311  		if (!node_online(node))
^1da177e4 Linus Torvalds    2005-04-16  5312  			continue;
e6ee0d8bd Pingfan Liu       2018-12-20  5313  		nr_zones = build_zonerefs_node(node, zonerefs);
9d3be21bf Michal Hocko      2017-09-06  5314  		zonerefs += nr_zones;
^1da177e4 Linus Torvalds    2005-04-16  5315  	}
^1da177e4 Linus Torvalds    2005-04-16  5316  
9d3be21bf Michal Hocko      2017-09-06  5317  	zonerefs->zone = NULL;
9d3be21bf Michal Hocko      2017-09-06  5318  	zonerefs->zone_idx = 0;
^1da177e4 Linus Torvalds    2005-04-16  5319  }
^1da177e4 Linus Torvalds    2005-04-16  5320  

:::::: The code at line 5288 was first introduced by commit
:::::: 19655d3487001d7df0e10e9cbfc27c758b77c2b5 [PATCH] linearly index zone->node_zonelists[]

:::::: TO: Christoph Lameter <clameter@sgi.com>
:::::: CC: Linus Torvalds <torvalds@g5.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--huq684BweRXVnRxX
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--huq684BweRXVnRxX--

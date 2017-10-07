Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B60C46B025E
	for <linux-mm@kvack.org>; Sat,  7 Oct 2017 07:46:14 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y77so43233219pfd.2
        for <linux-mm@kvack.org>; Sat, 07 Oct 2017 04:46:14 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q11si2873306pgc.807.2017.10.07.04.46.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Oct 2017 04:46:13 -0700 (PDT)
Date: Sat, 7 Oct 2017 19:45:18 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 2/3] mm: slabinfo: dump CONFIG_SLABINFO
Message-ID: <201710071928.VpRvNUPG%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="SLDf9lqlvOQaIe6s"
Content-Disposition: inline
In-Reply-To: <1507152550-46205-3-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: kbuild-all@01.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Yang,

[auto build test ERROR on mmotm/master]
[also build test ERROR on v4.14-rc3 next-20170929]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Yang-Shi/oom-capture-unreclaimable-slab-info-in-oom-message/20171007-173639
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: sh-allnoconfig (attached as .config)
compiler: sh4-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=sh 

All errors (new ones prefixed by >>):

   mm/slub.c: In function 'get_slabinfo':
   mm/slub.c:5864:14: error: implicit declaration of function 'node_nr_objs' [-Werror=implicit-function-declaration]
      nr_objs += node_nr_objs(n);
                 ^~~~~~~~~~~~
>> mm/slub.c:5865:14: error: implicit declaration of function 'count_partial' [-Werror=implicit-function-declaration]
      nr_free += count_partial(n, count_free);
                 ^~~~~~~~~~~~~
   mm/slub.c:5865:31: error: 'count_free' undeclared (first use in this function)
      nr_free += count_partial(n, count_free);
                                  ^~~~~~~~~~
   mm/slub.c:5865:31: note: each undeclared identifier is reported only once for each function it appears in
   cc1: some warnings being treated as errors

vim +/count_partial +5865 mm/slub.c

57ed3eda9 Pekka J Enberg    2008-01-01  5850  
57ed3eda9 Pekka J Enberg    2008-01-01  5851  /*
57ed3eda9 Pekka J Enberg    2008-01-01  5852   * The /proc/slabinfo ABI
57ed3eda9 Pekka J Enberg    2008-01-01  5853   */
0d7561c61 Glauber Costa     2012-10-19  5854  void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo)
57ed3eda9 Pekka J Enberg    2008-01-01  5855  {
57ed3eda9 Pekka J Enberg    2008-01-01  5856  	unsigned long nr_slabs = 0;
205ab99dd Christoph Lameter 2008-04-14  5857  	unsigned long nr_objs = 0;
205ab99dd Christoph Lameter 2008-04-14  5858  	unsigned long nr_free = 0;
57ed3eda9 Pekka J Enberg    2008-01-01  5859  	int node;
fa45dc254 Christoph Lameter 2014-08-06  5860  	struct kmem_cache_node *n;
57ed3eda9 Pekka J Enberg    2008-01-01  5861  
fa45dc254 Christoph Lameter 2014-08-06  5862  	for_each_kmem_cache_node(s, node, n) {
c17fd13ec Wanpeng Li        2013-07-04  5863  		nr_slabs += node_nr_slabs(n);
c17fd13ec Wanpeng Li        2013-07-04 @5864  		nr_objs += node_nr_objs(n);
205ab99dd Christoph Lameter 2008-04-14 @5865  		nr_free += count_partial(n, count_free);
57ed3eda9 Pekka J Enberg    2008-01-01  5866  	}
57ed3eda9 Pekka J Enberg    2008-01-01  5867  
0d7561c61 Glauber Costa     2012-10-19  5868  	sinfo->active_objs = nr_objs - nr_free;
0d7561c61 Glauber Costa     2012-10-19  5869  	sinfo->num_objs = nr_objs;
0d7561c61 Glauber Costa     2012-10-19  5870  	sinfo->active_slabs = nr_slabs;
0d7561c61 Glauber Costa     2012-10-19  5871  	sinfo->num_slabs = nr_slabs;
0d7561c61 Glauber Costa     2012-10-19  5872  	sinfo->objects_per_slab = oo_objects(s->oo);
0d7561c61 Glauber Costa     2012-10-19  5873  	sinfo->cache_order = oo_order(s->oo);
57ed3eda9 Pekka J Enberg    2008-01-01  5874  }
57ed3eda9 Pekka J Enberg    2008-01-01  5875  

:::::: The code at line 5865 was first introduced by commit
:::::: 205ab99dd103e3dd5b0964dad8a16dfe2db69b2e slub: Update statistics handling for variable order slabs

:::::: TO: Christoph Lameter <clameter@sgi.com>
:::::: CC: Pekka Enberg <penberg@cs.helsinki.fi>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--SLDf9lqlvOQaIe6s
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
Ihs/d8OEg21auUldxv8Dwi4X1g5PAAA=

--SLDf9lqlvOQaIe6s--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

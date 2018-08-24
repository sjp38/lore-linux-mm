Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 744BB6B2E06
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 01:33:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e124-v6so4683538pgc.11
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 22:33:30 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f12-v6si4469449pgf.183.2018.08.23.22.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 22:33:28 -0700 (PDT)
Date: Fri, 24 Aug 2018 13:32:24 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] fs: fix local var type
Message-ID: <201808241151.885cwq5J%fengguang.wu@intel.com>
References: <1535014754-31918-1-git-send-email-swkhack@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1535014754-31918-1-git-send-email-swkhack@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weikang Shi <swkhack@gmail.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, alexander.h.duyck@intel.com, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, l.stach@pengutronix.de, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, my_email@gmail.com

Hi Weikang,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.18 next-20180822]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Weikang-Shi/fs-fix-local-var-type/20180823-180758
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   fs/seq_file.c:210:21: sparse: expression using sizeof(void)
   fs/seq_file.c:210:21: sparse: expression using sizeof(void)
   fs/seq_file.c:276:13: sparse: expression using sizeof(void)
   fs/seq_file.c:276:13: sparse: expression using sizeof(void)
>> fs/seq_file.c:860:27: sparse: incompatible types in comparison expression (different type sizes)
   fs/seq_file.c:1037:24: sparse: incompatible types in comparison expression (different address spaces)
   fs/seq_file.c:1039:24: sparse: incompatible types in comparison expression (different address spaces)
>> fs/seq_file.c:860:27: sparse: call with no type!
   In file included from include/linux/list.h:9:0,
                    from include/linux/wait.h:7,
                    from include/linux/wait_bit.h:8,
                    from include/linux/fs.h:6,
                    from fs/seq_file.c:10:
   fs/seq_file.c: In function 'seq_hex_dump':
   include/linux/kernel.h:845:29: warning: comparison of distinct pointer types lacks a cast
      (!!(sizeof((typeof(x) *)1 == (typeof(y) *)1)))
                                ^
   include/linux/kernel.h:859:4: note: in expansion of macro '__typecheck'
      (__typecheck(x, y) && __no_side_effects(x, y))
       ^~~~~~~~~~~
   include/linux/kernel.h:869:24: note: in expansion of macro '__safe_cmp'
     __builtin_choose_expr(__safe_cmp(x, y), 23-                        ^~~~~~~~~~
   include/linux/kernel.h:878:19: note: in expansion of macro '__careful_cmp'
    #define min(x, y) __careful_cmp(x, y, <)
                      ^~~~~~~~~~~~~
   fs/seq_file.c:860:13: note: in expansion of macro 'min'
      linelen = min(remaining, rowsize);
                ^~~

vim +860 fs/seq_file.c

839cc2a9 Tetsuo Handa    2013-11-14  843  
37607102 Andy Shevchenko 2015-09-09  844  /* A complete analogue of print_hex_dump() */
37607102 Andy Shevchenko 2015-09-09  845  void seq_hex_dump(struct seq_file *m, const char *prefix_str, int prefix_type,
37607102 Andy Shevchenko 2015-09-09  846  		  int rowsize, int groupsize, const void *buf, size_t len,
37607102 Andy Shevchenko 2015-09-09  847  		  bool ascii)
37607102 Andy Shevchenko 2015-09-09  848  {
37607102 Andy Shevchenko 2015-09-09  849  	const u8 *ptr = buf;
5f9924ac Weikang Shi     2018-08-23  850  	int i, linelen;
5f9924ac Weikang Shi     2018-08-23  851  	size_t remaining = len;
8b91a318 Andy Shevchenko 2015-11-06  852  	char *buffer;
8b91a318 Andy Shevchenko 2015-11-06  853  	size_t size;
37607102 Andy Shevchenko 2015-09-09  854  	int ret;
37607102 Andy Shevchenko 2015-09-09  855  
37607102 Andy Shevchenko 2015-09-09  856  	if (rowsize != 16 && rowsize != 32)
37607102 Andy Shevchenko 2015-09-09  857  		rowsize = 16;
37607102 Andy Shevchenko 2015-09-09  858  
37607102 Andy Shevchenko 2015-09-09  859  	for (i = 0; i < len && !seq_has_overflowed(m); i += rowsize) {
37607102 Andy Shevchenko 2015-09-09 @860  		linelen = min(remaining, rowsize);
37607102 Andy Shevchenko 2015-09-09  861  		remaining -= rowsize;
37607102 Andy Shevchenko 2015-09-09  862  
37607102 Andy Shevchenko 2015-09-09  863  		switch (prefix_type) {
37607102 Andy Shevchenko 2015-09-09  864  		case DUMP_PREFIX_ADDRESS:
37607102 Andy Shevchenko 2015-09-09  865  			seq_printf(m, "%s%p: ", prefix_str, ptr + i);
37607102 Andy Shevchenko 2015-09-09  866  			break;
37607102 Andy Shevchenko 2015-09-09  867  		case DUMP_PREFIX_OFFSET:
37607102 Andy Shevchenko 2015-09-09  868  			seq_printf(m, "%s%.8x: ", prefix_str, i);
37607102 Andy Shevchenko 2015-09-09  869  			break;
37607102 Andy Shevchenko 2015-09-09  870  		default:
37607102 Andy Shevchenko 2015-09-09  871  			seq_printf(m, "%s", prefix_str);
37607102 Andy Shevchenko 2015-09-09  872  			break;
37607102 Andy Shevchenko 2015-09-09  873  		}
37607102 Andy Shevchenko 2015-09-09  874  
8b91a318 Andy Shevchenko 2015-11-06  875  		size = seq_get_buf(m, &buffer);
37607102 Andy Shevchenko 2015-09-09  876  		ret = hex_dump_to_buffer(ptr + i, linelen, rowsize, groupsize,
8b91a318 Andy Shevchenko 2015-11-06  877  					 buffer, size, ascii);
8b91a318 Andy Shevchenko 2015-11-06  878  		seq_commit(m, ret < size ? ret : -1);
8b91a318 Andy Shevchenko 2015-11-06  879  
37607102 Andy Shevchenko 2015-09-09  880  		seq_putc(m, '\n');
37607102 Andy Shevchenko 2015-09-09  881  	}
37607102 Andy Shevchenko 2015-09-09  882  }
37607102 Andy Shevchenko 2015-09-09  883  EXPORT_SYMBOL(seq_hex_dump);
37607102 Andy Shevchenko 2015-09-09  884  

:::::: The code at line 860 was first introduced by commit
:::::: 37607102c4426cf92aeb5da1b1d9a79ba6d95e3f seq_file: provide an analogue of print_hex_dump()

:::::: TO: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

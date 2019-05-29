Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74C09C04AB6
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 02:40:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E47AE21019
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 02:40:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E47AE21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85C7D6B0266; Tue, 28 May 2019 22:40:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E6086B026A; Tue, 28 May 2019 22:40:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65DF66B026B; Tue, 28 May 2019 22:40:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08CA66B0266
	for <linux-mm@kvack.org>; Tue, 28 May 2019 22:40:19 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x5so758825pfi.5
        for <linux-mm@kvack.org>; Tue, 28 May 2019 19:40:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=0QmUImyj2cYZyU0NZ442YhXk53xdWQE7PnvMfRZsCtI=;
        b=XEUQ0wZ5HfYZUoXWBtougHdLazez25noKPXIjOzl/G4L5MLt3Muyq2Iz0Viy8PrGbj
         PuYYnLl6UUMxu6ReRnLoznVsKbpzdNP3IDLDjmyJGg/N1tTdDx01TNXcfAS8/+2NSgBI
         UaVlcZTnSsFxKQU/50Eb67RJgI8TFtvZpNU0MlUuUazyYAsMvysMttbX5VSMaER8LBXR
         /njxB1hSdPge/z99PwO7S4HlMaaHCfvXO+C3kSVfivYWpRt9z4Iz8Sn1NmntZXk50jFL
         T8VT4GyqYUIwZK3OT5FZv1iGGAAdzNf8K7EH0voJgJCeb6h+hVNt6lZxzPUdEVHVaRHj
         imBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUGtEgDg7SrBLpaCbZRbNltyI/EGPQnzlXvg2sjcVkpAP4RXXzh
	OHrI8qVzy2nND1gAZEn3UnacHjpH7DZ2grm0gjUHMhKy/AN8TxNCyIW2n5pHFHCFHM4M8CGDhn8
	DXT3QdxDtxdwntKDLkO2J5HxENN8oqLpR0D+GQG5dXozY2d2fAqUeEBYocWGsx7PRDw==
X-Received: by 2002:a65:6116:: with SMTP id z22mr136575829pgu.50.1559097618191;
        Tue, 28 May 2019 19:40:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJXeVMTrUzIyFFeeHI/dzo0wKbvMJtqFajOUAVeS/9J3y0gBMwqCe39iBSYVrbb3mwM36F
X-Received: by 2002:a65:6116:: with SMTP id z22mr136575663pgu.50.1559097615314;
        Tue, 28 May 2019 19:40:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559097615; cv=none;
        d=google.com; s=arc-20160816;
        b=cDgERbLOaiZd9spbfkv0eB6NXRWCd32Z+cAmF5tRqo4MW++hl/Bw0B5MvOJSD4JAju
         osHik5xz9qAzW0McN9xzOqpEQlYuRZVEDnMaf0arQm1W5a5gzWlKDr2XIupzwT6smGrZ
         B/cjzx0xZCHeEEoWYi4uIqxrR45clNVPB8kr+d2VwOzzOFzknoeJzarN74Rt0Hmk5jBv
         76WW7OkBy/y2PeDFm1MzfyGisEPM/yshI+IxSrfr466+Uo/gTl/eifeqE+CvMRcTd17d
         /Ge6yujzWFsjAyMmPtWL/Mkero3MVkeBzY6VyJdHwWy5Q3h9LOpNd2YeOTRxzNLoT0HB
         Jncw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=0QmUImyj2cYZyU0NZ442YhXk53xdWQE7PnvMfRZsCtI=;
        b=DE3K9umJ88G0O2fBOOnTIhzX7BIxC4cBHncFcKQyGqxmRRsd81YCmw6zY1l7GmMp1g
         pkZKvrAwGkY4ZdvgyRkusDco0Pr1t4GpmigjabWVQgnfFN9ZyO89TtWpNRjnwtfyXgeK
         +5iwbjzvkZbuyAsRq47FAyU3d16cuLCQUbFhnqfATWtl3xJVFbtyc0ZPZLtsnJacjbTg
         LNX56CtnGgVv050tho59MSLaeZVuUmoeKPEJssy2L5YlA/ypLU+wKHhqUWWAHe8RRnD4
         EmYc2zxFn0pAFu2/Gq82AiGyqJEHdtOoFhlm88rYefjlp2yXsvHSQdAOeN3Z5RjtXzDd
         ZfEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id q9si24507660pfh.199.2019.05.28.19.40.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 19:40:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 May 2019 19:40:14 -0700
X-ExtLoop1: 1
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga002.jf.intel.com with ESMTP; 28 May 2019 19:40:11 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hVoVf-000Hdy-0s; Wed, 29 May 2019 10:40:11 +0800
Date: Wed, 29 May 2019 10:39:57 +0800
From: kbuild test robot <lkp@intel.com>
To: Matteo Croce <mcroce@redhat.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
	Aaron Tomlin <atomlin@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [liu-song6-linux:uprobe-thp 119/185] kernel/sysctl.c:1729:15: error:
 'zero' undeclared here (not in a function)
Message-ID: <201905291052.AesPF9tG%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="Kj7319i9nmIyA2yE"
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://github.com/liu-song-6/linux.git uprobe-thp
head:   757cb898eb3096f4ed9487b503748d6e3a4d3332
commit: 115fe47f84b1b7e9673aa9ffc0d5a4a9bb0ade15 [119/185] proc/sysctl: add shared variables for range check
config: i386-randconfig-f3-05270030 (attached as .config)
compiler: gcc-5 (Debian 5.5.0-3) 5.4.1 20171010
reproduce:
        git checkout 115fe47f84b1b7e9673aa9ffc0d5a4a9bb0ade15
        # save the attached .config to linux build tree
        make ARCH=i386 

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>

Note: the liu-song6-linux/uprobe-thp HEAD 757cb898eb3096f4ed9487b503748d6e3a4d3332 builds fine.
      It only hurts bisectibility.

All errors (new ones prefixed by >>):

>> kernel/sysctl.c:1729:15: error: 'zero' undeclared here (not in a function)
      .extra1  = &zero,
                  ^
>> kernel/sysctl.c:1730:15: error: 'one' undeclared here (not in a function)
      .extra2  = &one,
                  ^

vim +/zero +1729 kernel/sysctl.c

^1da177e4 Linus Torvalds      2005-04-16  1285  
d8217f076 Eric W. Biederman   2007-10-18  1286  static struct ctl_table vm_table[] = {
^1da177e4 Linus Torvalds      2005-04-16  1287  	{
^1da177e4 Linus Torvalds      2005-04-16  1288  		.procname	= "overcommit_memory",
^1da177e4 Linus Torvalds      2005-04-16  1289  		.data		= &sysctl_overcommit_memory,
^1da177e4 Linus Torvalds      2005-04-16  1290  		.maxlen		= sizeof(sysctl_overcommit_memory),
^1da177e4 Linus Torvalds      2005-04-16  1291  		.mode		= 0644,
cb16e95fa Petr Holasek        2011-03-23  1292  		.proc_handler	= proc_dointvec_minmax,
115fe47f8 Matteo Croce        2019-05-26  1293  		.extra1		= SYSCTL_ZERO,
cb16e95fa Petr Holasek        2011-03-23  1294  		.extra2		= &two,
^1da177e4 Linus Torvalds      2005-04-16  1295  	},
^1da177e4 Linus Torvalds      2005-04-16  1296  	{
fadd8fbd1 KAMEZAWA Hiroyuki   2006-06-23  1297  		.procname	= "panic_on_oom",
fadd8fbd1 KAMEZAWA Hiroyuki   2006-06-23  1298  		.data		= &sysctl_panic_on_oom,
fadd8fbd1 KAMEZAWA Hiroyuki   2006-06-23  1299  		.maxlen		= sizeof(sysctl_panic_on_oom),
fadd8fbd1 KAMEZAWA Hiroyuki   2006-06-23  1300  		.mode		= 0644,
cb16e95fa Petr Holasek        2011-03-23  1301  		.proc_handler	= proc_dointvec_minmax,
115fe47f8 Matteo Croce        2019-05-26  1302  		.extra1		= SYSCTL_ZERO,
cb16e95fa Petr Holasek        2011-03-23  1303  		.extra2		= &two,
fadd8fbd1 KAMEZAWA Hiroyuki   2006-06-23  1304  	},
fadd8fbd1 KAMEZAWA Hiroyuki   2006-06-23  1305  	{
fe071d7e8 David Rientjes      2007-10-16  1306  		.procname	= "oom_kill_allocating_task",
fe071d7e8 David Rientjes      2007-10-16  1307  		.data		= &sysctl_oom_kill_allocating_task,
fe071d7e8 David Rientjes      2007-10-16  1308  		.maxlen		= sizeof(sysctl_oom_kill_allocating_task),
fe071d7e8 David Rientjes      2007-10-16  1309  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1310  		.proc_handler	= proc_dointvec,
fe071d7e8 David Rientjes      2007-10-16  1311  	},
fe071d7e8 David Rientjes      2007-10-16  1312  	{
fef1bdd68 David Rientjes      2008-02-07  1313  		.procname	= "oom_dump_tasks",
fef1bdd68 David Rientjes      2008-02-07  1314  		.data		= &sysctl_oom_dump_tasks,
fef1bdd68 David Rientjes      2008-02-07  1315  		.maxlen		= sizeof(sysctl_oom_dump_tasks),
fef1bdd68 David Rientjes      2008-02-07  1316  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1317  		.proc_handler	= proc_dointvec,
fef1bdd68 David Rientjes      2008-02-07  1318  	},
fef1bdd68 David Rientjes      2008-02-07  1319  	{
^1da177e4 Linus Torvalds      2005-04-16  1320  		.procname	= "overcommit_ratio",
^1da177e4 Linus Torvalds      2005-04-16  1321  		.data		= &sysctl_overcommit_ratio,
^1da177e4 Linus Torvalds      2005-04-16  1322  		.maxlen		= sizeof(sysctl_overcommit_ratio),
^1da177e4 Linus Torvalds      2005-04-16  1323  		.mode		= 0644,
49f0ce5f9 Jerome Marchand     2014-01-21  1324  		.proc_handler	= overcommit_ratio_handler,
49f0ce5f9 Jerome Marchand     2014-01-21  1325  	},
49f0ce5f9 Jerome Marchand     2014-01-21  1326  	{
49f0ce5f9 Jerome Marchand     2014-01-21  1327  		.procname	= "overcommit_kbytes",
49f0ce5f9 Jerome Marchand     2014-01-21  1328  		.data		= &sysctl_overcommit_kbytes,
49f0ce5f9 Jerome Marchand     2014-01-21  1329  		.maxlen		= sizeof(sysctl_overcommit_kbytes),
49f0ce5f9 Jerome Marchand     2014-01-21  1330  		.mode		= 0644,
49f0ce5f9 Jerome Marchand     2014-01-21  1331  		.proc_handler	= overcommit_kbytes_handler,
^1da177e4 Linus Torvalds      2005-04-16  1332  	},
^1da177e4 Linus Torvalds      2005-04-16  1333  	{
^1da177e4 Linus Torvalds      2005-04-16  1334  		.procname	= "page-cluster", 
^1da177e4 Linus Torvalds      2005-04-16  1335  		.data		= &page_cluster,
^1da177e4 Linus Torvalds      2005-04-16  1336  		.maxlen		= sizeof(int),
^1da177e4 Linus Torvalds      2005-04-16  1337  		.mode		= 0644,
cb16e95fa Petr Holasek        2011-03-23  1338  		.proc_handler	= proc_dointvec_minmax,
115fe47f8 Matteo Croce        2019-05-26  1339  		.extra1		= SYSCTL_ZERO,
^1da177e4 Linus Torvalds      2005-04-16  1340  	},
^1da177e4 Linus Torvalds      2005-04-16  1341  	{
^1da177e4 Linus Torvalds      2005-04-16  1342  		.procname	= "dirty_background_ratio",
^1da177e4 Linus Torvalds      2005-04-16  1343  		.data		= &dirty_background_ratio,
^1da177e4 Linus Torvalds      2005-04-16  1344  		.maxlen		= sizeof(dirty_background_ratio),
^1da177e4 Linus Torvalds      2005-04-16  1345  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1346  		.proc_handler	= dirty_background_ratio_handler,
115fe47f8 Matteo Croce        2019-05-26  1347  		.extra1		= SYSCTL_ZERO,
^1da177e4 Linus Torvalds      2005-04-16  1348  		.extra2		= &one_hundred,
^1da177e4 Linus Torvalds      2005-04-16  1349  	},
^1da177e4 Linus Torvalds      2005-04-16  1350  	{
2da02997e David Rientjes      2009-01-06  1351  		.procname	= "dirty_background_bytes",
2da02997e David Rientjes      2009-01-06  1352  		.data		= &dirty_background_bytes,
2da02997e David Rientjes      2009-01-06  1353  		.maxlen		= sizeof(dirty_background_bytes),
2da02997e David Rientjes      2009-01-06  1354  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1355  		.proc_handler	= dirty_background_bytes_handler,
fc3501d41 Sven Wegener        2009-02-11  1356  		.extra1		= &one_ul,
2da02997e David Rientjes      2009-01-06  1357  	},
2da02997e David Rientjes      2009-01-06  1358  	{
^1da177e4 Linus Torvalds      2005-04-16  1359  		.procname	= "dirty_ratio",
^1da177e4 Linus Torvalds      2005-04-16  1360  		.data		= &vm_dirty_ratio,
^1da177e4 Linus Torvalds      2005-04-16  1361  		.maxlen		= sizeof(vm_dirty_ratio),
^1da177e4 Linus Torvalds      2005-04-16  1362  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1363  		.proc_handler	= dirty_ratio_handler,
115fe47f8 Matteo Croce        2019-05-26  1364  		.extra1		= SYSCTL_ZERO,
^1da177e4 Linus Torvalds      2005-04-16  1365  		.extra2		= &one_hundred,
^1da177e4 Linus Torvalds      2005-04-16  1366  	},
^1da177e4 Linus Torvalds      2005-04-16  1367  	{
2da02997e David Rientjes      2009-01-06  1368  		.procname	= "dirty_bytes",
2da02997e David Rientjes      2009-01-06  1369  		.data		= &vm_dirty_bytes,
2da02997e David Rientjes      2009-01-06  1370  		.maxlen		= sizeof(vm_dirty_bytes),
2da02997e David Rientjes      2009-01-06  1371  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1372  		.proc_handler	= dirty_bytes_handler,
9e4a5bda8 Andrea Righi        2009-04-30  1373  		.extra1		= &dirty_bytes_min,
2da02997e David Rientjes      2009-01-06  1374  	},
2da02997e David Rientjes      2009-01-06  1375  	{
^1da177e4 Linus Torvalds      2005-04-16  1376  		.procname	= "dirty_writeback_centisecs",
f6ef94381 Bart Samwel         2006-03-24  1377  		.data		= &dirty_writeback_interval,
f6ef94381 Bart Samwel         2006-03-24  1378  		.maxlen		= sizeof(dirty_writeback_interval),
^1da177e4 Linus Torvalds      2005-04-16  1379  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1380  		.proc_handler	= dirty_writeback_centisecs_handler,
^1da177e4 Linus Torvalds      2005-04-16  1381  	},
^1da177e4 Linus Torvalds      2005-04-16  1382  	{
^1da177e4 Linus Torvalds      2005-04-16  1383  		.procname	= "dirty_expire_centisecs",
f6ef94381 Bart Samwel         2006-03-24  1384  		.data		= &dirty_expire_interval,
f6ef94381 Bart Samwel         2006-03-24  1385  		.maxlen		= sizeof(dirty_expire_interval),
^1da177e4 Linus Torvalds      2005-04-16  1386  		.mode		= 0644,
cb16e95fa Petr Holasek        2011-03-23  1387  		.proc_handler	= proc_dointvec_minmax,
115fe47f8 Matteo Croce        2019-05-26  1388  		.extra1		= SYSCTL_ZERO,
^1da177e4 Linus Torvalds      2005-04-16  1389  	},
^1da177e4 Linus Torvalds      2005-04-16  1390  	{
1efff914a Theodore Ts'o       2015-03-17  1391  		.procname	= "dirtytime_expire_seconds",
1efff914a Theodore Ts'o       2015-03-17  1392  		.data		= &dirtytime_expire_interval,
2d87b309a Randy Dunlap        2018-04-10  1393  		.maxlen		= sizeof(dirtytime_expire_interval),
1efff914a Theodore Ts'o       2015-03-17  1394  		.mode		= 0644,
1efff914a Theodore Ts'o       2015-03-17  1395  		.proc_handler	= dirtytime_interval_handler,
115fe47f8 Matteo Croce        2019-05-26  1396  		.extra1		= SYSCTL_ZERO,
1efff914a Theodore Ts'o       2015-03-17  1397  	},
1efff914a Theodore Ts'o       2015-03-17  1398  	{
^1da177e4 Linus Torvalds      2005-04-16  1399  		.procname	= "swappiness",
^1da177e4 Linus Torvalds      2005-04-16  1400  		.data		= &vm_swappiness,
^1da177e4 Linus Torvalds      2005-04-16  1401  		.maxlen		= sizeof(vm_swappiness),
^1da177e4 Linus Torvalds      2005-04-16  1402  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1403  		.proc_handler	= proc_dointvec_minmax,
115fe47f8 Matteo Croce        2019-05-26  1404  		.extra1		= SYSCTL_ZERO,
^1da177e4 Linus Torvalds      2005-04-16  1405  		.extra2		= &one_hundred,
^1da177e4 Linus Torvalds      2005-04-16  1406  	},
^1da177e4 Linus Torvalds      2005-04-16  1407  #ifdef CONFIG_HUGETLB_PAGE
^1da177e4 Linus Torvalds      2005-04-16  1408  	{
^1da177e4 Linus Torvalds      2005-04-16  1409  		.procname	= "nr_hugepages",
e5ff21594 Andi Kleen          2008-07-23  1410  		.data		= NULL,
^1da177e4 Linus Torvalds      2005-04-16  1411  		.maxlen		= sizeof(unsigned long),
^1da177e4 Linus Torvalds      2005-04-16  1412  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1413  		.proc_handler	= hugetlb_sysctl_handler,
^1da177e4 Linus Torvalds      2005-04-16  1414  	},
06808b082 Lee Schermerhorn    2009-12-14  1415  #ifdef CONFIG_NUMA
06808b082 Lee Schermerhorn    2009-12-14  1416  	{
06808b082 Lee Schermerhorn    2009-12-14  1417  		.procname       = "nr_hugepages_mempolicy",
06808b082 Lee Schermerhorn    2009-12-14  1418  		.data           = NULL,
06808b082 Lee Schermerhorn    2009-12-14  1419  		.maxlen         = sizeof(unsigned long),
06808b082 Lee Schermerhorn    2009-12-14  1420  		.mode           = 0644,
06808b082 Lee Schermerhorn    2009-12-14  1421  		.proc_handler   = &hugetlb_mempolicy_sysctl_handler,
06808b082 Lee Schermerhorn    2009-12-14  1422  	},
4518085e1 Kemi Wang           2017-11-15  1423  	{
4518085e1 Kemi Wang           2017-11-15  1424  		.procname		= "numa_stat",
4518085e1 Kemi Wang           2017-11-15  1425  		.data			= &sysctl_vm_numa_stat,
4518085e1 Kemi Wang           2017-11-15  1426  		.maxlen			= sizeof(int),
4518085e1 Kemi Wang           2017-11-15  1427  		.mode			= 0644,
4518085e1 Kemi Wang           2017-11-15  1428  		.proc_handler	= sysctl_vm_numa_stat_handler,
115fe47f8 Matteo Croce        2019-05-26  1429  		.extra1			= SYSCTL_ZERO,
115fe47f8 Matteo Croce        2019-05-26  1430  		.extra2			= SYSCTL_ONE,
4518085e1 Kemi Wang           2017-11-15  1431  	},
06808b082 Lee Schermerhorn    2009-12-14  1432  #endif
^1da177e4 Linus Torvalds      2005-04-16  1433  	 {
^1da177e4 Linus Torvalds      2005-04-16  1434  		.procname	= "hugetlb_shm_group",
^1da177e4 Linus Torvalds      2005-04-16  1435  		.data		= &sysctl_hugetlb_shm_group,
^1da177e4 Linus Torvalds      2005-04-16  1436  		.maxlen		= sizeof(gid_t),
^1da177e4 Linus Torvalds      2005-04-16  1437  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1438  		.proc_handler	= proc_dointvec,
^1da177e4 Linus Torvalds      2005-04-16  1439  	 },
396faf030 Mel Gorman          2007-07-17  1440  	{
d1c3fb1f8 Nishanth Aravamudan 2007-12-17  1441  		.procname	= "nr_overcommit_hugepages",
e5ff21594 Andi Kleen          2008-07-23  1442  		.data		= NULL,
e5ff21594 Andi Kleen          2008-07-23  1443  		.maxlen		= sizeof(unsigned long),
d1c3fb1f8 Nishanth Aravamudan 2007-12-17  1444  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1445  		.proc_handler	= hugetlb_overcommit_handler,
d1c3fb1f8 Nishanth Aravamudan 2007-12-17  1446  	},
^1da177e4 Linus Torvalds      2005-04-16  1447  #endif
^1da177e4 Linus Torvalds      2005-04-16  1448  	{
^1da177e4 Linus Torvalds      2005-04-16  1449  		.procname	= "lowmem_reserve_ratio",
^1da177e4 Linus Torvalds      2005-04-16  1450  		.data		= &sysctl_lowmem_reserve_ratio,
^1da177e4 Linus Torvalds      2005-04-16  1451  		.maxlen		= sizeof(sysctl_lowmem_reserve_ratio),
^1da177e4 Linus Torvalds      2005-04-16  1452  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1453  		.proc_handler	= lowmem_reserve_ratio_sysctl_handler,
^1da177e4 Linus Torvalds      2005-04-16  1454  	},
^1da177e4 Linus Torvalds      2005-04-16  1455  	{
9d0243bca Andrew Morton       2006-01-08  1456  		.procname	= "drop_caches",
9d0243bca Andrew Morton       2006-01-08  1457  		.data		= &sysctl_drop_caches,
9d0243bca Andrew Morton       2006-01-08  1458  		.maxlen		= sizeof(int),
9d0243bca Andrew Morton       2006-01-08  1459  		.mode		= 0644,
9d0243bca Andrew Morton       2006-01-08  1460  		.proc_handler	= drop_caches_sysctl_handler,
115fe47f8 Matteo Croce        2019-05-26  1461  		.extra1		= SYSCTL_ONE,
5509a5d27 Dave Hansen         2014-04-03  1462  		.extra2		= &four,
9d0243bca Andrew Morton       2006-01-08  1463  	},
76ab0f530 Mel Gorman          2010-05-24  1464  #ifdef CONFIG_COMPACTION
76ab0f530 Mel Gorman          2010-05-24  1465  	{
76ab0f530 Mel Gorman          2010-05-24  1466  		.procname	= "compact_memory",
76ab0f530 Mel Gorman          2010-05-24  1467  		.data		= &sysctl_compact_memory,
76ab0f530 Mel Gorman          2010-05-24  1468  		.maxlen		= sizeof(int),
76ab0f530 Mel Gorman          2010-05-24  1469  		.mode		= 0200,
76ab0f530 Mel Gorman          2010-05-24  1470  		.proc_handler	= sysctl_compaction_handler,
76ab0f530 Mel Gorman          2010-05-24  1471  	},
5e7719058 Mel Gorman          2010-05-24  1472  	{
5e7719058 Mel Gorman          2010-05-24  1473  		.procname	= "extfrag_threshold",
5e7719058 Mel Gorman          2010-05-24  1474  		.data		= &sysctl_extfrag_threshold,
5e7719058 Mel Gorman          2010-05-24  1475  		.maxlen		= sizeof(int),
5e7719058 Mel Gorman          2010-05-24  1476  		.mode		= 0644,
6b7e5cad6 Matthew Wilcox      2019-03-05  1477  		.proc_handler	= proc_dointvec_minmax,
5e7719058 Mel Gorman          2010-05-24  1478  		.extra1		= &min_extfrag_threshold,
5e7719058 Mel Gorman          2010-05-24  1479  		.extra2		= &max_extfrag_threshold,
5e7719058 Mel Gorman          2010-05-24  1480  	},
5bbe3547a Eric B Munson       2015-04-15  1481  	{
5bbe3547a Eric B Munson       2015-04-15  1482  		.procname	= "compact_unevictable_allowed",
5bbe3547a Eric B Munson       2015-04-15  1483  		.data		= &sysctl_compact_unevictable_allowed,
5bbe3547a Eric B Munson       2015-04-15  1484  		.maxlen		= sizeof(int),
5bbe3547a Eric B Munson       2015-04-15  1485  		.mode		= 0644,
5bbe3547a Eric B Munson       2015-04-15  1486  		.proc_handler	= proc_dointvec,
115fe47f8 Matteo Croce        2019-05-26  1487  		.extra1		= SYSCTL_ZERO,
115fe47f8 Matteo Croce        2019-05-26  1488  		.extra2		= SYSCTL_ONE,
5bbe3547a Eric B Munson       2015-04-15  1489  	},
5e7719058 Mel Gorman          2010-05-24  1490  
76ab0f530 Mel Gorman          2010-05-24  1491  #endif /* CONFIG_COMPACTION */
9d0243bca Andrew Morton       2006-01-08  1492  	{
^1da177e4 Linus Torvalds      2005-04-16  1493  		.procname	= "min_free_kbytes",
^1da177e4 Linus Torvalds      2005-04-16  1494  		.data		= &min_free_kbytes,
^1da177e4 Linus Torvalds      2005-04-16  1495  		.maxlen		= sizeof(min_free_kbytes),
^1da177e4 Linus Torvalds      2005-04-16  1496  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1497  		.proc_handler	= min_free_kbytes_sysctl_handler,
115fe47f8 Matteo Croce        2019-05-26  1498  		.extra1		= SYSCTL_ZERO,
^1da177e4 Linus Torvalds      2005-04-16  1499  	},
8ad4b1fb8 Rohit Seth          2006-01-08  1500  	{
1c30844d2 Mel Gorman          2018-12-28  1501  		.procname	= "watermark_boost_factor",
1c30844d2 Mel Gorman          2018-12-28  1502  		.data		= &watermark_boost_factor,
1c30844d2 Mel Gorman          2018-12-28  1503  		.maxlen		= sizeof(watermark_boost_factor),
1c30844d2 Mel Gorman          2018-12-28  1504  		.mode		= 0644,
1c30844d2 Mel Gorman          2018-12-28  1505  		.proc_handler	= watermark_boost_factor_sysctl_handler,
115fe47f8 Matteo Croce        2019-05-26  1506  		.extra1		= SYSCTL_ZERO,
1c30844d2 Mel Gorman          2018-12-28  1507  	},
1c30844d2 Mel Gorman          2018-12-28  1508  	{
795ae7a0d Johannes Weiner     2016-03-17  1509  		.procname	= "watermark_scale_factor",
795ae7a0d Johannes Weiner     2016-03-17  1510  		.data		= &watermark_scale_factor,
795ae7a0d Johannes Weiner     2016-03-17  1511  		.maxlen		= sizeof(watermark_scale_factor),
795ae7a0d Johannes Weiner     2016-03-17  1512  		.mode		= 0644,
795ae7a0d Johannes Weiner     2016-03-17  1513  		.proc_handler	= watermark_scale_factor_sysctl_handler,
115fe47f8 Matteo Croce        2019-05-26  1514  		.extra1		= SYSCTL_ONE,
795ae7a0d Johannes Weiner     2016-03-17  1515  		.extra2		= &one_thousand,
795ae7a0d Johannes Weiner     2016-03-17  1516  	},
795ae7a0d Johannes Weiner     2016-03-17  1517  	{
8ad4b1fb8 Rohit Seth          2006-01-08  1518  		.procname	= "percpu_pagelist_fraction",
8ad4b1fb8 Rohit Seth          2006-01-08  1519  		.data		= &percpu_pagelist_fraction,
8ad4b1fb8 Rohit Seth          2006-01-08  1520  		.maxlen		= sizeof(percpu_pagelist_fraction),
8ad4b1fb8 Rohit Seth          2006-01-08  1521  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1522  		.proc_handler	= percpu_pagelist_fraction_sysctl_handler,
115fe47f8 Matteo Croce        2019-05-26  1523  		.extra1		= SYSCTL_ZERO,
8ad4b1fb8 Rohit Seth          2006-01-08  1524  	},
^1da177e4 Linus Torvalds      2005-04-16  1525  #ifdef CONFIG_MMU
^1da177e4 Linus Torvalds      2005-04-16  1526  	{
^1da177e4 Linus Torvalds      2005-04-16  1527  		.procname	= "max_map_count",
^1da177e4 Linus Torvalds      2005-04-16  1528  		.data		= &sysctl_max_map_count,
^1da177e4 Linus Torvalds      2005-04-16  1529  		.maxlen		= sizeof(sysctl_max_map_count),
^1da177e4 Linus Torvalds      2005-04-16  1530  		.mode		= 0644,
3e26120cc WANG Cong           2009-12-17  1531  		.proc_handler	= proc_dointvec_minmax,
115fe47f8 Matteo Croce        2019-05-26  1532  		.extra1		= SYSCTL_ZERO,
^1da177e4 Linus Torvalds      2005-04-16  1533  	},
dd8632a12 Paul Mundt          2009-01-08  1534  #else
dd8632a12 Paul Mundt          2009-01-08  1535  	{
dd8632a12 Paul Mundt          2009-01-08  1536  		.procname	= "nr_trim_pages",
dd8632a12 Paul Mundt          2009-01-08  1537  		.data		= &sysctl_nr_trim_pages,
dd8632a12 Paul Mundt          2009-01-08  1538  		.maxlen		= sizeof(sysctl_nr_trim_pages),
dd8632a12 Paul Mundt          2009-01-08  1539  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1540  		.proc_handler	= proc_dointvec_minmax,
115fe47f8 Matteo Croce        2019-05-26  1541  		.extra1		= SYSCTL_ZERO,
dd8632a12 Paul Mundt          2009-01-08  1542  	},
^1da177e4 Linus Torvalds      2005-04-16  1543  #endif
^1da177e4 Linus Torvalds      2005-04-16  1544  	{
^1da177e4 Linus Torvalds      2005-04-16  1545  		.procname	= "laptop_mode",
^1da177e4 Linus Torvalds      2005-04-16  1546  		.data		= &laptop_mode,
^1da177e4 Linus Torvalds      2005-04-16  1547  		.maxlen		= sizeof(laptop_mode),
^1da177e4 Linus Torvalds      2005-04-16  1548  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1549  		.proc_handler	= proc_dointvec_jiffies,
^1da177e4 Linus Torvalds      2005-04-16  1550  	},
^1da177e4 Linus Torvalds      2005-04-16  1551  	{
^1da177e4 Linus Torvalds      2005-04-16  1552  		.procname	= "block_dump",
^1da177e4 Linus Torvalds      2005-04-16  1553  		.data		= &block_dump,
^1da177e4 Linus Torvalds      2005-04-16  1554  		.maxlen		= sizeof(block_dump),
^1da177e4 Linus Torvalds      2005-04-16  1555  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1556  		.proc_handler	= proc_dointvec,
115fe47f8 Matteo Croce        2019-05-26  1557  		.extra1		= SYSCTL_ZERO,
^1da177e4 Linus Torvalds      2005-04-16  1558  	},
^1da177e4 Linus Torvalds      2005-04-16  1559  	{
^1da177e4 Linus Torvalds      2005-04-16  1560  		.procname	= "vfs_cache_pressure",
^1da177e4 Linus Torvalds      2005-04-16  1561  		.data		= &sysctl_vfs_cache_pressure,
^1da177e4 Linus Torvalds      2005-04-16  1562  		.maxlen		= sizeof(sysctl_vfs_cache_pressure),
^1da177e4 Linus Torvalds      2005-04-16  1563  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1564  		.proc_handler	= proc_dointvec,
115fe47f8 Matteo Croce        2019-05-26  1565  		.extra1		= SYSCTL_ZERO,
^1da177e4 Linus Torvalds      2005-04-16  1566  	},
^1da177e4 Linus Torvalds      2005-04-16  1567  #ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
^1da177e4 Linus Torvalds      2005-04-16  1568  	{
^1da177e4 Linus Torvalds      2005-04-16  1569  		.procname	= "legacy_va_layout",
^1da177e4 Linus Torvalds      2005-04-16  1570  		.data		= &sysctl_legacy_va_layout,
^1da177e4 Linus Torvalds      2005-04-16  1571  		.maxlen		= sizeof(sysctl_legacy_va_layout),
^1da177e4 Linus Torvalds      2005-04-16  1572  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1573  		.proc_handler	= proc_dointvec,
115fe47f8 Matteo Croce        2019-05-26  1574  		.extra1		= SYSCTL_ZERO,
^1da177e4 Linus Torvalds      2005-04-16  1575  	},
^1da177e4 Linus Torvalds      2005-04-16  1576  #endif
1743660b9 Christoph Lameter   2006-01-18  1577  #ifdef CONFIG_NUMA
1743660b9 Christoph Lameter   2006-01-18  1578  	{
1743660b9 Christoph Lameter   2006-01-18  1579  		.procname	= "zone_reclaim_mode",
a5f5f91da Mel Gorman          2016-07-28  1580  		.data		= &node_reclaim_mode,
a5f5f91da Mel Gorman          2016-07-28  1581  		.maxlen		= sizeof(node_reclaim_mode),
1743660b9 Christoph Lameter   2006-01-18  1582  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1583  		.proc_handler	= proc_dointvec,
115fe47f8 Matteo Croce        2019-05-26  1584  		.extra1		= SYSCTL_ZERO,
1743660b9 Christoph Lameter   2006-01-18  1585  	},
9614634fe Christoph Lameter   2006-07-03  1586  	{
9614634fe Christoph Lameter   2006-07-03  1587  		.procname	= "min_unmapped_ratio",
9614634fe Christoph Lameter   2006-07-03  1588  		.data		= &sysctl_min_unmapped_ratio,
9614634fe Christoph Lameter   2006-07-03  1589  		.maxlen		= sizeof(sysctl_min_unmapped_ratio),
9614634fe Christoph Lameter   2006-07-03  1590  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1591  		.proc_handler	= sysctl_min_unmapped_ratio_sysctl_handler,
115fe47f8 Matteo Croce        2019-05-26  1592  		.extra1		= SYSCTL_ZERO,
9614634fe Christoph Lameter   2006-07-03  1593  		.extra2		= &one_hundred,
9614634fe Christoph Lameter   2006-07-03  1594  	},
0ff38490c Christoph Lameter   2006-09-25  1595  	{
0ff38490c Christoph Lameter   2006-09-25  1596  		.procname	= "min_slab_ratio",
0ff38490c Christoph Lameter   2006-09-25  1597  		.data		= &sysctl_min_slab_ratio,
0ff38490c Christoph Lameter   2006-09-25  1598  		.maxlen		= sizeof(sysctl_min_slab_ratio),
0ff38490c Christoph Lameter   2006-09-25  1599  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1600  		.proc_handler	= sysctl_min_slab_ratio_sysctl_handler,
115fe47f8 Matteo Croce        2019-05-26  1601  		.extra1		= SYSCTL_ZERO,
0ff38490c Christoph Lameter   2006-09-25  1602  		.extra2		= &one_hundred,
0ff38490c Christoph Lameter   2006-09-25  1603  	},
1743660b9 Christoph Lameter   2006-01-18  1604  #endif
77461ab33 Christoph Lameter   2007-05-09  1605  #ifdef CONFIG_SMP
77461ab33 Christoph Lameter   2007-05-09  1606  	{
77461ab33 Christoph Lameter   2007-05-09  1607  		.procname	= "stat_interval",
77461ab33 Christoph Lameter   2007-05-09  1608  		.data		= &sysctl_stat_interval,
77461ab33 Christoph Lameter   2007-05-09  1609  		.maxlen		= sizeof(sysctl_stat_interval),
77461ab33 Christoph Lameter   2007-05-09  1610  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1611  		.proc_handler	= proc_dointvec_jiffies,
77461ab33 Christoph Lameter   2007-05-09  1612  	},
52b6f46bc Hugh Dickins        2016-05-19  1613  	{
52b6f46bc Hugh Dickins        2016-05-19  1614  		.procname	= "stat_refresh",
52b6f46bc Hugh Dickins        2016-05-19  1615  		.data		= NULL,
52b6f46bc Hugh Dickins        2016-05-19  1616  		.maxlen		= 0,
52b6f46bc Hugh Dickins        2016-05-19  1617  		.mode		= 0600,
52b6f46bc Hugh Dickins        2016-05-19  1618  		.proc_handler	= vmstat_refresh,
52b6f46bc Hugh Dickins        2016-05-19  1619  	},
77461ab33 Christoph Lameter   2007-05-09  1620  #endif
6e1415467 David Howells       2009-12-15  1621  #ifdef CONFIG_MMU
ed0321895 Eric Paris          2007-06-28  1622  	{
ed0321895 Eric Paris          2007-06-28  1623  		.procname	= "mmap_min_addr",
788084aba Eric Paris          2009-07-31  1624  		.data		= &dac_mmap_min_addr,
ed0321895 Eric Paris          2007-06-28  1625  		.maxlen		= sizeof(unsigned long),
ed0321895 Eric Paris          2007-06-28  1626  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1627  		.proc_handler	= mmap_min_addr_handler,
ed0321895 Eric Paris          2007-06-28  1628  	},
6e1415467 David Howells       2009-12-15  1629  #endif
f0c0b2b80 KAMEZAWA Hiroyuki   2007-07-15  1630  #ifdef CONFIG_NUMA
f0c0b2b80 KAMEZAWA Hiroyuki   2007-07-15  1631  	{
f0c0b2b80 KAMEZAWA Hiroyuki   2007-07-15  1632  		.procname	= "numa_zonelist_order",
f0c0b2b80 KAMEZAWA Hiroyuki   2007-07-15  1633  		.data		= &numa_zonelist_order,
f0c0b2b80 KAMEZAWA Hiroyuki   2007-07-15  1634  		.maxlen		= NUMA_ZONELIST_ORDER_LEN,
f0c0b2b80 KAMEZAWA Hiroyuki   2007-07-15  1635  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1636  		.proc_handler	= numa_zonelist_order_handler,
f0c0b2b80 KAMEZAWA Hiroyuki   2007-07-15  1637  	},
f0c0b2b80 KAMEZAWA Hiroyuki   2007-07-15  1638  #endif
2b8232ce5 Al Viro             2007-10-13  1639  #if (defined(CONFIG_X86_32) && !defined(CONFIG_UML))|| \
5c36e6578 Paul Mundt          2007-03-01  1640     (defined(CONFIG_SUPERH) && defined(CONFIG_VSYSCALL))
e6e5494cb Ingo Molnar         2006-06-27  1641  	{
e6e5494cb Ingo Molnar         2006-06-27  1642  		.procname	= "vdso_enabled",
3d7ee969b Andy Lutomirski     2014-05-05  1643  #ifdef CONFIG_X86_32
3d7ee969b Andy Lutomirski     2014-05-05  1644  		.data		= &vdso32_enabled,
3d7ee969b Andy Lutomirski     2014-05-05  1645  		.maxlen		= sizeof(vdso32_enabled),
3d7ee969b Andy Lutomirski     2014-05-05  1646  #else
e6e5494cb Ingo Molnar         2006-06-27  1647  		.data		= &vdso_enabled,
e6e5494cb Ingo Molnar         2006-06-27  1648  		.maxlen		= sizeof(vdso_enabled),
3d7ee969b Andy Lutomirski     2014-05-05  1649  #endif
e6e5494cb Ingo Molnar         2006-06-27  1650  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1651  		.proc_handler	= proc_dointvec,
115fe47f8 Matteo Croce        2019-05-26  1652  		.extra1		= SYSCTL_ZERO,
e6e5494cb Ingo Molnar         2006-06-27  1653  	},
e6e5494cb Ingo Molnar         2006-06-27  1654  #endif
195cf453d Bron Gondwana       2008-02-04  1655  #ifdef CONFIG_HIGHMEM
195cf453d Bron Gondwana       2008-02-04  1656  	{
195cf453d Bron Gondwana       2008-02-04  1657  		.procname	= "highmem_is_dirtyable",
195cf453d Bron Gondwana       2008-02-04  1658  		.data		= &vm_highmem_is_dirtyable,
195cf453d Bron Gondwana       2008-02-04  1659  		.maxlen		= sizeof(vm_highmem_is_dirtyable),
195cf453d Bron Gondwana       2008-02-04  1660  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1661  		.proc_handler	= proc_dointvec_minmax,
115fe47f8 Matteo Croce        2019-05-26  1662  		.extra1		= SYSCTL_ZERO,
115fe47f8 Matteo Croce        2019-05-26  1663  		.extra2		= SYSCTL_ONE,
195cf453d Bron Gondwana       2008-02-04  1664  	},
195cf453d Bron Gondwana       2008-02-04  1665  #endif
6a46079cf Andi Kleen          2009-09-16  1666  #ifdef CONFIG_MEMORY_FAILURE
6a46079cf Andi Kleen          2009-09-16  1667  	{
6a46079cf Andi Kleen          2009-09-16  1668  		.procname	= "memory_failure_early_kill",
6a46079cf Andi Kleen          2009-09-16  1669  		.data		= &sysctl_memory_failure_early_kill,
6a46079cf Andi Kleen          2009-09-16  1670  		.maxlen		= sizeof(sysctl_memory_failure_early_kill),
6a46079cf Andi Kleen          2009-09-16  1671  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1672  		.proc_handler	= proc_dointvec_minmax,
115fe47f8 Matteo Croce        2019-05-26  1673  		.extra1		= SYSCTL_ZERO,
115fe47f8 Matteo Croce        2019-05-26  1674  		.extra2		= SYSCTL_ONE,
6a46079cf Andi Kleen          2009-09-16  1675  	},
6a46079cf Andi Kleen          2009-09-16  1676  	{
6a46079cf Andi Kleen          2009-09-16  1677  		.procname	= "memory_failure_recovery",
6a46079cf Andi Kleen          2009-09-16  1678  		.data		= &sysctl_memory_failure_recovery,
6a46079cf Andi Kleen          2009-09-16  1679  		.maxlen		= sizeof(sysctl_memory_failure_recovery),
6a46079cf Andi Kleen          2009-09-16  1680  		.mode		= 0644,
6d4561110 Eric W. Biederman   2009-11-16  1681  		.proc_handler	= proc_dointvec_minmax,
115fe47f8 Matteo Croce        2019-05-26  1682  		.extra1		= SYSCTL_ZERO,
115fe47f8 Matteo Croce        2019-05-26  1683  		.extra2		= SYSCTL_ONE,
6a46079cf Andi Kleen          2009-09-16  1684  	},
6a46079cf Andi Kleen          2009-09-16  1685  #endif
c9b1d0981 Andrew Shewmaker    2013-04-29  1686  	{
c9b1d0981 Andrew Shewmaker    2013-04-29  1687  		.procname	= "user_reserve_kbytes",
c9b1d0981 Andrew Shewmaker    2013-04-29  1688  		.data		= &sysctl_user_reserve_kbytes,
c9b1d0981 Andrew Shewmaker    2013-04-29  1689  		.maxlen		= sizeof(sysctl_user_reserve_kbytes),
c9b1d0981 Andrew Shewmaker    2013-04-29  1690  		.mode		= 0644,
c9b1d0981 Andrew Shewmaker    2013-04-29  1691  		.proc_handler	= proc_doulongvec_minmax,
c9b1d0981 Andrew Shewmaker    2013-04-29  1692  	},
4eeab4f55 Andrew Shewmaker    2013-04-29  1693  	{
4eeab4f55 Andrew Shewmaker    2013-04-29  1694  		.procname	= "admin_reserve_kbytes",
4eeab4f55 Andrew Shewmaker    2013-04-29  1695  		.data		= &sysctl_admin_reserve_kbytes,
4eeab4f55 Andrew Shewmaker    2013-04-29  1696  		.maxlen		= sizeof(sysctl_admin_reserve_kbytes),
4eeab4f55 Andrew Shewmaker    2013-04-29  1697  		.mode		= 0644,
4eeab4f55 Andrew Shewmaker    2013-04-29  1698  		.proc_handler	= proc_doulongvec_minmax,
4eeab4f55 Andrew Shewmaker    2013-04-29  1699  	},
d07e22597 Daniel Cashman      2016-01-14  1700  #ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
d07e22597 Daniel Cashman      2016-01-14  1701  	{
d07e22597 Daniel Cashman      2016-01-14  1702  		.procname	= "mmap_rnd_bits",
d07e22597 Daniel Cashman      2016-01-14  1703  		.data		= &mmap_rnd_bits,
d07e22597 Daniel Cashman      2016-01-14  1704  		.maxlen		= sizeof(mmap_rnd_bits),
d07e22597 Daniel Cashman      2016-01-14  1705  		.mode		= 0600,
d07e22597 Daniel Cashman      2016-01-14  1706  		.proc_handler	= proc_dointvec_minmax,
d07e22597 Daniel Cashman      2016-01-14  1707  		.extra1		= (void *)&mmap_rnd_bits_min,
d07e22597 Daniel Cashman      2016-01-14  1708  		.extra2		= (void *)&mmap_rnd_bits_max,
d07e22597 Daniel Cashman      2016-01-14  1709  	},
d07e22597 Daniel Cashman      2016-01-14  1710  #endif
d07e22597 Daniel Cashman      2016-01-14  1711  #ifdef CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS
d07e22597 Daniel Cashman      2016-01-14  1712  	{
d07e22597 Daniel Cashman      2016-01-14  1713  		.procname	= "mmap_rnd_compat_bits",
d07e22597 Daniel Cashman      2016-01-14  1714  		.data		= &mmap_rnd_compat_bits,
d07e22597 Daniel Cashman      2016-01-14  1715  		.maxlen		= sizeof(mmap_rnd_compat_bits),
d07e22597 Daniel Cashman      2016-01-14  1716  		.mode		= 0600,
d07e22597 Daniel Cashman      2016-01-14  1717  		.proc_handler	= proc_dointvec_minmax,
d07e22597 Daniel Cashman      2016-01-14  1718  		.extra1		= (void *)&mmap_rnd_compat_bits_min,
d07e22597 Daniel Cashman      2016-01-14  1719  		.extra2		= (void *)&mmap_rnd_compat_bits_max,
d07e22597 Daniel Cashman      2016-01-14  1720  	},
d07e22597 Daniel Cashman      2016-01-14  1721  #endif
cefdca0a8 Peter Xu            2019-05-13  1722  #ifdef CONFIG_USERFAULTFD
cefdca0a8 Peter Xu            2019-05-13  1723  	{
cefdca0a8 Peter Xu            2019-05-13  1724  		.procname	= "unprivileged_userfaultfd",
cefdca0a8 Peter Xu            2019-05-13  1725  		.data		= &sysctl_unprivileged_userfaultfd,
cefdca0a8 Peter Xu            2019-05-13  1726  		.maxlen		= sizeof(sysctl_unprivileged_userfaultfd),
cefdca0a8 Peter Xu            2019-05-13  1727  		.mode		= 0644,
cefdca0a8 Peter Xu            2019-05-13  1728  		.proc_handler	= proc_dointvec_minmax,
cefdca0a8 Peter Xu            2019-05-13 @1729  		.extra1		= &zero,
cefdca0a8 Peter Xu            2019-05-13 @1730  		.extra2		= &one,
cefdca0a8 Peter Xu            2019-05-13  1731  	},
cefdca0a8 Peter Xu            2019-05-13  1732  #endif
6fce56ec9 Eric W. Biederman   2009-04-03  1733  	{ }
^1da177e4 Linus Torvalds      2005-04-16  1734  };
^1da177e4 Linus Torvalds      2005-04-16  1735  

:::::: The code at line 1729 was first introduced by commit
:::::: cefdca0a86be517bc390fc4541e3674b8e7803b0 userfaultfd/sysctl: add vm.unprivileged_userfaultfd

:::::: TO: Peter Xu <peterx@redhat.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--Kj7319i9nmIyA2yE
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
PhHi3AEA

--Kj7319i9nmIyA2yE--


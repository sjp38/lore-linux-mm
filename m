Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF4C1C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:44:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5209A21734
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:44:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5209A21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C419D6B0008; Wed, 12 Jun 2019 13:44:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCA796B000A; Wed, 12 Jun 2019 13:44:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A46616B000D; Wed, 12 Jun 2019 13:44:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9F06B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:44:04 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 14so11819400pgo.14
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:44:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=eqPABMC9EjtIRg3oIM+b7yR3W1b87WyVdnEdBReL0CI=;
        b=O1YBToM4Z1n02XLt6/7I5NKxgN+YBFzfCFFoYYy4Z2eSBzN/dbvYIX5uJD4tq2DNPm
         VfSTu07a0uEBSAubqR8+RJReMrVuNaYUF2k6m2YcAlFAmpzuc6v/wYT02Kj6R+W1QDq7
         CbsF84KF7Nn66fksXWCOkVqxtMBmUhiu/JoD+6Of5RkxeOwavyn9vY2mofTpoV5jlCOY
         NnepWybFUKRjcwO7Wo7aIN5jqlAbGa10AiPbZHQ3xHVMFt/0LvRwpzI9P5RfsNf3Kw+7
         Cz+Iw6biVlzODUx89iIP6PbuVdTIJlfEbRsBE+Lo1IKJtCJJ0B+YxxzNzJlA49OLPNcQ
         jUiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWF4v73R/LRJQAa2oNXxUCMIO+8JbKSAwfV30ufuWmDkEAoeQhw
	R4Sp7UH7R+0oWsIr9lugTIew12VlfKtBct0CNuYX79b/yCGYR4zQwO1vo0ZSzotuqa49B2uIcxA
	m+jEwX2Aux1eu/AZTcAU0XxGp2YVu4io4cE7vE8yeSREeWg4onm4hGD3NUsvut3raXA==
X-Received: by 2002:a17:902:824:: with SMTP id 33mr85291342plk.29.1560361443591;
        Wed, 12 Jun 2019 10:44:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDMHNypAxOO1fwx7vTMCbnzox2LD4FygCwaF0BFs1Ry5M1S+gOGHVvdnJLbDjtJ1zpayB4
X-Received: by 2002:a17:902:824:: with SMTP id 33mr85291145plk.29.1560361440551;
        Wed, 12 Jun 2019 10:44:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560361440; cv=none;
        d=google.com; s=arc-20160816;
        b=U8L2EgFRdPRQ+7XnG3jgaePjEXpSFHKBtS43YgFym7MpZOOH7smK8cw1+atsqjGcdI
         ZVExz3/RJmFPQaCJoaeUNeSNYjCAGslP6FiZ59LpKDOPTsqkmPqdGwNOMk6rxta4CxzK
         VCLXejNmaIkQubyICYC7ZD4ggeRkN6tn1eyOZ0OBH0gtMPI+qa4w3m00WiG3mMsPq5fy
         sGEDwMFQ8qH+lT3hUTP11sDPUOzd2NVE9hDr3AM028xdsqtpDRXWEZUcixHF+n8tsvbO
         U+QTt/LgC9aPMuPA1ns3mQJz1FmzWYpYXfnUSKrJoZhwTD0gXP8VhLoOt8MrAHt7BBMk
         FYBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=eqPABMC9EjtIRg3oIM+b7yR3W1b87WyVdnEdBReL0CI=;
        b=aTl1a4fCE/FJqSFB3yzG5yf5GOpiVgsXaAlHEnPzB9VCiWkSuUTOsPdyE0KqeS3g/6
         s632XhvBtSJldbaurwbnjjTM7M3wXHmmM/t/5Rkbu63gi9PzyjSRJBlYRoJsw3SyRky5
         I7aopgvQ9pQDGRqany9n0WN4wSUOSvS49QvG4Cmo+YKlMN8MqYTaYqy816BL+BysEzh/
         XtjCeTHuIErAlQlD7+badRe1XDErgspA/3c+6rfN/BvRZ80ywWTyMsNW/6+tC/QO6SHC
         uzM0uTk7Dt6G1Olp7DxCEUTBHaeMbYon/cuPtzIlVPEBSVzAblDVavXf2UPX6HkP5W8I
         DkPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 65si286667ple.240.2019.06.12.10.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 10:44:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Jun 2019 10:43:59 -0700
X-ExtLoop1: 1
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga006.jf.intel.com with ESMTP; 12 Jun 2019 10:43:56 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hb7Hw-00079r-6a; Thu, 13 Jun 2019 01:43:56 +0800
Date: Thu, 13 Jun 2019 01:43:15 +0800
From: kbuild test robot <lkp@intel.com>
To: Matteo Croce <mcroce@redhat.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
	Aaron Tomlin <atomlin@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [liu-song6-linux:uprobe-thp 119/186] kernel/sysctl.c:1730:15: error:
 'one' undeclared here (not in a function); did you mean 'zone'?
Message-ID: <201906130111.tSFtzMVZ%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Matteo,

FYI, the error/warning still remains.

tree:   https://github.com/liu-song-6/linux.git uprobe-thp
head:   9581ef888499040962ffc3287d8fc04ced9c2690
commit: 115fe47f84b1b7e9673aa9ffc0d5a4a9bb0ade15 [119/186] proc/sysctl: add shared variables for range check
config: m68k-sun3_defconfig (attached as .config)
compiler: m68k-linux-gcc (GCC) 7.4.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 115fe47f84b1b7e9673aa9ffc0d5a4a9bb0ade15
        # save the attached .config to linux build tree
        GCC_VERSION=7.4.0 make.cross ARCH=m68k 

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>

All errors (new ones prefixed by >>):

   kernel/sysctl.c:1729:15: error: 'zero' undeclared here (not in a function); did you mean 'zero_ul'?
      .extra1  = &zero,
                  ^~~~
                  zero_ul
>> kernel/sysctl.c:1730:15: error: 'one' undeclared here (not in a function); did you mean 'zone'?
      .extra2  = &one,
                  ^~~
                  zone

vim +1730 kernel/sysctl.c

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

:::::: The code at line 1730 was first introduced by commit
:::::: cefdca0a86be517bc390fc4541e3674b8e7803b0 userfaultfd/sysctl: add vm.unprivileged_userfaultfd

:::::: TO: Peter Xu <peterx@redhat.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--J2SCkAp4GZ/dPZZf
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--J2SCkAp4GZ/dPZZf--


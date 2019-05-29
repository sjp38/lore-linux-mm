Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7391C04AB6
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 01:33:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64B71216FD
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 01:33:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64B71216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF9886B0286; Tue, 28 May 2019 21:33:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA9586B0287; Tue, 28 May 2019 21:33:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4A1A6B0288; Tue, 28 May 2019 21:33:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5948F6B0286
	for <linux-mm@kvack.org>; Tue, 28 May 2019 21:33:13 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x14so428201pln.6
        for <linux-mm@kvack.org>; Tue, 28 May 2019 18:33:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=H8rYww1qsTyC8hiW0h8NdBBVn57hShQ7s3DhM7YyvHw=;
        b=UQzxoQsbGv9HevHf06LI3mpsLc1MwZ8QZh4ql9+cJ930AdLNaSsUJCTwHW04N0EyrX
         U41WcIVdfQt+PnlNiifIDLyIfgKNIflyx5bptdBhUzwVSKzgDywcbCqw9vCrsc1/xBnA
         UtT0uMJ+X3rO+2m/ZVNi+ncZZQA83UreFIPVvtJPfXssxDCvEkmuB77ete76a2+S0Y5d
         +0PZobkeI53m3azBAyIKqPW2X4BJcnc21E8RGvwjCeZ2WwgVYLmbnpo1PUONhi/5oNO3
         vno4750nyrDM0y9/EtYsD4nUuIjyuE6rp9g+xVfPm6JRgBs25OcJcnGXj5+2ppk3wa6S
         caTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWM80njXw5U1X4U6UpNwx0PYtGDz09xWxoSa4GuU9U+YQKH5lmL
	cJFt+A7Fn1TwrAQZWXrY9oWYnBWf9izeZJB27p4LgJWmqnpx6QXENl1YmtyPMavIVMaFQDUQIxy
	O0vQysx/qDVDINZnzP0rhNI3seCLH5xNTOrV3C8qyxOKqRtpnJkjfoZsju4RB2nD+vg==
X-Received: by 2002:a63:110c:: with SMTP id g12mr3390867pgl.18.1559093592674;
        Tue, 28 May 2019 18:33:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOopPPf02XZFfeM1zBSY84feZA/fIZ3jPauGhkEbXUFoZg1q/N8IzAXDfXYbiEw2c28vGV
X-Received: by 2002:a63:110c:: with SMTP id g12mr3390714pgl.18.1559093589579;
        Tue, 28 May 2019 18:33:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559093589; cv=none;
        d=google.com; s=arc-20160816;
        b=mVHtSHokLHkHv60Hg1rIPwKHbGuhmneO727QWXMsNPkPfYfboOs4ST7ZlZkE2gbiCg
         RSy5JtY/uOr5JVsAQ4AIrY9lrPCnVKBNl0G4cT+a88Ij+Vhukm/bQYszYcqXW8+g8/D2
         XNRJXnOdrlbYALgTTh20y2Mmbf91kvxtiKAFTovpnfT6d+drnRDhOQ0O72selMFSxF9t
         qCrwVzBBPMPtmesD8YpxeahCtp5gzN8gSTcPqF4zRTIckgaC49upZ5iqhz5wSOjCaIhZ
         q2/6O4BTHLWVUV66rSQ50bZu8kGKCax1AqjHYq5OnTHP/eVQ87v7j5mRjtJb+vDnSM52
         W93A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=H8rYww1qsTyC8hiW0h8NdBBVn57hShQ7s3DhM7YyvHw=;
        b=aeD+FkopbLX54iUW87kHaz+k2KCmYRzidyFbymmil9xx2PX+fGVl0GC/70spgphQ3w
         +RVyAs0lOVJmNgoPU2mR+OpKTGKwAEq/Ua7wdGJ+De4Xu+g+vz/PK+ldl+4x7kwrIxXl
         BQNxGuCtX3EQmbetAzR80NtUGvr6LKEa87W3AiuMiAP29Ni+BdU9IVIMnTo6h2opesRv
         c745M/JuvSDHvRk4vWF3V2gXs0SNSPy6riB5c+f6/KGcv1whzu3H2sbcXSr3DLehPSgV
         4rwypvz73RqGmK3zdO69sYKI3ipodpJqFmZe8lF8Rp2xl6CIKR/Ae5leorM9VaFNlapz
         lnQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 9si23094501pgu.189.2019.05.28.18.33.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 18:33:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 May 2019 18:33:08 -0700
X-ExtLoop1: 1
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga007.jf.intel.com with ESMTP; 28 May 2019 18:33:06 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hVnSj-000Dv3-VP; Wed, 29 May 2019 09:33:05 +0800
Date: Wed, 29 May 2019 09:32:06 +0800
From: kbuild test robot <lkp@intel.com>
To: Matteo Croce <mcroce@redhat.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
	Aaron Tomlin <atomlin@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [liu-song6-linux:uprobe-thp 119/185] kernel/sysctl.c:1729:15: error:
 'zero' undeclared here (not in a function); did you mean 'zero_ul'?
Message-ID: <201905290901.PIMVaPOB%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="dDRMvlgZJXvWKvBx"
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://github.com/liu-song-6/linux.git uprobe-thp
head:   757cb898eb3096f4ed9487b503748d6e3a4d3332
commit: 115fe47f84b1b7e9673aa9ffc0d5a4a9bb0ade15 [119/185] proc/sysctl: add shared variables for range check
config: x86_64-randconfig-x019-201921 (attached as .config)
compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
reproduce:
        git checkout 115fe47f84b1b7e9673aa9ffc0d5a4a9bb0ade15
        # save the attached .config to linux build tree
        make ARCH=x86_64 

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>

All errors (new ones prefixed by >>):

>> kernel/sysctl.c:1729:15: error: 'zero' undeclared here (not in a function); did you mean 'zero_ul'?
      .extra1  = &zero,
                  ^~~~
                  zero_ul
>> kernel/sysctl.c:1730:15: error: 'one' undeclared here (not in a function); did you mean 'zone'?
      .extra2  = &one,
                  ^~~
                  zone

vim +1729 kernel/sysctl.c

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

--dDRMvlgZJXvWKvBx
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICNPb7VwAAy5jb25maWcAjDxZc9w20u/5FVPOS1JbTiRZUby7pQeQBIfIkAQDgCONXliK
PHZU0eFPx8b+9183wAMAm+NspdZid+PuG435/rvvV+z15fH++uX25vru7uvq0/5h/3T9sv+w
+nh7t//vKpOrWpoVz4T5CYjL24fXLz9/eX/WnZ2ufvnp5Kejt083x2/v749Xm/3Tw/5ulT4+
fLz99Ap93D4+fPf9d/Df9wC8/wzdPf1n9enm5u2vqx+y/R+31w+rX396Bz0c/+j+ANJU1rlY
d2naCd2t0/T86wCCj27LlRayPv/16N3R0Uhbsno9oo68LgqmO6arbi2NnDrqERdM1V3Fdgnv
2lrUwghWiiueTYRC/d5dSLWZIEkrysyIinf80rCk5J2Wykx4UyjOsk7UuYT/6wzT2NjuwNru
693qef/y+nlaKA7c8XrbMbXuSlEJc/7uBDesn6usGgHDGK7N6vZ59fD4gj0MrUuZsnJY+Zs3
FLhjrb94u4JOs9J49AXb8m7DVc3Lbn0lmoncxySAOaFR5VXFaMzl1VILuYQ4BcS4Ad6siPVH
M4tb4bT8VjH+8uoQFqZ4GH1KzCjjOWtL0xVSm5pV/PzNDw+PD/sf30zt9U5vRZMSjRupxWVX
/d7ylk+740OxcWpKj5mV1LqreCXVrmPGsLSYkK3mpUimb9aCFEfbzlRaOAR2zcoyIp+glo1B
JlbPr388f31+2d9PbLzmNVcitSLTKJl40/dRupAXNIbnOU+NwAnlOYil3szpGl5norZySXdS
ibViBmWBRKeFz9oIyWTFRE3BukJwhXuzWxiKGQWnAjsDsmakoqkU11xt7ZS6SmY8HCmXKuVZ
rzRgYRNWN0xpvrzQjCftOteW5fcPH1aPH6ODmXSjTDdatjAQKDyTFpn0hrFn75NkzLADaFRW
Hut5mC3oTmjMu5Jp06W7tCQ4wCrO7YzNBrTtj295bfRBZJcoybIUBjpMVsEpsuy3lqSrpO7a
Bqc8cLa5vd8/PVPMbUS66WTNgXu9rmrZFVeooCvLb6N4A7CBMWQmKBF3rURm92ds46B5W5ZE
E/jHgLnpjGLpxrGJZx9CnOOppXE90RfrArnTnokKGGm2D9NojeK8agx0VnNSNQ4EW1m2tWFq
Ryk5R+Ppt75RKqHNcBpp0/5srp//Wr3AdFbXMLXnl+uX59X1zc3j68PL7cOn6Xy2QkHrpu1Y
avuI9sgeX4gmpkV0gtzid4SSZ3n4YEeJzlAFphz0MhAav4cY123fET2g26AN88UAQSD1JdsN
ffqISwIm5MJ2NFqEZ9ef+z/Y8ZEjYZuEluWga+2JqbRd6bnwDKcLaH8W8Ak+FAgK5dZoRzws
B3qIQbhDXQDCDmHTynISSQ9Tc1C0mq/TpBTa+OweTntUzxv3h6ewN+OCZBpwxaYA9Q1CRPpn
6HHlYPdEbs5Pjnw4bmLFLj388cm0aaI2G3DTch71cfwusN5trXs/NC1ghVb9RQpct00DTqru
6rZiXcLAW04DY2OpLlhtAGlsN21dsaYzZdLlZauLpQ5hjscn7z2DsFaybTyubdiaO7HmnoEE
ZyVdR5/dBv6Je3KLmqA5E6oLMZMizMEusDq7EJkpSN0E4u21pfSsQzci00HPDqyyBV+yx+fA
pVdcLfdbtGsOWxp03YCHZijG6dtkfCtSTswGWqLMH5oQyFa+3HPS5ES31q+gBFKiCu1pnI8w
2S7wcsFfAZ1Gz6bg6aaRwCtob8BToqyT416MVOwYfvfgLsDRZhz0CDha4cFNZ4uakdLFJWrN
rXVclB/Z4TeroGPnv3ixkMqiEAgAUeQDkDDgAYAf51i8jL5PgwBUNmBIINpEe21PSqoK5DI8
6ohMwx/U3kURgdMLIjs+8/xJSwMKN+WNdUbRX+BRmybVzQZmA2odp+PFjJZX+g+ntL0YIxyp
guBHAFer4AyB89Gl73rfj14FnsboG/rnj1NfbpkXIPahO+UiJufakB4IalffAbHatq6EHycH
RpOXOSgyknfn2zaZewZO/IJXl7fguHm6DT9B93gb3UjfS9ZiXbMy95jYrs8HWL/XB+gi0KpM
eEwJ/kGrQjuQbYXmw057ahw6SZhSwlfiGyTZVXoO6QLnfoIm4DDAIpHbQXsRFHa3UJIxDAy4
r5vFDMhhNtD2l2utE6Z2pglDyzq1J+eJo+ZeWGVVXgSD5jzLfNPjBATG7OIAxQJhOt22ssFg
wIfp8VGQJLCOUp8na/ZPHx+f7q8fbvYr/r/9A7haDFySFJ0tcMA9D4oa1k2bHLx3bP7hMKP/
W7kxBnvtjaXLNnEDRjBnup3ohkEQ5q0YOBRqQ+prXbKEUgLQaSD7paTJGI6twLno0y1hI8Ci
NUZPr1OgHGS11MlIVjCVQWgYyE6b5+BYWR+GCPPtBqAPB6E6pg4DZWt4Ze0kZiVFLtIoKQEu
ZC7KwS/vzytMEA6kZ6eJH3Nf2sRr8O1bNW1Um1oFn/FUZr7AytY0remsoTHnb/Z3H89O3355
f/b27PRNIECwpb3v++b66eZPzPX+fGNzus993rf7sP/oIH7GcQM2evANvc0wEJhaazPHVVUb
CW+FfqeqweIKF8Cfn7w/RMAuMVtKEgwcOHS00E9ABt0dn83yLZp1mW/tB0QgDx5w1GGddXsC
UXKDQxTXW9wuz9J5J6DrRKIwnWJDPkLDIePhMJcUjoE31QF7cesyEBTAfDCtrlkDI8b5QHBI
nfPogmHFvZXbKGpAWSUJXSlM+BRtvVmgswJEkrn5iISr2qXIwG5rkZTxlHWrMfW3hLahC3rX
XVNBkAeiTFLYzWWl54f3JFcSdgpO+J3n4tnUp228FPz0ChgWN2jeQEQ7XTVLTVubIfW4Igdv
hTNV7lLME/omO9uBe42pz2KnQY2UUWa0WbvorwTVDRb71PMw8Zw1Qx5ACcSD5qlTYNYINU+P
N/vn58en1cvXzy7c/7i/fnl92nuWZ9gZT5z9VeFKc85Mq7iLAnw1jMjLE9aQWTBEVo1Ncvpt
1rLMcqEX4jduwCMSNeWDYX9OJMBZVGU4RX5pgHuQIwkXDQm2sCpySEQenBMSoIjDuQg6Mpko
ykbTERKSsGqaXh/1kbRC6ryrEkFbVRtFyQo4N4foZtQ/xIYVOxBPcPcgrFi33M+QwqEwzIUF
fkwPm8eHcxLdiNomhum18pq6xgHnY5jG1OOW3nMkdsKX02OMU/l2rm4kHRInYye/MVEWEl0r
OzFyoGrznoY3OqUR6Iie0CjwLig3ZTQJvss8MJWqwcb3+t6lh858kvJ4GWd0pLLSqrlMi3Xk
XGCifBtCwJiKqq2svOWgnMrd+dmpT2APB2K2SgdBYJ/3xECWlzyl8n7YJWhJJzBevNyDQUjm
wGK39l2rAZyCK8taz/8pGu44IoZxCFnR1Crj7UhmY8FJMYGPB7IHDgud42AlUOzmFOPhXgaK
s7aWUaNzClYr4Wv0T47/fULjQXmR2MH3JXABzKkFXflemQVVQbAywDAclgs61l4sd6jUI2aU
BFBxJTHgw9xFouSG110ipcE0+sxSVKG+cybKi1zuHx9uXx6fgrS/Fxf1Kratw0hvTqFYUx7C
p5h3X+jB6mh50ac2eq99YZLh6o7PwL9c2NLhPqznQxHGUeI9HUCBTwDiBNK/aFFA+pYNpcji
A/jFuhCLLRi6EQYiJZHG3mwfcAObpmrn3+vgfoWIccQIBUra+svJbmBqclmYwCZm6Jwr60y4
PhnhQo7oKWIM8FYlDffoeFVbRhQ9KrrcFmXJ1yASvaXFe9CWnx99+bC//nDk/S/YTcyIQsQh
NSYmVNuEwSGSoJygbaqGYSdC1zyWNLxmxquCC08XV0YFChi/0SUURkSJ6oATIBxa2mQXTIdj
a4ik5pYJZLESJBzMTMx7PWLcYPRUcaUbvqMtPM8FMUXNU4zm/N6Lq+746IjsA1Anvyyi3oWt
gu6OPANydX7sna5ToYXCG0cvwcUveaBpLQCDMFp6U8U0hOFtRVW8jIEAyCM4aUdfjkMGg6AQ
MxW9CEzOsz05zCRjlu1QvxB6rmvo9yTotgB+LNt16IZMXOqhvd1xXlqEi1NE20xT1gbFKt3F
2jFYU0yyeCudVpmNhmG+lIYDaRf5riszM88z2pC4BN3U4NVYoPgPBFAz/ciyzIaKse50umpg
/X6nvkWj4K9trOB6Kt2U4P1jHNwY4i6wp8IQ2IblfsGMs7mPf++fVmDOrj/t7/cPL3ZdLG3E
6vEz1vM9u8v5nt1dXE5xUxBjNdXixRKg0jJwvC9+d0YWK4JEKjAjSdiEQRGAc7ym9fUYbePs
Pdzsa+AjKzMadKjctHHoDvtUmL5eCps0ftbGQvqkn5u6dSK0l/CaDB/S2s1Yk3GZ66tJVWci
K2Zn2oh5b+hX59qNvNSj4tsOeEYpkXE/jRL2BEqpLyxa6ofFy06YAbO3i6GtMb5Js8Cc1fOd
ABZdGsvGF4oDO2gddTWFErG/FqH7OhsSOZuMaCrKrFhcqP/mB+CGY+u1AmYycvEgTMFV5SeL
3VJbDdFfl2lQQWgWvOvISYXY5lZ82wakNosXFuMIniO1o1tDKjDbTlp+O0MJ4RTo0PmuDTvj
9NO39k/IPk4IO9EJbehd24VLX3/rKm4KeYBM8azFWjvM818wxTtZl9RkJxFnDReRHRjh/VVh
OAQiyAlkjcnn4ulpR4EXvcA4oIcPLNT+TYqm9dqqMbid9HPoJg11Vav8af9/r/uHm6+r55vr
uyCmGoQuDKitGK7lFgtMMXw3C+i48mZEopQGtn9ADOWy2Nq7BqfNONkI91XD6fzzJnh3aAsW
/nkTWWccJkYzGNkCcH3p55Zyt8g21n1sjSgXtnepTiCg+Wf7sbgPFOGw+sVTn5a6QOKvbGTD
jzEbrj483f7PXX0S8UFjVf1y2JLaJBkOuZxl7e3KQSLwaXgGxtzlkJSol5IhzalLG4L3MSzr
+c/rp/0Hz1ci+3U12X7hHSGS4zaJD3f7UEDj6tEBZre6BF+TLkPyqSpet+FZjSjDZTw7OwUv
KWHPAxuQhYTf9iHt2pLX5wGw+gHsz2r/cvPTj156B0xSJhT3KxsRVlXuY4I6CCYjj4+KwPEE
8rROTo5gab+3YuEyGi/4kpZSrP3VH+a2wrRG7V0f2bPd6Tw404XFuYXfPlw/fV3x+9e764hP
BHt3EiSCvDEu/fupPniag2YkmH1rz05dXAfHHhQ/zqcSGLwh+by2DrGdfH77dP83MPkqG2V1
8MWzIKkEn53Mc3LHc6Eqa4XBaagYFeZmlRCevoFPV2YQgVKGT3jSAqM7CP8wMQBsUJYJC7P5
QqcaHLwkR/9qQY3nF12a99UMJMFaynXJx8lT4QgMP9zjDRtm9p+erlcfh21zKs5ihnprmmBA
zzY8OKHNNoi08C6jxWdMln9mxn8oMcB7/duX/Q1Gq28/7D/DUCinM7XlMhFhTtUlL0LY4N0F
OWbpqhz4HNIXmthSsab0q6Dsmg40BL8rzuH/1lagUVniB4A2V5na/BFm9nIT3HDZQabosq2t
aGD9YYp+fBT64RUQPpoyou4SfcHix1ECdgKLCYir9E18z+ugeJFJIWRDw/tuwAx3OVW3l7e1
y5dBfIcxT/2by59FZEF52/T0x/ZYQNAbIVHvodcv1q1siQcZGrbd2gz3fIVICoPmMZhY6Uss
5wTgSPZhwwLSqf+umm26m7l7bOdqXrqLQhjeF3f7feHdvx7v0W1pvGsRdQn+NwRZdebuy3te
CDW/owsqxcIDwDd8iw1dnsOHFBddAktw1bERrhKXwJETWtsJRkToweG9eKtqUH+w2UGJXlyz
RnAAhkPowtjSX1cgYFtQnRDjD+Vnqt80zFlSJ0XJKIUlqv/cnqdtH95iwdaMWRxzu2r5/hoz
HqeX8J5XMPcVn45r5264FnCZbBeqT3pbK5q0cy+3hjeZBK0sM4+e2pA+kd2X6XhqbQHutcRj
KIFnIuSsBmRQ8H2dSIC2idQgjgzQi1GzXaEwYIx7drBFCDHPpPPXTD56+RlOoHTnL3Fi+ZFb
Ww+0oPJqvBDifd0QwQ6LdF3Tkn3a+qPtgqbSMrfKzOxms8yG+ymeYqGg59TKrMV8JNofrD5G
0SB2gV8Kg5bBvq40bJbxxeO1zYcLAGp+QVVdbChxAFLHh62mQj2iX6/KbqkTn4ToqkdbcrzC
mLNVsxssgiljrOPH/pHi3DTC3gqXPh+rFSeKPjwINToKsRbrPgP+buZ193gWGWJbzWk5l3Dl
56hp+chZ4/lO7t4IXbqxc9IN9toMz5bVhedvHUDFzR0/LtAorBlt6yDHM8CWCuCnxTWw/xD3
9FdXsGGUDwaOQuBoTddA+DbFK13Wc7c3ldu3f1w/Q2T+lyuK/vz0+PG2z3xN/j2Q9VtxaDst
2eCQDo8VhhreAyONMSx4yvi+WGqTpudvPv3rX+E7fPydA0fje10BsF9Vuvp89/rp1vfYJzp8
hGt5q0QJ3vk75hHhnVqNP0BgFAgQVX800aIKGV0nqrOJYDmXN26UN/m4Avob4ckwNYUhBNgS
XxfYNwQai+HPj72bb6dL6bs/q2XtG8Px6md6wFHSFxQNi15K6/p4+sKfk3Dltw3sSlsfepSH
ZV/gl0JI6al++xbENgbNLi9q39irC82rJaSVhQXcKEn2hwSyqVBvIlnGxI3VBd10Bp/UyPAQ
o0t4jv+g3xi+ifdo3Y3uhWJNw8eaVf5lf/P6cv3H3d7+NsnKFt68eNyfiDqvDNq7mXqlUPAR
xrE9kU6V8AtZenAl/Jo5bNn7uyMDL03Qzr7a3z8+fV1VU15sFm8frEKZSlhArFpGYWLvYqio
4Jr7AYZXK3OJt8mcQm1dbmZWTjOjmA9qpaaztYkBvp+P/3LYb4nlBNiv/fWUOuCMpQvyEN7P
zRfgiGDItst6oZB4+Za9v1m3t+quxu40apRgITjxDCaNczFDs/mvVbiAu4sqyrE2A0sIVGfi
9yCuzlWig+KPu9FULemwenuu7tcRMnV+evTvs6kl5fMuWUMXWpsCfJAgL5JCBFLbylMP5leR
w8f4nsir0mAHrp8Ri48R9PmvA+iqkTJ4KniVtFQxwtW7HNyxgFC751IH6m1tGm9I7vhtYRO5
UmEsad+TUvnjbHhANI92RmXX2GceYejgCu+Hx79xi6ICHSAw2UMj/elOtPTdpB0DSz63S5cr
AwnEvoLascE0aPejErCQLi/ZOuBH9+bP5uUWcqv4JJnXaVExddCZxd2ywRILHK9l5Tr0UPN5
bhxgoAc2IMBah9U5epO4dwO6d0etCq/3L38/Pv2FV1Uz3Q1yvuFBHT1+Q9THvEMHz+Ay/AJj
E5yXhWEjYhNcXDOJaqmJpwI98jL3X/DiF2bjS+lHcRbKyrWMQP3zXR9kqxtzFl48Woxukw7f
ZaSU92gpnJ4jWo4VpXS1J8fAZEfiLrPGvkmnH8+L4KxF4zLN/Q/GTHcCDb54RQ8V3BYsVKYy
G0DU1E3QGXx3WZE2UV8ItgVx9B2TI1BMUbcduFTRiKBLB1sr1ANVe7nYqjNtXfMymk1lV0S/
EtlBbACerlh4sO+63RqqFgZxbeaN6cFz2c4A0/w82cLj6VgRAbhu5hCPZ73bRztBFOGFs59N
zwJDSXR0aTOAw+5xjQtCaPGKXdANEQgHBrZBUvKAA8Kf65HzAnkekImgn4+MBGmbkKp4JLiA
GVxI6T8WH1CFSRsKrE3I0hNml5RU2fVIsOVrpsmm9fZQO/TxQ99yRJX0VCDIpy7jR/yO+2w1
gkUJWl4Keo5ZCn9+Y7szunJqOrCE0h3jT8FFOzvA7b4tmFxHMRzjQSJFb8qAHiZ5/ubPl5vP
b/zNqbJfdPATN832LNQj27NeNWIQQd/lWiL3OxWoy7uMUT4YCseZE/pAYM5Qyul+LXYu5+HA
lWjOSLUNOOEnTF13lK4ESlrZWZQWJtwghHRnwY+JILTOIDq0UYvZNTxCzvQRAgN9+f+cPUlz
4zyuf8U1h6mZQ9dYtuPYr+o7UIttdrRFlJf0ReVOPNOpSSepOD3zvX//AJKSSAq0u94hiwBw
FQUCIAC2EF8P27NS7aV6YUL8jF/1PlnPm3SvmvEOGolAFLMc9WACMRkmnkJ4hDRkgGVdYkJO
IfjqwdoOZFnQZKSJE7b+rLTEYaDojjXMJnWocssvh/5sbx8nlMtA3/48fQySjxJVQbOgEFNy
Q0+jBUOiezrkrQkrHpunBoOymLfJQGP6kDyXaoAFlZmgHLc5DYaKQLyj69Bev9ZkmWh5nEaO
0aRa1aWnel5FHgyRfM/CQ69laEvu75wgc3kiSW3MPPHq2qldp9ukISMIoZKc2V3L0QnGGSjC
3CEiDPQ6x+NIIzIm7reJ61kLyOH3OOi1yhTbKREHaSA6jx7ffn5/fj09jX6+Pf16McOuzaIN
fmtu0c/jx79On74SNavW8CXa688kyG1nTKpwjgl7PKLqkHjlb0uTEBNLUHlmmaCE7SsTQ0t/
O0E/j5+PPy5MaY05T+O40ryabkqRdcvWJyy7BbzKEEHbeq/33naX2Jkl4YuEtDiUzU7YuwcA
JFf3UbuZXRQQ1qw6iwsmOvFruROjz4/j6/n97eMTzzU+3x7fXkYvb8en0ffjy/H1EfXi8693
xBsubbI6PLQpGkv0NBEgb9MIttGKgTMghXVkB7K8r6yIbFWtH+QZlg5+kR/m/qGKVrQVRSH3
F7EpLdProiklzivcqnCnptitXFAaphEFq1xgvHEhYgDJhjRWWmwJyu9briQnTWyseXNa6JfT
wiiTXSiTqTI8j5ODvQaP7+8vz4/yixj9OL28U+9p5VfDsesre+/Qdf/PBTmiZ/ggV1dMykkz
a5dQ5ogWbm0RsOAODxJD71gxhry79aEEwKpyABsQVgn6ew0ahqECkpeUwNimDL4wZD0n/5lf
mhVzlP34KU5jTcPc6r8e/dyZtX5Ynvr0ZJj5j8q5OWZ7NiRKcV0spXJ2kh+dpBwKoxrRbWhf
6RwGXUv5Ok0GfavY3mT3lyeYXHXGeJUMiugkHA5ZYwGFMptPKTCoaj1oYlAWlSVgGZjFeNJM
SQzLClPWNzHmCjfg3AceDh/hKnE+hdHiEzXe8q7G/f/atAgPLzFIdimjDnjscVZJmT54uhLn
ZNC1M46GHqIhW5H9d+qmaOBbukYihTyaqPSuG2BCcRS5hj0EteYzyUUQMIoiHp/9LEZX1SDZ
5EI4m0k3Jdmet7W+Lzp33ub4+G8rPKqtvD+8Mut0ShmFUNgwXw8+N3G4borwa5STKZAlhbbh
KHOt1MjRaDOsiaATGxbQ9l9fCTd+2qQf9sCHxXad961adMylVUxpTbVyiexNbOhSmcECZygj
egoM6mY1dfyZTkwtEJ+MPPomdDd1ANwtl9SGiCTMarMhQxt8tHydwZLIi8I2gWgsMhPNiYdu
jfLzEVZKNhoA+9QaOXJwT6PCKsqGhgeH4EJRZGeJGRJmUqzF3pwyE+Xta+LFZPUdjbgT3y4O
AfBexHJ2e0sj7yNPP+C9LKfjKY0UX1kQjG9oJOiPPDXP1OQ7bt9O787XQZv1jjwoMiiynbnS
4iRSh16GeTiSJxW+k63UVBjgYWJ/QCylLHyHiTHClJVWts5yAwyE3mrmabEvyT2SJ0mCA7ox
hNoe1uSp/kemHeYYv8Rs62hPqyRQytGCRV0T1jHXIBN4P3sRlXg0ztHVURR4t4612wLDYehO
QZ13FPCd7OCDaPNHtK/Sf37ZmrnsE6usNA/RsPsIgW+tsGnkK7c4h4SCVEwc2uXC6tSGTBok
p0oOQNkjrTlMp2i2QasGIL0HinkkKBN7ZWaLr1byUgSziwcTr/OPSytzZaYyNhDK9OywpQqT
7IuHxk6oHN5bC0mmGa6rhGXKhd83ESAG7Tt50/QKGH2ezp+OS6ns6129TnJSEhmUdBCmo4Hx
klhWsZjTlxNFjI4hD8nQflBIDpW947Ywn+bV42WcEYiOQpDl/SJadbhjnlj9VXMXkdl6zTfT
v8M9CL6pFbPVQtB7w4BixIHt6ydB+i4HEyTKhwERN6zw0WqNzCSwvgPJpQJ5S1fmJOVyiuFX
kqQFJkfFC8jgO7UvG2jJogSDp3Tm4KbIyfjUjrpKMLw1kUnC0Z0hWcfhsMvSgbP19UYSGSFH
0LXSYUn37YKXVtf9KmZU/pOOAGeW2pV4OJjdFuZNIqP5uyF2thDlnB4RiCpCDzhcVimN7Zzl
fofqj7/8fH49f36cXpofn38ZEGaJaWTrwGkSCwI8EErNekTrTWZzeKusE93dIfNC+SUTKNjQ
wkIkri24bznN/EhRMy9uU3tRRRQ2Ay/ADstDIa6+cVih/i6X6YXq0f9rc73+bLPPSn8T8F6V
Y/OFhpAmEuwCP7Rpy98Ydh2n4kKbahW0idwvVYSvboNBvngTjcwW3aX82vPMTC8tH3XNMldg
H6VTre64ubOqZ2d5ayDPy60dJqLg65JMOokb6NJRJZaldHs1JQANHvqUMk7egZKUm8a6Ga+F
oF5T1w/Dilo8slBTDCRtk9bBIqqna+6IrQjOIzpfDOI20TB1S346foxWz6cXzN7/8+ev19YK
/jco8ffR0+k/z4/WmRfUI3hm96XMb6ZTAtTwiXV7wG82Zkj/gmGsid+lbEVti60ngsXvNQxF
MkoIx0TitnMxyH/whlJXPpa31mTCPprEDdg+21+BclbsBgGVCUqEX3sxL5ZDHuY9UMTc1F71
UzcifAbdDVcXCI5kJmJJgvkq6LIqrh9EezJFk6TJiWBLqLCHuA/6pkPbUTfiCe7ZTj4MEw8z
SonyiJE5Ntz6LiWNxqxT9ZZStRCFrvZSllMwt15e0PoG4mCi/TgmPMm6JXZSxmSaUdkjHcPc
y+I6sKAkvleEPb69fn68vbycPozkNkpDOD6dMGksUJ0MsrNxgtqfCl+j1Qv0/Pyv1z3misCm
5VGyGFZ2kazL4UL3vRtX8vr0/vb8+mkqO3L15rEMVyfVHatgV9X5v8+fjz/ombJXyl5roXUS
eev319a/x4iZ7ltllEWcuc8Nup02ETfFYyim4ix03788Hj+eRt8/np/+dbJ6+4BmCnqFxfPb
yZI2XC8m4yWdHLxiJXcUvj6fx/Oj5kmjYpiicasCIzdJWpJ7FTDDOittR6IW1mQoQNA25Jrl
MUsvXAMpm+3yvMhbhwfd71KboA+BeQS82svpN1kyRiqxrkIjQV5HqxIRqJGawyEJuiwx5EJy
O9bJQExmo9yZwV+t5pqiXYDGOVBjolGYikG99LwbiU52lcnXFRQ1TV2ycSOVjJTx8ko1z328
iN5tU7wUI+Qpr7nZCqiHVkCKetZCgg0TpZlWQgP3wQCUZabE1lZo3nCLKUfk9R0xXni4sl8j
IldJHintxxNVSn8PXbqpXkSyEjUNhRn4k/uSHaxz096ATw2sK+sGIAnM8AJHCiF4taIx2/Aw
QGR1bD102Wzx3iFho1h124EVjzp+fD5Lse39+HG2xBakh5mWGdmJqlqUOlqU4W0yjPWLGVbr
ViFz6cggbo9ZdVgCA/bdXIw9Qx90X45qC/+OMuU1Jy+zqtEtSWWwGqXH/3X2Dmy0KEpaoEGk
vMEJ7SyY/17aMgesqmLZP6oi+8fq5XiG3eXH87uxS5kvZ8XtefyaxEnkfIEIh6+wyyVudQZq
QEOydKkuclJ5q7GbmAYhv2vkfZdNYFfuYCcXsTNneUH7PCBgEwKGieAsQ1s3ggzE9JgaG2wd
lHTVou30h3K9sMytpyKvypBfQCicFGcX3pwKyz2+vxu5BzFmV1EdHzG/s/N6VTw9TmHpmu7k
Sto8CMdv0sKLMGrWByqYR3Y+i2/nh8rMsI5gHm000KorEeHEmQh7su8W49nhEoWIwgnG6nku
t0ESUJg+Ty9edDqbjdcH/4fl0XAVDsUsL1rlGNxhMhqKCcsaUla3i6MNA7zyMuUbF6eXf35B
AfEo3W+hKr0DUIKnbCiLbm4CTy9EqvpgrQJizcIPQAeMJX4+//tL8folwl76VEwsHxfR2vSu
Ua6pIAVkfwSzIbT+Y9ZPy/URmy0BH8xVtk+bhSqwutLuodlXvCYjqA1SLWrYs9MiC+vY3EBM
DsgZ19R3z/ZN7qRhlbOYlnFcjf6q/k5ANM9GP1VEKMmlJZnd+L2MOu85sp656xU7n1TJL6zY
bejsDgBo9qnMWyM2GKQsg7EdgjAJ9YHTZGy3htgVbFi0q3ZLgd7yoZWvuKDsKm6ic5XLyjXg
axClH5txkjJIUtuiu9ja9uIx6Thshs7mpU7LruxcuyyhFFcLrnj38/lxaPdi8c3k5tCAImon
S+/BKMdSAvc2yx60SNqrZWHWMEEz0XIDCoGHwYo1WiiiGYms+Srz3SfLI7GcTsRsbGzCIPem
hcB71jDTLo9sT78NyNEpZT1lZSyWi/GE2YHDXKST5Xg8JbumkBPq+gvYWkVRiaYGkpsb6zKH
FhVugtvbS2Vll5Zj6w6QTRbNpzcT6o2IYL6wPBO2ItRWgGYl2HK2IBtzeIdpmZCqE/02dyXL
ObUwool9caV6hvUC7bCqmQRyMlSOkqTELXfgBq/gDasnlheCBqsrCCjLnsJn7DBf3N4QJZfT
6DAnh6MJQMZrFstNmQhK7NBESRKMxzOT8TnjMFSj8DYYD9auTnX65/E84ngQ9uunvGlW50Pu
wwZeYAMaPcFn+/yO//bzU6NkaHbg/1HZcDmmXEw9HztDByt5rVFpO5Toy2hoyaXDws8VgvpA
U+yUSWSXESZD/orSVgaL8K+jjxNoNDDefik5JKi6xn06WbsD8irSYYCMiPjKUxBRZJldUdpF
2oEUZWPYw/qObd7Onz21g4zQZmYjZae89G/v3U0r4hNmxEzy8LeoENnfDYGp6zDR2f773WHy
raZyLuC9NPn9NIFMs78nk/9Gm8ISWDAglKURptT0ycFIAlrwwUuxYaCpsYY52FbcNfc/y/DP
ZQiVnl3BW3FvwJZkXmSVwLyXFokChjltK6jUwuiHNQqmy9nob6vnj9Mefv5umbLb4rxK0EeD
HG2LBBFK0BaBi80YE4vn43WB1yhJG5nHy0plz7ADFZPatzGDgOT42ClIE0zGtKttix+T2oPG
qpAAGxbZOWdaaJEtx3/+eakpTUKepbbtcdgUhi0W2WQM2z7drES5i9RDFXUcQZ6+9uzaOQAB
zefz4/n7L/zMhLLaMyPx21ByD29M/edm2mQxL/QLNrstUWjk8FpWkQJkhNBTGGSs2BfTKX06
wyhrxGrirhtEpUXhy/Ah0SAw8nufg2xW395Mx1S12W6xSObjOX1hWUclbwXc8LL1cL3QE1Xj
4XDwNwdIUB6KkKWUbNbS3kdsQTjoVgnusHeNMK3DLVJkwPi8/rQm1jY5kxS4DEz+9bsLq2Pc
eCmP82VjQzsQGYF5TyPS2mRQsJiVtX3FmwbJW9pWnGQnZgXrpLIMgUkdTAParmIWS1mEWni0
uVI9vIjCuXwpoSVdLRXVwg2L7erK2Dcym5lFYxkP4HERBAHOs+fUFcpOqSWmj+LyLEqdy6Oy
uDmsQ7+3QduT+y1+cJTB0aSqnCXWwnFhFLZ3Y53SR3SA8OwBgKD7iRg6KJSl19/9tioq2nxm
UKlg/WvrF6giJ+Y6zK/MGRbII9uVzPIGx2fpLbPZy2wPPs+n0LOtWG3t+NZS6OrNNscTvRyv
Rqfzkpgku+skoceMadJUHhrVP0x9QaJTfr91j2+JQW6SVHBLgtSgpqZXVoemFfkOTZsgevSO
sgaZPeNVZacXjMRi+SeleFulRGSNxuU41HqN8MqAnF7W0QFEbDJMLvYz7zihuJxJ4GabiNMJ
HeovYCG4+WyH9eHlLYm1p4bJxBcWYZb7hvv25bpX26+8FtYFdJpDrrLd12BxlWls6AVqUmzZ
PrnyOfLF5OZwIDlme3F3/9ID8iLVRF+jatGNPRr1OvTBPd81P/iKePcMPvO2Ti/arx7935iM
jFW7hEx9bRIBBcsLa8Vk6WHWuCEDPe5moKCYWLG/iF7tr/QHREj7Fd6JxeIGPYBTsk6QNBeL
2UCDpWuWwqlZOYz9dja9unBlWZGQ9zOaZA+VZefG52C89iibIKDmvrx6usKc1diqxVwUiO6x
WEwXpOnUrDPByD5bHhMTTzjH7uDpvV1hVeRFdoUz5fYwOAhQmJ83B+EzUznAr3OpxXR5bXQ7
2OosB8ZVUUVJ7Ah/w4LFHbcl4A2Zn9UooTNsJvma545BnMlLocjRPCToqbPiV2TY+7RY2xdV
3qdsejjQS/U+jXy7233qf4OHJG+85TwuFGYft2heyq5Id1VsDaOaj2dX3qFW3cxSi2C69KTJ
Q1Rd0Mu3WgRz2tvNag5eH/Pp2y0RRstZmrqCXKtcsAw2btr91CRL7BsBCYoiBVUOfuyrUVb0
2wM4uphF11QlwR3NRkTLyXhKmYusUtZyh8el55ZzQAVLv9GgrQ/U6as0RYQeMoerPELUkltf
GcE2tz/YsnzIYNn5JC/gUR7RWwiee7gx317t60NelOLhytqrk822triTglyr/TrFzuMBYZDs
+bffYMwHDnLs1W30wCtaGVzFsWGliZOVKd/Jx9Z9r38pdyuaH8AOX/oHLkKU9IguKGOek/Ja
AkPz+jEFiTJMlOwkKFQoXoeM9LCX6DbKwYTB4sdgMO5xlEESrQVSJorNgx1NIAFGZInYA6R/
TJO4qSuO1383CqFOsjkfwePQEaXjJ6avaRbrsr3FQBs6EE6ZdQQ/NFY/WL0YTx0YTOst2vyc
ugG8uFVgypYK70KGuTrjbk0Pbm0Rj1js66fW/+xuxaBeExXFJQpbE7cmC19HCwwSI9uS5WcL
py0Ezm9t4ErexWaBeFSmW+HA5MnbYc8ebDio2WjQGwdB5CAOtQ3QGgMNBEHWnQIlrHvG1xuD
7eo6cB0QGJRtbXAuQ1BZ6jZ+35ISbbfGX6sivc+79eA+3naTZv9o7PUia1AdD54EvknFYGny
SHi6ueN1IkRid1Ox0mYNn+Skwt/Gt11aygs8NqGIvRlqEQ/MM/Vl1ke8N3UOIrPSTCUrIZgH
1mE4ZVnYVIWd6QTLMYxStEEybrG2bwYSKWmDEOkmajkVHu5+OT8/nUZbEbZHb7LM6fR0epIu
d4hpY9vZ0/EdU1sNjh73SvJpn9q47b0ZNIg0vZU9c4RSgCwmASUrWeVqK8UBGfZpYm9o84/E
eM9pAbsk7y2oN/M7w6FVPTcitjdTDfb3a8/T+SSgBTkoHIzpTu+jfDr36Cz2HGUJLXuZVJQ1
mSSUtr+rVJJf/hZVBWLylbesuaTBXHmYVDUTQ4g6oTTMsxosfDkVOgr/++lIMISX6GqHx+sR
MYqF7EGLvBQrvMdbPj0ut/t04VkH5kxhNiX4kq4SVgwZzZV5J3TFqk4XAemXBRgZRSUG5MuJ
G9JhY8VFbOzH3k6m7CLWYxBUg1gkF9u9gAXG5G13v1hcm1VhqRvw2CwDylZlFjJTMkf7YGJb
WBVEFXBXOlFZzU0uHExuAve5ZWIG0NQa4HlhPzv5N+TzgBPu5e4mfbvxArkG71m7ulK/PcSk
/cCkkQJykueWbeq+zleYtAzDXqk9WFnXK/YQOVGtEr5Ppzdj0i+8y36wtwKw5W1N+AG3m+n+
OWOHEXqxvJzO51H48XZ8+n58fTKcWpVX4au8VMzccT/foMWTrgERpvO6Pgm/Wr0xnVeyM7WO
NIa42+NW7C5JQxLVzkBv0cwOeNxLm2TVAUfjc74A9dAOaMd8PIPobS7i3H5q+Cx1IEqUcyDN
7qsDzCyyXmAjympJ0MGwrbPAJRTELug4zcUlwWFyYyKVixUgRv88HaUTw/nX90HecFky5v3d
w73blKdoV+8sfX799efox/HjybiFvlt/5fF8BsAIA14HDVY70PmFzBWhHHu+PP44vurLL1WS
aN20GTWPJZpkW1mTEycNI82+ijwv0LMzVlE49o1CHUHqSbTcEdwlD6Un/ZCiCeqKSnykKzBj
oxQI82KoXU0nN948i+Of7YcKInE7a24784b+DBQaQ6sEfaqiCMQ4LA5uZ1YVr79Zkf4KznZZ
w4I+2NlpLEkFzWYVOubJJoWVdYlGJHEasq3HJKtnL6m/eoxZJkFDG+7aNxBFtC6o8OEdjHR2
qRER1bgdxKSRUpGs2Tcn0F+CN6vI76opKfbzuSeIu69B0B++nmpX9DOWlI6ZkmHn59OHNBUN
uID1vntnvHZRftfftq8gdHAmFmI4drmycPRl7qi7XbSmySQsHhFZlyfjUzO4ZVmTyV/SD3GA
yXgcp8meVd5ywIsGvNZEtnmOBvOLeIr7mT2GKR1UjnUCPAyaMPAtDILQG/rm0Na/W2lEpRbv
aNZ8zYTtI6FBcmRE0RatNs5BqSwg5Z4WPcxMJDegwYb2+v7r0+uaPMgUJAEyqxA1VolcrfAy
TjsjnMJg7j/rNhUFVjeG3lmx7gqTsbriB43pwo5fUHr6P8aupMttW1nv36/o1Tv3LnIikuKg
RRYQSEl0czJBavCGp+N0Yp/r6XTs+5J//6oADgBYUGfhpFVfEfNQKBSqPn75/vzy+5Px6Gj8
qO5hGVxnM9HRS05/daKCt1kGm/8v3sbf3ue5/RJHicnypr4RWWdnkqg6SOsG19tD9QFsmvva
cJsxUQaWcpLahGGS6P1nYTuiFxeW7nFPZfa28zbmyyMDIp8eaRy+F22IVNPR3WYbJSGZdvEI
xSHn4czicGBl4HIUZlS9Os6irRfRSLL1EgJRI5QAijIJ/MABSO9P6+KDEBMH4d0+KbmgStG0
nu8RQJVdOt0z7wygQ1Q8+wmyIMSF7Yqlqy/swm70931l9dWqRUt/6Oqen4BCFO/qGHqoHB8y
aqyjp4em1N+5anNW06/jT1gBfII0sMJ0trgg+xtVmwVHQwX4v6maXmBxq1jjDLJJ8A2idHl/
Wrj5rbGDaBFcRX7I9nVN6ZAWJhlcRz7NoyuQoc08beOslT5DZaJpsKFlIXs7p2XChe1Qc1Rm
ccdz+JnvXMq/nQWaXXhY37IGjy1YljsZ7HkZ7mJqO1c4v7GG2SMI28i0lDfpq3tPE131uMF2
Ftfrla3yxAXNpi2DiMxwgVFhQYo1006GsQSpcaMYZLQLY7woinweCnIldxzwdK68cSlBNa4T
qy7MYT6isT1i/I3XmBqM90i288ikxs1wYXDA3dqLiRw3avNfII2Ib9cbdBprrqs6B0vjJKaW
eJOJO7/HW4KhdJiAGJw97HX5lefUzZbOuO99ECUDukYS9Heu4uClIcbJznmVhJvwlZz4LeFd
efS8DZ0Zv3WdaCYnwXSGisV6T3qHdes2xdSZU7bbkM+fDSacO21NF/7Eykaccv1gpMNZpqtz
DeTICrZ2OmSwXHmgrHUJcDFJJsBjXaf51dWapzzNMjKkg8aUFzmMgSudvojELY48VwbHvnpH
LdJG5R67g+/5saPqxhWliTh6Qk7e4ZJsNs5yKZZ/MopAKPO8hDxqGWxchJY9tQGXwvOoDcVg
yooDXl/lzZauWCl/0FheZdfc0SDlY+z5jhUrq6SLOUcTpxi3MbxuIhqXf7for8JVcfn3hbT0
NIohFypHd6adtH2xtjOdBZd21EjWgnaIYvaUF8SJY7mTf+dwRnHhgsuJ6mhogP3N5mq5OV9z
OPpXgbGzLRU85OQpR+dsy0F3JmZM2LzI9AD0JiZMCcYAO88PHKNIdOXBmeE1icywD0adGhGF
m5i6V9PZ3mVd5PuOTnknzZtprK1P5biJOb7O3wrjKcV4bsjF6iwBe7e3NdZSne5cTRTTvmRe
SB2NR21AcN1AOTvjuDYWRZTDOd+3rKvbdeYNF80jGfdpVKFck50fDnWlTlrW1xLexWj8CcLe
neKPs2ZoLq0qpTvHEg7Lpn5gbKaGOeIdS/jY+Gz9kTyy72GTomNbLTxpxus0IxpIorL97lSP
dQWsvPuuoo9TE1MuHT12Ga1dntU0Amo6ct5jvHZvHG5IR3XZJWtLl+GS4rllKwMBi4OX3uZe
Lm127AscWsQYMIXfS4Fm66op183cy/85v25YUaLd2TR8VrpBfgg3UQADrOwJLAnjlTTeXMpx
ZFDIVMz1WGjrjrU39OdDDxglCqoZ46wPS69FsF0tGyPZXEWnjmCmDGeQqS9AOIM5g+7N4K89
W1Uzbc9+BLuN6jhB1AQZonBicFZG8cVaQuYQQW8WIHQTndeW+dba7STJdFKKFDjfWpSD/u58
osy762J4IRGPfn85gg6XvRIMSCsYBW3tAoThpJE9TRcR+c/1A2rFdUtgUwIgvHZZHPLnkCeb
rW8T4b+2fy8F8C7xeeywN1MseBEkqEOLgot8rzRd1mctox6gKWx8fE5+B0S0fbxTIGiJwSqR
xaFUsGShe6vRjqzM7KaZaEMlwpCy4JkZii35XVb23uaRHkwz06FMbG8i4/0aNSoW3zXEVYq6
2frw9PL0Hi0wV47SLOPPM7WC9lV+3SVD091MoznpsEqSHd3JCgwoqBxF6/cG8tlOt4oLc+MF
o51ulPWVKVvBwpycEhAlOm+l7fbQwtW5Q02gw3Z3goej4+1F/a52vALMSf/4cOBNC+MQASdU
h185eTcKEjFpfVf1RTF23dQZqXQ11Hc1OrrWs0izc+l4OQPQo4WN3jFfPj59Il4gqD7NWFvc
uL4Mj0Di2x7hZjLk1bSZ9Ap8x62t/oHhS1AHDjgQHmkMSKLWY+4aKeomETqQXfXNzUhPuOpT
yqMcFbZA56raoZeOlbcU2sLBNy+zmYXMKLt2WZU6XgIaLexaVefsOj9JrnRFi0a/LzUqmqfO
NoDZtxo81dcvPyGK1gk4iqSlGuEFakwI617Qp+aRw9zeNaLW23aqbxyzaoQF55XjwcDM4UW5
iEk/vSPLuFW96dgRK0GUwuKYynsv3/ETZL/L1jreHCq4bVy7MoAHUUB3O4q8gFRpTV6cAu+8
QF2Xzm5mjaXD+gIvr42nXBqdd61c0+xtAe3kmhbmPLUQns58ceA07WEyMNB6KcibMkdlfmqE
4ZTUFP/JA5wFoA2qtD81hFuJoJ/IQcY4oHcAma58y6bs1w+M9Bsh+URu5StEflhlecHI5akj
ArMqFB7Z6gPlzON0AbmrSk0f0jNxwHUIpB9rN1ixTc4dVoDl72cBXM8bdQ7n7l2dLX/JM4L3
aLn1DmEMyaHso9wiz7yt6ycNNN7D+J1b44i0ULfmxsZbf0stDXmjhSPUgpI4yqQJMheQ3OmG
asiApjCQj/yU8UfVdcaM4fCvoToSOo9LF/5zDWGE2hPumhfFbXX9O4WhWddhEurGgdT2GJyp
6aeDDKql1oY9+vkMHf/KO8gaRIRjbhzOgSov2NE1s0lGfasehV7STsBqmLoAsexns9Tyx6fv
H799ev4Lyo/lkh63ib1p/Mxl0DHBRce3ga6bnoCGs1249VzAX2sAKm7M95FcFlfeFCnZFXcr
o6c/hjtB4dDMWN75miRWHOv9EvAK053PHOgA1PJE2vAHSAToH9Df5/34PSr53AuDkF7BJjxy
eCWe8OsdvEzjkPaFO8LohuwePpSNQ7uGV+irc5kOCselvgJLxz4BYJPnV9pDE6KVVC+7C6Xc
bcBYpS1mZUfncFzduZsd8CigT/ojvIscluoAu5b4EWvaddQinPKuMSJ4SXjFxVXk7z+/P39+
+BXDtYzO/f/1Gcbdp78fnj//+vwbPj38eeT6CaRQ9Pr/b2PNGTgMeMtqAclw6syPlfTJa0qb
Fjg9SbGnqsYiCtdCbqflsuoEtqzMzpQEh9hYeoNfajVUrFIVkpd0P4+cj1kJ64lZwXpliSUH
JWdzfR2JibzsdGsopKmns9P6kf0FW8UXEAgB+lmtFE/jY9DV6VJmqlzLD8V4p6dBHUPbK2l/
K5Ouv39QC9+YrjYsVkv5ehXVx4Qy6hq0KISTRsW1+lkD9pUuV4E4HUYACwsuva+wuHZlfY/V
vgschwTS3HeM4bTIHXSIP9NEraEilaqdoREP7z99VF677e0fPwMZDF0OPU7iyxqSOg07txGz
d+Y5zz8w/tPT968v672qa6BEX9//hwqvtwa1bPMKDyeUtg9KYXg8GAkyIoOMLquCNoSer3MM
Y6gD66O8fWv7xlLd7hBDZFLiJvQ4wZK2irkhqdK8c7PIQiqGxeenb99g3ZRZENNHFbdMG0oG
VRdfF9YYXh8lFVUqtJJTKyC5vpicuWNPlWBxg1O8HWrQqPI+ieAQvyodnFzfeT7lGle1aV6v
vzlfk5AyMJpaaDjwk7543GlfNRxhkP00oqjNtXpAT/0Qe4biRrVMl8SrQgrSRnKCAs9b1+uS
V/u6ohZHBQsv4tvEOM7cK/m8W0vq81/fnr78Ro4pZRzu7Dk5WDfUEPbtlhipZiA5pehHcTtY
13mk4xeuAqhLv/WnXZNzP7GvRbR12Kq3mmuH9NX2aPN3NelxVc0yeSloVW/ezK1p0QS7beBK
qWiSmGoSeUHqnmstD7swcaaq7CiSiGgvAJKIOiwv+M6ze3ok++v03pbXhHqbp1B1SWwldimT
3c4IbUF0yP9MwUhf66g7ZwhlLdAlDncLarQWQ17fWdRkWFt0OOTR55iJKVNcPn1wUH2W8sC3
fUhrgVJXLWAWtOaPPWWcJwM7ynbxfvq/j6NoVD6B2G0218UbQ+nJZwo1+XZ9ZkmFv020Aa4j
3sWQuBfI3hjn2hEF0wssPj39V1cJQYpSiBvQ27Odl0IErRqbcSz/JiQ/lVBCdpPB41Gzy0wl
MhpoAXTjIh1IZJGoLwLPBTiSAgBEZe4CExqIk40LcBQgyXTzNBPxYn0Sm505C5CoAx3Y2ZRT
JRFOOaQuTaGib5pCu1LTqevnbA06sEIOaikaxRuW8mHPOhiphi8nZRElPzbUdhjPdZXkcj16
Yi16DMONcxNR9qBjVrJ19TdOOj1x0Q1TVQOhNQ8Ti9jTm8ZUXBeuvI6ucCv1/Vs/vurWcRZg
G2Xa8CmlNnibK+2GHvoTOmCozAeec0O4zLM1BhUByqKj+W5saY8t7F6yksX3tAaY2nUyWFoj
coBtCAB3ft3MeaLbGoUlIdlFRPHmFLsg0r2CaEXwtmFM5AVNvvXCK5WdhEjfsjqHHzpSjYOQ
BEJoDCo7Ue6DLXUEmNr+yPpjhjpef7clZ0fbhZuAWrOnLNputw2JUkmNQy/2jXVnUpJmjXJP
MizzFQEDS3S5MC2mJiyDQzUsQ2ifMd4JwRJWMBhR4hctguDEjpEc8QEK+iV0RMmdWNNMKZqO
9Rk9rzVwgCDfQVH8B5a3KryzsfARnDJOt2hWUZ7vfDIu/Cr4MKkAm756vSjOypGc6G1ysF1O
kpx0tQhGqzJUGdHNvPTLt1aWyihWqB/7TJlxKCeFMgdeMDMeucJEzWFRFFNWtPoWWIPt5krk
o6eGLFQ68y5+Ny27YA0/3U2Mrjm1Ly+zahHGiPvVERL4dqsWIt9b5gaCsgDZ85KR7AisGlPe
4/z+48t7Gbva5f0TTiyrh0lIYyKIHacRfI+qztk+rduX37POT+J1ND+NRT5H3JhRgiQ93YWx
V17O7sSvjb9ZWabrNZof1BrfTSrZ8T7PmX7J0sxhVy0rj9t2QJ07ZlQ/U2OKo/Gt/XRxQugr
lAmOaFFphqm9YgQN4UFWjXuBIfloRPP69NSh3lzk3HjVjVRgW10eaqmpKfW2Z+3jfItAMhcN
dyriEHNefM2LCbb3P2CBDu8u/5QRJ7Ejpt5cOTRrktrWf8LnDNEHbG9Y9W7gZU17TUOOtTIG
qUnSlAnt7HhGQ/KjaEPGCJejfpaurNlwjeNoR9+OzgwJqRoaYZCVYmvIqeMKQdxRBQAypdOT
aBcFxDdZdfC9fUn3OnK0Wdc7klwLwbMdv+GSYqbaoq5Mf60l0VEp5JnVH3VhJlHgekUs0CLf
xtH1TkAO5ClDx8WyRB9vCXS4e3GxfbePENtfw81mVSi2D7zN3QVf3AQ3g1MgtcsHVgZBeMWH
YNC8jo+V9tH+GM8eCa0DGdMuSmcvS9WkJuM2IvI25iFC6R89aqJNT7zM7qIUlgvd4S9/Yki2
pJeRqSaThtVONokoqqH81Kg+TaX2JsBgkQnoIdRdiu0mcHb49K7GvPjGVNGdYxwQQFEGoT0n
lF7WLpjr0kQKB0rjbSYzEqlKcrGNC5/0ioCFLUNvYzUZ0uzGlbrgmKAlK9rWfE87UgPP/dRu
Ygk3d2SeWRs90qbnLfM81e17XHLh/PH0fEpLb35RNSmtVoDyZn6uiw4O+HodFxa0yuuloW0l
+tKhk1rY8WAjzzXkByt22OGOxmxYIMa7JIlCulQsDQNyg9FYKvhfQ6VMybFaY61UPDSTywWz
xUQp6LQOYFUYhLpuYMHsPWpBclHsAtLLgcET+bHHqJRxaY49Om2JvVZ9qUGidkqTha5X0fEg
THYuKIojumSTuPNK2ZAtJG+GDJ4k2u6c+SSRI7qqyQVC0qvZKJnJlcCrA22UsO5nM54GrPdv
Bm68NDchKKKjhCCoud67GUw+JUmaLKbAt2Dr68Y1y0q407BD/w7jxZHYOUk20caRL4LJa50s
uUhVpMZjXkotwFt07YDWNHc/X8mQGmSJnAsi/LJhG88FCc8xuUVYJnF0fzSBDBF6kf7C3sAm
iYvE/CAiu0IJUz5Zl7VYZmOJY0GQqBe8NoXu3DxbTEoCcyWxcz3vnNmUrHA3n9Wmvz4sAKlk
1H1rkbfmJUdzkDQM2u6wC2359CCdVuZKHN8mOC5n0D+8vPqqzXcoUmF1fHn69uHj+z8py2l2
pGpwPjKQ7DQ7qZEg/eYem1784kVLGgiKS95xDL1LHbfTVnMAnaKH8GZg/VUz/57TSidP+kPp
eAM3M4isOOAdHJ3h8FiK0ZLaTv+wx/crpDpW48J3eQO0a4oh7suLpXgea8HJWKUIdp1VZwHN
g+qG2eDm+cv7r789vzx8fXn48PzpG/yFBrCaChG/Ulby8WYT2bkrg87Ci2iDgomlujZDBxLO
zhFqdMUXuk1lXCVWOua21N5uLOpijWzm2rI0q+mImQizMrVMpCdV9sO/2I/fPn594F+bl6+Q
7p9fX/4NP778/vGPHy9PKH0bBfhHH5h5V3V/zhhtny0bbOdRUh1C52NW2l11hrHoTOtcXo4H
d98cSxY6AsUh3Kd0OA7ZgoI2YUesPLKjfyddFUB4eJuV7lZ4e3Xnva/5iRIXZI3Vg69j05sz
pGHKnld5JP/457dPT38/NE9fnj8ZI8pC9BT2bZ4eMyLVBTESzyevsA/7l4+//fFsTT44mqCn
xiv8cY2T8SBilWKdhJ5C1lXsnJ/NEo1E6koD4VMucviPS8UmF5e8uqUOM0zZwvv6es5hejk5
1GNwRwepJqtbtNyVS+Twts/bx9kv9eHl6fPzw68/fv8dloDUfq912A+8RPesWkcAraq7/KBH
6NK2l2mFleut8dW+rjEUnph3NwPl8O+QF0Wb8TXA6+YGabIVkJdwit4XufmJuAk6LQTItBDQ
05obGEsFwkJ+rIasgp2Z2mKmHOtGGImm2SFrWzjt628egH7KeL9nVi4oUIybHDXZgKPLC1k8
GDFHsvsIB9p6DmodIIcRoE1JizP44W2ftT4dNxBgZopISIHNDJqKXrJkr4nOCYII4lFHSYRg
8JgDcet5ZtMe7Xad3d06Os5Lp8se/Sv1sMdVxNblih/rFm/ppRiwIks2YUyrYnEIrEz1jEzd
eyw2eXfzfGfKgLog4YgFAgg7M1fw5j0+THL2oLvlqqyGWea4kAL88dbSCx1gQerYWzHLuk7r
mj44I9wlke+saAcbiustsRzftAsLOWmciXKQlmDdpEcd7AjD8dptQ1PNKdtO6v7oz8op1LS9
duyheuR7edlRGK7D+kKUsX20GjdDckOQK8n+6f1/Pn3848P3h/99KHi69hy/XEzydOAFE2I8
6ZBttGf8Ub41usM6lumVnOfb2LTUnnbAdl+bv+DkVuHDTmhCvTk0yLX2aCy86DvfNyyaV4ey
JW1R96Z9v3IwlKfrhzkn09kD/FwM/bo2q44dfdMLjLRXn/6kb8CY3vI4Rfka+fb8Hj0GYHFW
Rg/Iz7bojtlMg/FWd6E/k4bDwS6+dLhMFExiohcr/r51xSCWrZEVjzm9ACKMR9aWEoMUmMOv
m1luXvdH1tqlKBlnReFMSJ7PrXSUN247IeiWY121LismZMngYEu7DECwyHhdmlll7wyv6apT
y33e2j19aK0v4bvJhahRhMebu3gXVnQ1pVRA8JxnF1FX+lsnmfOtlXKmnQ/GnXXnRHshQeQN
s3zOIbG75NWJlMVUVSsBMpLhrQzpBZ8Mf3ViltqEqj7XFg2ODuupMFHxhx6oaqabUwLJbV/u
i6xhqW/1u8F13G039/DLKcuKOyNHbrGT+3trcBe4hTi/ux1gLbaqCRKsHMmrtGTA2vpAukhA
vEbfG/ZwlSFULWe2SK+63CTAAcEMbIhEOM7gUauoW+rVlOTIOoaP08zEGpj+sHOQRHV8MbMZ
ETvaCclEu9mWHOg7v8U5IqycWzhsWEUULDd8KymajMZgEZssS80gtJLcZaxckWCcwJKfWflD
ohhA2a52SyrO5axGf6kg1msr30xSw1xPHZ2CvalvdhY63T14u9yefbAGicyephis81iuFoYT
+sBQT1ScHdfjhjk0grpCkctenqP/TjO/a16VtZ3du6ytsTbOrDA0IndPOAErFbrf7PdWCyo6
h7rghYb8Ze25U8CKyfkPsZcvbiQoeUO6pxhlDv3RtcarWbTm4mQlM9dTmXEBAyZHKxzpJGbP
enqWk/Ai4Oh24vmAB94iGw/fSxsgvlIjyMAC6JHxxMRw4oY81ZPmojIwAJ8DQiKTdJplBeBD
evPh/1l7lubEkSbv+yuIOc1EbG+DhEAc5iAkAWokpJaEjfui8Ni0mxjbeAHH1/39+s2s0qOy
lIVnN/bSbjKzHqpnZlY+fp0PDzDE8f0vPsrGJs1EhTs/jHjDScRKj1aTO/mVlrRqvGBpyOVW
3mUhL2FhwTyF4ZQ6fiMNnHsoFfFG1UiwjbNId4lv0LfkOIWf1e2KzaOXJArvgJlIqzoyVocX
njnN7MDvz0XwWaRPxTzYqPdtgp70EidhYc0IA0FFsPKJr30LNNsgthRma8aukrhc8Mo8pLmd
FwabUPzUaAF73YwvAuDd01VlyiWTYIwNU9RQxN7gw1KQJKx1DOC38AnRBNbHkI6Z/5UZszIt
VtHc00dNoUhK5YZKgNXFnCKkmhpmCGMgvbiLy+Hhb8Ymuym73RTeIkT/sm3SKoXVouaV0u+I
mAKDgr8l+iIYn01lG55hWsLcmXEORpvwVjAWCsMIv6QUzMGqhifreEDEzUXw/Q0mbV/d4vvb
Zhn2RU0g7Q+eKO8JnT2t0yvsydjhPKEFWhifDbU+CqDVq0oaql2paTJmC02GrD2oQEvDh14p
6VLODbVA05gzsh00lBz3mwcw62pWYx1HmHwkiSpZtDg1DVcHtBngxOoBXWeoF/fj8AY97KNY
Q4jvpTaYKvyKMXlDNWEt8wW6tczXSt1yLrgCxdjByQUaWO6wX1NtTV6MLVahLCe6NZ+hZTFP
mzPkzZEkQew7sxGrCpMVt9bT+lp1fjaHR7dlBt+Pp8Ffz4fXv38f/SGu5nw5F3io/h09tzm+
a/B7x5/+oW26uYh52/suNtaYRgDDbPoqtADs1QlSx9Sd79gToTwdnp76RwJe+UuSZVoFV1q4
GIJL4SBapaUBm5SBAbMK4cqfh56pZKsl7K+FmsLPOONlQuL5IFREJGavimYOiAbVOLmJDS+G
7/B2wWTg58FFjmG3FDb7y/fDM8ZXehDv0YPfcagv96en/eUPoh4lg5p7myLS1M/sd3ow+p5x
GDIMinllY9RkMo33R21lQvGoH3LtcOpJtT3fD9HjKgJmnX9oiODfDbALbLCTEGSkCg4QdC4p
/FwVhgSqx+fnpV+R2D8IgDNjPHFHbh/T3KxtbxC48oGDuTOY6AAecCUIIEx3Eaub95YYCy4J
2whZAKB5SkndcAQuZPQgQ/WCIMtTnzYhwCTIogqttlEoTGEoGjPQqlw0CnnYvR5X0BB787nz
LSzsfjXePEy/zfSRlJidyzrNNARBMbJV/xYKr3zYANv8jqsaKdiEfArBZGr1q4azfjIjdood
ona26TVWm49eaa13gzSIvHB8m+tHVMQja+iaEJbFdWQHGN7jraEQUXIMj1qEhnd+IyT2hJlt
gZnYXO8Eio1I0w7TeFS63NgLOCZ26uPmX21rzfRD80FpF3XPr4NgiG9HO0k9088aUQC3Oht6
fcQisUc2VxMseM12scM4LmuDrhTVTJRrTJjYQzY2Vlv0BgiYpZSj1Sz3WU7CtVMEsOncHmuA
0emMR4MI0rlB9WOrLkF6zMj84ZESFLZls+scVpKlhQPrDyh+9My3ev3Nnu8vwKK9XG/cT9Le
6V+fG5bLB/pRSBzenUAhcNgtgqeS61QLL4nYxySFbjpmTg0Rc2bM1mwKiNHObrkeTUvPZQ+4
sVvylvoKgRrOQYU7MwZeJBNrzM7t/OsYFvr1qc0cn02w1xDg1DO7TzFQ79VZezD3Vsvx9RPy
inSt9EovSvgf783WfrLfMxlpUcLunn3wLfavZxAnDM0H6E/dswqWFm6JN98uBsc3tG7Ugmmj
mRP1ir8VcF5xV9fE6R21Rpo2vO0uiIosptmeV8F4PHXZjGYJlCn8KKpiqn5F+2B8LJnHFR8k
XSXYGEoKRQincqTs6BZD0EdcI4jJcJ6W4YaErENEAPxbhyC1eSZ9qszi46cGK5ptHVSsfng3
0gBXzjFPoni+pcwrApPFhPXGQ+uROig/KYNGhMstb2AtTTi7oahNOpNwQ/RDNZhX99XIOQbN
UHUjNVzkkuq3kNBpU8CN1SFnKS8VfIeH0/F8/H4ZrH697U+fbgZP7/vzhXueWN1lYX7DLvqP
aml3WuktI/UZzk/RDED/rUsFLVTKkLC/qiL6Flbr+Z/WcOxeIQMmU6UcaqSYoVCZZorEiJI9
YC0AUGAd8ZdsNomJCq+pn12zTQWwtP8RGcbg5ygpnWuRiD0dsFLN/mr4Wv6Vwp4UbKJ0cL7c
Px1en/T3G+/hYf+8Px1f9m2gvMaknGIk9ev98/FpcDkOHg9Ph8v9Mwr0UF2v7DU6taYG/dfh
0+PhtJdepaTO5rgNyqk9UiLN1YDWJ5e2/FG9chvcv90/ANnrw/7KJ7XtTflUlYCYjidqHz6u
t7bPxo7BH4kufr1efuzPB80M3EAjs9rsL/86nv4WH/3r3/vTfw6il7f9o2jYZwfRmdWcQV3/
P6yhXioXWDoDDGX89GsglgUuqMhXGwinLs1rWoP63sntMjPVKtUF+/PxGRWOH665jyjbJ1dm
M3TdlRaAdKIbk7D7v9/fsEpoZz84v+33Dz/UDhgotKOyasyk6m3weDoeHunekaCm3LKoFtnS
QxtxctltouKuKDJDROPbKPZHmEKxMAQHSQtSHf6ufF4BJnCbsE/Pu5Ovi+mQhE7NwzuS0qEG
CLP3XLXjahDEPK8B9nSdLYINjtRh0wxVpf0Ke7EOG4RmNNjDN3lnr7QqPTGCKlvdcS0Y3yEa
An5k257fMoNWBCRPYA2t342li9z9+e/9hfgvaWtz6RXrsKwWuZeEt6lu3dsYddJqlL0ThXGA
jZqiI60z32Asv3MnbdzthrWhetQwr5osNmzdSLEKeMuwwA/mrF9vEMYxxtyLqBxcg1PXNTkP
IUE+Lw2OXRLL+xTViekrEdmOt1JAwTit8sU6inmbz2UGK0ukK0Sffd7EJhO6Z4PNaMaOZbMY
hFEN7MLAo3H15fsUsL9xym8QNF39aJayqLo15CdEa6bSy6vYyzTjSoVEvq3Py2vj01CtPEPY
wNowZ1PCarSqG+N2lHTCvNScU0vQ3JgWQ93U1Y5kiX8lF8M8ASGa/1BZPDe4wNXviWhbBpBN
6F8jwz5EmSE3w1YkCkO9u11dyXQt6oGLqcSaurMoiXdskhI14Xhgylkpcg7FJXDeImdnGXms
QWzmhxs4wkLxeq8ojfCz8AFF4ZJXcOd0WVMKHZMW9QKkonaNghVqmqiWppyzhiRN/DgtikwD
jrNrhWDoy7RXbD0XlpjdW6CpBhHXE2/KpfpOmcBB5W1SMjtNqXiNDydwe663igGvSOULOOhP
CKyHYgkoH/8R11w3/vHlBbhuXySwEM4TyGqq105XBuW62djl9foKWRE5tsM7s1CqMe8wrBD5
gR9Oh7yWUyUr8MqqfP48UhuVsQ54MsDXIY0+quZKyHuV6pY3pZJfv4j01C+NZMJPiXIz3BZZ
tMFsbD0GWBYqju8nLhIkNBzewL4HoVRRtoufFU3uBpTzOGgpu75x9bcr1YviOc1/kfn8YVUn
q0zmBoexCEZxawwjkO9fjpf92+n4wKpCRfp6fH5kh5cpLCt9ezk/MWr4LCnUp1L8KZR6OkwE
71iK9IAbr4TJvUIAAKJ+FXgum2HTZ9I35cxH/xy8y/uSEHz974VMe5W+igxvf6Cw83D4fnhQ
jMikgPMC4jiAiyNV7jbCDoOW5VB6ejQW62OlI9bpeP/4cHwxlWPxUpTeZZ8Xp/3+/HAPotvX
4yn6aqrkI1JpDPFfyc5UQQ8nlTS7bPzzZ69Ms2oBu9tVX5MlL+/V+E3Gb3ymclH71/f7ZxgP
44Cx+JZRTNE0sznud4fnw6ve/4a9F/m3qht/q+54rkQrTP+jRaacBkJsWOQhF1o93CED9GeX
/gtE9NqDr28eK4lFON4vRG6sEXokrBrcspT2eMa9ItVkXJjMDmXbbGC6joA+sNfw9hlYrzEr
N85ID3VBSfLSnU1t3iu1JikSxzE8VtUUjfH2BzQ+9wDVaRTgbGW91CKSGA+V6dvFgmTLbWGV
P2fBaAZaR4Cj+PUiWggqCq7teZCzYtqS/1UTXClleqSiVWAchUWTJLFUkuK2FnhpSQB3NfKq
2ubCC3YxMa+oATQg7zzxRiTPQuLD0pBCIg+l5QPPcsmjfuDZ7ANwAPJGMFTeQwVAVQgpfhyy
ITvQRq1meiVWRnEggiiOT9kU9nYGh+v1rghmnIJq539Zj4YjNVikb1s2Me72piRKfg2gY4LA
yYQWc8ckenOChqejfgxWCeeUbQKjdm3nj4dqxhQATMh7QFGuXVuNzImAuVenvf+/q/Pb5TS1
ZiN1eU0nw4n+u4qkiOjlXhyHJN4HEMxmPDPmCyXlqNIityqLDINQw+HCh3Zd7aY0uli08Sy4
Bk3VYd6E8ZQbdoFxiemJAM14Aww8xm1DSlgUZSYGQSDxM3tscSYKMm+569YxgtsSG287NdkK
yIPfODqCK7zBi0y3zG6jwVURCUncwW8McAArK68UgKE78jVYAduLpGD/xy9Ci9Px9TIIXx+5
ByUFWXOXb8/AEPSYyhYqWagf+xfhNSQNDeizThnDCGar+kBih3mehBNDdD7fL1xT6l7vq1Gn
A0z5dDjkrMSwG1GO0WiKZWbT/N5ZYUiHe/PN1fdXmxlb+3R6iDYHbaPy0zssTTQOj42JBr6d
SBmSusPXp7m88ehS09DdndY5ubH1q/dBUrQ9lOevlEOKrCnX9qnjH3vI+s1NLj5Yh/dySfEn
njOcjNUTzrHVuxN+j8cTesQ5zszmXgQAM3HJaelMZhNdCRQU4zEfRXhi2Wr4QzhcnJEaKdjP
xlNqMgcbMPB8x5mO2CVxdQja5+LH95eXXzVbrnhGijyUGDWjCrZJ0r+UFZxUmXIK5h5ly2SR
RzrShTqmz/6/3/evD7/ah9B/o1dBEBSfszhuRE6pSFg2KVc/B4fz5XT4612PmXaVTlrR/bg/
7z/FQAbCZnw8vg1+h3b+GHxv+3FW+qHW/b8t2cUYufqFZA0//Todzw/Htz2MbXOutSfWckSS
bYnflHlZ7LzCgtuXh2nZHLpNvLzLU8KwJdnWHpJEERKgL/GaaZPldZ6toSmXtjUkfIv5a+Xh
tL9/vvxQTvYGeroM8vvLfpAcXw8XMjjeIhyP1XRuKHgNR1pcbQnjI8Gw1StItUeyP+8vh8fD
5Vd/przEskfKjRqsSsrRrAJkkTgbKOImnUQBceNYlYWlul3J3/qcrMqtxXFDRTQd0gwQCNET
tjQfrH9c7RwNRwr6/7zs78/vp/3LHm7udxgscv3Ok6hemByfnuwmyidEmxtcWxOxtohMqCLY
RRcXySQo+CvySkelV5AIr3NmWAd8y/Jiw0NX8AVmh5eQvBiOdNWi2suCYkYSywrIjGzh1Wjq
aL+pQOYntjVyDQroBM2MTSg+ZjIgJiSR2jKzvAxWgTcckvAd7d1cxNZsOOJjbVEiiwuXLlAj
Na2HKinGeqQGCc/yVLFz/1J4I0sVhfIsHxL/w6YfbboAhd/PHdbiNr6Bk2DsF9r5AIcIn0NF
oog3SJqVML9c5Rl02BoiUuljNBrRviFkzKmGQNSzbWptD+t9exMVFv+YUvqFPR5xrIbATC1u
ZkuYGccg7gica8ZNp5y4A5ixY5OTbls4I9fi3KBu/E2Mg92NkISo1tg3YRJPhlOVJp4Qjcc3
mAQY6pF6u9DNLQ0o759e9xcpJzPn9dqdTZVmvfVwNlND7dUalMRbblhgL4mEt4RTgufrlWWO
RcMyTULMMGtzg5Qkvu1YNKljffyJdk13bvvcn/iOO7b7O6VGUI6gQeaJTSKeU7hunceO7X+0
+cbenvc/NUaKwOuL5eH58NqbH27Qoo0fR5trg6YQSyVcladlF6WpvSKYJkWbjbvo4BPalL0+
Aj/9uqf88ioX3qFE8lHQqDfO821WNgS8MImiEz7wojkTR6lOOLrPcYIW31nCU74dL3D9HRgd
o2OpKkYQ8IlXDYohcPJTgKOm8y2zeDiqnZ411k5rlO0QdPiiOuUm2Ww05DlFWkQy8qf9Ge92
Zj/Ps+FkmCzVvZpZVFGKv438cBPgrMFkZFiyeKRyd/K3pkTMYpsSFc5EPVHkb60QwOwps9VF
d7jz1hkPaSq2zBpOeC3Zt8wDZmHCcku9kex4pFe0qFQ3pHrGEmQ9J8efhxfkG9FR6vFwlgaz
vRkSXAGNARAFaCUUlWF1o4rG85FFMgUs0DJXTb9T5AvqOFTsZqa400jLczI3sWPH/QSCyhBd
/bD/X7NWeQrtX95QiGVXuLJWyzBRbDmSeDcbTkZkQCSMjRhRJtlQVfuK32QJlnDyGDKGCZTF
x0Dieq/oP8s5PwtJaAizQ6wj4Yc8ECmISfGIYJkmjFfZCfSVhHwdQW1MY6QScSaorYu82fKv
ItZ8PyKVhzHSI19kJtjkf46Uq0kv026bzPPX1ZzGGZunXo6JufyIDzGBEdE8tFZL/VJN7ity
lONjVpmncUwvMYkrozpBG1PrQo1mBD+qhbcOtZQICIYr6ybiI7xihKAcN3yI1heJXpJJySnP
mNXdoHj/6yzekbvhbFKuSuvcZmz8pFpjlq9tMbcoCn5U2c6rLHeTVKtCDexIUFiSLClA+jDb
mR5jqzsrSAeVkiIPLpt4I/FJFCn4aY7PBDjNrEwOy/6EzqHiWHqRCgziH9R07gqZMv8Ga6Vy
td0EYT5P476VjWr23izxTZCnhihpukl8oEYIbKILdCcGAsxBBOrEZu1Ckgqa28HldP8gLil9
8xUlqR5+Smu8ao75TVmZrKHA4OeKdxEiGr2pAirSbV7nKEvjkMUxwUCkwUFJwh81MOOKaAn0
gF06fmmouDDE2m0JkoK3e+66ZsiP2hL0Yl51mqb+LLUnREbjm9dWYBkIAZnZthZLVckyb8j9
G27HCSo960JdYpGH4bewh60NXrJcZLzZZrFqGCDqy8OlFgtWgIMFb+kr3T0qkOvTnL/2ioja
x+HvinM2aPBxlBC3DATIlz6/zGN99nO/b0Jco+EDkUD5QFi4X7deEIRE+tMsbqRK/4CeMuL4
U/NS+J6/CqvbNA/qECqKWO8h/wdXAQg5mZcXpGH06igwl4Wv3F7hDk39FpqFjIRVc7ROrNKM
G1J0IRbWi8TFMYGjCt0/7nR8N5PAW2z8/C4zZN5ZFG2eiO4FSILYPSkwTSyjpg6vX8fXLQiv
nMJxW6aLYlypXJCEEdACWiAAX8bJrX+lN2Eee3eEooNhMNwI00pU8Oc6gRffeiIrRBynt0RL
1hFHcHdwSm+FZAcDIz6DbQ2Efg8TWjQnvH//8IMk8CjEGqPTJpddUXolf6c1FKuoKNNl7nGR
vxqaxuW1Vzidf8FRiCPdbL91HxQ9lTf1ef/+eBx8h13S2yRohlrRVS1Aa0NOVYFEJq1U9oYA
Zt4yxKDEkQxVRqvzV1Ec5CG3jtdhvlFXg8Zog4TQ+8ntT4nYeWWphnLdLsMynqsV1CDRXWU7
hjI5O1yO6vHcBDtdRkv0GvC1UvJPswE6lqc/3go7hc7FuOcxAlKYcCfGJizRb0qlUjgVbb/h
b1WAFb+JkC4hOFpcW4gc6+TFrcebqkvyypBCETPQbBb8qpf9FovXiMejQxpqwUnGjkxNhGsG
7nkg0nrOqedgi6FNETDrqRomDU5c/accCaUt3Q6h2G5y1SlF/q6W6tUCAEyYDbBqnc/J+xct
FUQFum+hT0robzGlz8bH2LL8+DWFdL6mqTrMVto+rkHmIa8Jut3E1RuRszzCxYEnm6UBMTTB
bfcpfXM7QXUbeuh2gHuK5wAF1TbDFAFmvNjkhr72T8wOyikkOiwy1RnG8S/6pdlOqRTdRdBO
deDRq1Lbtx7XV++DTdIWgls1L1jn0VlGmhE/tb4JGDlD2wYkSkyiFmuu2RXqCxr8aOIq/Pnb
4Xx0XWf2afSbisZMjeJmGNtTWrDFTKkOkuKm/AMUIXJZl3qNxDK07qpGkBrG1GNXfVPVMCMj
xtgDNTqYhhkbMcZeTyZGzMyAmdmmMjPH9KUz2/Q9s7GpHXeqfQ8IIrhmKte4AEbWx5MLNCO9
AhElx1CwabVXqEGwYYUVvM1/xdhUH/fmquInpoK83ahKwZkmk2+0TXWPeOc2QmLefOs0civu
/GmRWzpIiecDg5CoQeYbsB/GpaoO6+AgEW7zlMHkqVfKgPWkVwJ3l0dxHPGvEg3R0gs1Ep0A
RPI1V30EveXjbLYUm62aMI98fMR9f7nN15GaFgQR23JBdkUQ87pgkOlxI7BCAJGLpbnj/uH9
hK8KvXBX9cWn/ELuJ1OVRZg7D+QNmBXE5yCvUr1wXY4ZmlqQDYPe/Qq/q2CFaeRkXhv+cVle
RxhCqhC64jKPfBLG4cqN1aA0IQcPjlLyX0VqTG8rXFWFXngDnd+KYFTZneB2fE8TdHpkvPSX
5kIQlzo5VvHnoaSBlWDSwjYx7zU0RpRd/fnb5/P/VHZky23jyPf9Cleedqsys5adyWS2Kg8k
CEkc8TIPy/ILS3E0jmrioyy5drJfv90NgsTRUDIPie3uJgCCje4G0Men/eO/Xw+7l4enz7uf
VOXZUR3rDEjTdEbGosua/OObb9uH7duvT9vPz/vHt4ftHzsY1/7zW0y1eo9s80Zx0Wr38rj7
SgURd3QnN3HTP6b88Gf7xz36RO3/pyvNDl2lGNwN7yFWfVEW1u55IWCPlXWLtMCqXB3sMtFi
xJdlJ5Mnjze15HM4nKDvQyan9QyGSMMj7GoLvLVGhydtdDd2F+doTOLiKcdDiJdvz8ens7un
l91UX9gIoiVieJ1FVJk5tEzwhQ+XUcICfdI4W4m0WppM6WL8h5ZW3SMD6JPWViqwEcYSjuan
N/TgSKLQ6FdV5VOvzMpTugUUjD4piPdowbQ7wK1LnQHlMjb74LhRxCxjjdf8Yj67+GClJR4Q
RZfxQH/oFf30wHgKcdXJTnoY+sEwTNcuQdZ78CbNfeJF1umSrJi6RbN39frp6/7upz93387u
iNPvsf7fN4/BaytrmYIlPo9J4Q9HimTJfA0p6qSxjj7VPdPr8Qv6gtxtj7vPZ/KRRoWpwP67
P345iw6Hp7s9oZLtcesNU4jcf3MGJpawSYsuzqsy28wuzVCtcTEuUkypygxco9jtqUFy8cv7
E0/DL02R9k0jAz6eTmd/hx56/kHyvKy75n0oxYFN4zXGkM0sPxwXQ0x4Ao0dnEBH1zc+upFX
Zh3rkbmWESi+a83mMQUOoJ4++DwTC+Y7iTlXYkkjW1/wCEZaSPvid4BmNVfhckCWZv3pUWDE
/rK6aRumbbDw1jV7Ca1F0tLgeffpCfmdj20Qsl8lwgJXbTdd1m4PX0LTn0f+yy054A03DdeK
Unug7Q5Hv4daXF74TyqwusTkkTwUPkfGaQBAtrPzJJ2HMaFHF6zCDgqnce4xB5d5aqGXTMLB
/HbyFJYJ5odKuRVQ58mMdfo28O/P+QdBAp0SKUBxecGdNOhFvYxm/koHILBlIy85FMo8jXS7
A/QvswuFPtmpEtncw3yrp1rLmWG2sM+NS9/gahf17Def3dYV3zOxS0+s1Bep4mBPkYr98xc7
34vWEL6cAljfMuYrgEcW8zVNw3buUBVdnDId1oJrM87K9Txl0yI7FN5lgYsPjhtLj2RZyl26
OhSh5TXilY4FAfjjlBdhUszmyL8U4jhxTXCj/1Ov1LScNULwH2ohYdgGYJe9TGR4suf0M9zq
ahndMluhJsqa6MK3JLTZFkSEZtcuuTkC60oWLbe0FYaU4HdnRhOf4AOD5CI8WU1+opdW+gZ4
uy7nKaM4BniInTQ6MFgb3V+uo02QxnpnnULsGR2OrTOIkV/mmXXlqw2i29KDfXjHSb7s9sQU
AXLJKbLbpvVrydXbx89PD2fF68On3YsOKdXhpq4Ma9JeVLABPrE86nih04wzGNaeURinHJ6J
E/zF20ThNfl7irWOJDp9Vv5Xww1wz51TaERoNCO+Gbbz4WGNpNzBwohkD0BIq6XFvGRGsORM
5qjZ5LnE40k62cTr3KlRA1l1cTbQNF1sk938cv5bLyQeE6YCfZRcB6VqJZoPWOT4GrHYBkfx
K3z8psFjTh6Lpwm9Ve68SRd4fFlJ5ZN0LWs1gnRKeyQwzPEP2gofqHzbYX//qLyu777s7v7c
P94bPo/ku9C3WDNYHf3Wlg+Uj28+vnljHOoqvLxp0atumhD+flzCL0lUb9z+uCNW1XCcUcbD
pg0ObaIgTsDf1Ai1l80PTMcQ2/DpZfvy7ezl6fW4fzT3HOhhbXUdp2CTYSZ3gyW0rzGYa4Wo
Nv28LnPHlcskyWQRwBay7bs2NS9xNWqeFgn8V8PLxub9hSjrxLydUef0pmP36AktUkyMF1U+
ygGTYw06coi8uhFL5X5Ry7lDga43c7RCKHlnlaX26ZrohQDpYoFm720Kf/8Dg2m73n7q0pHs
uKdqZDZvZSAr6kACa1jGGz7CwyIJJJJUJFG95vORKrz9NWrhamrBKyBhlmFMY3/LKewKNlGR
lHngvQca0IB0KWRHKyEUHVRd+C30isLTVrAE9dQu6FumZYRyLZNaZenfsfQ3t73yIrX+Hg4d
xxkYoOQ1H8hhO5Ck0Xv+gw74qOZ8+iZku+zymOkaE7Fzl5IDOha/Mw8FvtU0D/3iNjXWnoGI
AXHBYrLbPGIRN7cB+jIAf+cLA/P2TAs9sbT+ID/2lhJBmc5vN1FdRxslDky92pQipZyWPRFM
KJQgIHtk7oLQcbe3ZBLCE/OtC7DQ+4ZSj/UgUZUzu4lDBDRBV3Ku1yDioiSp+xYsUWsFN+u0
bDPjSA1JRT5m8092f2xfvx4xPuu4v399ej2cPaibpe3LbnuGyTz+Y9ix8DDVMsnjDXDCx3MP
UckaL9LRcfHcEBsa3eBpCz3LiyiTbmrq+7R5yt2n2iRmBAZiogwskBw3QB+Mi29EVGnQ861Z
ZIqjjLaqLo+aFZZCois7C9PX1mdPrgxNVmS2/6jIbvGS2Fx18E059+r6Cs/AjKbyKrUqZZZp
Qu76oJ8N/pyXuKdzC3AS9MNfpi4jEPopw8RJ0TrchrxbYcCKZUqPqE65v/fzrGuWjjMYEdEs
raPMmCkCJbKyC0bgzXuxCOjGMVTTsXXsO2NtJBL0+WX/ePxTxTg+7A73vl8CmLlFu6LiuOZA
BjD65PG2v4qDwWzVGVhT2XhR+GuQ4qpLZfvx3fgBB+vZa+Gd4fKAHq/DUBKZRfyVf7IpIiy+
Go5JCU7DuIHdf939dNw/DHblgUjvFPzFnzTlIzhsXDwYOtF3QloFxAxsA4YWb/UYRMk6que8
EjSo4jZwD5/EWIo2rQIu8rKgC8+8wxOopbQTSesVgfUlehhGoco9WTxagVLA8K1AsfkaNnvU
A1AFvGrAOk2wgbjMOJ8U9ZKWYzm0iTk6abzGuq+AdVHipUWWFpalr9qAjQsa1OgYnketqQdd
DL1sXxbZxlmmOpzFiQUaxlhi7JfyvPXrOZtZvX+Mycb1EWEwKWyUzEJvBnD0N1Ef8+P5XzOO
SkWLupOiHLxdKPrOazU5eFsku0+v9/fWtpNce2DTiEnwzLMm1QZitbpwZmpEaf4b3oALg8A+
ynVhR7EStCrTpiz4jafqpy7hW0VO0TCFUmEdTQA8yt0QHgPJ/PfSWEohEWZmTYa3/uFGatER
q3+3GTQWQNt6cV02lT3TFJSsOTvrYk3MmRKEJ19004a7lpqDQB2iq47/JhoTfAO1prrGivVQ
qOvch9CFn61UR1Qd+/0DuFrA/mfBfYpRZw+0ad12/vKYwE7bKv8xeVgxjQ9YivmCvXQv65oS
nPxuWRTDYlCyAg1cd4JpjKuoMX0ZhaBRE1Qb+ubwCMFF/9ADykozItK91e3Nz0qU11730BaA
seg7RnwYFqFNjX9RKZC6y+kQPGOmslliWLx7SEsjOsOcfK/PSkAut4/3ZlKRUqy6CtpoYVLN
LU5TztsgEg0J2uyYZBXWnP8RGpT/nfw4m75SnThd4fecm99xpCB9RbIBvkJesTSnBmyQBQfs
0owDNuYce+iXHViXLdjurFZeX4EKBEWYlLwZFfo4k9TGvkGjlqXJ1BbYnUuFxOkpu3baXjUw
bYlbkVIB3fNignrhgNYjSuLIIhmtB4cZsf+VlJWjVlwFBuI/r/xIeZyRaS2d/fPwvH9E95PD
27OH1+Purx38sjve/fzzz/+yGVm1S1W9pk2KYYOX12PoKvNu1AK+uCtbcOvdtfJGeopOFw7x
NP9I7rzyeq1woA7KNXrBnpieet3wAXcKTcN1dpIUFiYrv98BEWwMywWhjZPJ0NM4qXSBMeh0
bmA0JFh3LcZU2Yp/evHJJpi2YH/jg1uWJElOc7xkcsKkgEWMN5bAq+qg8MQ0r5RuD04N/LvG
lA4NY6r48aw2g7t4m3k821prOoZxBGyCJFaCss17dRMnOs6w5D8EGkQoXBlw+AHUrDDhMK9a
slwYwpCexS/BvCri5JUZO6Zz/FiD9tbJ1bARqJktgFaiMKgliOxM2UCt1MlauGAHzoawzO0q
/56hUcgWy0OFqCaXedpGjF2wY8fj5EJsnJJvejeHl3wTf/sHLmTWzLtC7beIqA5hF3VULXka
vdGf62UURvbrtF3igZBrXA3onOxmIMDrF4cEw6+JdZASthuFZwLP8b514wDF0JpqekKqDoUt
dumYx61bYQCHgE8MFLZbCuiKucfPlhpJE9hOLUU6u/ztHZ34uRbstDZg7LBkaE2pSqhFx5u6
o1DU5gjtJHrae8E8YLq8EDc1ESaW5iSyYQAvEsu4x79PGfRdTJYumBMtHgdE5mEh4czGfGL+
mILIMIOBPjnluJ+IprNV/3wQViEeHqZDGC93MhSlCQoQ4L3buOR6UVwEJjPtbPwlhj4Zg9gn
w7Cz1KKM6mwznKRxFyBY2bOlAF23CMaECuqFtZXSJCk72HF6G3vX4MpiOi0NsQCWUQ8IE6x1
j2eBdPvfn998OJ/MRhcHUz3jcR39blR5sbAUN3M5DXrEYnfsaxkUMjlN0XlHmS7FELYzztgg
oc0hmqMb9D4dltKNTkD9RNwRqdUGybUT+CJPT1/cIrsM52IBLahqT6L9Frxy6Io1phape9Co
1qrVcHU2SaLZjVxyo4HUcfj/Ab+lNsaqugEA

--dDRMvlgZJXvWKvBx--


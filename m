Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id C894A6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 10:13:08 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so2126605pdb.11
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 07:13:08 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id jz4si12236381pbc.223.2015.01.22.07.13.07
        for <linux-mm@kvack.org>;
        Thu, 22 Jan 2015 07:13:07 -0800 (PST)
From: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Subject: RE: [next:master 4658/4676] undefined reference to `copy_user_page'
Date: Thu, 22 Jan 2015 15:12:15 +0000
Message-ID: <100D68C7BA14664A8938383216E40DE040853FB4@FMSMSX114.amr.corp.intel.com>
References: <201501221315.sbz4rdsB%fengguang.wu@intel.com>
In-Reply-To: <201501221315.sbz4rdsB%fengguang.wu@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wu, Fengguang" <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>

Looks like mips *declares* copy_user_page(), but never *defines* an impleme=
ntation.

It's documented in Documentation/cachetlb.txt, but it's not (currently) cal=
led if the architecture defines its own copy_user_highpage(), so some bitro=
t has occurred.  ARM is currently fixing this, and MIPS will need to do the=
 same.

(We can't use copy_user_highpage() in DAX because we don't necessarily have=
 a struct page for 'from'.)

-----Original Message-----
From: Wu, Fengguang=20
Sent: Wednesday, January 21, 2015 9:40 PM
To: Andrew Morton
Cc: kbuild-all@01.org; Linux Memory Management List; Wilcox, Matthew R
Subject: [next:master 4658/4676] undefined reference to `copy_user_page'

Hi Andrew,

It's probably a bug fix that unveils the link errors.

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git m=
aster
head:   e1e12812e428bcaf19e23f83e09f602d161b8005
commit: c429f45c501ac95383be9e37467d4e6ca08782c1 [4658/4676] daxext2-replac=
e-the-xip-page-fault-handler-with-the-dax-page-fault-handler-fix-3
config: mips-allmodconfig (attached as .config)
reproduce:
  wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain=
/sbin/make.cross -O ~/bin/make.cross
  chmod +x ~/bin/make.cross
  git checkout c429f45c501ac95383be9e37467d4e6ca08782c1
  # save the attached .config to linux build tree
  make.cross ARCH=3Dmips=20

All error/warnings:

   fs/built-in.o: In function `dax_fault':
>> (.text+0x5dc6c): undefined reference to `copy_user_page'

---
0-DAY kernel test infrastructure                Open Source Technology Cent=
er
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporati=
on

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

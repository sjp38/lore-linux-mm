Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79F08C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 13:10:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31AEF2229F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 13:10:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31AEF2229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 520646B0006; Fri, 19 Apr 2019 09:10:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F6A66B0007; Fri, 19 Apr 2019 09:10:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E6036B0008; Fri, 19 Apr 2019 09:10:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id EEFD26B0006
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 09:10:20 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t17so3467619plj.18
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 06:10:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=u9Rrr6MGC4MgUYe2foYlTaeh1bVhOXNzOxkYr+uF1Dc=;
        b=aiungxVP8fuQjTf3vvAK3Zi7xmK1um/lVAh+VqA5HxiWKTXDGc+cBMqX5CvR2p0tIE
         rPML8WsfWLbZKgbLaNMq3QFpux/HhoFzNYbSaCzJj6XYKQqoOIeIfY9pxZtvcRy+YDut
         aJfyuQRpfGp4Sn7JHocVTGEKZCpTZQH/TlJ3BvPWl/QU0t13yezHRV7cC5u5Nb5Gv7Kf
         1bepktCUik/Pd7ev8bfGL43Fs2q77LJ/PUHm+yiJF2SgZ+2CQweFNa+nEqiE5kTpk0BA
         njK/pX92xmz2RUh+eptXZglVH/us7BVD5iwFRYqZ/POzhjW9i9UiwFiB8E34wF+BK+jR
         2nUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVx/9ruG8aYQxGa6HasbC/qOoDZO0H8fFcT9dgkMN5lkj4h2yIw
	k0c8VUQp8f9RfvRyF+oyUDfHKe/uA36pn27R1rvqGCGJQGC5SIkA5tPh/P1uKXMRsMGWg+fCumf
	B2hClyqx8W2AtT+Zk40EQQ298YWLOkvLyFThM660XIv6/L+/CRlZ3lxZ8bcGWCglKeQ==
X-Received: by 2002:a63:1064:: with SMTP id 36mr3766261pgq.155.1555679420261;
        Fri, 19 Apr 2019 06:10:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0/dxEK92XS639j5WyJ0oWNxvcS6iUjLSyTkMkvjXv/LoffhydGfxusJReGf2BL++sgi+Z
X-Received: by 2002:a63:1064:: with SMTP id 36mr3766191pgq.155.1555679419368;
        Fri, 19 Apr 2019 06:10:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555679419; cv=none;
        d=google.com; s=arc-20160816;
        b=kJ7JaBaqWUGai3+T7BJR4K6+JXJ6IVqetxweenUk0k0P7R8mgRZEO5g3wv3SiuOWMe
         Gc9sGTcm7Qql4hFzVllLyRsr/QtpV64nTGW/NlZKjim0gOqreQz74QgQHqGVcs2kC4Gy
         4KotcwuySxIcglzsTxDdOmnsQY5Wvn6b5UvvKixUmXUhhsoaMzmzPPZaAdhXzznDomyo
         ZJGldnG81AQpWlLfTw7LGAcyoJBY1vOoAYVoGbGmFwVNy71hICVi+XQ+wklJVZutOEto
         gj8DBfF8LEUdabOPxZRudmbBi5kWF1H1kXeIF4TM9P5b5WMeosbJli0C6kQkZIxVMok1
         2KIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=u9Rrr6MGC4MgUYe2foYlTaeh1bVhOXNzOxkYr+uF1Dc=;
        b=UJVt/e06lX63Ybz7p9nwY6Mw4XDByvMAKdTXs/QwFMO1fG5cASKN4XW0XgnDaKudGB
         H9okP222W8JiMzJ9J5POUDBYxBLQwSPUE2cGuv8MqxzDvvO4Xp66eA1FE/J/6ff0SUdR
         8Yz5Dv1FEq8gh3tevwwDgZG0BiqkZ9EIERXgB6lbCItTj5ho9njvFA/TGP836WFn5pxG
         ock2OJhssE/SxiiOHLQK8nzNBXn5D6RhXHJisGtKxGuvpbq+0V9a9ObJ7tRzl7Alb/hZ
         MK6G22B0jO4ck2XNLX2+jQODW33Tiybx59CTtfhPVjMFD7YX3fXFgcxRJS0o7UyeOcUy
         sSSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id g10si2192606plb.146.2019.04.19.06.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 06:10:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Apr 2019 06:10:18 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,369,1549958400"; 
   d="scan'208";a="163292854"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga004.fm.intel.com with ESMTP; 19 Apr 2019 06:10:17 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hHTHU-0009SA-Pa; Fri, 19 Apr 2019 21:10:16 +0800
Date: Fri, 19 Apr 2019 21:09:23 +0800
From: kbuild test robot <lkp@intel.com>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [mmotm:master 200/348] mm/z3fold.c:1288:6: sparse: symbol
 'z3fold_page_isolate' was not declared. Should it be static?
Message-ID: <201904192137.KiV8DXsU%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   0a5fb91e6404ba48c11565cc856f597311b21344
commit: eaa5a15c91fe04a61b97e14e5a2f229d0907678b [200/348] mm/z3fold.c: support page migration
reproduce:
        # apt-get install sparse
        git checkout eaa5a15c91fe04a61b97e14e5a2f229d0907678b
        make ARCH=x86_64 allmodconfig
        make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>



sparse warnings: (new ones prefixed by >>)

   mm/z3fold.c:519:25: sparse: expression using sizeof(void)
   mm/z3fold.c:519:25: sparse: expression using sizeof(void)
   mm/z3fold.c:531:47: sparse: incorrect type in initializer (different address spaces) @@    expected void const [noderef] <asn:3>*__vpp_verify @@    got [noderef] <asn:3>*__vpp_verify @@
   mm/z3fold.c:531:47:    expected void const [noderef] <asn:3>*__vpp_verify
   mm/z3fold.c:531:47:    got struct list_head *<noident>
   mm/z3fold.c:769:25: sparse: incorrect type in assignment (different address spaces) @@    expected struct list_head *unbuddied @@    got void struct list_head *unbuddied @@
   mm/z3fold.c:769:25:    expected struct list_head *unbuddied
   mm/z3fold.c:769:25:    got void [noderef] <asn:3>*
   mm/z3fold.c:774:33: sparse: incorrect type in initializer (different address spaces) @@    expected void const [noderef] <asn:3>*__vpp_verify @@    got [noderef] <asn:3>*__vpp_verify @@
   mm/z3fold.c:774:33:    expected void const [noderef] <asn:3>*__vpp_verify
   mm/z3fold.c:774:33:    got struct list_head *<noident>
   mm/z3fold.c:799:25: sparse: incorrect type in argument 1 (different address spaces) @@    expected void [noderef] <asn:3>*__pdata @@    got [noderef] <asn:3>*__pdata @@
   mm/z3fold.c:799:25:    expected void [noderef] <asn:3>*__pdata
   mm/z3fold.c:799:25:    got struct list_head *unbuddied
   mm/z3fold.c:653:21: sparse: incorrect type in initializer (different address spaces) @@    expected void const [noderef] <asn:3>*__vpp_verify @@    got [noderef] <asn:3>*__vpp_verify @@
   mm/z3fold.c:653:21:    expected void const [noderef] <asn:3>*__vpp_verify
   mm/z3fold.c:653:21:    got struct list_head *<noident>
   mm/z3fold.c:708:37: sparse: incorrect type in initializer (different address spaces) @@    expected void const [noderef] <asn:3>*__vpp_verify @@    got [noderef] <asn:3>*__vpp_verify @@
   mm/z3fold.c:708:37:    expected void const [noderef] <asn:3>*__vpp_verify
   mm/z3fold.c:708:37:    got struct list_head *<noident>
   mm/z3fold.c:531:47: sparse: incorrect type in initializer (different address spaces) @@    expected void const [noderef] <asn:3>*__vpp_verify @@    got [noderef] <asn:3>*__vpp_verify @@
   mm/z3fold.c:531:47:    expected void const [noderef] <asn:3>*__vpp_verify
   mm/z3fold.c:531:47:    got struct list_head *<noident>
>> mm/z3fold.c:1288:6: sparse: symbol 'z3fold_page_isolate' was not declared. Should it be static?
>> mm/z3fold.c:1323:5: sparse: symbol 'z3fold_page_migrate' was not declared. Should it be static?
>> mm/z3fold.c:1382:6: sparse: symbol 'z3fold_page_putback' was not declared. Should it be static?
   mm/z3fold.c:443:35: sparse: context imbalance in '__release_z3fold_page' - unexpected unlock
   mm/z3fold.c:462:9: sparse: context imbalance in 'release_z3fold_page_locked' - wrong count at exit
   mm/z3fold.c:475:9: sparse: context imbalance in 'release_z3fold_page_locked_list' - wrong count at exit
   mm/z3fold.c:610:13: sparse: context imbalance in 'do_compact_page' - different lock contexts for basic block
   mm/z3fold.c:950:35: sparse: context imbalance in 'z3fold_alloc' - unexpected unlock
   mm/z3fold.c:965:13: sparse: context imbalance in 'z3fold_free' - different lock contexts for basic block
   mm/z3fold.c:1075:12: sparse: context imbalance in 'z3fold_reclaim_page' - different lock contexts for basic block
>> mm/z3fold.c:1382:6: sparse: context imbalance in 'z3fold_page_putback' - wrong count at exit

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation


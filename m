Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFF04C46499
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 16:09:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67E92216FD
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 16:09:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67E92216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 058328E0003; Fri,  5 Jul 2019 12:09:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0093B8E0001; Fri,  5 Jul 2019 12:09:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E123B8E0003; Fri,  5 Jul 2019 12:09:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A96C08E0001
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 12:09:40 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t2so5215176plo.10
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 09:09:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=eThIZWQnzagbgTta1Er2DFELbFkQImvbvk7oy2+dkak=;
        b=WKm+tY/8bA+QpjYRM8KRBIgDRpDJGVjgbXTtX8pJABzk54/ueXJOkSMiKYtIr1KqaO
         09sxcbDvuUUzCwa6VOoyVwnG9wUcVqp3YiD99Q4UZop9fH2kalZNWJcONm/es4q1B5Oh
         qpITXR7RD8/R92ANYBoyy9qertSEuz025c3iJdYGxZ3/l9MNkN9nl0MHNp4/hcNtcvF9
         cYn5j1ru0pbI4npUvr5jG49IEvfdFlp3c92DM2L310J8EA6WwOLXrARtdXvZ+7xBamRH
         5IQKwzjP6E1mtrP7NTzTRYhmfDEbqyKEstBsausBaKSy0fyk4QENAVE+Axn1KwJtng96
         zBfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUmb/EU1ib3gGPCnKO4XaKP1stb32hTyOmH1sMVNYbSmo7fPAUJ
	WIGd2WAYdC+v2OKeGwqU/ovhfn7DliFe2T6fMgasOfQzQci3Glxu33l3rFxaESwGYPPtoPIwEts
	lrY8ZCwR1PCEfg8nIRQE3NTirge2FtuklQ2sHXMY3YrsSmbyjuEWS8r2A6/FnYWOBvQ==
X-Received: by 2002:a17:902:8489:: with SMTP id c9mr6559784plo.327.1562342980086;
        Fri, 05 Jul 2019 09:09:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxvZvRhCbW1U5dzSAVIXvKKQVGTgsMOfhxT24EU8NFMu66T70xHJBvVipiuaxEyHkSZizA
X-Received: by 2002:a17:902:8489:: with SMTP id c9mr6559707plo.327.1562342979123;
        Fri, 05 Jul 2019 09:09:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562342979; cv=none;
        d=google.com; s=arc-20160816;
        b=pLiQ/gquM4LeC7ZEBzICj6Zk5mEhvW3IBFjZq3jQqMrAn2gM7AnprRsKABtFSJGQQD
         T25sN3yMv9x4nBeLjknI7FsJhOjzycx8JrvFQ/G6Vz+Aa7u8zfbNYL9dM6UtlymjqmFg
         IUT5dYOUAhr68zfjFhWoROmd2Gt2xKoyijAV87YZrOKfrDAtIawO5Mwj3w+XvPObpww6
         dYxoaEmTNmYXvxVFQ1yRc5vM2/WG5aGGOSJniEuKWhWubQ7dsgT+Js7hHTFZPgD4W/Fs
         iWaOptHh3Ps8Ue0f2jrHmMLn8cQl+NFhOY3+MuEoSGr2O9SWcmG0oK6k03qq92mAUX5r
         8skQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=eThIZWQnzagbgTta1Er2DFELbFkQImvbvk7oy2+dkak=;
        b=rqJkxgzinDMWj+KDi/4RsWcAjhYO1xuNYGjsFq88op8TvlV1QHO8XhzQH+MVmdiEBB
         Xwm4rkWMrd0JI5mFGr2FdDjgpOyIKM7YGy2x+T6qfnUKt+1+bD1ZFGx0k1zp7X8vj3SR
         r79uYQzgHWbSBnj45UkD9qXPJTaCUCj5AqSZJ1E+X3qfrK7v8DE+Fn7C8c/vp94M7yKr
         7c6Y72Fiz6AEMiow4V8ZR+2qXBkpy63fkeusI5mk7LFaf5KOwNBRL4U4nuTm4fVbDSrS
         3z3mTnqDh3JG5skEXs/8popWi71wwbGDg/+vuyY/YzeYSNfDLBeM6DT3JIjddNhy5ACx
         rcFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id h63si9448019pge.559.2019.07.05.09.09.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 09:09:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jul 2019 09:09:35 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,455,1557212400"; 
   d="gz'50?scan'50,208,50";a="169702060"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga006.jf.intel.com with ESMTP; 05 Jul 2019 09:09:33 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hjQmD-000GHp-Bq; Sat, 06 Jul 2019 00:09:33 +0800
Date: Sat, 6 Jul 2019 00:08:59 +0800
From: kbuild test robot <lkp@intel.com>
To: Arnd Bergmann <arnd@arndb.de>
Cc: kbuild-all@01.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Sasha Levin <alexander.levin@microsoft.com>
Subject: [linux-stable-rc:linux-4.9.y 9986/9999] ptrace.c:undefined reference
 to `abort'
Message-ID: <201907060045.bQY0GTP0%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="tKW2IUtsqtDRztdT"
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-4.9.y
head:   af13e6db0db43996e060d2b9ca57f60b09d08cb8
commit: 273b0e9d8a3e0970fab8ad1b037adf9e3a9fc63b [9986/9999] bug.h: work around GCC PR82365 in BUG()
config: arc-defconfig (attached as .config)
compiler: arc-elf-gcc (GCC) 7.4.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 273b0e9d8a3e0970fab8ad1b037adf9e3a9fc63b
        # save the attached .config to linux build tree
        GCC_VERSION=7.4.0 make.cross ARCH=arc 

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>

All errors (new ones prefixed by >>):

   arch/arc/built-in.o: In function `genregs_set':
>> ptrace.c:(.text+0x9bc): undefined reference to `abort'
>> ptrace.c:(.text+0x9bc): undefined reference to `abort'
   arch/arc/built-in.o: In function `genregs_get':
   ptrace.c:(.text+0x2de8): undefined reference to `abort'
   ptrace.c:(.text+0x2de8): undefined reference to `abort'
   arch/arc/built-in.o: In function `arc_pmu_device_probe':
>> perf_event.c:(.text+0x99e6): undefined reference to `abort'
   arch/arc/built-in.o:perf_event.c:(.text+0x99e6): more undefined references to `abort' follow

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--tKW2IUtsqtDRztdT
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--tKW2IUtsqtDRztdT--


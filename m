Return-Path: <SRS0=B01V=PM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B2A9C43387
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 18:30:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0527218D8
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 18:30:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0527218D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BE578E0100; Fri,  4 Jan 2019 13:30:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36CBE8E00F9; Fri,  4 Jan 2019 13:30:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25BBA8E0100; Fri,  4 Jan 2019 13:30:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9A378E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 13:30:04 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id l22so37713082pfb.2
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 10:30:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JA9xWizUHWLawHgBORt127ISYI4c8pX2eYraqdL8E/o=;
        b=B3/yrhsBYKcmP/tMXRZzSre4FGo/POG20U6iC5AegPtsD969l643cwoww0RFRacNTb
         njD4ydx5zpPhzACwqxz3AAQUBRWmJzdJVie0awKXywHrmrDA1ua5/v5Lntw7SEpWr65y
         /kQYZptb5Zk7G+IM+wiXhG6OAdf+8I6ylp6YCtbm07YGWc6sE8vX3lULss4fWhv4Rnj6
         zB2TegeG5Au1M2K/w/4WoqsC+gta74UVj71pQU11cE7vuoSgZdUGEiccj8Fjsz3CxbFD
         PYrqgcglRUG4rxONjc2ns4j/A7J0o9nqk+b4pGA3UTZ+XPYmqx2a2DLY8bT2TQ2skmXe
         oDpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukdNbzn+WKNCrSMSMhY4aOx+qOQM0r/W5wGJWAzhJPl+fu6xKGBl
	nkuWmgm5hD6OVz0wDBe0IwsLpPSQBhZjr+k6iX7LJ+hx7rH2omwA/KHqQ4O36KJbJMX5Iohnu4W
	2LmV9+s5/NcMqfvrTj4Y5tAPn/brf4gGJ5kLUqu3yMovRrjZy4DmtW4DRzXCYb4fIpA==
X-Received: by 2002:a63:2263:: with SMTP id t35mr2530188pgm.69.1546626604180;
        Fri, 04 Jan 2019 10:30:04 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5pZJluhO311Fsdb+B9E8KRY1Um53/57RSrnB2RqrDC2ck5KGTV1fuJGXCYH8rqw5jprEY+
X-Received: by 2002:a63:2263:: with SMTP id t35mr2530111pgm.69.1546626602720;
        Fri, 04 Jan 2019 10:30:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546626602; cv=none;
        d=google.com; s=arc-20160816;
        b=jk9T61QyKMk+KSUeXlsLmd6t1SrZJzrgb37oB1PHudzunJNCX8sa6ZIBl9bX+LJftY
         kVnNk5q+1LEH7dW4fLIp0bj9geOeF6QOEbio7IZjgOyL2xtwKdebak3ad0bT6x5vAXC0
         vTEha6hESmO1amtxNCMxOJGTWKwm6vRoEG7Pr42bSq2kl5mweugJQXopcvadRvbHzIVX
         DDLo1jJYZB5detMxCs5f/ppM72qJXTJ7hV25ISRcpKFQ+xRH3uL98OGyQyHTLDGJuopB
         FMvG7HU9822FbrWV/r6Qe+gA++OvqYneh1TwzFnDSRrOyVRq9rjOAZmV0DX4i1V7qkh3
         LAMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JA9xWizUHWLawHgBORt127ISYI4c8pX2eYraqdL8E/o=;
        b=VuetSBDM+AR3xD/mjBFOmrflMHDrtcWQN2xj+L3lJouEN3Zt9JiCl76FU03lAbhTDZ
         MHGeOvr4KATHGX0+RmqF3XORDmgGv5T4/o5mLBlszcpA5vyiJ20nuQIEot0uqITPuKBT
         glhJwwpvWc/caIu9xXy0ic7ARc/5/YIY6d1wUMfn//11EZTOh92w1lYmh9uandmyVVPT
         naiV47upImuUBDjZOU1lDnksEYSGMm6fF3BRZ3PNLG4GzznnK+3AyIq5GMFRRTAINz+6
         cSLhZacPX1PxNFgdh4GZu5U61R6neNuARTxz/wWNJ/KqWQbAA+rCVrZYDioqWWjhDSeL
         pmSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t186si3478016pfd.68.2019.01.04.10.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 10:30:02 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Jan 2019 10:30:01 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,439,1539673200"; 
   d="gz'50?scan'50,208,50";a="131601294"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga002.fm.intel.com with ESMTP; 04 Jan 2019 10:30:00 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1gfUEJ-0002Af-IJ; Sat, 05 Jan 2019 02:29:59 +0800
Date: Sat, 5 Jan 2019 02:29:28 +0800
From: kbuild test robot <lkp@intel.com>
To: Ashish Mhetre <amhetre@nvidia.com>
Cc: kbuild-all@01.org, vdumpa@nvidia.com, mcgrof@kernel.org,
	keescook@chromium.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org,
	Snikam@nvidia.com, Ashish Mhetre <amhetre@nvidia.com>
Subject: Re: [PATCH] mm: Expose lazy vfree pages to control via sysctl
Message-ID: <201901050245.eqckFBTE%fengguang.wu@intel.com>
References: <1546616141-486-1-git-send-email-amhetre@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ew6BAiZeqk4r7MaW"
Content-Disposition: inline
In-Reply-To: <1546616141-486-1-git-send-email-amhetre@nvidia.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190104182928.ZTtY2gLo1sh2ncYjMNYHT_YQSXoWmDKH8XenRWnI004@z>


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Hiroshi,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.20 next-20190103]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Ashish-Mhetre/mm-Expose-lazy-vfree-pages-to-control-via-sysctl/20190105-003852
config: sh-rsk7269_defconfig (attached as .config)
compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        GCC_VERSION=7.2.0 make.cross ARCH=sh 

All errors (new ones prefixed by >>):

>> kernel/sysctl.o:(.data+0x2d4): undefined reference to `sysctl_lazy_vfree_pages'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--ew6BAiZeqk4r7MaW
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
NPh0mq0mxgwU+v8HKZZaj4eqAAA=

--ew6BAiZeqk4r7MaW--


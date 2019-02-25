Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71780C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 07:08:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 146BC20842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 07:08:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 146BC20842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8A228E016E; Mon, 25 Feb 2019 02:08:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A39BC8E016A; Mon, 25 Feb 2019 02:08:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 929B08E016E; Mon, 25 Feb 2019 02:08:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 515858E016A
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 02:08:03 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f6so1769535pgo.15
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 23:08:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zncS5Hei5eyrH5Lr25FkrUDlXatsvahypOUYl3EkvIE=;
        b=F92OTeJwaa7NOBl9H4UlXi4dm+P+lg5QIAlqAyxw35hw9lg9NN8lO6yMpvxhGWUicO
         w3tcHdMlGGYgook+p6NHu1NqvMiGgrULrThQkAnuTJ+pHPlQYKdn+K/wv9lQO2Ll+CRs
         J/B4aym3IZxe3Mt1brp3q/nbBCg2rDf4kgaVdQYgwRBtuHoJAokLP/bHIep+MwEM5Clk
         XdTi1kn5nV1xSWY8f6r+elZJAX9kbRHYHnLrxBenX0JWHWBTKgjDjpAcV3xxrYZeNA3g
         a+USR8n5X1sBXT6zUv1ixtottPllvuQyjf8MAxeIEX+Sq+IW4aBxXCqIhPtgQnWLmamS
         Jx0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubge1S1ktREW+oZyY9Yvtk0xBI4CCeGSLFWJ6lpCm7lUs1bPeUA
	P1mQ4QYBOA/FA4Y9OlmvCGZDdY8sil0LBKwqChsSCHHUaLOYuOV0Vxhzwrj4wkHpHMrWxYoXb5K
	5cyysBHQBJf5amItAEYxK7Vatx/kzUlDRLe+B/lkCkSszy5g3AOc+s3lqv3qz+zOyEw==
X-Received: by 2002:a17:902:2702:: with SMTP id c2mr8871525plb.239.1551078482315;
        Sun, 24 Feb 2019 23:08:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaxmSMc/tP/cTC9AlpwQLDXW1RM8fa5FEefMAwvLgUN70BUC4E3EFRvQftuS29I6GWzim8N
X-Received: by 2002:a17:902:2702:: with SMTP id c2mr8871449plb.239.1551078480720;
        Sun, 24 Feb 2019 23:08:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551078480; cv=none;
        d=google.com; s=arc-20160816;
        b=bsFK+6osfZZKJr61Tsm7uJVdCqA6G6Eszy/s42kUIa8iBzkhuq7GlceahLpqgQDHf4
         omtY7qyOTK4v6rdYmNOjtiHLWutMLhLwfPO5C7GRLBt3IIy7b6Pn2VXT19utT+tlzu0K
         gRvgAG9Wjt3oAylSFG3Vnx5sn/iTT1EjkitQxRgzWGE0lxCTLwWAxHhet48oLZTd3k/j
         goG2aWURUejzxYMeKUnfEGJp31fjxsVep4WNLyvkuUO1BLWDGzidlFC1Swqjh4Lysfbr
         V7b2il+UdQVIH4RFSonODrQjkfHU8rAXceThGewcLTA4dTDR2rWrBg3K9Pn8EWsgJa8s
         Hinw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zncS5Hei5eyrH5Lr25FkrUDlXatsvahypOUYl3EkvIE=;
        b=zfCwmUJiGdkRQhrvvePh00x73RxV/0ch161mIQxXnCmCPZrYOhZ1kWbN6AkKuwqDp9
         JUkoNSLOknxGK0X8rQNdgwdvUj8a92D3E0MCOU4ct9RF5tZLjyI1oYWmXg2e6zYL8pSo
         +tsRrkyY+19uZ9++LIMTcwsE0B6KpjU0849SF8ZVZG1Y3wfWvAb8EUsPBVcXUCxd3ufJ
         F7RuQfgB2eG0aH6b5kTCyzzV2FQlrdgV+er/DzTgEUNpqtiAUWZEdcLHqY8vCXcvYd4X
         Jl34+iNLZ0VAnnF8qBcKE/XI7PKA/SGVzGIY0/cFWOmKnLOFed3WDI7Ieoz1IEbV23Pz
         y0Wg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id f193si8712239pgc.510.2019.02.24.23.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 23:08:00 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Feb 2019 23:08:00 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,410,1544515200"; 
   d="gz'50?scan'50,208,50";a="141362597"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga001.jf.intel.com with ESMTP; 24 Feb 2019 23:07:55 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1gyAMl-000DqP-7P; Mon, 25 Feb 2019 15:07:55 +0800
Date: Mon, 25 Feb 2019 15:07:10 +0800
From: kbuild test robot <lkp@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: kbuild-all@01.org, x86@kernel.org, linux-mm@kvack.org,
	Pingfan Liu <kernelfans@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andy Lutomirski <luto@kernel.org>, Andi Kleen <ak@linux.intel.com>,
	Petr Tesarik <ptesarik@suse.cz>, Michal Hocko <mhocko@suse.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Jonathan Corbet <corbet@lwn.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Daniel Vacek <neelx@redhat.com>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/6] mm/memblock: make full utilization of numa info
Message-ID: <201902251505.hhsw20ny%fengguang.wu@intel.com>
References: <1551011649-30103-3-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="RnlQjJ0d97Da+TV1"
Content-Disposition: inline
In-Reply-To: <1551011649-30103-3-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Pingfan,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v5.0-rc4]
[cannot apply to next-20190222]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Pingfan-Liu/mm-numa-extract-the-code-of-building-node-fall-back-list/20190225-143613
config: i386-tinyconfig (attached as .config)
compiler: gcc-8 (Debian 8.2.0-20) 8.2.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   ld: mm/memblock.o: in function `memblock_build_node_order':
>> memblock.c:(.init.text+0x310): undefined reference to `build_node_order'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--RnlQjJ0d97Da+TV1
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--RnlQjJ0d97Da+TV1--


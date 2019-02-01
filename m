Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5314FC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:56:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E407B21872
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:56:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E407B21872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 805DA8E0003; Fri,  1 Feb 2019 09:56:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78F708E0001; Fri,  1 Feb 2019 09:56:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 608C28E0003; Fri,  1 Feb 2019 09:56:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08E0D8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 09:56:58 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t2so5748823pfj.15
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 06:56:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=O0BUif+2aFlGQObY67DR6q1FuJzsmb96MydB8vjhH7Y=;
        b=NEhf2bLYq/zS47vuRKka8CvqeuDtGc1b9bxx/ktwFmzfX4yvnKCB9V5Qs+9SkvyYxJ
         Uu8AZDPesJV5vtyw/7hY+mfzTHs8CYjIdYL4zgl8/VVxP7+ZCi4UX9uwmwmV2kZVty0l
         ldufURyyhJwSA3rFZq3hdG6m62DBSYGcd4s7oomz5dXICgBDGhWJ9WtvpPx0+AO74V/k
         Oy6+Q+rZNpsgiyPlSrSOSKbHyeGKH75+V1xvw0ydrvSwTsdtEY5N42SWuqgx6/JDztB3
         5WHHovrervsPZlK9TzNYR+vp0AmiVvHrdJNsu+2uWd2Mp9Dw9CYr21LvSgyRBGIgfun4
         UFrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukcQLXOf7FDjJJGeRpCC0NQdTgW2xkR8JALrj2tNOmq0BVTG2fTp
	1WqQd7jugggzPM3sD6jfSCfzkKD46cVqn1WZ/zwCX0cNzRJSo2AenmfRDUl3/fnTQP6+RJk54MV
	67jDSX8FLneSlMVkXv+J1Dkg6JWL7DWX1fKBmfsF55FIBiT65zRXzKFgHjHyMpBQyaQ==
X-Received: by 2002:a17:902:3064:: with SMTP id u91mr39145464plb.325.1549033017379;
        Fri, 01 Feb 2019 06:56:57 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6bup/S2K8YhY9YUuYHc6KJHF6r08pR2gGfAWQduA0N4J36m7Lk6296yq7UbGrbmgD8Vabz
X-Received: by 2002:a17:902:3064:: with SMTP id u91mr39145404plb.325.1549033016218;
        Fri, 01 Feb 2019 06:56:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549033016; cv=none;
        d=google.com; s=arc-20160816;
        b=YI0WlymwxEqISuO3Ay0Pb0aVl0RBegNZpQtSHhhj5PCehGtYNV8ILXAFIBlomiLZ7x
         fCWNgtq5TpqEfeyGoyjdR1kUQB3D3zOxeYZ6c8JYhdt+WdN3UX1W4VQqF5kogZDXOL3k
         lfTizrdJ/87kbmasaJGWB6nuElx/IvTf1X81r9kv0X3tdB+jW3M6CT27w1PfQqiXpd+M
         FmupRaXAS3YZWz/acXahd3YPMqGSmy++zStZlvkBXjCzvTtkSlw5BfovC7BAohp/nxp5
         tJo1stWcmRTptXvqgQ1lfx9raUbzZu9BV7M6EzSdQ7FatC0DG2LwzT2nyvHOrxEKYFh+
         asMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=O0BUif+2aFlGQObY67DR6q1FuJzsmb96MydB8vjhH7Y=;
        b=DT1zTESwXULyNTSg5T6CvRxfF+4sRrKbA37qrCfxXdzFHVs9TFQ3WLfs+1EWlllc/A
         1uDCYWYKB/Q/iSRDNpVtqk8FIxQRB9BfiOZzgOPqjmeHEL1vYjsFiaxg5K0U5dCliJWU
         WY2awe7fGOC0j2kH4yxZi3Gcf9zDkjrLKeDX9qgYjSVQtBR+U1TlSnu8KV77UEUWUFQn
         cVcmHqsB0dmqUr74YnWbJP8tutxX5c+5mce2NsEQmfPvAaaWYlon1N8yuuJWzXdhanCB
         z2EKWF3OlV+UOAo47VYk6cCzDZmmr4xLTGUn2mRUBpBcWid9DopoOptGlozXQhQtx0Tf
         zF9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 24si7055607pgm.167.2019.02.01.06.56.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 06:56:56 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 Feb 2019 06:56:55 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,549,1539673200"; 
   d="gz'50?scan'50,208,50";a="121267689"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga008.fm.intel.com with ESMTP; 01 Feb 2019 06:56:52 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1gpaFR-0001IY-B0; Fri, 01 Feb 2019 22:56:53 +0800
Date: Fri, 1 Feb 2019 22:56:44 +0800
From: kbuild test robot <lkp@intel.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: kbuild-all@01.org, Guo Ren <ren_guo@c-sky.com>,
	Juergen Gross <jgross@suse.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [linux-next:master 5353/5361] mm/sparse.c:422:69: warning: format
 '%lx' expects argument of type 'long unsigned int', but argument 6 has type
 'phys_addr_t' {aka 'unsigned int'}
Message-ID: <201902012242.eceQXCfJ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MGYHOYXEY6WxJCY8"
Content-Disposition: inline
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   9fe36dd579c794ae5f1c236293c55fb6847e9654
commit: 1c3c9328cde027eb875ba4692f0a5d66b0afe862 [5353/5361] treewide: add checks for the return value of memblock_alloc*()
config: arm-pleb_defconfig (attached as .config)
compiler: arm-linux-gnueabi-gcc (Debian 8.2.0-11) 8.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 1c3c9328cde027eb875ba4692f0a5d66b0afe862
        # save the attached .config to linux build tree
        GCC_VERSION=8.2.0 make.cross ARCH=arm 

All warnings (new ones prefixed by >>):

   mm/sparse.c: In function 'sparse_mem_map_populate':
>> mm/sparse.c:422:69: warning: format '%lx' expects argument of type 'long unsigned int', but argument 6 has type 'phys_addr_t' {aka 'unsigned int'} [-Wformat=]
      panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%lx\n",
                                                                      ~~^
                                                                      %x
   mm/sparse.c: In function 'sparse_buffer_init':
   mm/sparse.c:440:69: warning: format '%lx' expects argument of type 'long unsigned int', but argument 6 has type 'phys_addr_t' {aka 'unsigned int'} [-Wformat=]
      panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%lx\n",
                                                                      ~~^
                                                                      %x

vim +422 mm/sparse.c

   408	
   409	struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid,
   410			struct vmem_altmap *altmap)
   411	{
   412		unsigned long size = section_map_size();
   413		struct page *map = sparse_buffer_alloc(size);
   414	
   415		if (map)
   416			return map;
   417	
   418		map = memblock_alloc_try_nid(size,
   419						  PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
   420						  MEMBLOCK_ALLOC_ACCESSIBLE, nid);
   421		if (!map)
 > 422			panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%lx\n",
   423			      __func__, size, PAGE_SIZE, nid, __pa(MAX_DMA_ADDRESS));
   424	
   425		return map;
   426	}
   427	#endif /* !CONFIG_SPARSEMEM_VMEMMAP */
   428	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--MGYHOYXEY6WxJCY8
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
HzvXL70vqwAA

--MGYHOYXEY6WxJCY8--


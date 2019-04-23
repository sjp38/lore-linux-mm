Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 418D5C282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 20:19:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3069208E4
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 20:19:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3069208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 417FF6B0003; Tue, 23 Apr 2019 16:19:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C6456B0005; Tue, 23 Apr 2019 16:19:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B5F86B0007; Tue, 23 Apr 2019 16:19:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3E1E6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 16:19:56 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r13so10686525pga.13
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:19:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=xe4TgpSfBrTfmWCI9Ym9YkV54OqeoI6DXGEzdNzRb1Q=;
        b=eDExqDcRHzXGt1QE5btpLfVKL9UxGuSXZFUGoyZC64nwZwdWK32/Z/E06hoLZmdeS+
         6MnOF/3tODqVzCxbfOZEBrq88XGJSUUBYKFK1RaiHJuovUM2IH9XxkEDvVa5eCKbTbJO
         yx5E1XMBmCoTRt50Q+7DY2QPpSiKgYPhE5xNiBQvIduZFAaOmbS8mR42MWFf4ZFeGu9t
         9pM6c6UcFjfrCdp4k5Ueluxbi6Y8W0NMt1EezLPlMMiAiOW4ppZ4TekeKN+U9uvTJGN/
         D+w2nfbHpEDPhMY/hBuN5954tul6ZMMHWfIaMC5dfrAwbe7r0lku1FN2sGUewYIpe1u/
         TF6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUmTDZDR32qUJZ13S9VDXXxNo/NHlXYbtDCCwkeGgUOiseLkp7E
	vsYmfBk3U/mDsRDyaMv9Q8JyeBT1fruXbJyCyjSVzKxWXh6IiYm++QgGwV/nkJEeyc9V72GGHWH
	UOcyAUsjmtcEHKzfU9tIjswqGeWXT0GbEhyFcK2S8jzh0e2LvdtCJHJNfL6tF5Pv3OQ==
X-Received: by 2002:a63:445d:: with SMTP id t29mr12291934pgk.303.1556050795913;
        Tue, 23 Apr 2019 13:19:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRnWTubirvhzIEQxD9s2KChM8wSe1WKFRiigpiv4XIjMBsXvE9j4v40Cn/fxLnsueaJ9GK
X-Received: by 2002:a63:445d:: with SMTP id t29mr12291861pgk.303.1556050794671;
        Tue, 23 Apr 2019 13:19:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556050794; cv=none;
        d=google.com; s=arc-20160816;
        b=H8CwXaPPXFjvIOT2cyhUKwZzLzTQWac/wuuL+TB0ihkO6x9RWvF/qbc5zLHy6Z4T9j
         xTuSTGtXz7gOj69QEfavrnwxSVTforSJSWIw8mhAC5yyo+9tt29r6m/cjND48GoMugvj
         OgF8fWLgbeu9+G7EKck90Eu3GPDK5CWn+1/R/3wLDFijUHHRu2co1ID7SE1qzc5wnP5G
         rH9/m+V8Ol7zx/L/az7ocTFmHvRh9YHWIkOnbZVtPfOHHATVH6v3rccaHeRA2VbSMPoF
         VVwRaT53h2ZfqTQ5g/mkoa6BcvCFDx7IdPsWG6KCmAIUkQB//99c+zPhyDt3mOzjG3M5
         cxqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=xe4TgpSfBrTfmWCI9Ym9YkV54OqeoI6DXGEzdNzRb1Q=;
        b=0K6kLZmQ6PXIKp5b8uZ/ymf2Vm7nc4AxTmQURh9IP2bY4arPkv+BCAMc/8KdJ4Iv9v
         u/BsLI10NDkpmTZU2Z2AT0VTj6GSXLwbsIAmb62r91cBHvCoCPeNH2szv2Oc1BJ+qWNS
         0g1nEk/Siw2ZhLXAJ9m4JWIx0/XIEmGhNKW22UP/9cRkxrIYiOkfAg8JNKfEhGIPUKT3
         FlhWi5mCARVvHnF4PoKn5eXNCVW3iDofHjYEARvk9alDTOSLqxx1epcCcQJ/uAwbfhRF
         H2c+lWqcEAFPHi2NCpVbXeBBqpnWbIZ9KIoEZVUi2nJWVwN2PlpvBDjnKH8vnPy3oKVt
         24wQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 62si16939772pft.98.2019.04.23.13.19.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 13:19:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Apr 2019 13:19:53 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,387,1549958400"; 
   d="gz'50?scan'50,208,50";a="340115043"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga005.fm.intel.com with ESMTP; 23 Apr 2019 13:19:52 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hJ1tP-0003vV-VV; Wed, 24 Apr 2019 04:19:51 +0800
Date: Wed, 24 Apr 2019 04:19:36 +0800
From: kbuild test robot <lkp@intel.com>
To: Kees Cook <keescook@chromium.org>
Cc: kbuild-all@01.org, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [rgushchin:kmem_reparent.2 253/325] fs/binfmt_elf.c:1140:7: error:
 'elf_interpreter' undeclared
Message-ID: <201904240434.klMowbsN%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="qMm9M+Fa2AknHoGS"
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://github.com/rgushchin/linux.git kmem_reparent.2
head:   ad68b307e7a20f658307c41b9e8063743d07eda8
commit: e0477c3bfa481937438fa6733bcb70e1d8f3d1a9 [253/325] fs/binfmt_elf.c: move brk out of mmap when doing direct loader exec
config: openrisc-or1ksim_defconfig (attached as .config)
compiler: or1k-linux-gcc (GCC) 6.0.0 20160327 (experimental)
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout e0477c3bfa481937438fa6733bcb70e1d8f3d1a9
        # save the attached .config to linux build tree
        make.cross ARCH=openrisc 

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>


All errors (new ones prefixed by >>):

   fs/binfmt_elf.c: In function 'load_elf_binary':
>> fs/binfmt_elf.c:1140:7: error: 'elf_interpreter' undeclared (first use in this function)
     if (!elf_interpreter)
          ^~~~~~~~~~~~~~~
   fs/binfmt_elf.c:1140:7: note: each undeclared identifier is reported only once for each function it appears in

vim +/elf_interpreter +1140 fs/binfmt_elf.c

  1122	
  1123		retval = create_elf_tables(bprm, &loc->elf_ex,
  1124				  load_addr, interp_load_addr);
  1125		if (retval < 0)
  1126			goto out;
  1127		/* N.B. passed_fileno might not be initialized? */
  1128		current->mm->end_code = end_code;
  1129		current->mm->start_code = start_code;
  1130		current->mm->start_data = start_data;
  1131		current->mm->end_data = end_data;
  1132		current->mm->start_stack = bprm->p;
  1133	
  1134		/*
  1135		 * When executing a loader directly (ET_DYN without Interp), move
  1136		 * the brk area out of the mmap region (since it grows up, and may
  1137		 * collide early with the stack growing down), and into the unused
  1138		 * ELF_ET_DYN_BASE region.
  1139		 */
> 1140		if (!elf_interpreter)
  1141			current->mm->brk = current->mm->start_brk = ELF_ET_DYN_BASE;
  1142	
  1143		if ((current->flags & PF_RANDOMIZE) && (randomize_va_space > 1)) {
  1144			current->mm->brk = current->mm->start_brk =
  1145				arch_randomize_brk(current->mm);
  1146	#ifdef compat_brk_randomized
  1147			current->brk_randomized = 1;
  1148	#endif
  1149		}
  1150	
  1151		if (current->personality & MMAP_PAGE_ZERO) {
  1152			/* Why this, you ask???  Well SVr4 maps page 0 as read-only,
  1153			   and some applications "depend" upon this behavior.
  1154			   Since we do not have the power to recompile these, we
  1155			   emulate the SVr4 behavior. Sigh. */
  1156			error = vm_mmap(NULL, 0, PAGE_SIZE, PROT_READ | PROT_EXEC,
  1157					MAP_FIXED | MAP_PRIVATE, 0);
  1158		}
  1159	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--qMm9M+Fa2AknHoGS
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--qMm9M+Fa2AknHoGS--


Return-Path: <SRS0=B01V=PM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EAAFC43387
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 22:34:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8DA221872
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 22:34:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8DA221872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76D008E010B; Fri,  4 Jan 2019 17:34:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71B138E00F9; Fri,  4 Jan 2019 17:34:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60A608E010B; Fri,  4 Jan 2019 17:34:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE788E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 17:34:13 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 4so28029341plc.5
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 14:34:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zjqSTkFcPXv+1eofiASp8P7axWP25R2yYbsbwxcR6cY=;
        b=JG/96+KnbPsDs9p7gW1AH7QeOntkRTZAbL7fA+4B0nxDnVbwUKfhvBPlF/1xtonO0P
         fdtrgvmVmrYxKA4MOO69rfx6fX1ybTUcT4ZD7vX7FOpTAIOf9zIc7uQGG8XKFBBkmwFw
         f0BzrwoIT3tPWHaQ+Z4jyAMrOlMUeQULzGdiG2v4hVsOmp6JVFFaWxKmTB/rzo/jUX3Q
         BRo0IX1qX7XslMvKAy4hCogi9qTKs405GVEymDe6rRNshEohJzWK1ur1w9ppLpuOgesl
         WwkpXGJBOF6rxFcjzI1Eao0Eiv1s9G/UIZbFjcav0GOQsr+EGhHt41SNyJQ+yrfysflb
         igVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukcIVosiivXdWp1V6PdBDLHXpBmdc4RnTC/d21CohLRMoR0EhVKN
	tK1yRwya/OG/iXAfDUNLUP9XUNmmFaA4FGWjLJAf8+uVLtlGcgFRx31xnjQtAJASrnMG62Wbz0E
	HMVKOn6YGCke8cp3H0i9JnIPA6bjV97GUaJ2sQbNIvT8f6vuQxzLliQc6BCxEJ5xuBQ==
X-Received: by 2002:a63:5a57:: with SMTP id k23mr3113980pgm.5.1546641252043;
        Fri, 04 Jan 2019 14:34:12 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6bsdHjz3yZk+w5duOsCXF9CkIpRLjLSMlqIB4nLB33im83eKtiWiVOxrk6d1l5Vwq6IdO6
X-Received: by 2002:a63:5a57:: with SMTP id k23mr3113923pgm.5.1546641250818;
        Fri, 04 Jan 2019 14:34:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546641250; cv=none;
        d=google.com; s=arc-20160816;
        b=VJUT2L9BgrLxEBqJFVNiNN9N3hj8os8axhX2aIfvo0cYWlIUQ4mOpvYSV3inyQw4Pj
         XVMUFN1oiNRBzd0DrIL6BlRpc1PWx+KWfMSbJbHBbqNf5iYlWGt2G59p9M8/z7x7TU3O
         vtlTUEuzqvJBPyRRY8ThxPkqFxe5SaZaqUuLFjP5EjGrJyAfqjv9HTNPyem9iS4gHRd6
         O2kwRJV+pvjFKdFGbFhpcrdzQr/0zaCrCsCJY96clDE/JdxTBcTu3c9VBgE0uaxGlC2m
         OU7B2gF61wWupZvSa1YDacPhMsHecB6GHB8w3pZ4/U2m0oQySWfN5wxlO0PpjU5Hy50+
         qktQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zjqSTkFcPXv+1eofiASp8P7axWP25R2yYbsbwxcR6cY=;
        b=XXe4vPxliVjpTYn/FP/EVssYKSG6w2fM6Mr55GY21tC3FxR2UkhSmCA9Mbt57aH+Fu
         7eF4Noxd7o1dEWYGtj6G8iY6wA+9q88wrP7uahRcAnjJAHDIYVW59dVdvB7+ePrdZz9r
         69Cjr4jXV2AMG0CTu0Ehs6gYJ9wgikvW9siCKTMBEQYaYSxrkKm6Na9fGnFXRG/19g5Y
         ei4qVpPZ7DJy8ZCoEX8e/nwQR66bFIvalqEgPNM6+lDRpZM+laUSi2U25FiW+ocuQ+7N
         YDcct3DfoN6W7PNk85aNROfLACJmL9G3OUFZDSdfeV8zsYiM1UiyEORH3q4mxIJSTBpg
         KVng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id z86si11368129pfl.209.2019.01.04.14.34.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 14:34:10 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Jan 2019 14:34:10 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,439,1539673200"; 
   d="gz'50?scan'50,208,50";a="264504983"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga004.jf.intel.com with ESMTP; 04 Jan 2019 14:34:07 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1gfY2Z-000FRH-BJ; Sat, 05 Jan 2019 06:34:07 +0800
Date: Sat, 5 Jan 2019 06:33:13 +0800
From: kbuild test robot <lkp@intel.com>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: kbuild-all@01.org, dave.hansen@intel.com, x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 3/5] mm: remove MPX hooks from generic code
Message-ID: <201901050618.H86nOzMU%fengguang.wu@intel.com>
References: <1546624183-26543-4-git-send-email-dave.hansen@linux.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Content-Disposition: inline
In-Reply-To: <1546624183-26543-4-git-send-email-dave.hansen@linux.intel.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190104223313.MKO2m2Zm-pAeM0byK8AsIDRAH1Y5B5gN1OhXnUkUqK0@z>


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

I love your patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.20 next-20190103]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Dave-Hansen/x86-mpx-remove-MPX-APIs/20190105-051028
config: i386-tinyconfig (attached as .config)
compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

Note: the linux-review/Dave-Hansen/x86-mpx-remove-MPX-APIs/20190105-051028 HEAD 34ce15ccc190201bc8c062e1559df2c1864902ef builds fine.
      It only hurts bisectibility.

All errors (new ones prefixed by >>):

   arch/x86/kernel/setup.c: In function 'setup_arch':
>> arch/x86/kernel/setup.c:927:2: error: implicit declaration of function 'mpx_mm_init'; did you mean 'mem_init'? [-Werror=implicit-function-declaration]
     mpx_mm_init(&init_mm);
     ^~~~~~~~~~~
     mem_init
   cc1: some warnings being treated as errors

vim +927 arch/x86/kernel/setup.c

7465252ea arch/x86/kernel/setup_32.c Yinghai Lu          2008-06-23  911  
42bbdb43b arch/x86/kernel/setup.c    Thomas Gleixner     2009-08-20  912  	x86_init.oem.arch_setup();
2215e69d2 arch/x86/kernel/setup_32.c Huang, Ying         2008-01-30  913  
419afdf53 arch/x86/kernel/setup.c    Bjorn Helgaas       2010-10-26  914  	iomem_resource.end = (1ULL << boot_cpu_data.x86_phys_bits) - 1;
103e20630 arch/x86/kernel/setup.c    Ingo Molnar         2017-01-28  915  	e820__memory_setup();
28bb22379 arch/x86/kernel/setup.c    Yinghai Lu          2008-06-30  916  	parse_setup_data();
28bb22379 arch/x86/kernel/setup.c    Yinghai Lu          2008-06-30  917  
^1da177e4 arch/i386/kernel/setup.c   Linus Torvalds      2005-04-16  918  	copy_edd();
^1da177e4 arch/i386/kernel/setup.c   Linus Torvalds      2005-04-16  919  
30c826451 arch/x86/kernel/setup_32.c H. Peter Anvin      2007-10-15  920  	if (!boot_params.hdr.root_flags)
^1da177e4 arch/i386/kernel/setup.c   Linus Torvalds      2005-04-16  921  		root_mountflags &= ~MS_RDONLY;
^1da177e4 arch/i386/kernel/setup.c   Linus Torvalds      2005-04-16  922  	init_mm.start_code = (unsigned long) _text;
^1da177e4 arch/i386/kernel/setup.c   Linus Torvalds      2005-04-16  923  	init_mm.end_code = (unsigned long) _etext;
^1da177e4 arch/i386/kernel/setup.c   Linus Torvalds      2005-04-16  924  	init_mm.end_data = (unsigned long) _edata;
93dbda7cb arch/x86/kernel/setup.c    Jeremy Fitzhardinge 2009-02-26  925  	init_mm.brk = _brk_end;
fe3d197f8 arch/x86/kernel/setup.c    Dave Hansen         2014-11-14  926  
fe3d197f8 arch/x86/kernel/setup.c    Dave Hansen         2014-11-14 @927  	mpx_mm_init(&init_mm);
^1da177e4 arch/i386/kernel/setup.c   Linus Torvalds      2005-04-16  928  
4046d6e81 arch/x86/kernel/setup.c    Linus Torvalds      2016-04-14  929  	code_resource.start = __pa_symbol(_text);
4046d6e81 arch/x86/kernel/setup.c    Linus Torvalds      2016-04-14  930  	code_resource.end = __pa_symbol(_etext)-1;
4046d6e81 arch/x86/kernel/setup.c    Linus Torvalds      2016-04-14  931  	data_resource.start = __pa_symbol(_etext);
4046d6e81 arch/x86/kernel/setup.c    Linus Torvalds      2016-04-14  932  	data_resource.end = __pa_symbol(_edata)-1;
4046d6e81 arch/x86/kernel/setup.c    Linus Torvalds      2016-04-14  933  	bss_resource.start = __pa_symbol(__bss_start);
4046d6e81 arch/x86/kernel/setup.c    Linus Torvalds      2016-04-14  934  	bss_resource.end = __pa_symbol(__bss_stop)-1;
4046d6e81 arch/x86/kernel/setup.c    Linus Torvalds      2016-04-14  935  

:::::: The code at line 927 was first introduced by commit
:::::: fe3d197f84319d3bce379a9c0dc17b1f48ad358c x86, mpx: On-demand kernel allocation of bounds tables

:::::: TO: Dave Hansen <dave.hansen@linux.intel.com>
:::::: CC: Thomas Gleixner <tglx@linutronix.de>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--k1lZvvs/B4yU6o8G
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
B/XmBJXCWgAA

--k1lZvvs/B4yU6o8G--


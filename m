Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E09D2C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:44:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A19220869
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:44:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A19220869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B59E6B000C; Fri, 12 Apr 2019 14:44:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 266636B000D; Fri, 12 Apr 2019 14:44:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1545E6B0010; Fri, 12 Apr 2019 14:44:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC6156B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 14:44:41 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id c7so6776234plo.8
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:44:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=gZw1urUvbajoUmeB31SUHh8xLxXcngTyyUPwXPquPcw=;
        b=m2ggNck4FH6g//wZDv9rgum+tshxjYYV7HtNVrjp8iq6q7HNZFCeVDsPr54YsXApli
         wDbxYtnZ86oWxHMoP7KTy7tj598CkT7PtXMvCZ1L2bcZLbxUCv+BraKE6CJ2ThAX1Ypf
         bPkdTubcmSdLGKyTUfyUHlyTdatm+jqI5MZE4Ca0PEN6SwkBQFhFy9glvnsKcsELmNoR
         0fbtjKV92L2FjPvt4sr5SvNWYHJgQ3eGyXK7HlAEUtriCWutipIAIn89cgvQ89GJeICy
         m3qO5ysMHUryR7elKGBGMlbDf1Ri/KHkIBN1ibysmo0Wp4ABsGtgruowAt8q4kaw6TlB
         nLgA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWHFCiZLOAG/DCmoDFUiQ3uSVcN2sc8ZDl10JFnKhKrj/mThwAZ
	6BdcPvXYCA3T8GDNuPtsX5K0o4rDJgjNJwKchDOTHFqzCreUl+1mPSyMLL3i4l2TLn9u46XQ7XK
	VOprTEjygXBqa/173hRyeojilpIPlzSFw4bgd6T5Dg3YrFMkHVFH9qwokEwCvLbl86Q==
X-Received: by 2002:a62:1d94:: with SMTP id d142mr56963400pfd.83.1555094680383;
        Fri, 12 Apr 2019 11:44:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFZkxjLEM32s4axTj6iPS3IbvRaZQDQGKT1penlM80i1nUKGSTkZhwB6ph1vNzrVtLllez
X-Received: by 2002:a62:1d94:: with SMTP id d142mr56963280pfd.83.1555094678946;
        Fri, 12 Apr 2019 11:44:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555094678; cv=none;
        d=google.com; s=arc-20160816;
        b=I2nb98vyIJNLcNxpWjZfsQkjZdVx5X4uSeGzcaHVi9LWK0vQ5xcVQah3Y616BS4aTv
         qnrDa02Kz900zPHGgsAAMlYU03/+Jz3qyh0tEAHJZj12h9mhkhPVKKr6fSUeIP2+L8E1
         jxEEH0Cj6aCKwqTPnlBjyS6If+tHFrJVqC/UiZeQ0mAetUjpVMpbAPyz0PSMj8LRYQEl
         SxZefNxjWK0rXpkn6x7QF11TgZOla4xY59HvOvyEUqyqCWWJ9ww2GxcF7Vy1opCxBsEj
         pRBfSDVoKEAi8eoyMYUfdJNtNqs4TwosvLJ3NYphFiv7ITihmKMUko7HUvqNnr5wdPsI
         RLFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=gZw1urUvbajoUmeB31SUHh8xLxXcngTyyUPwXPquPcw=;
        b=kZ5X+1hrmgmINyg6iABXqBS6hIWWYgHZPqzOqAN1MBxK/Mro0LfzdG4e/3kdi66ICP
         L0DTmJ+KKlL+gqhAGt6TdN5bMbCQBLG8lJ461bHk3k4zRDVZg/9ZzDMMaLMHPCZbDKJw
         04wJ0DVR8770/+8h+FOVsrKsayGUKKR+BmHsqHEQNAXeIzx1P8wKiRDwu0W+D+DGh55t
         PfamZRtQSSU1YNwyNmJObOSkqlvKg0BBOaShWBA8VwaSCjtmUael/yjiEoXeoObWwR8e
         Z4CSS1ywSsidv109dUebLRNkRWLpSA86vxAccSwoYtxo9qdIK2V+a7/DVNTdS83Ja+Q9
         PWdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id w25si38637035pgc.23.2019.04.12.11.44.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 11:44:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Apr 2019 11:44:38 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,342,1549958400"; 
   d="gz'50?scan'50,208,50";a="148944773"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by FMSMGA003.fm.intel.com with ESMTP; 12 Apr 2019 11:44:35 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hF1AB-000I2t-Bo; Sat, 13 Apr 2019 02:44:35 +0800
Date: Sat, 13 Apr 2019 02:43:53 +0800
From: kbuild test robot <lkp@intel.com>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [linux-next:master 6345/7161] ipc/util.c:226:13: note: in expansion
 of macro 'max'
Message-ID: <201904130252.Ws2iLv7w%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="IJpNTDwzlM2Ie8A6"
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   bcb67f0fbce97425c5fae5109ffc44c5ddaf96ba
commit: 9b9607c0c01d45bbb0011bad9c6fefe4ab9df1d2 [6345/7161] ipc: do cyclic id allocation for the ipc object.
config: m68k-amcore_defconfig (attached as .config)
compiler: m68k-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 9b9607c0c01d45bbb0011bad9c6fefe4ab9df1d2
        # save the attached .config to linux build tree
        GCC_VERSION=7.2.0 make.cross ARCH=m68k 

All warnings (new ones prefixed by >>):

   In file included from include/asm-generic/bug.h:18:0,
                    from arch/m68k/include/asm/bug.h:32,
                    from include/linux/bug.h:5,
                    from include/linux/mmdebug.h:5,
                    from include/linux/mm.h:9,
                    from ipc/util.c:47:
   ipc/util.c: In function 'ipc_idr_alloc':
   include/linux/kernel.h:828:29: warning: comparison of distinct pointer types lacks a cast
      (!!(sizeof((typeof(x) *)1 == (typeof(y) *)1)))
                                ^
   include/linux/kernel.h:842:4: note: in expansion of macro '__typecheck'
      (__typecheck(x, y) && __no_side_effects(x, y))
       ^~~~~~~~~~~
   include/linux/kernel.h:852:24: note: in expansion of macro '__safe_cmp'
     __builtin_choose_expr(__safe_cmp(x, y), \
                           ^~~~~~~~~~
   include/linux/kernel.h:868:19: note: in expansion of macro '__careful_cmp'
    #define max(x, y) __careful_cmp(x, y, >)
                      ^~~~~~~~~~~~~
>> ipc/util.c:226:13: note: in expansion of macro 'max'
      max_idx = max(ids->in_use*3/2, ipc_min_cycle);
                ^~~

vim +/max +226 ipc/util.c

   210	
   211		/*
   212		 * As soon as a new object is inserted into the idr,
   213		 * ipc_obtain_object_idr() or ipc_obtain_object_check() can find it,
   214		 * and the lockless preparations for ipc operations can start.
   215		 * This means especially: permission checks, audit calls, allocation
   216		 * of undo structures, ...
   217		 *
   218		 * Thus the object must be fully initialized, and if something fails,
   219		 * then the full tear-down sequence must be followed.
   220		 * (i.e.: set new->deleted, reduce refcount, call_rcu())
   221		 */
   222	
   223		if (next_id < 0) { /* !CHECKPOINT_RESTORE or next_id is unset */
   224			int max_idx;
   225	
 > 226			max_idx = max(ids->in_use*3/2, ipc_min_cycle);
   227			max_idx = min(max_idx, ipc_mni);
   228	
   229			/* allocate the idx, with a NULL struct kern_ipc_perm */
   230			idx = idr_alloc_cyclic(&ids->ipcs_idr, NULL, 0, max_idx,
   231						GFP_NOWAIT);
   232	
   233			if (idx >= 0) {
   234				/*
   235				 * idx got allocated successfully.
   236				 * Now calculate the sequence number and set the
   237				 * pointer for real.
   238				 */
   239				if (idx <= ids->last_idx) {
   240					ids->seq++;
   241					if (ids->seq >= ipcid_seq_max())
   242						ids->seq = 0;
   243				}
   244				ids->last_idx = idx;
   245	
   246				new->seq = ids->seq;
   247				/* no need for smp_wmb(), this is done
   248				 * inside idr_replace, as part of
   249				 * rcu_assign_pointer
   250				 */
   251				idr_replace(&ids->ipcs_idr, new, idx);
   252			}
   253		} else {
   254			new->seq = ipcid_to_seqx(next_id);
   255			idx = idr_alloc(&ids->ipcs_idr, new, ipcid_to_idx(next_id),
   256					0, GFP_NOWAIT);
   257		}
   258		if (idx >= 0)
   259			new->id = (new->seq << ipcmni_seq_shift()) + idx;
   260		return idx;
   261	}
   262	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--IJpNTDwzlM2Ie8A6
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--IJpNTDwzlM2Ie8A6--


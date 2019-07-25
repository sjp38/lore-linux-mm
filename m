Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 708B9C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:03:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2111A22C7C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:03:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2111A22C7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AF7D8E0054; Thu, 25 Jul 2019 05:03:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9601C8E0031; Thu, 25 Jul 2019 05:03:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84E3F8E0054; Thu, 25 Jul 2019 05:03:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 344E48E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:03:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so31747451eds.14
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:03:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=O+uw8Iaq/8Apk9DHI9pBYV4+DkywBGrhuok6xbEvrTY=;
        b=noZQEhjen/BGgyGKJJmCkn+5PRJORTqDpoTQr1ncG/3dG69OUSxBbZ6MxeKwCJcOqA
         MOUDIfH/o/MFwWXMwE5DhPVMhz9mHP86KhiJX/dfwl4MScxRVsnMlqjLcdZ+S5ntFApX
         nEY3r4gtK/eTzIUC/Jalg9/8nN+9Uo5IbegIVH7YI46X8/2rLuR5OXTuL6EFwVaDU64r
         Vf6N3Ar1fymWLk4qhOg41wou8lbHDkEQHEbwNN47xPWIjhL4UmCAluSvkmNo7JmiGmq7
         qENVPGXmCc1UmoJzZkZquzN5Fqh2hwpG8ny7wOk7d1Xiwgd0z5IA4EE7qbsSUVq97yLZ
         1BdQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUjE9cTpkgL22cf1JhZETjOH9VTMjd6X+ryNI5UV4CMjsmRHuhg
	k3yLkNaRG/z3HLQ6hiYWY0pPG60jAbCGJJzL9CATK5PUMr/Y6dz6ngJmLycq2Eo1mjLAvcZG31z
	GIZT80R2vJcIEotailE7y/pUxe5n/2S+UCdYuN0jEr4/ICRQR0knVdjETzcjMyS8=
X-Received: by 2002:aa7:c1cb:: with SMTP id d11mr78068014edp.157.1564045428761;
        Thu, 25 Jul 2019 02:03:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOVgmnsYv9vworXGMF31/ZH8O5i2L+I43l8bLH/VrsbdJR4rAVafuB2+G2upAIl8K4lBLv
X-Received: by 2002:aa7:c1cb:: with SMTP id d11mr78067916edp.157.1564045427848;
        Thu, 25 Jul 2019 02:03:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564045427; cv=none;
        d=google.com; s=arc-20160816;
        b=FzgLWAruA+1VlhtZpPBGGO55fK0xJl+Q9LC3KCojry5BA0jSsANPnuzz1vp2xYpim6
         02bTbxUE3xi4C6I+m7ntdR0A1KIR5srdBkHn1BBjLR84jWdjXyQh1deAg1pCpeioVLr3
         kpf+RUotRst0yZpcMGmgDXh8cmjb5deB7vmnl9y+EdpZTNUgCPfBL0xIqGcHfCUvOk0C
         d4v4qPTVf5DWAKl13sOeQyiCjoo9lf+NfbOZqiS1Hwyzy+scbwm7cUtQro3YaZSQIpPT
         hgZv5iJsK5MMea9nwvNJvSULax9qVWUhrrXjn/dE5CK79FCj3mEqGPoJr5Zixsx5doIb
         eejg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=O+uw8Iaq/8Apk9DHI9pBYV4+DkywBGrhuok6xbEvrTY=;
        b=a/d3/a30/XMj8KZfkcgWD1/FD1q3WF1OrOkK1+riYQvTy0g0rjK/BuTtEQFddIkJ6v
         NJl/tBgeBh04eQ5xbHaVq2M3toj/VaALOa+hToGySUlNiht9r2zmjGkUVCctpl0D2a/O
         6o09fa9Sd5jU98i4H6+ptUKC/b83h/1bNY9S3LTF2ChG43oHEMrJaBy5g+6w3ug8Lwbt
         WKCgYyQP3l+/bw+gQAfQNabHEjp36sA9SA7SK1INmanDCVvUJxjAAksE/npyJXHYrOUz
         UaCP8EahFlz7dx+jygcOvTE9V0fUAslqn/Tsadyn4jlFLscQ3Jt/RwwAkxqBhhFrI5HH
         HJdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ec17si9905416ejb.327.2019.07.25.02.03.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 02:03:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4F278ACD1;
	Thu, 25 Jul 2019 09:03:47 +0000 (UTC)
Date: Thu, 25 Jul 2019 11:03:41 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"hch@lst.de" <hch@lst.de>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Junichi Nomura <j-nomura@ce.jp.nec.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH 2/2] /proc/kpageflags: do not use uninitialized struct
 pages
Message-ID: <20190725090341.GC13855@dhcp22.suse.cz>
References: <20190725023100.31141-1-t-fukasawa@vx.jp.nec.com>
 <20190725023100.31141-3-t-fukasawa@vx.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190725023100.31141-3-t-fukasawa@vx.jp.nec.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-07-19 02:31:18, Toshiki Fukasawa wrote:
> A kernel panic was observed during reading /proc/kpageflags for
> first few pfns allocated by pmem namespace:
> 
> BUG: unable to handle page fault for address: fffffffffffffffe
> [  114.495280] #PF: supervisor read access in kernel mode
> [  114.495738] #PF: error_code(0x0000) - not-present page
> [  114.496203] PGD 17120e067 P4D 17120e067 PUD 171210067 PMD 0
> [  114.496713] Oops: 0000 [#1] SMP PTI
> [  114.497037] CPU: 9 PID: 1202 Comm: page-types Not tainted 5.3.0-rc1 #1
> [  114.497621] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.11.0-0-g63451fca13-prebuilt.qemu-project.org 04/01/2014
> [  114.498706] RIP: 0010:stable_page_flags+0x27/0x3f0
> [  114.499142] Code: 82 66 90 66 66 66 66 90 48 85 ff 0f 84 d1 03 00 00 41 54 55 48 89 fd 53 48 8b 57 08 48 8b 1f 48 8d 42 ff 83 e2 01 48 0f 44 c7 <48> 8b 00 f6 c4 02 0f 84 57 03 00 00 45 31 e4 48 8b 55 08 48 89 ef
> [  114.500788] RSP: 0018:ffffa5e601a0fe60 EFLAGS: 00010202
> [  114.501373] RAX: fffffffffffffffe RBX: ffffffffffffffff RCX: 0000000000000000
> [  114.502009] RDX: 0000000000000001 RSI: 00007ffca13a7310 RDI: ffffd07489000000
> [  114.502637] RBP: ffffd07489000000 R08: 0000000000000001 R09: 0000000000000000
> [  114.503270] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000240000
> [  114.503896] R13: 0000000000080000 R14: 00007ffca13a7310 R15: ffffa5e601a0ff08
> [  114.504530] FS:  00007f0266c7f540(0000) GS:ffff962dbbac0000(0000) knlGS:0000000000000000
> [  114.505245] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  114.505754] CR2: fffffffffffffffe CR3: 000000023a204000 CR4: 00000000000006e0
> [  114.506401] Call Trace:
> [  114.506660]  kpageflags_read+0xb1/0x130
> [  114.507051]  proc_reg_read+0x39/0x60
> [  114.507387]  vfs_read+0x8a/0x140
> [  114.507686]  ksys_pread64+0x61/0xa0
> [  114.508021]  do_syscall_64+0x5f/0x1a0
> [  114.508372]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> [  114.508844] RIP: 0033:0x7f0266ba426b
> 
> The reason for the panic is that stable_page_flags() which parses
> the page flags uses uninitialized struct pages reserved by the
> ZONE_DEVICE driver.

Why pmem hasn't initialized struct pages? Isn't that a bug that should
be addressed rather than paper over it like this?
-- 
Michal Hocko
SUSE Labs


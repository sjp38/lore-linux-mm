Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B371C76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:06:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47ECC2189F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:06:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47ECC2189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A15676B0003; Fri, 26 Jul 2019 03:06:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C4ED6B0005; Fri, 26 Jul 2019 03:06:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88E508E0002; Fri, 26 Jul 2019 03:06:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7326B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 03:06:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l26so33562067eda.2
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 00:06:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SIgWQia1pGjlARJQoZwRDhhzyhiRBtXMTG1+Rpf80wk=;
        b=nQSLPoOcBI1Lh6FxPTBikNMrm0/UbDnPBEM05YMJn/174EGF5KAtejpZlymOQgWi9z
         6uuwaDXrNUZxWJsjhrjLC0EFUH1gSD4YVxC5IZi1g/HPFx/ardmpXivsSFT7rdF+FuDw
         9vvb643md3qLG3JOk8i71gFt5w8qItVSQvFBSJWSFj27dEMiX3VuSTQ8qkrL6wnwMy8w
         uQsj7qAFO512uknH/yPQ839MVC7ox4t6JW/0xAQzuVm+bTvaRtVqtwA5TeBSfmUjgpit
         d6qVNV42hs+9Cks0tUJl5F28/mwa6s82tHJjuuagEUKpfCuwCp3CaTtei4SvKIbdtOQI
         SnNg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXFT6RueI1o4JQDX/hBjLB290EuKfT3YsLxNjxPtgvja3Vtp+AC
	cEcPp32osN3AzQwri8e2xBURVTUIoaqdi5jVuswer6C2OVxYQssMk45kZvg+JajtEAes5N6EmJ3
	crWkbYxqKOk+ZHjU/LgytKjRL8eDXj32afK/bGxeR4foGeqiAVcoypz0FcGX+l/E=
X-Received: by 2002:a50:fc18:: with SMTP id i24mr80526670edr.249.1564124778619;
        Fri, 26 Jul 2019 00:06:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQeohiPEeLC8Fbx+IFBRqJDTsFV6Wj4FgWp07TxSCYspqIqsEDDTKj56w7Jmcvbpy73JzZ
X-Received: by 2002:a50:fc18:: with SMTP id i24mr80526584edr.249.1564124777553;
        Fri, 26 Jul 2019 00:06:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564124777; cv=none;
        d=google.com; s=arc-20160816;
        b=kraWdCCNumKH9tNvCtJox+xNAdbcRxTMRsRe5rE21WjMp3sHHLQ50KZ0bXiercC6tK
         2ulRC63ZWc/260tMqMRLiZXy3MTg8reaDDu6V/2GzazeZ+ZcC1JPkgh2x7q398itCDVG
         LM2Az/tu+Wy7TVYGnyuiP/eGq93ltWwn5S6klBsp8ws6gliPZA+dPL1LsAvbljOrcSG5
         yZc+5845RVpUeMLHIciDWlfYJgMODgcLLZjg9dqeLTAfY06o3unXrykMYubUWbs88Ewu
         /A3AGfQMggKR/CwWTwmd9QbxVU/nBvO1DrfvMcIVdxaJ1KcWG8L8xTiAN+sWvsAuONQZ
         +3oA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SIgWQia1pGjlARJQoZwRDhhzyhiRBtXMTG1+Rpf80wk=;
        b=V74j3VvLVSDyGbheSACvtDE575Zm7WA4wtGI07HeVSW1y82IPwVmcuBHT4PMhBLlbq
         DLWZDEwOWjn+BQQzYSSKdd8adTeE1QTkRE5nAAt8iwskvyygE0V4DuMdkdF539T/TeHu
         nejciC5FlYvd25ZrwzFiiKpnl12VobL1Rgf8oAs2oPDvH8ApFc5vQH/UHuys7IrHJ96S
         4qzti9MLyA/650/Pw1/7HIMcF8W2+q8l3+JKG7CwRuqVbAsJlXgGw0jkPofWdDPX8oZZ
         U3KaWf+IHEszEfbPzDHBzS3r3EGlyQ9OrdMX0U5+/Or4wC/jr61esABOrk+zZP26dER4
         8+KA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h54si12253742edh.205.2019.07.26.00.06.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 00:06:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 810CAB128;
	Fri, 26 Jul 2019 07:06:16 +0000 (UTC)
Date: Fri, 26 Jul 2019 09:06:15 +0200
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
Message-ID: <20190726070615.GB6142@dhcp22.suse.cz>
References: <20190725023100.31141-1-t-fukasawa@vx.jp.nec.com>
 <20190725023100.31141-3-t-fukasawa@vx.jp.nec.com>
 <20190725090341.GC13855@dhcp22.suse.cz>
 <40b3078e-fb8b-87ef-5c4e-6321956cc940@vx.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <40b3078e-fb8b-87ef-5c4e-6321956cc940@vx.jp.nec.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 26-07-19 06:25:49, Toshiki Fukasawa wrote:
> 
> 
> On 2019/07/25 18:03, Michal Hocko wrote:
> > On Thu 25-07-19 02:31:18, Toshiki Fukasawa wrote:
> >> A kernel panic was observed during reading /proc/kpageflags for
> >> first few pfns allocated by pmem namespace:
> >>
> >> BUG: unable to handle page fault for address: fffffffffffffffe
> >> [  114.495280] #PF: supervisor read access in kernel mode
> >> [  114.495738] #PF: error_code(0x0000) - not-present page
> >> [  114.496203] PGD 17120e067 P4D 17120e067 PUD 171210067 PMD 0
> >> [  114.496713] Oops: 0000 [#1] SMP PTI
> >> [  114.497037] CPU: 9 PID: 1202 Comm: page-types Not tainted 5.3.0-rc1 #1
> >> [  114.497621] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.11.0-0-g63451fca13-prebuilt.qemu-project.org 04/01/2014
> >> [  114.498706] RIP: 0010:stable_page_flags+0x27/0x3f0
> >> [  114.499142] Code: 82 66 90 66 66 66 66 90 48 85 ff 0f 84 d1 03 00 00 41 54 55 48 89 fd 53 48 8b 57 08 48 8b 1f 48 8d 42 ff 83 e2 01 48 0f 44 c7 <48> 8b 00 f6 c4 02 0f 84 57 03 00 00 45 31 e4 48 8b 55 08 48 89 ef
> >> [  114.500788] RSP: 0018:ffffa5e601a0fe60 EFLAGS: 00010202
> >> [  114.501373] RAX: fffffffffffffffe RBX: ffffffffffffffff RCX: 0000000000000000
> >> [  114.502009] RDX: 0000000000000001 RSI: 00007ffca13a7310 RDI: ffffd07489000000
> >> [  114.502637] RBP: ffffd07489000000 R08: 0000000000000001 R09: 0000000000000000
> >> [  114.503270] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000240000
> >> [  114.503896] R13: 0000000000080000 R14: 00007ffca13a7310 R15: ffffa5e601a0ff08
> >> [  114.504530] FS:  00007f0266c7f540(0000) GS:ffff962dbbac0000(0000) knlGS:0000000000000000
> >> [  114.505245] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >> [  114.505754] CR2: fffffffffffffffe CR3: 000000023a204000 CR4: 00000000000006e0
> >> [  114.506401] Call Trace:
> >> [  114.506660]  kpageflags_read+0xb1/0x130
> >> [  114.507051]  proc_reg_read+0x39/0x60
> >> [  114.507387]  vfs_read+0x8a/0x140
> >> [  114.507686]  ksys_pread64+0x61/0xa0
> >> [  114.508021]  do_syscall_64+0x5f/0x1a0
> >> [  114.508372]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> >> [  114.508844] RIP: 0033:0x7f0266ba426b
> >>
> >> The reason for the panic is that stable_page_flags() which parses
> >> the page flags uses uninitialized struct pages reserved by the
> >> ZONE_DEVICE driver.
> > 
> > Why pmem hasn't initialized struct pages? 
> 
> We proposed to initialize in previous approach but that wasn't merged.
> (See https://marc.info/?l=linux-mm&m=152964792500739&w=2)
> 
> > Isn't that a bug that should be addressed rather than paper over it like this?
> 
> I'm not sure. What do you think, Dan?

Yeah, I am really curious about details. Why do we keep uninitialized
struct pages at all? What is a random pfn walker supposed to do? What
kind of metadata would be clobbered? In other words much more details
please.
-- 
Michal Hocko
SUSE Labs


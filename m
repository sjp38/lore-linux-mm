Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59C2AC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 10:30:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 236882173C
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 10:30:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 236882173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B69C18E0004; Mon, 18 Feb 2019 05:30:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B18358E0002; Mon, 18 Feb 2019 05:30:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2EAF8E0004; Mon, 18 Feb 2019 05:30:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4438E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 05:30:16 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id j5so3314215edt.17
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 02:30:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zvFBH/qsp0Q6R/L2EVrkA4gUC2/IJsA+J/6xWUDqGYE=;
        b=IdTyqZpr9JC7Bm8pVgxHIKDZeaa0x+nLjdjIR5B3wui8u4IWwZsuiogeuknSE2Npw2
         8v/H1L8M29ujVr4nlYxRjg3YxD9H6t1dAhS8nPBIM0DNe+YG+IoRDzr7nyfhKvWm+83L
         3xDBtQTCTCpeWRgGGOfjsP3iTudEHYeAQsdFJFNhEt8CXlqP1Q5HQCsJZiIxw1gK/PNX
         MhNmDozJJGzAG3YvLWU3suNTnrzb0wfnKzZ1BsOZI2QO6xpBjqnZ0lE1GWyouPcQN7uv
         LGi++JKiFmxsSYpRyNtnPG/IktcdZBBl60J1709CNDePv32lSN5a9qF1DEWT9e8g/iIy
         RQIQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZBnr0esX3drezkC2cOXB4QKHwsgZYNhZ+V4kCQ961XUxJEvYdH
	rbOzB/LJmz+UAhkvKhIaShdsvtkGTj8rlSh3//S4u1H+gnOMznECFZCq1a6uE90W8pBs1DrQYNJ
	evCWIHqC9qWYydjVhqfBkhu98cpPZEXviKaFKpjf/phG4dHchUv0+RLIpu+F7gwQ=
X-Received: by 2002:a50:b744:: with SMTP id g62mr18798953ede.14.1550485815812;
        Mon, 18 Feb 2019 02:30:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY+oUcnwjkC/E/kEihE8/Lc+r/oAKeAJjTsh2eAKET0JOdFZfm1BnbhVLllwkDRGXN/fR3t
X-Received: by 2002:a50:b744:: with SMTP id g62mr18798879ede.14.1550485814616;
        Mon, 18 Feb 2019 02:30:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550485814; cv=none;
        d=google.com; s=arc-20160816;
        b=y+WkM2L0tUVWNVRBqMjQoROaa95uleb9kskWd7yke3E9lIhDll0iRRuXsNoU/Bnuti
         +JOm351bVP3WPdtyJWvc3I301ELlHQJ7J2Kxc5SO8uwpnJjpL1qfm/rAqcr7A+Y+vqjM
         rWXFjoBkcZktQ4Y7gkReNhMwMdMv3ZZLcD4YbMpOq+Bgj+i06xj9xJC2znRuOX37k3Fm
         Z64ngyy+gH2/aB6kqXgxa0xzZIse7dE3Yq2uFZoL1JhaWWrvtEa5Ao/9tKvu2+iquzr4
         EjKkFZMjwb0gtEyNIXcqZgl6g29Tj4l4Vsm20jmqh+Z1i4xQXaRPhpfApKfpcU3UBJa5
         pfuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zvFBH/qsp0Q6R/L2EVrkA4gUC2/IJsA+J/6xWUDqGYE=;
        b=jYXoFc+1JAw+GTRIA9VUjqVwOeYkFV1zyFeFFIZwrTZMpV9wlXLbrJhXoylpmT6TPC
         7mo06nCFDYdGUSRn904hTsvdMcAKYXejpA+pcUx7h59c2Nw2p/gQxsutuEyy0t5bJ5Y+
         L5o9J7+zr6fMZ8EipdI2ggOc/QrAxIVypL5spRuk9hYH9mQQJE5/oSLBSOx+Cg83aFwJ
         2SuIwPy7iArzgj0C8cKyUdKb5ELlq1mdkmX7X6RCyDlWieRFrBEWZ/gWJMPOAv2KsCms
         KWPC40YqxJIp2W6ZM5z2tRnqx386mFzeSqEO4DcUaSXSfETbVjBElggEjNPmkroiaU9o
         gc2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2-v6si1567126ejn.222.2019.02.18.02.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 02:30:14 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 09A9BAC97;
	Mon, 18 Feb 2019 10:30:14 +0000 (UTC)
Date: Mon, 18 Feb 2019 11:30:13 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Rong Chen <rong.a.chen@intel.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>,
	linux-kernel@vger.kernel.org,
	Linux Memory Management List <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>, LKP <lkp@01.org>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [LKP] efad4e475c [ 40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
Message-ID: <20190218103013.GK4525@dhcp22.suse.cz>
References: <20190218052823.GH29177@shao2-debian>
 <20190218070844.GC4525@dhcp22.suse.cz>
 <20190218085510.GC7251@dhcp22.suse.cz>
 <4c75d424-2c51-0d7d-5c28-78c15600e93c@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4c75d424-2c51-0d7d-5c28-78c15600e93c@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 18-02-19 18:01:39, Rong Chen wrote:
> 
> On 2/18/19 4:55 PM, Michal Hocko wrote:
> > [Sorry for an excessive quoting in the previous email]
> > [Cc Pavel - the full report is http://lkml.kernel.org/r/20190218052823.GH29177@shao2-debian[]
> > 
> > On Mon 18-02-19 08:08:44, Michal Hocko wrote:
> > > On Mon 18-02-19 13:28:23, kernel test robot wrote:
> > [...]
> > > > [   40.305212] PGD 0 P4D 0
> > > > [   40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
> > > > [   40.313055] CPU: 1 PID: 239 Comm: udevd Not tainted 5.0.0-rc4-00149-gefad4e4 #1
> > > > [   40.321348] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> > > > [   40.330813] RIP: 0010:page_mapping+0x12/0x80
> > > > [   40.335709] Code: 5d c3 48 89 df e8 0e ad 02 00 85 c0 75 da 89 e8 5b 5d c3 0f 1f 44 00 00 53 48 89 fb 48 8b 43 08 48 8d 50 ff a8 01 48 0f 45 da <48> 8b 53 08 48 8d 42 ff 83 e2 01 48 0f 44 c3 48 83 38 ff 74 2f 48
> > > > [   40.356704] RSP: 0018:ffff88801fa87cd8 EFLAGS: 00010202
> > > > [   40.362714] RAX: ffffffffffffffff RBX: fffffffffffffffe RCX: 000000000000000a
> > > > [   40.370798] RDX: fffffffffffffffe RSI: ffffffff820b9a20 RDI: ffff88801e5c0000
> > > > [   40.378830] RBP: 6db6db6db6db6db7 R08: ffff88801e8bb000 R09: 0000000001b64d13
> > > > [   40.386902] R10: ffff88801fa87cf8 R11: 0000000000000001 R12: ffff88801e640000
> > > > [   40.395033] R13: ffffffff820b9a20 R14: ffff88801f145258 R15: 0000000000000001
> > > > [   40.403138] FS:  00007fb2079817c0(0000) GS:ffff88801dd00000(0000) knlGS:0000000000000000
> > > > [   40.412243] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > [   40.418846] CR2: 0000000000000006 CR3: 000000001fa82000 CR4: 00000000000006a0
> > > > [   40.426951] Call Trace:
> > > > [   40.429843]  __dump_page+0x14/0x2c0
> > > > [   40.433947]  is_mem_section_removable+0x24c/0x2c0
> > > This looks like we are stumbling over an unitialized struct page again.
> > > Something this patch should prevent from. Could you try to apply [1]
> > > which will make __dump_page more robust so that we do not blow up there
> > > and give some more details in return.
> > > 
> > > Btw. is this reproducible all the time?
> > And forgot to ask whether this is reproducible with pending mmotm
> > patches in linux-next.
> 
> 
> Do you mean the below patch? I can reproduce the problem too.

Yes, thanks for the swift response. The patch has just added a debugging
output
[    0.013697] Early memory node ranges
[    0.013701]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.013706]   node   0: [mem 0x0000000000100000-0x000000001ffdffff]
[    0.013711] zeroying 0-1

This is the first pfn.

[    0.013715] zeroying 9f-100

this is [mem 0x9f000, 0xfffff] so it fills up the whole hole between the
above two ranges. This is definitely good.

[    0.013722] zeroying 1ffe0-1ffe0

this is a single page at 0x1ffe0000 right after the zone end.

[    0.013727] Zeroed struct page in unavailable ranges: 98 pages

Hmm, so this is getting really interesting. The whole zone range should
be covered. So this is either some off-by-one or I something that I am
missing right now. Could you apply the following on top please? We
definitely need to see what pfn this is.


diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 124e794867c5..59bcfd934e37 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1232,12 +1232,14 @@ static bool is_pageblock_removable_nolock(struct page *page)
 /* Checks if this range of memory is likely to be hot-removable. */
 bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
-	struct page *page = pfn_to_page(start_pfn);
+	struct page *page = pfn_to_page(start_pfn), *first_page;
 	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
 	struct page *end_page = pfn_to_page(end_pfn);
 
 	/* Check the starting page of each pageblock within the range */
-	for (; page < end_page; page = next_active_pageblock(page)) {
+	for (first_page = page; page < end_page; page = next_active_pageblock(page)) {
+		if (PagePoisoned(page))
+			pr_info("Unexpected poisoned page %px pfn:%lx\n", page, start_pfn + page-first_page);
 		if (!is_pageblock_removable_nolock(page))
 			return false;
 		cond_resched();
-- 
Michal Hocko
SUSE Labs


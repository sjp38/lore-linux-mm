Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18038C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:29:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD4992184A
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:29:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD4992184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DC3D8E0005; Mon, 18 Feb 2019 04:29:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68C008E0002; Mon, 18 Feb 2019 04:29:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A3468E0005; Mon, 18 Feb 2019 04:29:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 03E238E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 04:29:04 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d8so6841913edi.6
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 01:29:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=oEAuIDH3QHp3rhyXCXT0r+PJH5eBTCZg+PDlujylp3A=;
        b=U2MaHavVkALR94eGWxZ6ZGPDWKGp7kM+oBmPkcbE14dje4S7ca6dK/+SPYq2OVX6nT
         DVtIbDtxx7ydynOxqgCv11lgpxK1oZVcUq/yStGGnmK+NrwZVzMwoiG++2qCpw2UWSx4
         kBCXgb+twC7PZBrQ4I8+wnLSoiswJS5VaSTZ7sd+7zYs7wjaCTtU5XyRGgTAcwhlB+ep
         AZleVCDey5E8KXo0qRhdFcbXlZhRL+NvT+3v3C0ag/b1l4hHrQyBVP0ozRTxyko4k8ba
         nvL9mdRwvXxs8s+BatukLFrn05nlouJRfHLWw0FJTDvnVssKPHJVYgLoNMLbIE8VGG+p
         Ka6g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAua5KVnlHqRe/Mvt0It6x+RbZlrOBX1Zz2D6y34MoLt5UIt9PCMq
	LKNAmdfaF+nvruXf9TBfZGzRy9rYoiQPrctW9GhU25jhz7hcE/ahUMRQ/hl3fMK1VDazc6vTrzG
	ibex4FEA/6E6wa8dF9nuBcVoujcWFlqbKWo0HGlCA3sMirRwbvUnt61pwfmmFThI=
X-Received: by 2002:a50:ade7:: with SMTP id b36mr17676231edd.215.1550482143557;
        Mon, 18 Feb 2019 01:29:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYBclTAUyzygJTHAzNnya4vauhO98uz3DuY56JIZdvODTYdjKtJ5l4lRo/96meclRuDnY0w
X-Received: by 2002:a50:ade7:: with SMTP id b36mr17676188edd.215.1550482142645;
        Mon, 18 Feb 2019 01:29:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550482142; cv=none;
        d=google.com; s=arc-20160816;
        b=CVcc8wNNlAmap1xV1NubJRVAwmRVVOfPKaDmcLE8r6f5LzbSa/VTY12tY10CafsbRr
         LGKPZjyaNDGgwTJRMVecv53m651tW4k7p0eWPAWdFcG2jzwLh0P2p+ymSlLiDs4wZ+dn
         ymTIY0qfoWv9VOv3iCZF4kX8skS7m2mpNGWKCLQPtfEUBUjbLLF7llWZrFat0PCOpLiV
         xua4D0pfqOwQgSdHyGRK+cpwDSju1bqKcwEX651DDbIGPXISZ01gf37E9m6EHyXhXQNs
         CYipBgoGmfVgxYeg9Ymy4AF/5A5X0U+WEmfe2F9B3yxSb/xPqq6mGEceJLm8C0npM+uT
         c1dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=oEAuIDH3QHp3rhyXCXT0r+PJH5eBTCZg+PDlujylp3A=;
        b=hOV3kmF9w0eUKxcksEM7TTcfXoF7UV3A2AFa9WfsSWdE2S4PCEPCbaBpE59BmrKLEC
         vOikdVkdvhnvCa4knrx7ILg3DJn010Yh++4jcseTiKRAmgF9zburvbEl4NJbtz38lDPO
         wPv/xaJyzpttuEslCr9vo0iSOQ3i3i+G43w7a4Rp7JTrMZutVIf0EEn56xUFJFC/25QZ
         kqssvTe9MJdIyro8bX8JGCfx+EByR03t6gJecqmvt3OmX//lbWSxDuz+j4U75rcxhLDc
         5cu+vA0lBO9ayVFomzxxRVNgSV8FB0BknbbxnG3dur2XT/0FE2fAT6lotC/z7bpt06FT
         n60Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r19si1000419edm.186.2019.02.18.01.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 01:29:02 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 12A54AFA9;
	Mon, 18 Feb 2019 09:29:02 +0000 (UTC)
Date: Mon, 18 Feb 2019 10:29:01 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Rong Chen <rong.a.chen@intel.com>
Cc: Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-kernel@vger.kernel.org, LKP <lkp@01.org>
Subject: Re: [LKP] efad4e475c [ 40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
Message-ID: <20190218092901.GG4525@dhcp22.suse.cz>
References: <20190218052823.GH29177@shao2-debian>
 <20190218070844.GC4525@dhcp22.suse.cz>
 <79a3d305-1d96-3938-dc14-617a9e475648@intel.com>
 <20190218090310.GE4525@dhcp22.suse.cz>
 <f688387a-6052-6481-57f4-d3b20b2ea3bb@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f688387a-6052-6481-57f4-d3b20b2ea3bb@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 18-02-19 17:11:49, Rong Chen wrote:
> 
> On 2/18/19 5:03 PM, Michal Hocko wrote:
> > On Mon 18-02-19 16:47:26, Rong Chen wrote:
> > > On 2/18/19 3:08 PM, Michal Hocko wrote:
> > > > On Mon 18-02-19 13:28:23, kernel test robot wrote:
> > [...]
> > > > > [   40.305212] PGD 0 P4D 0
> > > > > [   40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
> > > > > [   40.313055] CPU: 1 PID: 239 Comm: udevd Not tainted 5.0.0-rc4-00149-gefad4e4 #1
> > > > > [   40.321348] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> > > > > [   40.330813] RIP: 0010:page_mapping+0x12/0x80
> > > > > [   40.335709] Code: 5d c3 48 89 df e8 0e ad 02 00 85 c0 75 da 89 e8 5b 5d c3 0f 1f 44 00 00 53 48 89 fb 48 8b 43 08 48 8d 50 ff a8 01 48 0f 45 da <48> 8b 53 08 48 8d 42 ff 83 e2 01 48 0f 44 c3 48 83 38 ff 74 2f 48
> > > > > [   40.356704] RSP: 0018:ffff88801fa87cd8 EFLAGS: 00010202
> > > > > [   40.362714] RAX: ffffffffffffffff RBX: fffffffffffffffe RCX: 000000000000000a
> > > > > [   40.370798] RDX: fffffffffffffffe RSI: ffffffff820b9a20 RDI: ffff88801e5c0000
> > > > > [   40.378830] RBP: 6db6db6db6db6db7 R08: ffff88801e8bb000 R09: 0000000001b64d13
> > > > > [   40.386902] R10: ffff88801fa87cf8 R11: 0000000000000001 R12: ffff88801e640000
> > > > > [   40.395033] R13: ffffffff820b9a20 R14: ffff88801f145258 R15: 0000000000000001
> > > > > [   40.403138] FS:  00007fb2079817c0(0000) GS:ffff88801dd00000(0000) knlGS:0000000000000000
> > > > > [   40.412243] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > [   40.418846] CR2: 0000000000000006 CR3: 000000001fa82000 CR4: 00000000000006a0
> > > > > [   40.426951] Call Trace:
> > > > > [   40.429843]  __dump_page+0x14/0x2c0
> > > > > [   40.433947]  is_mem_section_removable+0x24c/0x2c0
> > > > This looks like we are stumbling over an unitialized struct page again.
> > > > Something this patch should prevent from. Could you try to apply [1]
> > > > which will make __dump_page more robust so that we do not blow up there
> > > > and give some more details in return.
> > > 
> > > Hi Hocko,
> > > 
> > > I have applied [1] and attached the dmesg file.
> > Thanks so the log confirms that this is really an unitialized struct
> > page
> > [   12.228622] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > [   12.231474] page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> > [   12.232135] ------------[ cut here ]------------
> > [   12.232649] kernel BUG at include/linux/mm.h:1020!
> > 
> > So now, we have to find out what has been left behind. Please see my
> > other email. Also could you give me faddr2line of the
> > is_mem_section_removable offset please? I assume it is
> > is_pageblock_removable_nolock:
> > 	if (!node_online(page_to_nid(page)))
> > 		return false;
> 
> 
> faddr2line result:
> 
> is_mem_section_removable+0x24c/0x2c0:
> page_to_nid at include/linux/mm.h:1020
> (inlined by) is_pageblock_removable_nolock at mm/memory_hotplug.c:1221
> (inlined by) is_mem_section_removable at mm/memory_hotplug.c:1241

Thanks so this indeed points to page_to_nid. Thanks!
-- 
Michal Hocko
SUSE Labs


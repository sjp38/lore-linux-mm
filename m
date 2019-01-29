Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAC95C4151A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:06:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A1972084A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:06:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A1972084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1967F8E0001; Tue, 29 Jan 2019 04:06:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11C588E0003; Tue, 29 Jan 2019 04:06:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F013E8E0002; Tue, 29 Jan 2019 04:06:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 947288E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 04:06:08 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so7537497edb.22
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 01:06:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pAJjSuKvI34M/iyG8S5BJb1SVQf85IE8g3eQLQtREuM=;
        b=mmpG8OnxyLdlZiFeEy1XRcQfkC8VdzkvhsXokQhRa20J2a6B9BL+EIJAK9adrU4nIw
         xF+MPlPWxu32hp9xfJB/pAOKEq+vVLUwHykzp7agT7zG7/MwbAxD0Y9h8lsZ05ms06fI
         MJt/aBd8qDk56fQsNwVuJSguM6GyZehS47iEGF5Xsi3Uv+Wr5fZMb/vZ14ixU2p3qSXv
         XtcmeBKHUakRK3baQlg51g/8n/qjs88/pne0jOVyfeB2Kv0RATx6Q+olzSU79KtUdsAZ
         4vKyul7GdhkJYCicL2TqZccDJQN/1Qo8kAh3NtPuRhDhBNDRWYwfwMwj67bMopytclC2
         rcAA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AJcUukfKTe8G8Px0fzLqDsutziKaA/SlUIrnzVfBdiPiQywY7OkE6mZX
	YKylDiNoj7GGFIEXaY8Rmb1N/0ly9x3UBbYf7razOMC1eJTsnjYxWRRzHaVjQRW31ZSoJwkQgkZ
	oMk6PcqzSJtYkFtSeqbJ1syNdwWk3gW5rpubSYfXucBg3jDAfFuFF4CoxPb7ILGI=
X-Received: by 2002:a50:a8c3:: with SMTP id k61mr24416388edc.296.1548752768147;
        Tue, 29 Jan 2019 01:06:08 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4iMRWN8bviHlmZ7g71Yn2cxfLT15VgRzauA3vkO7m2k0r80z3//7HvhIoRqEM/zpSeIM/p
X-Received: by 2002:a50:a8c3:: with SMTP id k61mr24416349edc.296.1548752767133;
        Tue, 29 Jan 2019 01:06:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548752767; cv=none;
        d=google.com; s=arc-20160816;
        b=y2pGf8UUxof4l9itT5MsXPOXSLRah4E4dPPrpM0OTBAqVvrQVtv+BH9kO/wZg5rFbu
         Vc0uEm0KBLpGeofXVa22stnEhaj6VNnZm+v8/IAizvePSEzXCdN7fEBT4RnhlpyPjvyv
         Q6cQzcVeZaacFN8+N4h5IPO60liQSH7oOmQjsW0NPQTB4lZdCsGLAThBIHUBilX8FcYV
         3SWVSHZ2uOhYezQeTBYKrxuF/eJFeHeFhTdsVPvB+LUOP6k44dNWEyoW8QXiqq24fNt4
         I8ghJaPQRKcQK3qO4FQxTxIdXxqL6qM0DEJyGTlBJhMZPpvPsZ2kLlhHL9MzR+ZcwGe2
         cUpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pAJjSuKvI34M/iyG8S5BJb1SVQf85IE8g3eQLQtREuM=;
        b=Ebqse9sSRAngDrxjEU46rs5udK+sHwLwYpNfSQtA3+qZZIZlqbOBgoDh5vM0566M+g
         8Xfw+Ih7dOZvw2fzzUJrv3uVC7HTF0h8D+9MtS6+WdKphUD57PFcnJHtSREpZ+GBLGCt
         wuuA52tyNsvQw9uYb4HjWVC9B+dd2QNO0ZU6FFyEXB3GU8lsDjER77PA9V9GOl94DiV5
         ek5v6O/c4pRtNfY2CId+bniyyvhx/sV2FyAh1TcawSd93jhP6cDcqYBswHYbbQp4aWaw
         14PjCmjmhNGv5rEFQXsla2EJlLgp4PUK5Ohq0TdgF94f6D7fycCdQV3CzevKm+ra3H1y
         wV9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id o25si690329edf.159.2019.01.29.01.06.06
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 01:06:06 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 4A06040B1; Tue, 29 Jan 2019 10:06:05 +0100 (CET)
Date: Tue, 29 Jan 2019 10:06:05 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: is_mem_section_removable do not
 pass the end of a zone
Message-ID: <20190129090605.lenisalq2zxtck3u@d104.suse.de>
References: <20190128144506.15603-1-mhocko@kernel.org>
 <20190128144506.15603-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128144506.15603-2-mhocko@kernel.org>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 03:45:05PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Mikhail has reported the following VM_BUG_ON triggered when reading
> sysfs removable state of a memory block:
>  page:000003d082008000 is uninitialized and poisoned
>  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
>  Call Trace:
>  ([<0000000000385b26>] test_pages_in_a_zone+0xde/0x160)
>   [<00000000008f15c4>] show_valid_zones+0x5c/0x190
>   [<00000000008cf9c4>] dev_attr_show+0x34/0x70
>   [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
>   [<00000000003e4194>] seq_read+0x204/0x480
>   [<00000000003b53ea>] __vfs_read+0x32/0x178
>   [<00000000003b55b2>] vfs_read+0x82/0x138
>   [<00000000003b5be2>] ksys_read+0x5a/0xb0
>   [<0000000000b86ba0>] system_call+0xdc/0x2d8
>  Last Breaking-Event-Address:
>   [<0000000000385b26>] test_pages_in_a_zone+0xde/0x160
>  Kernel panic - not syncing: Fatal exception: panic_on_oops
> 
> The reason is that the memory block spans the zone boundary and we are
> stumbling over an unitialized struct page. Fix this by enforcing zone
> range in is_mem_section_removable so that we never run away from a
> zone.

Does that mean that the remaining pages(escaping from the current zone) are not tied to
any other zone? Why? Are these pages "holes" or how that came to be?

> 
> Reported-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
> Debugged-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memory_hotplug.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b9a667d36c55..07872789d778 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1233,7 +1233,8 @@ static bool is_pageblock_removable_nolock(struct page *page)
>  bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
>  {
>  	struct page *page = pfn_to_page(start_pfn);
> -	struct page *end_page = page + nr_pages;
> +	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
> +	struct page *end_page = pfn_to_page(end_pfn);
>  
>  	/* Check the starting page of each pageblock within the range */
>  	for (; page < end_page; page = next_active_pageblock(page)) {
> -- 
> 2.20.1
> 

-- 
Oscar Salvador
SUSE L3


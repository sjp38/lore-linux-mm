Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AD50C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:09:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4193C2084A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:09:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4193C2084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C665E8E0003; Tue, 29 Jan 2019 04:09:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C14878E0002; Tue, 29 Jan 2019 04:09:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB6D48E0003; Tue, 29 Jan 2019 04:09:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3DC8E0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 04:09:11 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b3so7687198edi.0
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 01:09:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=f2Z+gL14Vr5FSP+ZhHPGeiPYAVo5PvRL7oKYDcN8VQg=;
        b=KuJviI+y/ayOg7t00abGBD9lUM0aUCrDZ1E575mdW42PKsgN3qrYPlrN+tvhe3UjlE
         uxgRQ8lIRDFPUw0M+Mxwv1RE86aMLxPd2Hdr7nRLnRfhWJ6g/w8jfjbKL4nlYZOeg4B0
         sei+MKYOCMAWJaPItIxvlWFfyDl8PwQtXjBYaXU4nKNM29+2+MFDG9OZ6JEI6nIXjxDT
         cbbvpQaRw1IKWXWAjSTLRdR1zQu9xVDsi8V4Brin8dE+FLlx3CEqOiLSJ/bdXFQbTRm4
         YSpJvzqnVyTe2zKtFRv8ovduAUU3hgx+4o5R3VxyZRXMAq0/7encGqkUd1b+aDn2ctK0
         NVVQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AJcUukeiZKmKbB5G6kO3V3i9G23aS5AFPqdcgtS7sJKGEsitVWwpXLrI
	qNrtjFxSp7scwSmKgdy1NRriXpBmL8vj68pQebnUiz2Y8xc06kQMfQcZ50xoRfySqk/bZQ6owKe
	ICGkI/lrfgvzBSgctIHt1BzBOSHDvvqeU7xU6Wh/lSmS2DrKneMQSS3XOBl2Dm08=
X-Received: by 2002:a17:906:3e48:: with SMTP id t8mr14780203eji.149.1548752950863;
        Tue, 29 Jan 2019 01:09:10 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7Qwu5vRab920SBC+GBEJAhvYHWrz1cjYLZUeOfGmOVBe5/WmpIPY0zWmQGKudbO/mvLany
X-Received: by 2002:a17:906:3e48:: with SMTP id t8mr14780173eji.149.1548752950044;
        Tue, 29 Jan 2019 01:09:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548752950; cv=none;
        d=google.com; s=arc-20160816;
        b=Tf/qRcFZiD9paP8k48bYidb9f9QcrU6Akxd+s4vrfscxbap1AZpGhkfb8akRnxSGmp
         2PN44nwVg01g0na318ylXC6EPde+r/ClFSIXz562K8gJ8nEnnYI0ABrIRRfW+B1Stssc
         2cBrU59KoECSfUj/ZfYZDfqbRVwq557HvMdiCdXeuqYJVs2yh6SE9sLDa+1BdbBO+Z9Y
         ajJBX9mcb42+uscqYWfIgmNshbhcCwuUMsxFn46DoHeyjoRPyMk3MdCG3DLc5olKVaG+
         7kARE1FxABWsLiL3u6QxqLYt1jfcAK171k1xJU/Kl0XJzBPfqo5+/ODsbTxdgNMEh0lt
         FMqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=f2Z+gL14Vr5FSP+ZhHPGeiPYAVo5PvRL7oKYDcN8VQg=;
        b=Z16zxxUOHYRjXx1Q8AEVrF9W+rzgKuvFza06IANbKI0Q5tRDzLjz23KiTEOMltO4Wg
         LqjG/AV2tZ1AAcKdUyLZl+0Whcfn4XpVjD2848VStc7NJsb0nvBumlj8d5ItZYuHGdXd
         iXzsug8hIPutm9TOGPOIfhabMuDPXcKl/NJw0mBj5rpxhpco9xw86WdSmA8r8PFMl0tf
         BKPx0O6AAQelxw660CKQjq1e+gkZO0EiS0Rfp8U0m/K+Dz7tFluNY47Xr5M/wZx2HEzd
         XKvHoD8sS2VLZz2nM89NCPLsMysC+wIry7JB6rJDiVgPjWfPCe2wcTdWEaXuaaiorM9z
         mwsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id p16si5548173ejq.42.2019.01.29.01.09.09
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 01:09:10 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 559E540B3; Tue, 29 Jan 2019 10:09:09 +0100 (CET)
Date: Tue, 29 Jan 2019 10:09:08 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: test_pages_in_a_zone do not pass
 the end of zone
Message-ID: <20190129090908.oms43oyjicozkvzu@d104.suse.de>
References: <20190128144506.15603-1-mhocko@kernel.org>
 <20190128144506.15603-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128144506.15603-3-mhocko@kernel.org>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 03:45:06PM +0100, Michal Hocko wrote:
> From: Mikhail Zaslonko <zaslonko@linux.ibm.com>
> 
> If memory end is not aligned with the sparse memory section boundary, the
> mapping of such a section is only partly initialized. This may lead to
> VM_BUG_ON due to uninitialized struct pages access from test_pages_in_a_zone()
> function triggered by memory_hotplug sysfs handlers.
> 
> Here are the the panic examples:
>  CONFIG_DEBUG_VM_PGFLAGS=y
>  kernel parameter mem=2050M
>  --------------------------
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
> Fix this by checking whether the pfn to check is within the zone.
> 
> [mhocko@suse.com: separated this change from
> http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com]
> Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks good to me:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  mm/memory_hotplug.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 07872789d778..7711d0e327b6 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1274,6 +1274,9 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
>  				i++;
>  			if (i == MAX_ORDER_NR_PAGES || pfn + i >= end_pfn)
>  				continue;
> +			/* Check if we got outside of the zone */
> +			if (zone && !zone_spans_pfn(zone, pfn + i))
> +				return 0;
>  			page = pfn_to_page(pfn + i);

Since we are already checking if the zone spans that pfn, is it safe to get
rid of the below check? Or maybe not because we might have intersected zones?

>  			if (zone && page_zone(page) != zone)
>  				return 0;

-- 
Oscar Salvador
SUSE L3


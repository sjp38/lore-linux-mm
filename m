Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDE56C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 04:03:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6269A20828
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 04:03:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uxNM4zcn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6269A20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1BB26B0005; Tue, 26 Mar 2019 00:03:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA3616B0006; Tue, 26 Mar 2019 00:03:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 945DA6B0007; Tue, 26 Mar 2019 00:03:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 420926B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 00:03:21 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id t10so6561611wrp.3
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 21:03:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nTclXznRqIiChOV0ahId8cx0aj50mjj0i4BN7loAIpQ=;
        b=qKg86YWRegN8xJTXy3mCeX6PuQ+WIQTRMkSIzxnbbZxNGIntiZBihxJY8VvKUNCdUV
         /EH38lS56e37uxoEFHyTtyZHO6xMEhkYoLbSf1VjgB5ZVE7PLykPvokKANDyizAnpPcH
         vDKRVMcSqM1yWBx7cgYl3Nb5uejnSKW98Za1/NA+0VPjmAp10mwi10TstHnM4zC5hHxS
         PNDxAVj0wEO1aZF8n5IPFwDz/tXhMMrBwrEbdLqK0JMLDXWQvQiNSK5q4GG9NjHPK84k
         gV+46cEjytEJ8QHilwMX8wgg+61cOG3f9mD/1dqWWCSIir/prC7t3W1UNveBkrUHQ318
         tlJw==
X-Gm-Message-State: APjAAAUW9/UabF7Vb2VT6Bri4aOGn7GoUjYuaiCJIZIWEx1qHt4OywI1
	+sEI14/8GBlKgoe7t+NMw3B5rTsGkWWoPLEYrbMx6izvTJzj1fUpWJsR2I6b0OppPmlQ2/eYoCp
	IagqNWWgKCwM+p6rwSxKf6LHnUKHGuBBs0PDF8/Lr+tTyVhba5ilh7GNf9G0ZGG7jog==
X-Received: by 2002:a5d:6207:: with SMTP id y7mr17097223wru.60.1553573000672;
        Mon, 25 Mar 2019 21:03:20 -0700 (PDT)
X-Received: by 2002:a5d:6207:: with SMTP id y7mr17097195wru.60.1553572999776;
        Mon, 25 Mar 2019 21:03:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553572999; cv=none;
        d=google.com; s=arc-20160816;
        b=s43wRUnmktZ5pueyDjkg1wdWWX6UEwiIPrS0kH0SqriaCMlwKZCm2pwtv/fD2qLqSS
         O+LtW2xqb//hYzFJSFISZujvF8fWT39XSlDjoK5DPrat77PXeDAHxFesiGqxZhs6TYJ+
         +TMLBxAo/u4CPuCU0VQ0b2jKI3V36fdUwC6cmmiGnCfB3v5j61MeOjS2B0VQwQbihETn
         iQki5IRgkoPHGxQF/JpC8YbYvjOPTO9p6fpPBOCt3xA0EvzhgURcKcwbh7XAAvICRO+d
         eAzFpZtjZZi1UVCqyItXlxzyRhbJSLBUSjn6wVS53JIryl+O9oL0OkjdtD8qP43Qlzp2
         UxYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nTclXznRqIiChOV0ahId8cx0aj50mjj0i4BN7loAIpQ=;
        b=mSCr8Ywpe+RVZJAHMkzQJoZkIHUHjdxSe/gQZpJuzQctXtZx4DbcgJfsrbmdQ3nAR8
         lXVGQm6WT+X3sr6zgIcK9TN7V1FcwfPYQY6hzoeYPFqDqiGK5EfT0xB5AAbBz0YqNsue
         iC/KRHT23LW/D2CqAUb0sUGoa4zi894I4Av8pOjB+eQIHpDKaCz854uQNVlqfFQVca1n
         l4t2J3RLX2lTYPBkRKi1GpouaYczQV4vPKV5YJzhW5n0k3emA7cfRwOL7+NrgdNtzp2b
         E4lxRx0/56ScOWo3xFsBtN62vwonQ96R6ZEsYpSKQs7BXGtIf3FcRmS6tsEeP7Vj88oA
         dXyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uxNM4zcn;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n16sor10432076wmi.23.2019.03.25.21.03.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 21:03:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uxNM4zcn;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nTclXznRqIiChOV0ahId8cx0aj50mjj0i4BN7loAIpQ=;
        b=uxNM4zcnMrVhw8FDLspJOrZyUH+NX5DtfVv8BU9GGSErIamHA2/+X/Kw4j1uQIyP41
         JgQOrsKnhOhikxaw0XLuzcT41e3LR6ivuyR5jQYXHAUF42GX5px3AICUgSZWcgnsBGp7
         YPEyoTzZYHI+DsqxtiZusAybk+zqQHEwzv6QyOg3VLqwCJ6/HFbBWBJWvl+P4LusfQyS
         3ggxR2+2JXllx6g/Tmz9moQ3F1IQfHm9TNKc9AljwB1GqatxVkXQxe9JRmejqX1cP+AQ
         nBSOBxFrJIHmAMQzZbFsi4d6tsXTDybau7vZr9K4BbvKw5nS5YLDj8cZdyMChP8xMGPT
         qMiQ==
X-Google-Smtp-Source: APXvYqyOPxbEzW6XhF+4nwzehmp00ewrda2Kip2kB3sR5VkbfObklUuOsaXXc0DjMO8I7YCdV4+s54qGUSg7XxyXGL8=
X-Received: by 2002:a1c:7ec2:: with SMTP id z185mr8135332wmc.69.1553572999055;
 Mon, 25 Mar 2019 21:03:19 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
 <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
 <20190322111527.GG3189@techsingularity.net> <CABXGCsMG+oCTxiEv1vmiK0P+fvr7ZiuOsbX-GCE13gapcRi5-Q@mail.gmail.com>
 <20190325105856.GI3189@techsingularity.net> <CABXGCsMjY4uQ_xpOXZ93idyzTS5yR2k-ZQ2R2neOgm_hDxd7Og@mail.gmail.com>
 <20190325203142.GJ3189@techsingularity.net>
In-Reply-To: <20190325203142.GJ3189@techsingularity.net>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Tue, 26 Mar 2019 09:03:07 +0500
Message-ID: <CABXGCsNFNHee3Up78m7qH0NjEp_KCiNwQorJU=DGWUC4meGx1w@mail.gmail.com>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Qian Cai <cai@lca.pw>, linux-mm@kvack.org, 
	vbabka@suse.cz
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Mar 2019 at 01:31, Mel Gorman <mgorman@techsingularity.net> wrote:
>
>
> Ok, thanks.
>
> Trying one last time before putting together a debugging patch to see
> exactly what PFNs are triggering as I still have not reproduced this on a
> local machine. This is another replacement that is based on the assumption
> that it's the free_pfn at the end of the zone that is triggering the
> warning and it happens to be the case the end of a zone is aligned. Sorry
> for the frustration with this and for persisting.
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index f171a83707ce..b4930bf93c8a 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -242,6 +242,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
>                                                         bool check_target)
>  {
>         struct page *page = pfn_to_online_page(pfn);
> +       struct page *block_page;
>         struct page *end_page;
>         unsigned long block_pfn;
>
> @@ -267,20 +268,26 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
>             get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
>                 return false;
>
> +       /* Ensure the start of the pageblock or zone is online and valid */
> +       block_pfn = pageblock_start_pfn(pfn);
> +       block_page = pfn_to_online_page(max(block_pfn, zone->zone_start_pfn));
> +       if (block_page) {
> +               page = block_page;
> +               pfn = block_pfn;
> +       }
> +
> +       /* Ensure the end of the pageblock or zone is online and valid */
> +       block_pfn += pageblock_nr_pages;
> +       block_pfn = min(block_pfn, zone_end_pfn(zone) - 1);
> +       end_page = pfn_to_online_page(block_pfn);
> +       if (!end_page)
> +               return false;
> +
>         /*
>          * Only clear the hint if a sample indicates there is either a
>          * free page or an LRU page in the block. One or other condition
>          * is necessary for the block to be a migration source/target.
>          */
> -       block_pfn = pageblock_start_pfn(pfn);
> -       pfn = max(block_pfn, zone->zone_start_pfn);
> -       page = pfn_to_page(pfn);
> -       if (zone != page_zone(page))
> -               return false;
> -       pfn = block_pfn + pageblock_nr_pages;
> -       pfn = min(pfn, zone_end_pfn(zone));
> -       end_page = pfn_to_page(pfn);
> -
>         do {
>                 if (pfn_valid_within(pfn)) {
>                         if (check_source && PageLRU(page)) {
> @@ -309,7 +316,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
>  static void __reset_isolation_suitable(struct zone *zone)
>  {
>         unsigned long migrate_pfn = zone->zone_start_pfn;
> -       unsigned long free_pfn = zone_end_pfn(zone);
> +       unsigned long free_pfn = zone_end_pfn(zone) - 1;
>         unsigned long reset_migrate = free_pfn;
>         unsigned long reset_free = migrate_pfn;
>         bool source_set = false;
>
>
>
> --
> Mel Gorman
> SUSE Labs


I do not want to hurry, but it looks like this patch has fixed the problem.
I will watch for a day.
But the system has already experienced a night without a hang (kernel panic).

--
Best Regards,
Mike Gavrilov.


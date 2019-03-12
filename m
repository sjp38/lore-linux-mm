Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA837C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:35:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B34712083D
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:35:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B34712083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B7CD8E0003; Tue, 12 Mar 2019 11:35:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 368768E0002; Tue, 12 Mar 2019 11:35:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 232538E0003; Tue, 12 Mar 2019 11:35:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B9AA18E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:35:09 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id j5so1251170edt.17
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:35:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MXkRqvDumFyg7EefuQvzkze22bPacSrv3IAwpe5vbSQ=;
        b=PTAVTrDDjo/e1u0sqns973QPcJRl9Q3H3hiopkLuMbHb5PQD40osGUs2DMzB4hSuT7
         FV2ah6EejT+JJt8qQRhTLnFt/VfIMMQ/ceJm3r95RLC6m5oov52cyfolPd7L3FiUjdzF
         9iIoAIHQBIvWMVdWsdp+Ru0Vr/nDBoEe8xCNbh9smCNY0FWic0PMgE5tsgr+cN4ExJW7
         UTGxeaphErBY7leIxxdvibju+JlSRnA/WmVgCtRKTQrtRLUp+n2ebl6Om2OS2Kcw5nEG
         Ffu2MgYSgNgqTqxHylugOpDwuTykxpb6Zu0QcU2Fs8suN9yJmzWPyl8L1Iq/+pCj8HSu
         5bzA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVKN/spjDhxm3Ck4h6sujhIrs6osCNjQ3N1k9eVoiHiNz0PZnRp
	K0q8RgQ76uJs/x/f5WXtU5TczD+hVLRKa9quLtAWTjztWWbsK4pQXqZD5E9s+9l/0OB7hSGOarz
	Ik7gjZsEliMNWs4C95hc+RizuY0ydaHaoan334OslNMb4rQ1zZggOW3PvCVGrprE=
X-Received: by 2002:a17:906:2a9b:: with SMTP id l27mr26387905eje.89.1552404909305;
        Tue, 12 Mar 2019 08:35:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx90ZWXtXh9t8KK3/dXYbSz3bcxGo8bRnhdECfg6koWCDl+IYs0ZOcKvgjGNbsyQcQV39d8
X-Received: by 2002:a17:906:2a9b:: with SMTP id l27mr26387859eje.89.1552404908364;
        Tue, 12 Mar 2019 08:35:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552404908; cv=none;
        d=google.com; s=arc-20160816;
        b=rPtciq6wyLy/NX32oCMnSri/zXKD21OVuDCWgNYQMUVu/o3LUKE+ONfbEP+2Jt4+Yk
         oYJNzmU+mF2PcmIzsBb0akqj3hTS6Sry3OHXb30+uxls8KetQak7RPq2lgmsCn09j4Ky
         RNLc9ItivwpRFZfGv5gJxl9Of1NMLNEIz0ZHP+ZZf/p6YHgr+ClrehqcMAKZKxNrLUX6
         H1RBd5P6TFppKde5dlCaPPeK9+Xr+1ppbubgLYj289BCGbWMr+34tnc9i6+JD/Np7WEx
         u4LU726wxENT+Eeec+XiejbtUAlgflq19i7fKddsFB2FdJ5Y1ffeKJic2b9UQ3d6ZH9B
         K1ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MXkRqvDumFyg7EefuQvzkze22bPacSrv3IAwpe5vbSQ=;
        b=0dR+jdZeMRRp/Dvg8l65WJbrx17Cfen4Mfmwoi3NUa9gEOv+MgLtb/DiKywYHVfzds
         eO2MPHAmXSwHREmCV98zCWYwxMaIKF3/exUk7+rY4jJOmYb4q++kJ24J2S3hUInEX1XJ
         re35wS982uiYo1Ev8xElR8H1HRin1nasv6/ajZ3ctnUEULHu1Wyi4SgO6C2bcMoOpg+A
         kQmbkvJqre6szwbMoymc3PJo2CGnj0Zo/VvaiV0iZpjT3EASAkgNo/XkNFzV1TMIseiB
         pIUDL8L6pAJ1PxGSFAGeD8y35kr/G4RTniWccILM31Y91CKNCc+qeZPAN3OFxhd/5GNr
         QFtA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id c21si763387ejx.131.2019.03.12.08.35.07
        for <linux-mm@kvack.org>;
        Tue, 12 Mar 2019 08:35:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 87303453F; Tue, 12 Mar 2019 16:35:06 +0100 (CET)
Date: Tue, 12 Mar 2019 16:35:06 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [RESEND PATCH] mm/hotplug: don't reset pagetype flags for offline
Message-ID: <20190312153458.qvmrblg3pnokgx4d@d104.suse.de>
References: <20190310200102.88014-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190310200102.88014-1-cai@lca.pw>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 10, 2019 at 04:01:02PM -0400, Qian Cai wrote:
> The commit f1dd2cd13c4b ("mm, memory_hotplug: do not associate hotadded
> memory to zones until online") introduced move_pfn_range_to_zone() which
> calls memmap_init_zone() during onlining a memory block.
> memmap_init_zone() will reset pagetype flags and makes migrate type to
> be MOVABLE.
> 
> However, in __offline_pages(), it also call undo_isolate_page_range()
> after offline_isolated_pages() to do the same thing. Due to
> the commit 2ce13640b3f4 ("mm: __first_valid_page skip over offline
> pages") changed __first_valid_page() to skip offline pages,
> undo_isolate_page_range() here just waste CPU cycles looping around the
> offlining PFN range while doing nothing, because __first_valid_page()
> will return NULL as offline_isolated_pages() has already marked all
> memory sections within the pfn range as offline via
> offline_mem_sections().
> 
> Also, after calling the "useless" undo_isolate_page_range() here, it
> reaches the point of no returning by notifying MEM_OFFLINE. Those pages
> will be marked as MIGRATE_MOVABLE again once onlining. In addition, fix
> an incorrect comment along the way.
> 
> Signed-off-by: Qian Cai <cai@lca.pw>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

One thing I noticed when looking at start_isolate_page_range and 
undo_isolate_page_range functions, is that start_isolate_page_range increments
the number of isolated pageblocks, while undo_isolate_page_range does the counter
part.
Since undo_isolate_page_range is really never called during offlining,
we leave zone->nr_isolate_pageblock with a stale value.

I __think__  this does not matter much.
We only get to check whether a zone got isolated pageblocks in
has_isolate_pageblock(), and this is called from:

free_one_page
free_pcppages_bulk
__free_one_page

With a quick glance, the only difference in has_isolate_pageblock() returning
true or false, seems to be that those functions perform some extra checks in
case the zone reports to have isolated pageblocks.

I wonder if we should set nr_isolate_pageblock back to its original value
before start_isolate_page_range.

> ---
>  mm/memory_hotplug.c | 2 --
>  mm/sparse.c         | 2 +-
>  2 files changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 6b05576fb4ec..46017040b2f8 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1655,8 +1655,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	/* Ok, all of our target is isolated.
>  	   We cannot do rollback at this point. */
>  	offline_isolated_pages(start_pfn, end_pfn);
> -	/* reset pagetype flags and makes migrate type to be MOVABLE */
> -	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
>  	/* removal success */
>  	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
>  	zone->present_pages -= offlined_pages;
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 77a0554fa5bd..b3771f35a0ed 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -556,7 +556,7 @@ void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -/* Mark all memory sections within the pfn range as online */
> +/* Mark all memory sections within the pfn range as offline */
>  void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
>  {
>  	unsigned long pfn;
> -- 
> 2.17.2 (Apple Git-113)
> 

-- 
Oscar Salvador
SUSE L3


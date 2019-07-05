Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF92AC5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 09:11:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DFB82147A
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 09:11:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DFB82147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DBB16B0003; Fri,  5 Jul 2019 05:11:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38BC68E0003; Fri,  5 Jul 2019 05:11:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 253778E0001; Fri,  5 Jul 2019 05:11:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD4116B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 05:11:16 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s7so5257067edb.19
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 02:11:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FRjE28iIzgD8xjJPwAlH5WY5jHL/uWd4ooAeEu2dfww=;
        b=kQ+3gIk8fnkmwXz2vrQmBJXVk7bzchYidUNgAv1PWCnwPq6UHOoDhpo+CJmBm27FCv
         FsT2tB265WEfwF2qdJpnLuV9TdYtH/JY4wH977zZ16wOkLHMSENLzrba8oKdP+662pVF
         /+niNNfj4AX0UIO6WkLfroULmjo+m/penA/BT18gIAHhIEV9zPp+HcgkkYibe9YjHygS
         RIMn4wRAH78+VG53MlE6/BhpctCNlKUtUZaBnhYkR/YAVH9VyTMxR9wO/01XiYUmgRGs
         tJ8W3zt09x020q5xbqzFiu+05UIGbFri1pyBy/5mGHi2uNbwcVg5+SYGsZuMO2kvv5S5
         dEVg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUw75Kd9HKFOW1CUVLPdCMj9CrJ+GgOSJfcnDyScW8DSRY2AZjE
	Io3Vk3luvHMiHQ7sDuFOqsz7d209GUpK9d0zUO4hLFqVS/n9WHHDEhn9LEtEyWNdiAWB/Lv7aS7
	GvnjQGuFRRETuEAK1blz9tNKMUFDOr+sBhkiqdWBCdI3jnyC9GyF/kh+oyFL22G0=
X-Received: by 2002:a50:9f4e:: with SMTP id b72mr3274687edf.252.1562317876407;
        Fri, 05 Jul 2019 02:11:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtneNekJgooMI1tuUy2QVZyS1OAibTdHbOrIPc/V1GgmdhPDw0nj+UCDOD09JHb9ZiiW4W
X-Received: by 2002:a50:9f4e:: with SMTP id b72mr3274624edf.252.1562317875713;
        Fri, 05 Jul 2019 02:11:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562317875; cv=none;
        d=google.com; s=arc-20160816;
        b=qm5XwYmDC47g3hiRoQBCuy78jEWEwqxno/g+JgC11KMfA0R+CduRJiSYlyZG6MUs07
         7h80iO6d8O8r2pOzKx+e81D8/LL0JFmGp3UUNZmLWpTsVkEBwlNAxnFGoZWicTeEDtlg
         owwBXMRGLra64d/Wiu2+Rrgx4qV2eI8DXkXEKN8HGnq3Xi14CsirwFSMmcqK8MZtseTB
         rAXajajMDR1AUU/9FIN6v8Ynt49AFVOzX38Jpe5q+IUtTRmiIjYVyCvnOunhBgW4jbHb
         Z9bWEWwoEit0pXBM2KzzBsJkAXmLu4X+Yy8jHIaH6VqMnPKnmIh0dV3GlRrwlGBplqPZ
         jT0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FRjE28iIzgD8xjJPwAlH5WY5jHL/uWd4ooAeEu2dfww=;
        b=xZC5Gq2jGDOa5DMa41/39ZiqlSKEkxAo0WrrzZXOFncHynoBC37SQX7YR+ldI6U5EN
         eeJ1L0mty1egSNeTFJDjdsfadagv+5xkG4vrGa/NoHq/pF3hb2/oWpLGQFoaOowAWNhv
         XNgg8CFgh/tUkawEPmFkmjEAEAR29lDFcBErKC2YsgQuALoDSw7Y2yQ6VjiFEyqgNs/E
         tMKuW9OVnDmwXzdtSVVdSgoFDK/mpkoLzvXFKzeW+nyYlFtW8CNC1c9+tIaq5xf/cuPc
         6iLCSfIwGx4tFJvEvZ1F8kt8eoT94a1IwTqKDDUzAvtzNu/sgdz3urkGHVah7RVXSzCp
         uAog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z56si1419447edz.417.2019.07.05.02.11.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 02:11:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 56408AC68;
	Fri,  5 Jul 2019 09:11:15 +0000 (UTC)
Date: Fri, 5 Jul 2019 11:11:14 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>,
	Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/isolate: Drop pre-validating migrate type in
 undo_isolate_page_range()
Message-ID: <20190705091114.GG8231@dhcp22.suse.cz>
References: <1562307161-30554-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562307161-30554-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 05-07-19 11:42:41, Anshuman Khandual wrote:
> unset_migratetype_isolate() already validates under zone lock that a given
> page has already been isolated as MIGRATE_ISOLATE. There is no need for
> another check before. Hence just drop this redundant validation.

unset_migratetype_isolate take zone lock and it is always preferable to
skip not take this lock if we know it would be pointless. Besides that
undo_isolate_page_range is a slow path so a nano optimizing it is not
worth it.

> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
> Is there any particular reason to do this migratetype pre-check without zone
> lock before calling unsert_migrate_isolate() ? If not this should be removed.
> 
>  mm/page_isolation.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index e3638a5bafff..f529d250c8a5 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -243,7 +243,7 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  	     pfn < end_pfn;
>  	     pfn += pageblock_nr_pages) {
>  		page = __first_valid_page(pfn, pageblock_nr_pages);
> -		if (!page || !is_migrate_isolate_page(page))
> +		if (!page)
>  			continue;
>  		unset_migratetype_isolate(page, migratetype);
>  	}
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs


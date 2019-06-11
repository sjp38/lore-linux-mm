Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B302EC4321D
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 13:08:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 838342173C
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 13:08:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 838342173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 169CA6B000A; Tue, 11 Jun 2019 09:08:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11C3D6B000C; Tue, 11 Jun 2019 09:08:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00AF36B000D; Tue, 11 Jun 2019 09:08:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id A44D16B000A
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 09:08:22 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id i11so5900132wrm.21
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 06:08:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zG7D9tA9mltNdg5ILkPGMptmgP7ku2Sk3DeC7scybP4=;
        b=OK+2iNr6Ak06iJxk1eBfbO445+AcD50UeoodylxYdotdsTueVSvfL5FuGNuv0Wmjn8
         zfamrffz7SWYmadls2CDsmhuVrBD0qcgJ2ZwyMlWhasLwYgfbm0bB1oYZhWpGKjFfgFF
         8c9BRuM6Jh0j7lezuaU1q4F+QFQw9ZAFS+i4026cx4FQ/Zubi7Ebfn5oNtyeHYDH4W27
         K1Vrjbu7xKlsIJKKDJuqqQteiHWkbjVLchR4odoZ0H15KUrZ25VDsEvOVEjmfEVdVzwD
         mqdDytmTvuvB45/2mkfGqxJvVIFSjhdBA0UQ0B0kUVdZY31tJV8e8hUve5wV2qGq8O6A
         B7Ng==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXQbn8wgL0/MK6uwZmQckHs9Fa8lC8R03I/pTRP66xdMPvXHcal
	khbEZ6Caw04VJ3/l0b0GKwmLbcgiKANACdWC+o0OCnlgmcSfj9B2KU0uDLuprxzABi8+H34N01+
	Hsb28+YZksiYIadB05zYjvWzqxn8jiM61zIQYEYcaLKuDFllFxdCedCAq6X2/dC4=
X-Received: by 2002:a05:6000:1289:: with SMTP id f9mr11590240wrx.125.1560258502240;
        Tue, 11 Jun 2019 06:08:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1Zu8piLGYfDi1kGFHHDRsN9tvg46YtXSdun8aG46ZcDDr9rqdxKDpuFy1zPQrhzyC6Qw+
X-Received: by 2002:a05:6000:1289:: with SMTP id f9mr11590179wrx.125.1560258501494;
        Tue, 11 Jun 2019 06:08:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560258501; cv=none;
        d=google.com; s=arc-20160816;
        b=JOM1rpNGsd7RWu7lzAqJQghvDehVkDxOwzUjGTNWWteQd7dgujji1tsMpSzeyOxXk2
         MRJntkzvs2GNxFlO8OrbiLzntJeP/O5E0qS/FUVrHMnP1BgXNnNq89DesPLevnbSmeg8
         KKRXY0Yawde2+ddzIpM49S9zI1ZA2LQsf3TEMYpdPeYc7glOsVoaJZiFttVHQKxjE4eJ
         FP1ykMAVxMuf4k+PO+IUcFJWqZBO4Z42PRSU1dqqmMSb74AOOaCch9JXdK09M4V36RhZ
         f+J+N+Al16BDRiOlYqQApk9JmMAqyL0nJLkFkF6JI8zD5nj+uqgBLS8owqvJy1SfBpMc
         dxxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zG7D9tA9mltNdg5ILkPGMptmgP7ku2Sk3DeC7scybP4=;
        b=RSObAdLeGlqZEmZiQf7NaUYvjpYssh9Zh51ZqYidRmE99EDJporJAw5YJz47U+3MzM
         ElhlHlY9QbTJ0Xdq6RVvd4Ikfkoxmzz67mDSP7bdtAaXlCh0FjhK591MtPVY9pv9Fkij
         UzqBd4lteGscB3k5QLHHP/VhgDppjmVnL6eOCnjuIj8IRcorBe4e2v0HJx8IdCFuklN3
         zp8UZIJeTMjEHt31T1JnfGHKP55iTCKlAjbkiZz99cZoHTTpBMX+9mbWvEADWfbWTVJs
         GONOHQ3QIhRrqiJrWugtfePRwoH0uphQ06Wl++u4W4YuOjlje9GFidqLvIQuQh44QtVW
         o9Dg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c2si2343552ejk.291.2019.06.11.06.08.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 06:08:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B5CA9ADD4;
	Tue, 11 Jun 2019 13:08:20 +0000 (UTC)
Date: Tue, 11 Jun 2019 15:08:20 +0200
From: Michal Hocko <mhocko@kernel.org>
To: "Chengang (L)" <cg.chen@huawei.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"vbabka@suse.cz" <vbabka@suse.cz>,
	"osalvador@suse.de" <osalvador@suse.de>,
	"pavel.tatashin@microsoft.com" <pavel.tatashin@microsoft.com>,
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>,
	"rppt@linux.ibm.com" <rppt@linux.ibm.com>,
	"richard.weiyang@gmail.com" <richard.weiyang@gmail.com>,
	"alexander.h.duyck@linux.intel.com" <alexander.h.duyck@linux.intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm: align up min_free_kbytes to multipy of 4
Message-ID: <20190611130820.GI2388@dhcp22.suse.cz>
References: <D27E5778F399414A8B5D5F672064BAD8B3E5FB7B@dggemi529-mbs.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D27E5778F399414A8B5D5F672064BAD8B3E5FB7B@dggemi529-mbs.china.huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 11-06-19 12:16:35, Chengang (L) wrote:
> Hi Michal
> 
> 
> >On Sun 09-06-19 17:10:28, ChenGang wrote:
> >> Usually the value of min_free_kbytes is multiply of 4, and in this 
> >> case ,the right shift is ok.
> >> But if it's not, the right-shifting operation will lose the low 2 
> >> bits, and this cause kernel don't reserve enough memory.
> >> So it's necessary to align the value of min_free_kbytes to multiply of 4.
> >> For example, if min_free_kbytes is 64, then should keep 16 pages, but 
> >> if min_free_kbytes is 65 or 66, then should keep 17 pages.
> 
> >Could you describe the actual problem? Do we ever generate min_free_kbytes that would lead to unexpected reserves or is this trying to compensate for those values being configured from the userspace? If later why do we care at all?
> 
> >Have you seen this to be an actual problem or is this mostly motivated by the code reading?
> 
> I haven't seen an actual problem, and it's motivated by code
> reading.  Users can configure this value through interface
> /proc/sys/vm/min_free_kbytes, so I think a bit precious is better.

The interface is intended for admins and they should better know what
they are doing, right? Using an ad-hoc valus is not something that is a
common usecase.

That being said, your change makes the code slightly harder to read and
the benefit is not entirely clear from the changelog (which btw. sounds
like there is a real problem which is not described in the user visible
terms). So if you really believe this change is worth it, then make sure
you justify it by exaplain what is a negative consequence of a dubious
value set by an admin.

> >> Signed-off-by: ChenGang <cg.chen@huawei.com>
> >> ---
> >>  mm/page_alloc.c | 3 ++-
> >>  1 file changed, 2 insertions(+), 1 deletion(-)
> >> 
> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c index d66bc8a..1baeeba 
> >> 100644
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -7611,7 +7611,8 @@ static void setup_per_zone_lowmem_reserve(void)
> >>  
> >>  static void __setup_per_zone_wmarks(void)  {
> >> -	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
> >> +	unsigned long pages_min =
> >> +		(PAGE_ALIGN(min_free_kbytes * 1024) / 1024) >> (PAGE_SHIFT - 10);
> >>  	unsigned long lowmem_pages = 0;
> >>  	struct zone *zone;
> >>  	unsigned long flags;
> >> --
> >> 1.8.5.6
> >> 
> 
> >-- 
> >Michal Hocko
> >SUSE Labs

-- 
Michal Hocko
SUSE Labs


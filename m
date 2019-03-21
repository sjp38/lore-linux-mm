Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 384CCC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 09:53:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E91ED20850
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 09:53:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E91ED20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8251C6B0003; Thu, 21 Mar 2019 05:53:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D4946B0006; Thu, 21 Mar 2019 05:53:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C50A6B0007; Thu, 21 Mar 2019 05:53:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5BC6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 05:53:40 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h27so1977473eda.8
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 02:53:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=R2fHyczZrMyxTT/SnziV5HJuFeU5Zf81UxAwYCwe/xU=;
        b=tALTi+plJ5ffPT8CSZHsZcjAZhcfBBJNJfzKNDCOYyAVwFaB5TP2f9sL+t++ebS8Zv
         u5jXeJ/uwGcRJsz/ltWMFyAslz/qGt1DLrhB5BejhFZemHjkcueo6YFtn6xRBTepRU0G
         39ErSkHkIG5yDTNI2Wt7c5B4JBz2psKta/7+bs7+vsRa1mcVkKWZ1tZKMdtZqFjKQmP3
         b9Y8tiA1GAfOBo9j7d1EqFRedFaYfEdWgDrtZm6h3O9kRRD2W+xaJbH7VPXwQx/xtjZf
         1Gb6ZQAG+Kk/j4rUhu2kx8w+1D4re1jDdeknYSswBhC/CrqsKPe5UkEtqqmDX4nkH9Ri
         040A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVmUr+kzGmuiz5ziXhXAR6PDtMT/DP7VRUt3NT51Kn0VBG/WkUX
	d5niGugzL5yx3tzisuz3cHC2bfcptkZTSVnKne8ggtM07r5+tmMVl353m0iHEw3e8Os9wCKvKDK
	bn5/NIolklGDszjndEkbaiwh/Qkktt4k05j/pymb3Cibvpm1qPAhSZl6a/MZEuCQ=
X-Received: by 2002:a50:ada5:: with SMTP id a34mr1877349edd.38.1553162019673;
        Thu, 21 Mar 2019 02:53:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0lLVAtsg037H658mmw7/X8GHuuVkieuAeZTIGy059/R70H+LsRiR2byomqvKITFrfAs/c
X-Received: by 2002:a50:ada5:: with SMTP id a34mr1877317edd.38.1553162018895;
        Thu, 21 Mar 2019 02:53:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553162018; cv=none;
        d=google.com; s=arc-20160816;
        b=b5+md2vllKENDuQ+8ZWkUe8iNrRHkaCPo2Gtm/hTtvRlYEfj9ibjPhpGox8iZixfN+
         z9bWH1MD2fF0XI1B/mSj0axAywUuZTMs3Sv/HDolENlFdVUUJezOvRtmEfUhLDJkY/Vv
         lMVUfR0VPcaxrHuhEI+wPBgb5/JuVk3kzdiCYXYKE5SZ/c5EPb0/6XYuw4zCd7uiaUZ7
         hU8XQrte2lCfs6eXXd036M6NaTMi/odSbMQXuVbhFC4juCWHk+YGjvQjcWKTv1epUtBc
         5uBwFGswSEjG/Rtg4cQX1aajdHz5UwS842ufScusuVw8OpNTg55vmbADQ6vmBiTFsNGM
         J+LA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=R2fHyczZrMyxTT/SnziV5HJuFeU5Zf81UxAwYCwe/xU=;
        b=A4LCsgERUMRcBMRKSEXQEDD1L7FmccYqAbXpd9VaHx7ye/o/KjYmU825K/3KBn2ffj
         YXW5wfOwhPayKpKTU19tLxKqPe0O4IJP1AHwymNrdPSUql1U9uQojA3HrxEDcQc9rwzt
         MUc3mva++WWrcUkkXyaYilld7Z9XoN5hvSfa1T7Kuk5KYnDhypna4vMVz525ztkvOud1
         VpyQxK8dNEyJEZULigku+bbmTvb7iUKxUVA/3AHFDU8HcoUtMPPFqAdi0V0YqgFJh5kI
         d9v1+j0G2rM+ZhVZK8nVDJoCqE+Iz8f/QUtRgtfqEtlHnt0wJxEHeXOhkH04/uQI+C2j
         ig8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o25si1517025ejs.68.2019.03.21.02.53.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 02:53:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 67D92B0BE;
	Thu, 21 Mar 2019 09:53:38 +0000 (UTC)
Date: Thu, 21 Mar 2019 10:53:37 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"minchan@kernel.org" <minchan@kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [External] Re: mm/cma.c: High latency for cma allocation
Message-ID: <20190321095337.GM8696@dhcp22.suse.cz>
References: <SG2PR02MB3098E44824F5AA69BC04F935E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190318130757.GG8924@dhcp22.suse.cz>
 <SG2PR02MB309886996889791555D5B53EE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190318134242.GI8924@dhcp22.suse.cz>
 <SG2PR02MB30986F43403B92F31499E42AE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190318142916.GK8924@dhcp22.suse.cz>
 <SG2PR02MB3098DCB820E3367B09DDA45AE8400@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB30981381635A6BC3783D42CDE8400@SG2PR02MB3098.apcprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <SG2PR02MB30981381635A6BC3783D42CDE8400@SG2PR02MB3098.apcprd02.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Can you please fix your email client? The broken quoting is just
irritating.

On Tue 19-03-19 11:45:03, Pankaj Suryawanshi wrote:
[...]
> I have tried for latency count for 385MB:
> 
> reclaim- reclaim_clean_pages_from_list()
> migrate- migrate_pages()
> migrateranges- isolate_migratepages_range()
> overall - __alloc_contig_migrate_range()
> 
> Note: output is in us
> 
> [ 1151.420923] LATENCY reclaim= 43 migrate=128 migrateranges=23
> [ 1151.421209] LATENCY reclaim= 11 migrate=253 migrateranges=14
> [ 1151.427856] LATENCY reclaim= 45 migrate=12 migrateranges=12
> [ 1151.434485] LATENCY reclaim= 44 migrate=33 migrateranges=12
> [ 1151.440975] LATENCY reclaim= 45 migrate=0 migrateranges=11
> [ 1151.447513] LATENCY reclaim= 39 migrate=35 migrateranges=11
> [ 1151.453919] LATENCY reclaim= 46 migrate=0 migrateranges=12
> [ 1151.460474] LATENCY reclaim= 39 migrate=41 migrateranges=11
> [ 1151.466947] LATENCY reclaim= 54 migrate=32 migrateranges=17
> [ 1151.473464] LATENCY reclaim= 45 migrate=21 migrateranges=12
> [ 1151.480016] LATENCY reclaim= 41 migrate=39 migrateranges=12
> [ 1151.486551] LATENCY reclaim= 41 migrate=36 migrateranges=12
> [ 1151.493199] LATENCY reclaim= 13 migrate=188 migrateranges=12
> [ 1151.500034] LATENCY reclaim= 60 migrate=94 migrateranges=13
> [ 1151.506686] LATENCY reclaim= 78 migrate=9 migrateranges=12
> [ 1151.513313] LATENCY reclaim= 33 migrate=147 migrateranges=12
> [ 1151.519839] LATENCY reclaim= 52 migrate=98 migrateranges=12
> [ 1151.526556] LATENCY reclaim= 46 migrate=126 migrateranges=12
> [ 1151.533254] LATENCY reclaim= 22 migrate=230 migrateranges=12
> [ 1151.540145] LATENCY reclaim= 0 migrate=305 migrateranges=13
> [ 1151.546997] LATENCY reclaim= 1 migrate=301 migrateranges=13
> [ 1151.553686] LATENCY reclaim= 40 migrate=201 migrateranges=12
> [ 1151.560395] LATENCY reclaim= 35 migrate=149 migrateranges=12
> [ 1151.567076] LATENCY reclaim= 77 migrate=43 migrateranges=16
> [ 1151.573836] LATENCY reclaim= 34 migrate=190 migrateranges=12
> [ 1151.580510] LATENCY reclaim= 51 migrate=120 migrateranges=12
> [ 1151.587240] LATENCY reclaim= 33 migrate=147 migrateranges=13
> [ 1151.594036] LATENCY reclaim= 20 migrate=241 migrateranges=13
> [ 1151.600749] LATENCY reclaim= 75 migrate=41 migrateranges=13
> [ 1151.607402] LATENCY reclaim= 77 migrate=32 migrateranges=12
> [ 1151.613956] LATENCY reclaim= 72 migrate=35 migrateranges=12
> [ 1151.620642] LATENCY reclaim= 59 migrate=162 migrateranges=12
> [ 1151.627181] LATENCY reclaim= 76 migrate=9 migrateranges=11
> [ 1151.633795] LATENCY reclaim= 80 migrate=0 migrateranges=12
> [ 1151.640278] LATENCY reclaim= 87 migrate=18 migrateranges=12
> [ 1151.646758] LATENCY reclaim= 82 migrate=10 migrateranges=11
> [ 1151.653307] LATENCY reclaim= 71 migrate=31 migrateranges=12
> [ 1151.659911] LATENCY reclaim= 61 migrate=77 migrateranges=12
> [ 1151.666514] LATENCY reclaim= 94 migrate=42 migrateranges=15
> [ 1151.673089] LATENCY reclaim= 67 migrate=59 migrateranges=12
> [ 1151.679655] LATENCY reclaim= 81 migrate=14 migrateranges=12
> [ 1151.686253] LATENCY reclaim= 49 migrate=93 migrateranges=12
> [ 1151.692815] LATENCY reclaim= 61 migrate=54 migrateranges=12
> [ 1151.699438] LATENCY reclaim= 42 migrate=99 migrateranges=10
> [ 1151.705881] OVERALL overall=285157

cumulative numbers are

reclaim:2222 migrate:3995 migrateranges:552 sum:6217

So those code paths you were measuring were contributing to the overal
latency only marginally (~2%).
 
> cma_alloc latency is = 297385 us

As I've said earlier I would just use perf with the call graph support
and look at the time distribution to see where the bottleneck is.
-- 
Michal Hocko
SUSE Labs


Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2041FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:18:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCCB32147C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:18:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCCB32147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E3908E0006; Tue, 12 Mar 2019 12:18:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 767728E0002; Tue, 12 Mar 2019 12:18:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 632F68E0006; Tue, 12 Mar 2019 12:18:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 080558E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:18:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id u2so1334293edm.1
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:18:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ex9/apj4g4KbhFyZOkV3xbOn6LnYjdACet6sO4R+t+4=;
        b=WATC/RXViiOJjn6wKILH4GZ26PSF3Yi/sbk6aT2xPODDlTK7lG4CoatAkMQGS78JTv
         V2g3qkH/IZLJnEtDlTIZyE2jJ1sSqznl4ch4l78KvDrR2YDgBDY/X+qAliOJxZ/UaZuT
         /Fs4EzyEzY//Yei5cFRC/OQ7vZrP6U66Sx7waGyQeQzZUe/tyqrC1YgmY2wKbsv8mBdA
         27LHEzend1zn5Iga/CpzpkHVsBfJV64zTzbEMekajzPtIIrxKQZUbT1OZMWJNUBFEEa8
         YlvBJCbJXEALKgmOQkPhmdLjSfqBv9xPmd8Dr0IcIbN8e755B+aTxmyCO1/y/F+zVMz/
         +Scw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUdTtFxejnns67xo2jzZ8rXQF8HstmI+ojvUaUO6WzcC0mH/AHU
	PONOI6DGrd+SW+sw1rQcvEuG8s0x9iUw36j+3RxoV7rZrRRpj53aI3AgZU/v0oc9/1irFKez9A4
	tpppHPjBzjqq8o1/4ATnau1f5/OLAbnXxIdNTRGuoM9LlaUnVb5vJp7M5tahMHwY=
X-Received: by 2002:a05:6402:1615:: with SMTP id f21mr4169317edv.110.1552407484601;
        Tue, 12 Mar 2019 09:18:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFw0h540/MKUzDrXKeytVnoR8oC+tL0UDjtJoLvBGupKzlynn2h7c23dIhdct0pDEkGo+k
X-Received: by 2002:a05:6402:1615:: with SMTP id f21mr4169269edv.110.1552407483884;
        Tue, 12 Mar 2019 09:18:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552407483; cv=none;
        d=google.com; s=arc-20160816;
        b=lW65uTkvcvzwGRwqe6Nop9GlYfOVPQXjJpx4F7EzRDE3GoJPxM+zhIXbjkVGMxOW/i
         4LislnKCb56kwUoRqVBgmgubPhvDXL8YwGeM4X4/1i3Bj4qE4PW61WADZZXnqaeRi293
         lRgKJyQnL9Ho7DvhFtbTKiY7si6nI4cPJdKw8NVszMthRjAZDMjCuKTwp3x2344EOlYG
         kQmE9EGpRmY2cwJcxZM55MaOq26EGKj/mhb2P2PQzWrBFtF+vavyrlJw1YFH7DmxONIh
         eUyoFBIT25DzAvTuMBuwOYeQTK4XUCvuhanpFka6K/qmgroTPNXkhp65YKuQiJpk9ujv
         FsIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ex9/apj4g4KbhFyZOkV3xbOn6LnYjdACet6sO4R+t+4=;
        b=SIEDhVh8SfvW5AdWsRusBRXlFyuPhu0qpNDdMRrycODtD2s6VknFk0gJEsDQ2/8uvq
         yCYqg55gTdZouLpuaJU9eYMRyqqa1PPZXxacnAxvluwH+yyVN02rvxjVpCQr8NXrE9Zc
         LsIufBawUCLZiqtCbI+WeDgBkN/7hx054rXJsK+fUciaT8DMS9s5CLSRBhoioy2C1WXA
         DFmXr1H8xiGusemUkNns1xUBv5SfzuPhFiVaGaoxlbx4z7QGi2XOcRHb8OZTf4fUPsN4
         a6BLhtFKwd5CGCDK6Y56taSc42S7/CscazaFCEc4hZLV1Jtgx6pdOVwwtRBhho8BV+P7
         qoSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k21si2878097edx.392.2019.03.12.09.18.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 09:18:03 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7CA88AC3C;
	Tue, 12 Mar 2019 16:18:03 +0000 (UTC)
Date: Tue, 12 Mar 2019 17:18:03 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: vbabka@suse.cz, jrdr.linux@gmail.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm: compaction: some tracepoints should be defined only
 when CONFIG_COMPACTION is set
Message-ID: <20190312161803.GC5721@dhcp22.suse.cz>
References: <1551501538-4092-1-git-send-email-laoar.shao@gmail.com>
 <1551501538-4092-2-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551501538-4092-2-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 02-03-19 12:38:58, Yafang Shao wrote:
> Only mm_compaction_isolate_{free, migrate}pages may be used when
> CONFIG_COMPACTION is not set.
> All others are used only when CONFIG_COMPACTION is set.

Why is this an improvement?

> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  include/trace/events/compaction.h | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> index 6074eff..3e42078 100644
> --- a/include/trace/events/compaction.h
> +++ b/include/trace/events/compaction.h
> @@ -64,6 +64,7 @@
>  	TP_ARGS(start_pfn, end_pfn, nr_scanned, nr_taken)
>  );
>  
> +#ifdef CONFIG_COMPACTION
>  TRACE_EVENT(mm_compaction_migratepages,
>  
>  	TP_PROTO(unsigned long nr_all,
> @@ -132,7 +133,6 @@
>  		__entry->sync ? "sync" : "async")
>  );
>  
> -#ifdef CONFIG_COMPACTION
>  TRACE_EVENT(mm_compaction_end,
>  	TP_PROTO(unsigned long zone_start, unsigned long migrate_pfn,
>  		unsigned long free_pfn, unsigned long zone_end, bool sync,
> @@ -166,7 +166,6 @@
>  		__entry->sync ? "sync" : "async",
>  		__print_symbolic(__entry->status, COMPACTION_STATUS))
>  );
> -#endif
>  
>  TRACE_EVENT(mm_compaction_try_to_compact_pages,
>  
> @@ -195,7 +194,6 @@
>  		__entry->prio)
>  );
>  
> -#ifdef CONFIG_COMPACTION
>  DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
>  
>  	TP_PROTO(struct zone *zone,
> @@ -296,7 +294,6 @@
>  
>  	TP_ARGS(zone, order)
>  );
> -#endif
>  
>  TRACE_EVENT(mm_compaction_kcompactd_sleep,
>  
> @@ -352,6 +349,7 @@
>  
>  	TP_ARGS(nid, order, classzone_idx)
>  );
> +#endif
>  
>  #endif /* _TRACE_COMPACTION_H */
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs


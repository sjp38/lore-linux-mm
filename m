Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6127DC28CC1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 15:44:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1004823BB5
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 15:44:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="CEz/AAKk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1004823BB5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9423B6B000E; Wed, 29 May 2019 11:44:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CCE06B0010; Wed, 29 May 2019 11:44:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 745A66B0266; Wed, 29 May 2019 11:44:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39F6B6B000E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 11:44:54 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id c3so1788152plr.16
        for <linux-mm@kvack.org>; Wed, 29 May 2019 08:44:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5rb0csxEYpq6VfGz5/QVGNKPlo9rHsx48NwguhVphjA=;
        b=QeVmGFwAcmMeWF2rTyUcvHiKoGcy6hl2nnwwYUcqeukGN72ut1WNbPa33v1OVutAfI
         wDtDx0vR0ItxEWQHf9u2kiTNtFKH7Sj5cob1XhYKu1e9ySN4amtsxaZQeBBHfQpfPGfq
         tF+5VIzA6jCUV+rk/PzLE/h0HjLsFK+HDtKkSVCUvbSrAky7294Xp/9zfDEZReajvIhg
         Nu1bKHtSFtWNEKroy6Ne/pjwcl1gennFOwqxbTlKN1Np/8uHZQwx0imXt2GelAu+cchi
         K9xv/adwkQEGdkW1ERbODKliPbAFbHeEgG4ahEfp5pWCPHG4suWUS1rFJU5goY5aNJvC
         FgTQ==
X-Gm-Message-State: APjAAAVn5EPn89GMHf6R5S9AKpU6rpb5vjnRSxjZ5ut4kRRMb12h52qT
	z16MHtnrewxTQynG5z3SW1s/JMHIa+Z/H9oAg2Uhjr+1ToQng0nZeZqnsWonJG5uk4i4RfolLV/
	6HHwqIwlrh3sPGLxV0zwQlm2+qkuoy63BFFxTBYbrF8g1lWBewT81gyFyiETBJ6TctQ==
X-Received: by 2002:a62:2e47:: with SMTP id u68mr62866697pfu.24.1559144693892;
        Wed, 29 May 2019 08:44:53 -0700 (PDT)
X-Received: by 2002:a62:2e47:: with SMTP id u68mr62866593pfu.24.1559144693010;
        Wed, 29 May 2019 08:44:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559144693; cv=none;
        d=google.com; s=arc-20160816;
        b=BHEY4znHs5AkO2zDk5Lb9ww//YbYhcqO4zcLFf/Y8yNN0DIOnhqs18jbak1rtoIF/3
         glV6i9SvF6bZqZTdRN4Te5e3hNa3ziWdNaDkWwXfYC70caP0Y99uwmDsCVFBRKUUqgrg
         gPnpwaaG/6zZTSzQcbz2A+qKemG7aaqW9iFbfrfRlzVQA/UysDyh8PItRPKmq9JPoWoQ
         dKOsR4u+d8Vnfur2A/QRvu10S30PbCiu8NTqkT9F51egtIW2tqoBAL1SwchcxQZDUzML
         5LpaR15NTukY+d0zlAQlqjQyqxzcqwxKslah3vPPEXhQ4yG37Wuh9z011W+TGP4S08q1
         LdrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=5rb0csxEYpq6VfGz5/QVGNKPlo9rHsx48NwguhVphjA=;
        b=IyaIzhxqVYtzjbGsbUlNOKm/FMKHED7/Ca/Uam5vmDx3FAXYmN2UQxF48f7beUUqKp
         TdLJfpKsXqG16VwreV6G/FzChHEUUirybB7bo74tnzPbx/nR4T8322tRaxi07+e13prS
         p3pTEsVml+sCJLJ9L/lYbA30dwRQOXlBeHyY0BX5+bGUcQl53DJ4DHY6NwzlMJwtOr73
         jnBPZcyIWMX17YFGe+weK4wFZA82JcWVwTMzgpnOCT1T+cJaCv+7juPMzJTMndBCfX2m
         4L7NG9p5RTNjJAGazttRUoqkdbqyEFdi756e/f8LEck72N8yeSQWmGuESyh4W8jCVObA
         3tEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="CEz/AAKk";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3sor6931pgh.12.2019.05.29.08.44.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 08:44:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="CEz/AAKk";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=5rb0csxEYpq6VfGz5/QVGNKPlo9rHsx48NwguhVphjA=;
        b=CEz/AAKkGLOaVc6lKqbFaOc50JrPG1TariHgp5nHwAf4jc9op0iyz3MxM7nZQO/ymz
         TKSA2wwMayYrX89UdiTQxgkG4S2uhqZZfbfJxJVrGdU/vGSjR0D9qbnlCv3hPvxbf04h
         Ptmo3H9PVCcjr5mewqD05lu0+wKuy3MLedN6FiIdjWSRebWK1w/ufeqTcilgHIHBazbc
         tyoemTy21uGhYOqr9lyIgiAn/tR8SfT65+AmsE1LktTtLpWu7PLifc6+sL7ywovtk1bi
         74jY3Z9dWSAxMmcGS8tt10gNmMq+Ozl+YJCCkookIzFLu2enYs7QRr8eHmDBbvyKGl4B
         9HTw==
X-Google-Smtp-Source: APXvYqwzUrKfcPoy1hsbTCw6ESg7o3qVXGDDyPIfLq5La7nokllnQ2NESefsdh56kWG23ear160irQ==
X-Received: by 2002:a63:e953:: with SMTP id q19mr14654295pgj.313.1559144690141;
        Wed, 29 May 2019 08:44:50 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:a47c])
        by smtp.gmail.com with ESMTPSA id u123sm34317pfu.67.2019.05.29.08.44.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 08:44:49 -0700 (PDT)
Date: Wed, 29 May 2019 11:44:47 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Fix recent_rotated history
Message-ID: <20190529154447.GA28937@cmpxchg.org>
References: <155905972210.26456.11178359431724024112.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155905972210.26456.11178359431724024112.stgit@localhost.localdomain>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 07:09:02PM +0300, Kirill Tkhai wrote:
> Johannes pointed that after commit 886cf1901db9
> we lost all zone_reclaim_stat::recent_rotated
> history. This commit fixes that.
> 
> Fixes: 886cf1901db9 "mm: move recent_rotated pages calculation to shrink_inactive_list()"
> Reported-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>


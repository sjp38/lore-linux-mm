Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94293C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:22:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5452A263E2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:22:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5452A263E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D28756B0269; Fri, 31 May 2019 02:22:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD83F6B026F; Fri, 31 May 2019 02:22:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEED46B0278; Fri, 31 May 2019 02:22:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1F16B0269
	for <linux-mm@kvack.org>; Fri, 31 May 2019 02:22:09 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h12so12324788edl.23
        for <linux-mm@kvack.org>; Thu, 30 May 2019 23:22:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ap8vgq4H78kV9CQ8w76vCgd6GKZKVoHcnCwmQS1int8=;
        b=lomNvekZEcIMLzXZCouH3d0vrtpofUo2I7bhDHkms9jBPDLSNM4my3br1TwmGBSTYm
         T1SgVke/t5bthJPJjI1KkrFjDs/aL/xRPJmGIKzk+h2wB4ujwcGpobf2Tf0EUznI7QYZ
         NW+IFFKaPowAZSKCylo3aTukokIeTF9Tg1RLC14ZqsRC2JU1cRSAGh/02jV2CzbObgLo
         FbR8UnH2+8M7PtWxz4zJ4D65KcXsrqQs2KdPBwLph5SH+GI9Bpbuit2Hy0zW0wgmzDkB
         qn555DL8fwPQUGWOTJ8IJA2rvMW2d8AX9mSgGYzDgd3Df56sIohyNjN3f5ohecVHS2pF
         f1YQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVCravRE1KH9nnXkRzArCuTaamWCqyokLJ9SWszXsGAk2Uex8We
	mSO/6MAFK6JBYkYxdutImeDCmyPaYumbCWIzhRG0yz6D8LemCnHopU+RrBdJou6YyPmVgfkWQOE
	wxw+NKSrjjcBsNmDPby2isEMPptUhZQe13lT1rQvE7JyrNJxygTnylDMpSaU8Naw=
X-Received: by 2002:a17:906:a354:: with SMTP id bz20mr7610684ejb.209.1559283728941;
        Thu, 30 May 2019 23:22:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlUH3fJTEgv6jeyGpRbSMxMEz36uwjh+cF4n9J4AVU22AhAj+00zJIJpnl1VHkmyEF1cn3
X-Received: by 2002:a17:906:a354:: with SMTP id bz20mr7610633ejb.209.1559283728091;
        Thu, 30 May 2019 23:22:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559283728; cv=none;
        d=google.com; s=arc-20160816;
        b=q2w4KEfI1RZwMIrwPNNpzNAXPnbibdRwjOfPvyPK66nGT01o4jxxuLRkdE5r7RkVIj
         DCC6lATYqq9dq8l4awqbbEYr/sAuWrjDvs3c4PVfaPQo1FHodjj5llujlv2A+WwWqgIC
         83i+RAM6xByPvOKRMVCg6I1FZRXyLrZGNZGIcJVupgZLFubZ2F5ZBIEBMzFD1QmaJaSm
         yqT+x3il4XBmjQT2V5lY5ifYv07yuUwxB4YOttvWAyhrib6whDiySH7lGbXWjkwLeGq8
         upETmvuNK9W8/Gyy20FtKstmdxiWXwTq8ApRUkJLhX1UHDsw6GOvf+5ky2DxntqBYXx8
         AZ+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ap8vgq4H78kV9CQ8w76vCgd6GKZKVoHcnCwmQS1int8=;
        b=WuHxkyapxJBJcnAOX+smCVDt3Hu3TFRBerQrBMY9hEMbdI4CBAkwcfaqWNoZAiVy3n
         c56HkyDSC5GVoSnLrgKItogcH2KARM8oXo9VcP8YENkzteNabOV4p1a06uXeAwA9d/8J
         jDh0H7m8Zf5imtTQfIzO62tMYH+ZpPQVOLYRXaFRl98rWUH/VPocBvwbvwZJZ4y387yQ
         cvCb1BsdpQreLLTieiZNgfjBenosqE1Ym4yYc/72ryLTQeB/qrtkGoT9knsx4BF8tuKB
         CJhvmOvTnbyQy4x6Kh7TPIXMhzyAKJplIUBHk1TDkzfPAkNtytnzU56vUss0vivuaXLM
         whvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hh10si200247ejb.3.2019.05.30.23.22.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 23:22:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 93B68AF60;
	Fri, 31 May 2019 06:22:07 +0000 (UTC)
Date: Fri, 31 May 2019 08:22:06 +0200
From: Michal Hocko <mhocko@kernel.org>
To: semenzato@chromium.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, sonnyrao@chromium.org,
	Yu Zhao <yuzhao@chromium.org>, linux-api@vger.kernel.org
Subject: Re: [PATCH v2 1/1] mm: smaps: split PSS into components
Message-ID: <20190531062206.GD6896@dhcp22.suse.cz>
References: <20190531002633.128370-1-semenzato@chromium.org>
 <20190531060401.GA7386@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531060401.GA7386@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 31-05-19 08:04:01, Michal Hocko wrote:
> [Please always Cc linux-api mailing list (now added) when adding a new
> user visible API. Keeping the rest of the email intact for reference]
> 
> On Thu 30-05-19 17:26:33, semenzato@chromium.org wrote:
> > From: Luigi Semenzato <semenzato@chromium.org>
> > 
> > Report separate components (anon, file, and shmem)
> > for PSS in smaps_rollup.
> > 
> > This helps understand and tune the memory manager behavior
> > in consumer devices, particularly mobile devices.  Many of
> > them (e.g. chromebooks and Android-based devices) use zram
> > for anon memory, and perform disk reads for discarded file
> > pages.  The difference in latency is large (e.g. reading
> > a single page from SSD is 30 times slower than decompressing
> > a zram page on one popular device), thus it is useful to know
> > how much of the PSS is anon vs. file.

Could you describe how exactly are those new counters going to be used?

I do not expect this to add a visible penalty to users who are not going
to use the counter but have you tried to measure that?

-- 
Michal Hocko
SUSE Labs


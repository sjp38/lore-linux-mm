Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E521DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:28:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3C18206B8
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:28:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3C18206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2541B8E0003; Thu, 28 Feb 2019 05:28:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 205538E0001; Thu, 28 Feb 2019 05:28:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F59E8E0003; Thu, 28 Feb 2019 05:28:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADFB98E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 05:28:56 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m25so4455921edd.6
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 02:28:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5v9+27HRYiH/y+N2nK8sCUZrvUXQoieSR1SKOlFlFJA=;
        b=a3VooBIqctARYQ1DwuapUnDm7a79w0QW9m53qUBlXi2ZiwWSBbnCFxQCG3HLNg8wTv
         tP7SXDpVLFSICP+j5WiP2ynBH+xHImmocLo8I4utlFwoeO9HATbXupcl+byRksoc8zhf
         6z2qOdXNIZNPZBmYk2CylaTUAyZmlRLms8Y6T0yy//1ngLlllZgOk9wbPl7y+7X/m1Hj
         NwhtbYmDSd+v1ur+SEU2kRuEtQDWCgFxVyDidHI8b2WZtQ3N1Kl8/HlTfK2M0hmfRbTN
         LkstRsBgreLQdogDeGyWptd+npM2cG7ZSCuWWDSe0JTc9L9uKaqMdwGjjzehN8w3EtfD
         Z0AQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubRt0oNbl4CSVgN5RicBVBfGIXm8CD6zeK7dGvXYJ7FaK1F2TRz
	UNOQ2XIscAuje6M7Wfq+Mdfr5m9cip/Kiw++mKMCdXTh7FN6kpckEpuLTs/uhAFNXdahyLD9vSj
	x51bixglnmeAeVfS8d3u27ZJkZy/8VV97RB7r3gQIBoPEb9yvmkSqwyyLEFkbrl4=
X-Received: by 2002:a50:a5f6:: with SMTP id b51mr6263887edc.9.1551349736303;
        Thu, 28 Feb 2019 02:28:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY7HFE+092i//lFvqeGQTpd2e98jxiFFM/N5E61urLNz04Lb0HTBHoXi1eRdU7RHdl7hOAI
X-Received: by 2002:a50:a5f6:: with SMTP id b51mr6263847edc.9.1551349735466;
        Thu, 28 Feb 2019 02:28:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551349735; cv=none;
        d=google.com; s=arc-20160816;
        b=FFxdfG+hHYiso8cI9Nflr7xIbm3jueKXW6asyShN1zhyyi4kwvq5hH5S0z071xdajU
         x0Oyd6sjzFv2sCa0Ig9hjTDe/1bM10xbIqmNqssLUvZEG2cDsKpQ+F5SE9Z2WDi5ay9y
         MMQtgqxDe2n02SEVNZKVadk5gtKNPxoQ/nbRar+BZ3MAfsCllfMi8JpVc3GsEZUr3Ugu
         9lVABKatUmMF/BBeAOECccSDOd7x4tqolKrwhyKug8ZGt5XIQeaW8Ll6ApILiSctzD5o
         T6Fh/44lzs5gMkpoc+YHjYRR3Pq98muVcX2gEcurQ4TqJb7cf3Y6Y0Bfanqw3VRw8/ij
         7ACA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5v9+27HRYiH/y+N2nK8sCUZrvUXQoieSR1SKOlFlFJA=;
        b=fgR6OPAtUOnCjkogIGKFifrLZCqUxq2K7f3FbmEJ54IvsZN+x7vEyADX1SUapzM4qK
         02DhtZmzOjuOGbEFkaqlBRhum/frXHs8k/9w3Qw+1uTiNXzfiT7lRDWnkMMqOPiGbd/J
         ldO/aDJTO0gDD+gKFWpPzI8J+dZ3tp9TLLqvrxEssx9Y6DcUhJSnuGyZxmp93q3jdFCO
         RaaCynWHsJCCmceNgRYC58MpTxCQMPgeOR8Rvh0JKmWx+ckDTjYDx5ND2/Bv2QG2g/Xu
         mAmTypv8KVYjRyNKM+oBqPMCYj+w7zxBUuBby/mvyqhldjoWkN60eEMjLfLjE+ni/T0+
         HgDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e1si1170580ejb.248.2019.02.28.02.28.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 02:28:55 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4B536ADD4;
	Thu, 28 Feb 2019 10:28:54 +0000 (UTC)
Date: Thu, 28 Feb 2019 11:28:53 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ktkhai@virtuozzo.com,
	broonie@kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm: vmscan: add tracepoints for node reclaim
Message-ID: <20190228102853.GZ10588@dhcp22.suse.cz>
References: <1551341664-13912-1-git-send-email-laoar.shao@gmail.com>
 <20190228101730.GY10588@dhcp22.suse.cz>
 <CALOAHbDAUFndukjQykK5zwU7XEBbdVj5eGqTW4NTwp8er4Rs4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbDAUFndukjQykK5zwU7XEBbdVj5eGqTW4NTwp8er4Rs4A@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-02-19 18:20:16, Yafang Shao wrote:
> On Thu, Feb 28, 2019 at 6:17 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 28-02-19 16:14:24, Yafang Shao wrote:
> > > In the page alloc fast path, it may do node reclaim, which may cause
> > > latency spike.
> > > We should add tracepoint for this event, and also mesure the latency
> > > it causes.
> > >
> > > So bellow two tracepoints are introduced,
> > >       mm_vmscan_node_reclaim_begin
> > >       mm_vmscan_node_reclaim_end
> >
> > This makes some sense to me. Regular direct reclaim already does have
> > similar tracepoints. Is there any reason you haven't used
> > mm_vmscan_direct_reclaim_{begin,end}_template as all other direct reclaim
> > paths?
> >
> 
> Because I also want to know the node id, which is not show in
> mm_vmscan_direct_reclaim_{begin,end}_template.
> 
> Or should we modify mm_vmscan_direct_reclaim_{begin,end}_template to
> show the node id as well ?

OK, I see. I thought it was there but it would make much less sense than
for the node reclaim for sure. A separate tracepoint makes more sense
then.
-- 
Michal Hocko
SUSE Labs


Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2789C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:51:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8324022C7B
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:51:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8324022C7B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1718E6B0003; Wed,  7 Aug 2019 03:51:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 122056B0008; Wed,  7 Aug 2019 03:51:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 011D96B000A; Wed,  7 Aug 2019 03:51:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A308D6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:51:04 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f3so55555280edx.10
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:51:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NiqSqWuBBWxZTNj/EkIyOWFFlLbLPmwn0ltZD+LjKds=;
        b=FXUanvlwChu39KwdqL/2LJw2T4Q/AICWGcherZOKEMtuyiVh2cmQtceRk8NHTIJrJj
         MXRHvxzwcN0bjOn9gYt7hvg2a2DagDGuR4Jb/0s1yXhmMJCRw5gv/XcqlnkLG9tHA87k
         AUdjNTpIhee+1uTxBX9j0bxuhSxun6XTc1VXkVwtrKrhft5jA2sgE2LjjjUgO4M2vFMN
         qTTVBDp77a7lbdxL9GM2L9mtj6pMUHeuFXRe90PnQVToHwBLt/pJGJ2PTOszWOwEWc4b
         BbQUzYw4zwCJpVyi/7Jo6pzHUVcO1MitWVusTvN/tKq2v2h3X/2VDCzPgjjuSJgYPmpa
         nvIA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW641+OawnbChxY7OU2EYDivwy38elWW7Dx8kUG5EpsEY85KBw8
	89hiwQi4xyzqUAWRCxQx3t6IlujISAwKzu/fb9SylYgKQ4QLyxezp6MsQY8EbyZr/ZRyTTejEob
	QJgYU8rmeFE5QaeF/defAV1tDBvGzxoRRtb5HS/ZlNbBb0DPNDPLM0J/wQJ66FIw=
X-Received: by 2002:a17:906:b2c6:: with SMTP id cf6mr7399195ejb.274.1565164264225;
        Wed, 07 Aug 2019 00:51:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwt+xXt+eLLbPlnIXthZmz/sX7hCVpcucM2gxwIaHcVEJJp6JFm92UlJfLUn/MNYD/1IhHX
X-Received: by 2002:a17:906:b2c6:: with SMTP id cf6mr7399157ejb.274.1565164263443;
        Wed, 07 Aug 2019 00:51:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565164263; cv=none;
        d=google.com; s=arc-20160816;
        b=QvLr/vu8hYre+SPWJF92KC2zsU69pL56A4C+UF1R8WueUGlq/bWB0NudbdJC4wYqEr
         hcEkTfQZf2htbkrahkXf90gDoQ/VOVr5PgVh4urtcyWG1lfz1osM4FlxOzn6TfP5Femj
         OzC/dECNtsugPcxhzrgIFhD/Lu3/OXLKZPoFfp5wp43LwdI1Actr3ClHYbT055SyyP3R
         uY/6xspP7RzLmSXlo6HVKKa+Jr/thWhzckoxCZLPTvx66lCJ8228fNnpDiI/EPG5y9DA
         MABW/uLWCqazFb6VChq9d2wiaIou5o18wUCfh+LtCdNnMK3uO4Q2vTHJcUiIEdzqzWFr
         qfBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NiqSqWuBBWxZTNj/EkIyOWFFlLbLPmwn0ltZD+LjKds=;
        b=taPXyVChFIrZqk48IWWVip6VrY8V83Kht4FVotEusVr0f4G645jJV3UW+wvqatRY5/
         KidvjJyHd8rF7cvbyak9CK+qEJuPu2u4Rp3su1WhSVnnKacRTU+eEEFPD1JeACyb4hVB
         mwZuwS9Qjdd7PUY4FGdOaRW9oBOihrmMT1kdbWyySACmur3rQwhQrebLFlIuTlB0dHGw
         GjEINnQ2Xp4HNYTU7A4UX2J2ojsUPcB7EhGLKQ0PjnXA1kc/B10sBu72qFECJZ0DsGbW
         Mnv+X89VazJOgARbY1ZyTOX3K4kUPnVeBxUc/ajO0ZTfOpJrNunT4G2GuJh8DqhrUvr7
         UEkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z48si31442007edc.301.2019.08.07.00.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:51:03 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 42D39AFDD;
	Wed,  7 Aug 2019 07:51:02 +0000 (UTC)
Date: Wed, 7 Aug 2019 09:51:01 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Wei Yang <richardw.yang@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org,
	kirill.shutemov@linux.intel.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/mmap.c: refine data locality of find_vma_prev
Message-ID: <20190807075101.GN11812@dhcp22.suse.cz>
References: <20190806081123.22334-1-richardw.yang@linux.intel.com>
 <3e57ba64-732b-d5be-1ad6-eecc731ef405@suse.cz>
 <20190807003109.GB24750@richard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807003109.GB24750@richard>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 07-08-19 08:31:09, Wei Yang wrote:
> On Tue, Aug 06, 2019 at 11:29:52AM +0200, Vlastimil Babka wrote:
> >On 8/6/19 10:11 AM, Wei Yang wrote:
> >> When addr is out of the range of the whole rb_tree, pprev will points to
> >> the biggest node. find_vma_prev gets is by going through the right most
> >
> >s/biggest/last/ ? or right-most?
> >
> >> node of the tree.
> >> 
> >> Since only the last node is the one it is looking for, it is not
> >> necessary to assign pprev to those middle stage nodes. By assigning
> >> pprev to the last node directly, it tries to improve the function
> >> locality a little.
> >
> >In the end, it will always write to the cacheline of pprev. The caller has most
> >likely have it on stack, so it's already hot, and there's no other CPU stealing
> >it. So I don't understand where the improved locality comes from. The compiler
> >can also optimize the patched code so the assembly is identical to the previous
> >code, or vice versa. Did you check for differences?
> 
> Vlastimil
> 
> Thanks for your comment.
> 
> I believe you get a point. I may not use the word locality. This patch tries
> to reduce some unnecessary assignment of pprev.
> 
> Original code would assign the value on each node during iteration, this is
> what I want to reduce.

Is there any measurable difference (on micro benchmarks or regular
workloads)?
-- 
Michal Hocko
SUSE Labs


Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E9D5C5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 09:09:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07F9F2147A
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 09:09:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07F9F2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42CF96B0003; Fri,  5 Jul 2019 05:09:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DC9E8E0003; Fri,  5 Jul 2019 05:09:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CD1A8E0001; Fri,  5 Jul 2019 05:09:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E61FF6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 05:09:05 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s5so5269874eda.10
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 02:09:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iU0enR2VgdWeLrxAP5i3curnTEfzzA4sDyXdDRQq3F4=;
        b=CbghiBbJb3qbrKEUK8lkrIppB+F5/5gqpeqrHFlC2nr/dGvFL8KjdGJnmLm2H5yrpS
         gQrl3y8qGPUbTuID3huWBG0+aY5pBRP/trMcrw1QBK/JdU2BP52UGj0wZbtmhoiGkmSh
         dhw4SpgYUiwwnrU4a/vO7YwjQ5JGtIrIPxgwOUWRQLobEPL+vrOb34Fi9dr9i1wTTXme
         2dZQtb1vzT9El+Xg993dt7+Vqtqi30YvPx/t0N2Z3aVI6FepmbT86opeuzM6UmVjb4n6
         M0w/McDz5vzsM8s1hHE6cRtVvYVUp89s2NH/vkodE4QuVQFHyBfCdeTbyrt3SweHEFiO
         ypxg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWJFPciySEaaR9mHh0s7FcKEdFDfF7kX8vpkn2ORJVUHhNjYma+
	5YIZyMeuIO93Fk/HLlLMDr/35sVuNhntnuhe2vUVIVIlgErnuhlhyWqSL0wVMYHaJ28FWpzHdRC
	B+BRKhxnOCOJz25p9Q8OFZj+CuybM0bb1ulJvGp6XSbsg6tH6pcAc0ZMEEFhcmQs=
X-Received: by 2002:a50:e718:: with SMTP id a24mr3212511edn.91.1562317745408;
        Fri, 05 Jul 2019 02:09:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy89KeHCjKHXOGeulXP0gicFw09Ihth9XWAHo1naPNMAxUrPI5CcNxiJOZGnFHJb/bxhgDt
X-Received: by 2002:a50:e718:: with SMTP id a24mr3212426edn.91.1562317744468;
        Fri, 05 Jul 2019 02:09:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562317744; cv=none;
        d=google.com; s=arc-20160816;
        b=j44HMg1Lguh6wa8Fh53KozML5051cOJ/etQn8MtKLehdNYQEss4ei+iXYW3lMN9fif
         JFaHz1TrYNRrmQ09uXr6FosPnSgjQic7WQvV7UigE5co3nWQBlHu+e3D/edyk2q+u0Kp
         paxhI/mFkL++Jn5Lzl1WbTlHePDOKN7p4RuEeGLqEk15HpgmO+wcN8qVRYWjVhxIcznj
         xla9vh/gJ47Vc/1uIERqiaXI73o9B8+sOUVP4tnbwxJosy0b9E5RFq6QOtXRREgybgc+
         xAuwMRUrLtZ63z6Fhgmo+lEvjiJtnpCP8j6NiZIftWVW2LG3ggbgwOUHOQ5JHtZTjmeR
         rBLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iU0enR2VgdWeLrxAP5i3curnTEfzzA4sDyXdDRQq3F4=;
        b=TJNMsoLYVQh+iVXGVt2LFu2TzJLg8jLz6OAUP2xoDQCNtipj+X8H1JfCRY/7s2VBFm
         vswSJ+pHqqxwjcdJHEzgAKmzGkOG1feeBmuXqqLRgH6s+jGWHhOdsJkSLPidw6E5FHsD
         YC/1/sYVs6Xh1Kk5EYthbPYzeiKCSlWyB8swA3tHXJpO7u1b95lTlOaguCRpvGyxUmYG
         pGO8nJe4cqlBfvA3SXlEL2DH94/qxjyezYbwHD48ht49dp4bBOMuDatf7kcBsgo8ynS6
         q7lxydyxQ/MSdgXuXoNY8BRe+9tAWzRCgz6U5gBlF5jo3vZfrxFM/Xokayj72WwjcdAN
         yheA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b22si2899714edd.227.2019.07.05.02.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 02:09:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9E07FADE5;
	Fri,  5 Jul 2019 09:09:03 +0000 (UTC)
Date: Fri, 5 Jul 2019 11:09:02 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm, memcg: support memory.{min, low} protection in
 cgroup v1
Message-ID: <20190705090902.GF8231@dhcp22.suse.cz>
References: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 05-07-19 15:05:30, Yafang Shao wrote:
> We always deploy many containers on one host. Some of these containers
> are with high priority, while others are with low priority.
> memory.{min, low} is useful to help us protect page cache of a specified
> container to gain better performance.
> But currently it is only supported in cgroup v2.
> To support it in cgroup v1, we only need to make small changes, as the
> facility is already exist.
> This patch exposed two files to user in cgroup v1, which are memory.min
> and memory.low. The usage to set these two files is same with cgroup v2.
> Both hierarchical and non-hierarchical mode are supported.

Cgroup v1 API is considered frozen with new features added only to v2.
Why cannot you move over to v2 and have to stick with v1?
-- 
Michal Hocko
SUSE Labs


Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA525C76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 20:07:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63DC020659
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 20:07:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63DC020659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 964596B0005; Tue, 16 Jul 2019 16:07:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 915336B0006; Tue, 16 Jul 2019 16:07:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B6268E0001; Tue, 16 Jul 2019 16:07:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A79F6B0005
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 16:07:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l14so16624022edw.20
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 13:07:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2/PgH7i8VostDkVWP0PffyppCC58/NJi/jkjPZBn0pc=;
        b=cmkrjfQhXJQAIblW22rZIrssvcHxZGbje8yv4r1PABNjF8Irv3dTwq1csIo5KRt/Vb
         ipgJ1+xsngLCmGOgyiYzpCYQ8m56LoQu59bGe7P+QgY6tEw0P+1F6xYkHNxyGANoORw/
         Nogdm0AVhQcWah11kEmW0xGriJKJakl3veCWk7w1yAWzdx11XG7OY34RKyYHUXbQkGwd
         VZhrIscctOcLDqPKqN6r2EKgu79ssKAAxHRGw1bk9e00B8/fXStNzoD+rSkfasv0Mpmq
         LXy7m4Mt//PT9ojXOKN2Yvq7lQFFNyj03p2U3duTCfKMxUmjf6owSoci6zHRpWa5+mqh
         2lhg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUStVOTb0BngoudKe9/G5BM4rk5Z6nmAtAHPuMHaXP5PfMmyTFR
	3rH3UnEX/7Ni5RhRXFrTJYZMazY866Y0sw1Qdgp4bTxm8wcYtYuDBhmBehFU3jtEDnjAl+6BXy3
	jt8XS6lA/Us2dyfSWk9Egwwx3JaFa/WUJWDChbS5igYx0wHGCPoQ5MnexZ3/cuNc=
X-Received: by 2002:a50:ba1b:: with SMTP id g27mr30773506edc.18.1563307638652;
        Tue, 16 Jul 2019 13:07:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1IFLcsoTAuTpWC/fuKoqTdBtsjyQk7NcV64TedPLRAIab5UkfJ7HmlyPhw1ze+Kn3HOrR
X-Received: by 2002:a50:ba1b:: with SMTP id g27mr30773408edc.18.1563307637606;
        Tue, 16 Jul 2019 13:07:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563307637; cv=none;
        d=google.com; s=arc-20160816;
        b=o3fbgnOmQiYlIdADs76rxQyM3M/5mdCjtojjIXz6bi85pn7xpGeuhvM43AuLOMaOJs
         oGugc9kaDKSRGSsR2SNFWe7seYc1aQ9TlEVI9HP5hekSfj35cg1efVmQN9Hzx82gZZM4
         pksRMnWYcLa/Tn0bWe82JML2pzPrOhZ69oDAsopKuKSY2jqzi1A216OmBdvkq+Soyl8A
         WukGFr1/rN1z1cUIVGs4UQ1eZmOt957MJYLKf64cO4INqaP203O+IDOJX22B81Vb14eb
         UwMsikDYbGnkOOuHvomIUpeKPJ4F0yIea34Pl85lzhIcaPoqmtGRqin/8jfEOqsZNZFA
         JRDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2/PgH7i8VostDkVWP0PffyppCC58/NJi/jkjPZBn0pc=;
        b=R5kIPf2cW4WR1nfcMJGhFt17h2rZTFddDdO3ljkzK4dkmGKq1K8+AY98mgQ3JOTkXf
         0XpqqSkzKJTHBH+TCrPNBge+lYW3ljCxBO8BHvztNA/8mGRSy2XFvArM2Er8DdMVzL3K
         Ur2V6NEteBR0vgV+ICPXo1xOwHbJ2TFGc+beHPhA6J161SYuyHZdsgwEOlgbfoiHWD5T
         T+BKhcXcCzVTU62RHoIsF5iqq4RdxCI4MGrs5rY/FgkRvDTfKu5cJLs2BEQ4EvdTzmoF
         K7RTfTxjVBLz3amXduW3Ds4hUHcvyJZg4NVoZzUw7hEnhgEBymX66RFbb6REUDQVGrjt
         +bkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m12si13588287edm.38.2019.07.16.13.07.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 13:07:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AF0E5ABE3;
	Tue, 16 Jul 2019 20:07:16 +0000 (UTC)
Date: Tue, 16 Jul 2019 22:07:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, catalin.marinas@arm.com,
	dvyukov@google.com, rientjes@google.com, willy@infradead.org,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Revert "kmemleak: allow to coexist with fault injection"
Message-ID: <20190716200715.GA14663@dhcp22.suse.cz>
References: <1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com>
 <1563301410.4610.8.camel@lca.pw>
 <a198d00d-d1f4-0d73-8eb8-6667c0bdac04@linux.alibaba.com>
 <1563304877.4610.10.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563304877.4610.10.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 16-07-19 15:21:17, Qian Cai wrote:
[...]
> Thanks to this commit, there are allocation with __GFP_DIRECT_RECLAIM that
> succeeded would keep trying with __GFP_NOFAIL for kmemleak tracking object
> allocations.

Well, not really. Because low order allocations with
__GFP_DIRECT_RECLAIM basically never fail (they keep retrying) even
without GFP_NOFAIL because that flag is actually to guarantee no
failure. And for high order allocations the nofail mode is actively
harmful. It completely changes the behavior of a system. A light costly
order workload could put the system on knees and completely change the
behavior. I am not really convinced this is a good behavior of a
debugging feature TBH.

> Otherwise, one kmemleak object allocation failure would kill the
> whole kmemleak.

Which is not great but quite likely a better than an unpredictable MM
behavior caused by NOFAIL storms. Really, this NOFAIL patch is a
completely broken behavior. There shouldn't be much discussion about
reverting it. I would even argue it shouldn't have been merged in the
first place. It doesn't have any acks nor reviewed-bys while it abuses
__GFP_NOFAIL which is generally discouraged to be used.

Thanks!
-- 
Michal Hocko
SUSE Labs


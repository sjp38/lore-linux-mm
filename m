Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF07CC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:00:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B86C021841
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:00:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B86C021841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36AC96B0003; Tue, 21 May 2019 07:00:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31A236B0005; Tue, 21 May 2019 07:00:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 231AF6B0006; Tue, 21 May 2019 07:00:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C78226B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 07:00:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n23so30106679edv.9
        for <linux-mm@kvack.org>; Tue, 21 May 2019 04:00:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ET1wMqrFOstYPCHMYL62mdFN03DNLYto1nGyGG1/OwQ=;
        b=GKNnQiSz1J2jIZFK5xBc96e34mQEz2HOVV52QLCAkp+qCE4o+GJVnN6cA2LOr2HLCF
         +hDlq7reynI2tI5Qb3C0ohrQTN19nkfDzl5WAlZmy/kFVZ5p4wcIZYx9SEIqUpzCecZj
         MoWc6hpcgGt4kgWde+25K55Yvdt9aaNPosEJ0DQPbtx3Vsam9g3FVIjNugVGQ3+EKp1X
         j8VzzwTXC6Yp78x6ihVNbrg9ESWYH8Gp8Pc7C4xFR+yPkJQqCUc5kl8FXwCctQcD6qL/
         HhZZtpKmIL5c/42zarU9Pi30UF93XtP+eWJa98xJyoPNAn9AkPZ5ZsM2UDK2/rXHi56J
         B+1w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWUowDDaK1zdBPkiwfavaW9UZCMHho6o/XrItbR/ZhLQecOqoF2
	I38wlUxFOzl/2IUw+tJJPzWBbQihnxWz+DyMHHBGJTAN9BQ8TkupZ/+A/L+T3BGbwknpyulFUxh
	7Z0WOPrgOYmLtYPwwctP0RMgt6yaONqYJcl8mCWuUo78mCYCDWmRxouhmjnPj2ME=
X-Received: by 2002:a17:907:2131:: with SMTP id qo17mr16745869ejb.220.1558436433379;
        Tue, 21 May 2019 04:00:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyh5gGkMMnlhbkVPP/EcNbWWF+mF0x9QawXtRW5rORmsdCwg85DSVQXnz4vtgVKLb5aXiPD
X-Received: by 2002:a17:907:2131:: with SMTP id qo17mr16745802ejb.220.1558436432612;
        Tue, 21 May 2019 04:00:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558436432; cv=none;
        d=google.com; s=arc-20160816;
        b=jop0neV+ohUfpM7WMAoMSAP9TZTUgwPjp+5CaKK0+mka9p25NXSpeWuQYGIKmcgwCB
         cJttz9YRS1iRgYRs70ehlnZQGhNBfuv+Esa3MfYUUw54hD0wgdBaxs6177sdEOw7SoV8
         +e37K45HyKCsHT08g7SOy4R/IPuBfViDUOxm00mfUIdLd6k6R8Mly/1hg5oRanxX2xIM
         qjkiHxctsPLsMyv+EpZVBRyYd4RnrNF5JmOtQepJAghXImBqDwqax+xjFZW6jiNOMQ2K
         Nn3cTzjwYuad1Et5vBFm80HLWTcHl/oknatgpA3NnUjUHlXyGudcv4dotIqlf2hiGiO9
         xP2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ET1wMqrFOstYPCHMYL62mdFN03DNLYto1nGyGG1/OwQ=;
        b=k1dnPEpOgSqSeyerYyiESoSODkxVlYUUPv+EzcZGQzUwOknz4/U4m3GMTS8pv5FczS
         L8qO1n5FlUWjAuKFFVsnx2VGOT8aPPPMtmU7Z/TOdnXLiXc3Ju3SVCFyFnK8zb3UdL/L
         eC08pb7zXu6FztvmF83k/5EFMQTO+akF0DRK9I2b0AnZnewrytUBYUNc7pt4nf4wG7Vp
         8Zxq1egZl8muIjccwkbnb1+i8r60MYoO5+igbXL60XisyHWPrmPPZXO4GWMjnW4yKjVb
         p6g+7rQsdbr0yDgGYdzFOUxVG1G/+jqvzI7kJmUd5Gtaqk2XPlcCmbZeqajcmEuAjwNT
         pPCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w31si5635329eda.349.2019.05.21.04.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 04:00:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2064FAE31;
	Tue, 21 May 2019 11:00:32 +0000 (UTC)
Date: Tue, 21 May 2019 13:00:30 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Oleksandr Natalenko <oleksandr@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 4/7] mm: factor out madvise's core functionality
Message-ID: <20190521110030.GR32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-5-minchan@kernel.org>
 <20190520142633.x5d27gk454qruc4o@butterfly.localdomain>
 <20190521012649.GE10039@google.com>
 <20190521063628.x2npirvs75jxjilx@butterfly.localdomain>
 <20190521065000.GH32329@dhcp22.suse.cz>
 <20190521070638.yhn3w4lpohwcqbl3@butterfly.localdomain>
 <20190521105256.GF219653@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521105256.GF219653@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 19:52:56, Minchan Kim wrote:
> On Tue, May 21, 2019 at 09:06:38AM +0200, Oleksandr Natalenko wrote:
> > Hi.
> > 
> > On Tue, May 21, 2019 at 08:50:00AM +0200, Michal Hocko wrote:
> > > On Tue 21-05-19 08:36:28, Oleksandr Natalenko wrote:
> > > [...]
> > > > Regarding restricting the hints, I'm definitely interested in having
> > > > remote MADV_MERGEABLE/MADV_UNMERGEABLE. But, OTOH, doing it via remote
> > > > madvise() introduces another issue with traversing remote VMAs reliably.
> > > > IIUC, one can do this via userspace by parsing [s]maps file only, which
> > > > is not very consistent, and once some range is parsed, and then it is
> > > > immediately gone, a wrong hint will be sent.
> > > > 
> > > > Isn't this a problem we should worry about?
> > > 
> > > See http://lkml.kernel.org/r/20190520091829.GY6836@dhcp22.suse.cz
> > 
> > Oh, thanks for the pointer.
> > 
> > Indeed, for my specific task with remote KSM I'd go with map_files
> > instead. This doesn't solve the task completely in case of traversal
> > through all the VMAs in one pass, but makes it easier comparing to a
> > remote syscall.
> 
> I'm wondering how map_files can solve your concern exactly if you have
> a concern about the race of vma unmap/remap even there are anonymous
> vma which map_files doesn't support.

See http://lkml.kernel.org/r/20190521105503.GQ32329@dhcp22.suse.cz

-- 
Michal Hocko
SUSE Labs


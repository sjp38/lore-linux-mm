Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C327DC04E84
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:24:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86F692070D
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:24:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86F692070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22EEC6B0005; Wed, 15 May 2019 10:24:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DE8E6B0006; Wed, 15 May 2019 10:24:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B1846B0007; Wed, 15 May 2019 10:24:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADEFF6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 10:24:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 18so285143eds.5
        for <linux-mm@kvack.org>; Wed, 15 May 2019 07:24:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=R6SfYUURybcFTNACeHn1BEBuqop/WIQBpGhDMXT5TSE=;
        b=oFDK46E7Tl83Hthp5wdDgRr6zWo1TGzlUlfXVLcOgixhXiEnon8gzCQtRclF+IBmEb
         BfrRFvSsPHjyqdN67/z8CNgjrJ+W4JU4DikTiWoDeic7/K+CxsFoe2eDwntydI85gGxl
         eX/LmwTK04Hoj+FPflZ1MGVoYFc8ZC5/ko4kbfMbbBTgZcgk9m0W48VRVOT/Ogo/cHr0
         KWE/l4zOAqQvdxCkww0MuWpcy8rCqAP7Xk9lDy8c+Bsn2zzGE/chrk9wn/PlVUcG/L5i
         OnL4wRcn1NN4pxL+Ka1JsM7YU3MC3TG6Cfy7pQMYLyO+6IimuRzW0m4ZI1FHaaLM/99G
         8UNA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVnOaN9dNW/4njY6k8oMmiHRVE1473wGxcPAWUa8fV+Dnw9M18G
	9jAf+MTaNN39u3fkcnv0R88jtoCXnwBwHIEqxitj3FNlkbvsm9Bj/jeeqECflsbpDQ7eKerG8Wc
	mVWstOuyfklwdxwrkQkxEwWRloruwkdfhp8OiaEsTXt+Fqvw7u0zicgajTVi52I4=
X-Received: by 2002:a50:a5b4:: with SMTP id a49mr44541028edc.30.1557930263286;
        Wed, 15 May 2019 07:24:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzb3V8h2vTQTERWSUQTmaFRv6WzAT9K3iigoOTFkd88Ub2/5YykuyNRW4y69Rih3iPkJ2WM
X-Received: by 2002:a50:a5b4:: with SMTP id a49mr44540902edc.30.1557930262133;
        Wed, 15 May 2019 07:24:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557930262; cv=none;
        d=google.com; s=arc-20160816;
        b=SVNjnv42Yr3WFUdhj7KX9omh7hoT2xmW9aD4PTlxUB/RgJJ2K2VeG8FLgayWBC632D
         VjkGoeKuJqk8/PMgMPQjZxqaPLT0SFaPVFt0o4zjJiDLgvrL5aipkSj7d4XjEYTA9B1m
         LH+bcgQbvymrSCzWdIVahCyEa0xUTS7ycn5ZgPBtUk3CSd7REMZwFNDXNCd/AdgCIXnc
         C2DD23ri9CiWYWlAvlq+FyMTNdfuX9eW9J9oiVViFNCHzK9FJ9dDr2Hs8r7LsaVsyZj5
         XMOcofy9Fgazvc3yWgoKxtKQVnZY3px0sFBAT/UGe43JHCMfcCYdtTy+BTh21PYAxbzW
         DL5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=R6SfYUURybcFTNACeHn1BEBuqop/WIQBpGhDMXT5TSE=;
        b=CePI7EM3q+BOktJV5cjXS+4+sUr4+C2lr0ruM5IH8Gy3yygwCoSri619bHLfgu2MGo
         b5oYQVu/dlqLTl3aWE1c9jG8tu9FMHwoEKtopQoMe1zoOy6FTevNp3GppXDEg+lnLh0o
         l8e2kHxCPX5AOetAZkLQckgCktjT5vye4xVEJ+yqhvz/2exbHDind7oPqBgt3vBR+F+v
         83eBPHmmcKTv3in37/UIQ0BZYau4UiiwxPiipJH44pBBzUMP/Icsowx3OcgEkvE6MfyC
         RwL/Rj31iL/SYjZvy1kqp4KFtVeL1k77AJzbSUOvKTpXyZgQEdYVr1TmvALcXfvFrLZ2
         wzyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l4si1460635edd.297.2019.05.15.07.24.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 07:24:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 08E71ACF5;
	Wed, 15 May 2019 14:24:21 +0000 (UTC)
Date: Wed, 15 May 2019 16:24:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC v2 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190515142419.GD16651@dhcp22.suse.cz>
References: <20190514131654.25463-1-oleksandr@redhat.com>
 <20190514144105.GF4683@dhcp22.suse.cz>
 <20190514145122.GG4683@dhcp22.suse.cz>
 <20190515062523.5ndf7obzfgugilfs@butterfly.localdomain>
 <20190515065311.GB16651@dhcp22.suse.cz>
 <20190515073723.wbr522cpyjfelfav@butterfly.localdomain>
 <20190515083321.GC16651@dhcp22.suse.cz>
 <20190515085158.hyuamrxkxhjhx6go@butterfly.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515085158.hyuamrxkxhjhx6go@butterfly.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 15-05-19 10:51:58, Oleksandr Natalenko wrote:
> On Wed, May 15, 2019 at 10:33:21AM +0200, Michal Hocko wrote:
> > > For my current setup with 2 Firefox instances I get 100 to 200 MiB saved
> > > for the second instance depending on the amount of tabs.
> > 
> > What does prevent Firefox (an opensource project) to be updated to use
> > the explicit merging?
> 
> This was rather an example of a big project. Other big projects may be
> closed source, of course.

Again, specific examples are usually considered a much better
justification than "something might use the feature".

[...]

> > OK, this makes more sense. Please note that there are other people who
> > would like to see certain madvise operations to be done on a remote
> > process - e.g. to allow external memory management (Android would like
> > to control memory aging so something like MADV_DONTNEED without loosing
> > content and more probably) and potentially other madvise operations.
> > Or maybe we need a completely new interface other than madvise.
> 
> I didn't know about those intentions. Could you please point me to a
> relevant discussion so that I can check the details?

I am sorry I do not have any specific links to patches under discussion.
We have discussed that topic at LSFMM this year
(https://lwn.net/Articles/787217/) and Google guys should be sending
something soon.
-- 
Michal Hocko
SUSE Labs


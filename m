Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19D62C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:01:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3742208CA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:01:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="b8UGgDxX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3742208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 718BD6B0005; Mon, 13 May 2019 14:01:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B2066B0007; Mon, 13 May 2019 14:01:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 568AD6B0008; Mon, 13 May 2019 14:01:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 308196B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 14:01:08 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 49so8171828qtn.23
        for <linux-mm@kvack.org>; Mon, 13 May 2019 11:01:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=PlYvmqxRpVISnjsRFpBbrKcWou6q8G660sOR1uIfQB8=;
        b=VrqJvKSgfPeNXjUkgZmW0lGy4aS+1IDJagb7NCjREsS0QEoWK7/KAjC1lMGMHMmPDw
         Llz5RvvVbmvv0mbHkhcoYj1EYpHQYmx6Aei5rpqOPSxy0dDR9WVce1DLfVwIDEw4Hh2G
         1FWMI17w7Q2FL1Drww98y2A/73bfgLvyC/mPO6BbYyH33aMZGHpKRA9Ttm/oBzZwQ2Ar
         E/IRehktyEvhNnexIdu5FfHRHoPn0vDDso8NXbxsCMGLNCJT6sKaepZvhZy/m68eU6zN
         vmK0LNlqKHwqHpaxAA89uYMVm5O03PBqOYD5me4eKruoMsiUfJsmctjfIrVYZ6TjNXxw
         in4w==
X-Gm-Message-State: APjAAAVawHHIpBnvyXhSKtLWVeO+XQ8BzAyElL9QY0nyOh2nIEh8hjJN
	LD0RUnRbbrBRkkgp1hcDCLQuyOcpB3VxKUzzSlaBJuMaSpYos9mR+ZTcrQBNCg9G2trCUjRF94g
	9GFQXniWK7mXsc8fbtRIH7dw/Jn2QpzBQJuOND3HpjcUpw9x0y9fMooUJ904DDjY=
X-Received: by 2002:ac8:3702:: with SMTP id o2mr25296499qtb.119.1557770467913;
        Mon, 13 May 2019 11:01:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJeU5BKZi6l6EKCqLRFvjCmBx0VSb/IIryvEN+/td+j6RDQX2QIxf3uUWGhYy0Y5kkhxyW
X-Received: by 2002:ac8:3702:: with SMTP id o2mr25296372qtb.119.1557770466679;
        Mon, 13 May 2019 11:01:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557770466; cv=none;
        d=google.com; s=arc-20160816;
        b=yoq0Hbz06hR5FBx9+yhgcAS4FlNaHp7ukqc4vtOjIaatLm0eOhct2YL2ehHn3LuJm5
         ev89wW3YpgAvJpF66+tHfSbY51Hm58bcFIktoQuJooojp1GKR8KDGfXwfPdzDK8I1veg
         XeeUVnta7FRkjlVqEsbWBQNnQuIbgJApdBB3f7oRHsUzcdKb6TKNpG9txBdFtL2KAmZQ
         Yw2lqz1FQKsAZ0gGpUpvyLZeO5nk362yE0FIcJPehef455lgS3Nu2l1MN2zO7kQmcIhV
         C0//IsFpHVkGh8p38ztfucKJNIzMuwWIBnYPQtkKuEBuHMZlqqoCGCcway0oe/rN99VO
         SDhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=PlYvmqxRpVISnjsRFpBbrKcWou6q8G660sOR1uIfQB8=;
        b=I56o3N+5+Kba3H9XejAc4Uu6crwcsN1phMKVj2g0Nx/UEnwk21RZWHPvVxohfQQ28E
         Y1wMaARG2B5ly32E/ejvg/qkrPsu3PpQRKcN7hdJ56bHfR7NbCfkRW2vbf2hf2Y5x7oS
         yU6tIRRYofrDi91GwskeEuxWFGOpA7kByRTVKu0lE6a0dU6xH5bTlKAQy+0aczCe8tpu
         ckU68tKJw59e0uZOFL2UubIeznX7cQ6l1GEmd7hzAbFT09+3IfcOnR/2JngLCrCtP49F
         XDdwquMOut4PCEiHa+bcukdujURgFS8WNkhtV7rdGsn6JwariVR885+vDldtP8DXlMCb
         EC3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=b8UGgDxX;
       spf=pass (google.com: domain of 0100016ab25aef20-4552213a-13e1-4aff-ba52-e970f3ac7fd4-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=0100016ab25aef20-4552213a-13e1-4aff-ba52-e970f3ac7fd4-000000@amazonses.com
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id y34si2230995qvf.20.2019.05.13.11.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 13 May 2019 11:01:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016ab25aef20-4552213a-13e1-4aff-ba52-e970f3ac7fd4-000000@amazonses.com designates 54.240.9.54 as permitted sender) client-ip=54.240.9.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=b8UGgDxX;
       spf=pass (google.com: domain of 0100016ab25aef20-4552213a-13e1-4aff-ba52-e970f3ac7fd4-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=0100016ab25aef20-4552213a-13e1-4aff-ba52-e970f3ac7fd4-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1557770465;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=PlYvmqxRpVISnjsRFpBbrKcWou6q8G660sOR1uIfQB8=;
	b=b8UGgDxXFtgOe6/nHEgwLitQKKdP6MaTm72eml72TE9fnqIiPmXw8fT7pLun0Kck
	rTcHdXuzgkeKJJQmYht5nMnPLcckFMsU/bqzVWYwIlrnDkBQuekNUTWLhxi0ugBfjUe
	6vhOsZoNl7l4/KTlnny/6ogqiyJ4zFkjdnQwfoKQ=
Date: Mon, 13 May 2019 18:01:05 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Roman Gushchin <guro@fb.com>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, kernel-team@fb.com, 
    Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
    Rik van Riel <riel@surriel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
    cgroups@vger.kernel.org
Subject: Re: [PATCH v3 4/7] mm: unify SLAB and SLUB page accounting
In-Reply-To: <20190508202458.550808-5-guro@fb.com>
Message-ID: <0100016ab25aef20-4552213a-13e1-4aff-ba52-e970f3ac7fd4-000000@email.amazonses.com>
References: <20190508202458.550808-1-guro@fb.com> <20190508202458.550808-5-guro@fb.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.05.13-54.240.9.54
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 May 2019, Roman Gushchin wrote:

> Currently the page accounting code is duplicated in SLAB and SLUB
> internals. Let's move it into new (un)charge_slab_page helpers
> in the slab_common.c file. These helpers will be responsible
> for statistics (global and memcg-aware) and memcg charging.
> So they are replacing direct memcg_(un)charge_slab() calls.

Looks good.

Acked-by: Christoph Lameter <cl@linux.com>


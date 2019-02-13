Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DF42C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:12:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59D9B2084E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:12:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bCsoIO+W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59D9B2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC1958E0002; Wed, 13 Feb 2019 07:12:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6F9C8E0001; Wed, 13 Feb 2019 07:12:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C11288E0002; Wed, 13 Feb 2019 07:12:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE088E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:12:08 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id y1so1583907pgo.0
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:12:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1OM8g/NX/UZBg3UJqR2J9FLZx57Ly7BOAmEDV2K7uhY=;
        b=OXy6N47lEHH0PcoUm0KESkFfMYGcvZgSaKqGXUqqyVx5FDl35WDMkGgrDuX3l9/Sj/
         wVlzc/dco9s6MZ6mAGWUr5wDjqki9Mj3J0qLCW7ydipcBKMLU+kq4+aMWJk4PiFEB+Kx
         AYAbyJsoZU8rSl/BwXNF1w1MoxaDkfzPjIeu0PXJTMZ0uju9PiaKfE5l63tYhZIi+cCo
         loV8NVADWKiZirGnQ6TLdx41vq0/O5k7DyUKL51+F3Cm+z5cd/FLli8VgE8pUfIHqvzl
         LKVkLSKptdVO5hARSuKbspzInt2yIYE/A4j4g7C/A2zCk/ZGz8q7AZiIAyXBKfkx8ZZv
         5+gg==
X-Gm-Message-State: AHQUAuZcO1f8aCwFi8qpfX0vEvowrIOELeLiGNf597p/3rG/5vPg3VFx
	fM0ythBSr5pk2eJ06YsEWcH8kJ304gPmw5FyP+UV0+lQ+BZIaOe2rksrE014B4ZAmJwfoXkmuTP
	aAT/MudsRT3ma2wJKCSISiyqmLN350Wzw0OGrwkYZ7I5eai806gw3sB7qAcpGoNSS6+iARv7Lzx
	uIxTlBkoEaxUXFh+3Y1qZ8HEgdjYtFUnGr1p+U2+OSX+8FhGO6bcJLI2duIL6hf02KpRjsndnjy
	xuy5IkDiP3cUFhtKydtZRrzo0+/7ZdbbwqBLsBBRtF/DvUxe0oZbFeXe1smIYlpiFLGLXU2/PuB
	xDAOFJ/UhGWMCwqn+hgFQF5zjKefT1+mM0cUGOo4b8Lyv3q/idXVOmdlBck2ahkBt3y1gSsgew=
	=
X-Received: by 2002:a65:6150:: with SMTP id o16mr184135pgv.434.1550059928161;
        Wed, 13 Feb 2019 04:12:08 -0800 (PST)
X-Received: by 2002:a65:6150:: with SMTP id o16mr184070pgv.434.1550059927381;
        Wed, 13 Feb 2019 04:12:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550059927; cv=none;
        d=google.com; s=arc-20160816;
        b=0DatLaciGN3xN/x6W+t6VB9sO/uqSdhu3qW3TdI415LFgkPA5cqGcKWTcMPRv1tZzp
         m6BdaqLEOdiX3iOYUGRFmf8fVGEeNinFdd1IYKgyxtD0vi8bOXPuBZCkCJwwU/sg5+Kr
         K13FDEim2jZCsnQg8V6ul+7TSGbL0V7CS0AWoY8OdiWYjZexpxUaw/g7Ej2UXXlyPitf
         aBFRWgg09dgzqUetqy+Cft+PLl43xRPYIi1eJgqvvnuwE0E+Yq8nJWb669DtKyKsTjeA
         kEIRVG4zcTG4vXQKTagm4eWhJTcLNKF7ojCdv0OEQbgNC2avZLXoLQ4qBbaCetcqdHrp
         3E4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=1OM8g/NX/UZBg3UJqR2J9FLZx57Ly7BOAmEDV2K7uhY=;
        b=evFDdxnrq2LeHBxvbRECezbmd3k8PA36sr/dbc2VzwCNe9InbTRdRrY1WpsJ24CXci
         Pw2hhkq/t67hdxSI802bivpEaTeEVPib87xcbHhFwbZ/TOqsXJuCeazqEgyrFsk59to9
         iOSkKRFc28IdtiAj3XJHo1ERqpFJ2mXLjxbPk9zAuDSGlRQuQFsreRBKc55p1n48K8dt
         icHN2d0cizDo0ypGw6NYTgSTvuDwkXhfqChzJid/HbbwTbjzvO56ap2yFy3sP1g9Nj7Q
         UnpiWr7ecYl9P5BKEkMNU4W04+YNDEkrTK1Q51N7BlHnqsL5mMcoG0zPqvcrsTIkhmr9
         ZtOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bCsoIO+W;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b16sor23422398pge.50.2019.02.13.04.12.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 04:12:07 -0800 (PST)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bCsoIO+W;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1OM8g/NX/UZBg3UJqR2J9FLZx57Ly7BOAmEDV2K7uhY=;
        b=bCsoIO+W9IVxnutoTPEN/oRIhliKyeo6O09HLO5LT2wgmpMxrLpdlAlNGnyfqWVttb
         WRrAd4Op7rx8uyEcrj99cVKq9ZNkl1KcNrbHupj7rdHdVLTeHhnRGabPSroasWUjauxp
         oNdtSGYJx8ocvFN1UGgNhkHGAmIwcaODVMDFMuSi6MDC4lqJUNTP4gTUuj/nHZ/cQTcb
         u4XaqoEw8neWGBtPXzW063ntW5Rbo2vkJfxeLqAPoul2vPo31U+gSK18wmR31ftv/lqa
         ZPi9edi/YcsHQ8HdVg7RBeMjRzs2+t6X6UF9kGArpJb2qAd8pBKVDNv5TuHX8D0V2Wkg
         vcBQ==
X-Google-Smtp-Source: AHgI3IZGp/7T2ZjzKZOFr0mllbEWlNI/Wg/mSYl7woG4cC/jww2Wcp/Jh9R9HpnmO4AroPzsWODNzA==
X-Received: by 2002:a63:da42:: with SMTP id l2mr141927pgj.403.1550059926786;
        Wed, 13 Feb 2019 04:12:06 -0800 (PST)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id r80sm23435460pfa.111.2019.02.13.04.12.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 04:12:05 -0800 (PST)
Date: Wed, 13 Feb 2019 21:12:00 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: gregkh@linuxfoundation.org, linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hugh Dickins <hughd@google.com>, Liu Bo <bo.liu@linux.alibaba.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix the pgtable leak
Message-ID: <20190213121200.GA52615@google.com>
References: <20190213112900.33963-1-minchan@kernel.org>
 <20190213120330.GD4525@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213120330.GD4525@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1+60 (6df12dc1) (2018-08-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 01:03:30PM +0100, Michal Hocko wrote:
> On Wed 13-02-19 20:29:00, Minchan Kim wrote:
> > [1] was backported to v4.9 stable tree but it introduces pgtable
> > memory leak because with fault retrial, preallocated pagetable
> > could be leaked in second iteration.
> > To fix the problem, this patch backport [2].
> > 
> > [1] 5cf3e5ff95876, mm, memcg: fix reclaim deadlock with writeback
> > [2] b0b9b3df27d10, mm: stop leaking PageTables
> > 
> > Fixes: 5cf3e5ff95876 ("mm, memcg: fix reclaim deadlock with writeback")
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Liu Bo <bo.liu@linux.alibaba.com>
> > Cc: <stable@vger.kernel.org> [4.9]
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Thanks for catching this dependency. Do I assume it correctly that this
> is stable-4.9 only?

I have no idea how I could find it automatically that a stable patch of
linus tree is spread out with several stable trees(Hope Greg has an
answer). I just checked 4.4 longterm kernel and couldn't find it in there.

Thanks.


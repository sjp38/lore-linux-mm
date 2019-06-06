Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79D09C46460
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:55:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E315208C0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:55:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E315208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01C326B0287; Thu,  6 Jun 2019 15:55:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0E836B0288; Thu,  6 Jun 2019 15:55:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E24BD6B0289; Thu,  6 Jun 2019 15:55:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 96C836B0287
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 15:55:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y24so5298814edb.1
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 12:55:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5CgWskb2VbYRiF6wwP1HFZ1ljOYTY784fqcWj3a/820=;
        b=PGzK6O3VG5RzcwTxKU5GIylZ79vH75x7oATPEFARTETUHV5v8TwcWuHKHONDtKC7R+
         PVGMwhQbGckZZ22Hac4cGTwjPdzk564A9hjDuIj2TytJwmV6jG6a2bc+kYY1jKZn0ZbR
         SKe5dtIFMuWvGRaSF62TGpRA7Du5NDsxlapPV5RKJKoQ4WtlwbxcycgO7i4s+VTAL2fJ
         JrlyOojhpPJsjPTGF1etWE+GCdgV0yQxYyKUKU3Y17aD379YKyD/6whB1Solmj67xpUr
         9+e9EKmtzGLYifsly8Y3HM+MFgzmdVr6uBKfwjuEIR1xHxTkU8TzFoLVexxtk9bssNE4
         Lnrg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWxZ6Vxf4tAoPpy1hQHSQDyZBSxXQWHw9s6iyeJtlW1pCVwnhrB
	W2gVK8jMbFGsgU4SgD2nEHCPBodDa0KhDUb/Mhi5iM6dGrskWh+NeVWkdLQ2Hm3dAhYp9DJUPOR
	Udj/dMMvR/C7qYux1u1Hg7wUGtEIuR8M6aNK/wQhKklGDlN1oH+UV1TQTT6sZBHU=
X-Received: by 2002:a50:9822:: with SMTP id g31mr25024983edb.175.1559850913205;
        Thu, 06 Jun 2019 12:55:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7pHriYAvTsQ1d21shSU66QeBJdWNkoPO7vk23iljoYsWPFhOtU3I1hwXOg87bhN3Gtt/s
X-Received: by 2002:a50:9822:: with SMTP id g31mr25024916edb.175.1559850912534;
        Thu, 06 Jun 2019 12:55:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559850912; cv=none;
        d=google.com; s=arc-20160816;
        b=XSLSc+ALfr35D1OSkFyrT/PhNUzimzDYk/AstzsSilgwRe3XKKT5/N/6pCKrMA8/UZ
         Zt256Pmzb2NB3w3iPW7F63OgqnsO/necfQY3L3y7AdZsMeIyRArdc7XIiGibJa70a8uz
         IRkTXzWvBqFTa50XgWmGzZTEhVErogXY9hc7M1PEZWETK8jOzYlAvWvm7LZWxTl1a8Of
         71ZJE7RSv7M6RkmbOgzo70jwYf5qTt+Tfqiz0QymTcRpJmw0uKEuCqYzMzLPJf3XZgLI
         R0zDXirsfZYCs0bQPsNK3d9QUEoz/Tw5VCtwVDdj/srl5M+iQ1KLnVtv9Keyn8A14PFi
         koTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5CgWskb2VbYRiF6wwP1HFZ1ljOYTY784fqcWj3a/820=;
        b=N+ScLLg58y82a7UI3+0wGhVAOTcRzu9uXPNgKg+zgQIfrV7hFdP74bUMmbqJsk0S5e
         olM9AsLD0je/rFBkObQKwDhoQfdsyGS0ESkNAZF1kxwq9KkpwENhLPLh+/tau4aF0lll
         aAdAVAYQ+PR41mcSFgbTbhUfp79St7q651x2hDb0+Ogq7lGHSSqaz7AoKMY5NFL2xZUH
         Kt7Y/han+MNHkr5c3TdZZMes4VtHrMEKUKtf62J8NEKoqMP3vQMO5aD8QK22DG/HOcZv
         y4CJgFumBVvkf/W3MfA/eKctUV4Hn60VeAOgJOeTSFR/spMuNqBEef49z63bCRtZG0Hm
         X5Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y20si2359967edd.115.2019.06.06.12.55.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 12:55:12 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DACD6AD8A;
	Thu,  6 Jun 2019 19:55:11 +0000 (UTC)
Date: Thu, 6 Jun 2019 21:55:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Ajay Kaher <akaher@vmware.com>
Cc: Stable tree <stable@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Jann Horn <jannh@google.com>, Oleg Nesterov <oleg@redhat.com>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	Srivatsa Bhat <srivatsab@vmware.com>
Subject: Re: [RFC PATCH stable-4.4] coredump: fix race condition between
 mmget_not_zero()/get_task_mm() and core dumping
Message-ID: <20190606195505.GA7047@dhcp22.suse.cz>
References: <5756B041-C0A8-4178-9F5B-7CBF7A554E31@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5756B041-C0A8-4178-9F5B-7CBF7A554E31@vmware.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 06-06-19 19:42:20, Ajay Kaher wrote:
> 
> > From: Andrea Arcangeli <aarcange@redhat.com>
> >
> > Upstream 04f5866e41fb70690e28397487d8bd8eea7d712a commit.
> >
> >
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> > Hi,
> > this is based on the backport I have done for out 4.4 based distribution
> > kernel. Please double check that I haven't missed anything before
> > applying to the stable tree. I have also CCed Joel for the binder part
> > which is not in the current upstream anymore but I believe it needs the
> > check as well.
> >
> > Review feedback welcome.
> >
> > drivers/android/binder.c |  6 ++++++
> > fs/proc/task_mmu.c       | 18 ++++++++++++++++++
> > fs/userfaultfd.c         | 10 ++++++++--
> > include/linux/mm.h       | 21 +++++++++++++++++++++
> > mm/huge_memory.c         |  2 +-
> > mm/mmap.c                |  7 ++++++-
> > 6 files changed, 60 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/android/binder.c b/drivers/android/binder.c
> > index 260ce0e60187..1fb1cddbd19a 100644
> > --- a/drivers/android/binder.c
> > +++ b/drivers/android/binder.c
> > @@ -570,6 +570,12 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
> > 
> > 	if (mm) {
> > 		down_write(&mm->mmap_sem);
> > +		if (!mmget_still_valid(mm)) {
> > +			if (allocate == 0)
> > +				goto free_range;
> 
> Please cross check, free_range: should not end-up with modifications in vma.

A review from a binder expert is definitely due but this function
clearly modifies the vma. Maybe the mapping is not really that important
because the coredump would simply not see the new mapping and therefore
"only" generate an incomplete/corrupted dump rather than leak an
information. I went with a "just to be sure" approach and add the check
to all locations which might be operating on a remote mm and modify the
address space.

-- 
Michal Hocko
SUSE Labs


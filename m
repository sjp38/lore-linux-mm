Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BDEFC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 16:11:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09704208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 16:11:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09704208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D3496B027C; Tue, 28 May 2019 12:11:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85CD86B027E; Tue, 28 May 2019 12:11:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D5AD6B027F; Tue, 28 May 2019 12:11:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5996B027C
	for <linux-mm@kvack.org>; Tue, 28 May 2019 12:11:13 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 18so33815346eds.5
        for <linux-mm@kvack.org>; Tue, 28 May 2019 09:11:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EDL/SS9dmt2Wk5Aq/dpjbAy46I2nsgA4KzoIsKSaONo=;
        b=fRUIuZ6ACogjJy4tGUJgCzbKaomyVwbzVb91lKbNO2GyqY2qmaz6qgWANTIqITVWgr
         ShGCoGY5Zjhq92Nm/Usp14qUBkiUIkQ9HgCS6TTHqByhAdSVEF2MS87+NeBhgn4voKWN
         t4ms4ygn2IUOFEZCT+f8TmkwhHKz323hosUcCMaYb7fpQgV2B+0gKqm0bCGVnpzGPrtI
         Gfdlq1b0Z7j4rjOUSPn2JOL1WvVy7bbKddGqUipOjINKcANYtRBDLoItw0lNI+l09wd/
         B4xDFzOlcgN5C+JZKoQq2vTR+TcIH37mYatLNhY6i2QZgH56MgrwDJW7qC14rKTzK23b
         5Iew==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWjZh2zaP4oA+PqOK4xMB3cqE+mYe87ssc3FKKvkZeGyTeZb6e1
	iIOXbj0ZwMnrrhkdoLPR5M6d29CWUBpR/LGcSaZ84Oh2xa5WQ+Ss2HsIzKkviziJE6iDBgBNIcv
	iHe7Xd2SK79K0z2LppfeN3Rw41qVdTtO9+M1iy1IbyxQbzcFhAjHV3g2H28fWrfY=
X-Received: by 2002:a17:906:5512:: with SMTP id r18mr20864008ejp.298.1559059872660;
        Tue, 28 May 2019 09:11:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWNecdC/0p5g5lRAsC9IVXkUzREZ/ySp38rQvzpx74LiCHhiEmWLHgABlYcePR4sX9LTPy
X-Received: by 2002:a17:906:5512:: with SMTP id r18mr20863916ejp.298.1559059871583;
        Tue, 28 May 2019 09:11:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559059871; cv=none;
        d=google.com; s=arc-20160816;
        b=xvLgF0o8C/yY4101F1rSqGuGrmKZ6/o8P5d7CqflSLnO/0ltZOLhL0laPydoTFRA5u
         dtzKhGBDxPjwtjTB/ZxDqvRRiY2ZmE+s2e8ZzN9fp/iX0ZFa8w8GPJPWCycG3APR3c8j
         TxiTMtdiRmfVWJ0m4Y4+iBdTEn6ctC5M1JbHLyMimJ6lwOg4MSzU1tY3NqA914VtfaZ9
         xAjkoJWRac5m/42bZ0xufhm8LaoyTzposyYHaq7skkCrMW1z8SwwfMNkq8s+/HE4aGrL
         NMk4Y884xXUmATsnkp0wbBwj9AszkDPwfvdInkiJ+KBygnbkvWtdUbEz4wfPyFj4sC3x
         +gSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EDL/SS9dmt2Wk5Aq/dpjbAy46I2nsgA4KzoIsKSaONo=;
        b=QUG7BNA27ky720fia0NHujeTv9mZUzMBnHq50nSnGW5VyDNyzRC1e/hJmnYFdq90yF
         V1hscwoCRjvYTHSzScN84FDg+iiZ1u94ZZhLP/dKjaoF+zR0F+E+xuGezWsECA0KWQu0
         kbYuASAJoDDO0zII7DBZh9EdCVvXGOBxHK0GV0RsHTqhONqF+62Rt9gCTLoVcbfyLNxj
         xJ4VEZRoEQMknmomoHp4XQwztG3Fz4oTaf06c0TZpiGIk9d30yPldtEf+G/9EjFCqBNu
         5ODmv/jGChT4Q4128DIXWMPEkk0R+ASUti8eu39C/mGJhb6BmZXi9gue9iLkmtPiSkcD
         XJ/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e52si11641354edb.265.2019.05.28.09.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 09:11:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 08E1FAF3B;
	Tue, 28 May 2019 16:11:11 +0000 (UTC)
Date: Tue, 28 May 2019 18:11:09 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 1/7] mm: introduce MADV_COOL
Message-ID: <20190528161109.GF1658@dhcp22.suse.cz>
References: <20190528153811.7684-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528153811.7684-1-hdanton@sina.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 23:38:11, Hillf Danton wrote:
> 
> On Tue, 28 May 2019 20:39:36 +0800 Minchan Kim wrote:
> > On Tue, May 28, 2019 at 08:15:23PM +0800, Hillf Danton wrote:
> > < snip >
> > > > > > +	orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > > > > > +	for (pte = orig_pte; addr < end; pte++, addr += PAGE_SIZE) {
> > > > >
> > > > > s/end/next/ ?
> > > >
> > > > Why do you think it should be next?
> > > >
> > > Simply based on the following line, and afraid that next != end
> > > 	> > > +	next = pmd_addr_end(addr, end);
> > 
> > pmd_addr_end will return smaller address so end is more proper.
> > 
> Fair.
> 
> > > > > > +static long madvise_cool(struct vm_area_struct *vma,
> > > > > > +			unsigned long start_addr, unsigned long end_addr)
> > > > > > +{
> > > > > > +	struct mm_struct *mm = vma->vm_mm;
> > > > > > +	struct mmu_gather tlb;
> > > > > > +
> > > > > > +	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
> > > > > > +		return -EINVAL;
> > > > >
> > > > > No service in case of VM_IO?
> > > >
> > > > I don't know VM_IO would have regular LRU pages but just follow normal
> > > > convention for DONTNEED and FREE.
> > > > Do you have anything in your mind?
> > > >
> > > I want to skip a mapping set up for DMA.
> > 
> > What you meant is those pages in VM_IO vma are not in LRU list?
> 
> What I concern is the case that there are IO pages on lru list.
> > Or
> > pages in the vma are always pinned so no worth to deactivate or reclaim?
> > 
> I will not be nervous or paranoid if they are pinned.
> 
> In short, I prefer to skip IO mapping since any kind of address range
> can be expected from userspace, and it may probably cover an IO mapping.
> And things can get out of control, if we reclaim some IO pages while
> underlying device is trying to fill data into any of them, for instance.

What do you mean by IO pages why what is the actual problem?
-- 
Michal Hocko
SUSE Labs


Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 885C8C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:08:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AFB421773
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:08:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AFB421773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D42556B0007; Tue, 21 May 2019 02:08:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF3036B0008; Tue, 21 May 2019 02:08:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBAA86B000C; Tue, 21 May 2019 02:08:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 701CA6B0007
	for <linux-mm@kvack.org>; Tue, 21 May 2019 02:08:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 18so28978725eds.5
        for <linux-mm@kvack.org>; Mon, 20 May 2019 23:08:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fkEdIW8L/0UUq6EzmPYswRjupFW1ly6DTFV8SR2yfEo=;
        b=mIEPxaeuoNJ5y95jMCmfTGjfCMADUl6fnMqLeNckn00Q8zZ/5oYZJA7XeMW7ueiqkM
         ii1b78G4SwM881FyhDFMEUgDgWVEjBTh3wGkqysz+qfv9AY9YoE9xlyH/WJCyOi8fzTF
         AG5TMjF7nLPOojNvRkukhMV0u/JjZY7qLWN+NcE/kol9jaJ4C7WPQRUYyZxwu9JFMGaC
         P41yh6glnA5nkPrPd++lW/aT6ZnUEAaYINNZBZP7sIHKW52R//1votfp56JFLNy8uOG6
         BS0uwOpF6w+s3/mGunHy2ocwNXghQqA9kPrRQcN7JA1C1PrnehxDOX4assSyYqA1Jmv9
         RvNA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVkT/8v4BKHA0ZgZTb54L0CvZqOWXIrlqShl5Y+c3RyndDRR8yK
	ceoE8F+RZ01zdyYDnkiNeD4wAT1uXfxDMCvi6Pm1hYyWr6hsj3ln+lkrBV6l8leOtDYcNGTzwjt
	0QNR2WCKRiTTEtpvcND8T5/MsvTQHw7l34VoIAME/9/XeJb6RT9UOxpG1ODyBwnw=
X-Received: by 2002:a50:b513:: with SMTP id y19mr81627829edd.100.1558418902997;
        Mon, 20 May 2019 23:08:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZFx06JTfGHKWM35rlcWXgoqheBhbBDTJpsZ8ZC7ZHs34zjnBa9gBpmNfgVSUt2mpDEiO1
X-Received: by 2002:a50:b513:: with SMTP id y19mr81627759edd.100.1558418902146;
        Mon, 20 May 2019 23:08:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558418902; cv=none;
        d=google.com; s=arc-20160816;
        b=Svt/BAqr84vMTjMhos7oeQhmIz/BdsQ04Xhnbkt+agCw+No1u1MOk2aOkrd2ZvtJdI
         Erbl4bER5BtUcouA/jqrj53W0/SKjSEH2vSdd6hMHxRsbOks6PfcRB8new4YVgiPzKwL
         +WVj+wKtBRf1gWLz8E5kJ0V542TOkK07jzNf/ngOnMLz/AG3HsZwEL0le4FZQJt1kg3Z
         SerLVPbgtOFK6EE/s+b8j4soQbrnIPaOix6SNO3dTaiTu298NKyertyYqCiFAsDmsw49
         SjsYZR+ct1cY6WtiF0dN2w6iGN715uMkqeaa5OIwBiFxBxf+soNlhUYv6PckguC2Juj4
         P98Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fkEdIW8L/0UUq6EzmPYswRjupFW1ly6DTFV8SR2yfEo=;
        b=fkq+XuYDEmfuReto90WRHNBj63p+yjiT9jNdAuJXwGqNFd2/Jp/fNJsXigNomI/Rle
         qTQxUi4pKsBpxorTNfMvL28uUmKFYr9f+h6UxtXhpetPPt9KKKCpW4TGQ75IOaZKod4f
         rFu4KZxZzsACKqmtbhsqkCgtpCafYrdF0KVj3noN82DoSZqNRpD5O7iseEc1uLuZ+tlh
         Jt+Awmeq6G2tl+7bj65FVko3OIeyusLrXoYGvfWjHK2Up2D13Ek8XGJtTRaIoT4/uK52
         lyE7U28Gq2R5SfsU0TOflpu6xXw9r6GYT0S/qtpUkUE9yb7mpyKOcv3Jb+p+sgYIBesN
         rjWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x12si655545eda.175.2019.05.20.23.08.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 23:08:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6A6FDAD45;
	Tue, 21 May 2019 06:08:21 +0000 (UTC)
Date: Tue, 21 May 2019 08:08:20 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 3/7] mm: introduce MADV_COLD
Message-ID: <20190521060820.GB32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-4-minchan@kernel.org>
 <20190520082703.GX6836@dhcp22.suse.cz>
 <20190520230038.GD10039@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520230038.GD10039@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 08:00:38, Minchan Kim wrote:
> On Mon, May 20, 2019 at 10:27:03AM +0200, Michal Hocko wrote:
> > [Cc linux-api]
> > 
> > On Mon 20-05-19 12:52:50, Minchan Kim wrote:
> > > When a process expects no accesses to a certain memory range
> > > for a long time, it could hint kernel that the pages can be
> > > reclaimed instantly but data should be preserved for future use.
> > > This could reduce workingset eviction so it ends up increasing
> > > performance.
> > > 
> > > This patch introduces the new MADV_COLD hint to madvise(2)
> > > syscall. MADV_COLD can be used by a process to mark a memory range
> > > as not expected to be used for a long time. The hint can help
> > > kernel in deciding which pages to evict proactively.
> > 
> > As mentioned in other email this looks like a non-destructive
> > MADV_DONTNEED alternative.
> > 
> > > Internally, it works via reclaiming memory in process context
> > > the syscall is called. If the page is dirty but backing storage
> > > is not synchronous device, the written page will be rotate back
> > > into LRU's tail once the write is done so they will reclaim easily
> > > when memory pressure happens. If backing storage is
> > > synchrnous device(e.g., zram), hte page will be reclaimed instantly.
> > 
> > Why do we special case async backing storage? Please always try to
> > explain _why_ the decision is made.
> 
> I didn't make any decesion. ;-) That's how current reclaim works to
> avoid latency of freeing page in interrupt context. I had a patchset
> to resolve the concern a few years ago but got distracted.

Please articulate that in the changelog then. Or even do not go into
implementation details and stick with - reuse the current reclaim
implementation. If you call out some of the specific details you are
risking people will start depending on them. The fact that this reuses
the currect reclaim logic is enough from the review point of view
because we know that there is no additional special casing to worry
about.
-- 
Michal Hocko
SUSE Labs


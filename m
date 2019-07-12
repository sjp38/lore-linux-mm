Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EA9EC742B1
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:17:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4382521670
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:17:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4382521670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC50B8E0130; Fri, 12 Jul 2019 05:17:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C74248E00DB; Fri, 12 Jul 2019 05:17:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3D2A8E0130; Fri, 12 Jul 2019 05:17:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 648748E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:17:48 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z20so7265457edr.15
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 02:17:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=F50tGA5hW7um+TbyxgChVy93AL72+ibEKffr18+YBxs=;
        b=Mz7bnH+P50M+GLDYlyA5NhNX1/xSsyRgZPu57tCgO3mhV7rV7dUVCj7m/ITRH03wYS
         WGOS+g0vcMyfAVwzrAtsyhxoq4pbCFUorzagwsWB6FaIpY/lvFljBC2ENpv+0QuXe7uv
         tR3AD3UI4TPFX+3cy+YlBVPuNcLAI5fWnQFm3hfes6toNiLkKqxHxRd9BbMIeKLPoo1y
         yVRmvEzleXUb7cATpPB1ktzP4CbEIh9qn86WjdD1fvG+Oi2uAIHG2rk14gxZ/b9zVtFD
         iFqrwsumwmPdkhXSvhGJmOstYkIIb3W0SX3Y7bAdcQHXDF8x2YQfAfEoNPgolZSSNQUJ
         abyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXZgJ2YdgeRNK0buItS5elfaoqJjdkQ4rOTHSAFSOgpSGhv5yL+
	QoHIvjF/8icHXdbqkSaggVw2ZREBbnSvLKNZLBChXyyVfikFCnFX3dYVLNdAoK3R3A2MMO4xPvW
	0cpR1Z6cujcIoAus9535J/MQTgiSXk/B7I/20Pc1GqmZkRfsuOgCXgsx7Ib6QRPHJvQ==
X-Received: by 2002:aa7:d68e:: with SMTP id d14mr8138915edr.253.1562923067985;
        Fri, 12 Jul 2019 02:17:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVACc247Gfng1ktKoekMZlcxo2DvluHYYJ1xzYlph7q6qSeqGKIC7RZsjzRmuPOfbQhxAA
X-Received: by 2002:aa7:d68e:: with SMTP id d14mr8138877edr.253.1562923067264;
        Fri, 12 Jul 2019 02:17:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562923067; cv=none;
        d=google.com; s=arc-20160816;
        b=Fx+v6TODsgVHiPAfQ03XwMH2nSVxGzSQ15mTnjYf0Wkso3+5bkK9A76aUme74Kkqiw
         8/fft3BLpUf/KLuFIlm7322OgORFW9JfvpLaMgViHESW2EtmvKOpF+yf+zlEXI+dgDy3
         nxby8QtPYmnHIuBmtX3e/y/bUxp/cxKjS7D0/HyAcwE8OT3GAKaaDuYUTkOR4O1E7D60
         ybuazOZQtJemvWCPr2NjPPbgnLUG/kd3VdZWev6yh52ePwiYtepmFbY+waxH6B1sCW7r
         VNIB9UW+n75zs/P7GpP9D2KCj3jKrwRPulv6j+OH70JeheuK71jQLR3zu2wuqGZbmZ6r
         em8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=F50tGA5hW7um+TbyxgChVy93AL72+ibEKffr18+YBxs=;
        b=qU60i3tJ7284H2a/RoLueToLQ4fISAJ5hyrLkLSz9QhtPDCkldGKwRQeGI7geRc7VN
         wUTve3Jnu3V4+o0UXw+ky7BSM9SK+UF62SdxbM6BUmZYTsXvJBJQ7IwoFIIqfhgkiEJo
         YJc4DxCNeYAg7lr9xASQYMZqfdk+XAZ/W/IEKGSgrxVm0xRep60rB2c1ySzz8wkTKuq/
         aHgZziSAJJdBA92tmFkgCumOF8JktJ01C4UVGQiLo4F2pvZpKpPbCjbjzqWkD7mUmiBD
         M8dat1LEn0F/EO5660PKaZ2S0pamfLC7nPN8R815VnZbS/z7FNZloRlhZ4sSSmLMirG4
         P4wA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h20si5383412edb.132.2019.07.12.02.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 02:17:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7ABE6AC63;
	Fri, 12 Jul 2019 09:17:46 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 3F1FD1E43CA; Fri, 12 Jul 2019 11:17:46 +0200 (CEST)
Date: Fri, 12 Jul 2019 11:17:46 +0200
From: Jan Kara <jack@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mgorman@suse.de,
	mhocko@suse.cz, stable@vger.kernel.org
Subject: Re: [PATCH RFC] mm: migrate: Fix races of __find_get_block() and
 page migration
Message-ID: <20190712091746.GB906@quack2.suse.cz>
References: <20190711125838.32565-1-jack@suse.cz>
 <20190711170455.5a9ae6e659cab1a85f9aa30c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190711170455.5a9ae6e659cab1a85f9aa30c@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-07-19 17:04:55, Andrew Morton wrote:
> On Thu, 11 Jul 2019 14:58:38 +0200 Jan Kara <jack@suse.cz> wrote:
> 
> > buffer_migrate_page_norefs() can race with bh users in a following way:
> > 
> > CPU1					CPU2
> > buffer_migrate_page_norefs()
> >   buffer_migrate_lock_buffers()
> >   checks bh refs
> >   spin_unlock(&mapping->private_lock)
> > 					__find_get_block()
> > 					  spin_lock(&mapping->private_lock)
> > 					  grab bh ref
> > 					  spin_unlock(&mapping->private_lock)
> >   move page				  do bh work
> > 
> > This can result in various issues like lost updates to buffers (i.e.
> > metadata corruption) or use after free issues for the old page.
> > 
> > Closing this race window is relatively difficult. We could hold
> > mapping->private_lock in buffer_migrate_page_norefs() until we are
> > finished with migrating the page but the lock hold times would be rather
> > big. So let's revert to a more careful variant of page migration requiring
> > eviction of buffers on migrated page. This is effectively
> > fallback_migrate_page() that additionally invalidates bh LRUs in case
> > try_to_free_buffers() failed.
> 
> Is this premature optimization?  Holding ->private_lock while messing
> with the buffers would be the standard way of addressing this.  The
> longer hold times *might* be an issue, but we don't know this, do we? 
> If there are indeed such problems then they could be improved by, say,
> doing more of the newpage preparation prior to taking ->private_lock.

I didn't check how long the private_lock hold times would actually be, it
just seems there's a lot of work done before the page is fully migrated a
we could release the lock. And since the lock blocks bh lookup,
set_page_dirty(), etc. for the whole device, it just seemed as a bad idea.
I don't think much of a newpage setup can be moved outside of private_lock
- in particular page cache replacement, page copying, page state migration
all need to be there so that bh code doesn't get confused.

But I guess it's fair to measure at least ballpark numbers of what the lock
hold times would be to get idea whether the contention concern is
substantiated or not.

Finally, I guess I should mention there's one more approach to the problem
I was considering: Modify bh code to fully rely on page lock instead of
private_lock for bh lookup. That would make sense scalability-wise on its
own. The problem with it is that __find_get_block() would become a sleeping
function. There aren't that many places calling the function and most of
them seem fine with it but still it is non-trivial amount of work to do the
conversion and it can have some fallout so it didn't seem like a good
solution for a data-corruption issue that needs to go to stable...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR


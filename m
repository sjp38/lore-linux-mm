Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51934C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 08:37:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 145B32238C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 08:37:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 145B32238C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D5236B0003; Wed,  7 Aug 2019 04:37:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 284DE6B0006; Wed,  7 Aug 2019 04:37:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 173DE6B0007; Wed,  7 Aug 2019 04:37:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BCDCB6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 04:37:29 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m23so55590546edr.7
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 01:37:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WKhshljJmOZyjYvyZX7QsR3FEk2iXyhB3CFtsjRwYa8=;
        b=K4RMz/8taHA1sefm4QbOQgkjHnNYUEYF33CWtB9UgjRhXpYu2O4ueCXOpVAfL2U4ma
         yTEOvwebIoLuheEMO7MZaHgZnuuZ+XV8Db4BXHpteZYCkvFuQh9zmqiWXzvlqmDzRdjc
         XRGwyMT09NW8qcrYX7BmpfTTNY3Jrli/C6yo1y4r1ewksErfKiHRGpFbbEVQQTvLc+w6
         XO6qheY5iHUMuEd5JdrAK+4hx6ijCTm2jsuF/s5Q6+kxcSFzeGMVMShXn0blwhwyBKOd
         jh06K392vD4hjEU++0sNvO+fFZ+p7EwZX1g4+cgcJ95rPNbx2vPN9WmqOlDq0a7YeUr0
         1IRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXbgXW4811HwzGhr6/VKYCXaye5ceIFAvc/mHoGCtNI2dT1kzOm
	Z5uvUY5H9yoiCWa1hBEYwHHTlpIpgoI5nJ/aW5lMnRaTZYoqF3BBIjhd3O7XVQ2+FhAN1vVgZ2q
	XZBMTTDm66rSHPYehHVk35teZUP2LubbUjC9gq3Fmo+OBlNrCEInd/y4v2wwniqWNXg==
X-Received: by 2002:a50:b561:: with SMTP id z30mr8390220edd.87.1565167049318;
        Wed, 07 Aug 2019 01:37:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyF/0sx4Lk7PovecvRiJpUqOoXppEXrjA1ZSYPOvlyjeA9VKIRP+FYgz0PR4MbkFl6DP1I4
X-Received: by 2002:a50:b561:: with SMTP id z30mr8390166edd.87.1565167048478;
        Wed, 07 Aug 2019 01:37:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565167048; cv=none;
        d=google.com; s=arc-20160816;
        b=QF9G74DTXx6vS0vUatKtKT/FhkqrQcxZWCbjSr/tbNGLao9BF4ml9/e2XC7hB2Z+Rb
         427zB656VqjYUF5m6DMT0Ke6JvgF03Srv71rPbvzL46d+saXr4p0DNicuBDoF/G7FU5d
         43nV0FZQdL93jjbCO2wbImDC+mN6KWhi7qhsVcPCtSmUUYZaLUjR2NHRd74J5i2IfT/A
         CfB6KtxfzP1ZPQrifq3L+JJKXgDVppKtbgHh655Wt+RROHWWXpedhOfcLvNhfBBcZMcz
         Del1fbrpKmOKZXicxRCOiMhyZ2FqCjX+/+1vT2IVKsU1/c6KCdS/Fk/DQ0zpZrQBaX8w
         qhvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WKhshljJmOZyjYvyZX7QsR3FEk2iXyhB3CFtsjRwYa8=;
        b=W+Bn4R1uF7JQfWXLrAevq3162mhqheiro6AdevWMMbxQGNSRdCXlXr5J5Bqe9DVeIN
         15P9w1Cuu4aGtBbYIDIqQqdrUsGw1Ulk41r5mmXosBL2B0L3PSXPMmfI5TnQ2UjNUVpg
         4UzG0ozI03KePdwts3vdFydxnbz3TlHMz2ZIqQNMdL/6Roaxlaya1BLTW89elgylWca/
         ZZqeirRabGQittL5TlYha5aFM7gi/uiO8vLGunD+OCNLL3AyFxoweaRdBmx4fe1e7Eq7
         RgCyUuXRIOq+ZnxK8L2NRxqaN94FEYtEgrLqoXyR/9eq1OmEusm3IHUvAkqYqiNEt+LW
         5wlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q36si33994526edd.153.2019.08.07.01.37.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 01:37:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F237BAF41;
	Wed,  7 Aug 2019 08:37:26 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 9D5DC1E3551; Wed,  7 Aug 2019 10:37:26 +0200 (CEST)
Date: Wed, 7 Aug 2019 10:37:26 +0200
From: Jan Kara <jack@suse.cz>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
	devel@lists.orangefs.org, dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mm@kvack.org, linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, sparclinux@vger.kernel.org,
	x86@kernel.org, xen-devel@lists.xenproject.org
Subject: Re: [PATCH 00/34] put_user_pages(): miscellaneous call sites
Message-ID: <20190807083726.GA14658@quack2.suse.cz>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802091244.GD6461@dhcp22.suse.cz>
 <20190802124146.GL25064@quack2.suse.cz>
 <20190802142443.GB5597@bombadil.infradead.org>
 <20190802145227.GQ25064@quack2.suse.cz>
 <076e7826-67a5-4829-aae2-2b90f302cebd@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <076e7826-67a5-4829-aae2-2b90f302cebd@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 12:14:09, John Hubbard wrote:
> On 8/2/19 7:52 AM, Jan Kara wrote:
> > On Fri 02-08-19 07:24:43, Matthew Wilcox wrote:
> > > On Fri, Aug 02, 2019 at 02:41:46PM +0200, Jan Kara wrote:
> > > > On Fri 02-08-19 11:12:44, Michal Hocko wrote:
> > > > > On Thu 01-08-19 19:19:31, john.hubbard@gmail.com wrote:
> > > > > [...]
> > > > > > 2) Convert all of the call sites for get_user_pages*(), to
> > > > > > invoke put_user_page*(), instead of put_page(). This involves dozens of
> > > > > > call sites, and will take some time.
> > > > > 
> > > > > How do we make sure this is the case and it will remain the case in the
> > > > > future? There must be some automagic to enforce/check that. It is simply
> > > > > not manageable to do it every now and then because then 3) will simply
> > > > > be never safe.
> > > > > 
> > > > > Have you considered coccinele or some other scripted way to do the
> > > > > transition? I have no idea how to deal with future changes that would
> > > > > break the balance though.
> 
> Hi Michal,
> 
> Yes, I've thought about it, and coccinelle falls a bit short (it's not smart
> enough to know which put_page()'s to convert). However, there is a debug
> option planned: a yet-to-be-posted commit [1] uses struct page extensions
> (obviously protected by CONFIG_DEBUG_GET_USER_PAGES_REFERENCES) to add
> a redundant counter. That allows:
> 
> void __put_page(struct page *page)
> {
> 	...
> 	/* Someone called put_page() instead of put_user_page() */
> 	WARN_ON_ONCE(atomic_read(&page_ext->pin_count) > 0);
> 
> > > > 
> > > > Yeah, that's why I've been suggesting at LSF/MM that we may need to create
> > > > a gup wrapper - say vaddr_pin_pages() - and track which sites dropping
> > > > references got converted by using this wrapper instead of gup. The
> > > > counterpart would then be more logically named as unpin_page() or whatever
> > > > instead of put_user_page().  Sure this is not completely foolproof (you can
> > > > create new callsite using vaddr_pin_pages() and then just drop refs using
> > > > put_page()) but I suppose it would be a high enough barrier for missed
> > > > conversions... Thoughts?
> 
> The debug option above is still a bit simplistic in its implementation
> (and maybe not taking full advantage of the data it has), but I think
> it's preferable, because it monitors the "core" and WARNs.
> 
> Instead of the wrapper, I'm thinking: documentation and the passage of
> time, plus the debug option (perhaps enhanced--probably once I post it
> someone will notice opportunities), yes?

So I think your debug option and my suggested renaming serve a bit
different purposes (and thus both make sense). If you do the renaming, you
can just grep to see unconverted sites. Also when someone merges new GUP
user (unaware of the new rules) while you switch GUP to use pins instead of
ordinary references, you'll get compilation error in case of renaming
instead of hard to debug refcount leak without the renaming. And such
conflict is almost bound to happen given the size of GUP patch set... Also
the renaming serves against the "coding inertia" - i.e., GUP is around for
ages so people just use it without checking any documentation or comments.
After switching how GUP works, what used to be correct isn't anymore so
renaming the function serves as a warning that something has really
changed.

Your refcount debug patches are good to catch bugs in the conversions done
but that requires you to be able to excercise the code path in the first
place which may require particular HW or so, and you also have to enable
the debug option which means you already aim at verifying the GUP
references are treated properly.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR


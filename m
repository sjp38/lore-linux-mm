Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71141C19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 08:46:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E4622231F
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 08:46:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E4622231F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDFA06B0007; Wed,  7 Aug 2019 04:46:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C90506B0008; Wed,  7 Aug 2019 04:46:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA6676B000A; Wed,  7 Aug 2019 04:46:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9696B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 04:46:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so55691664edv.16
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 01:46:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fSrr7hsfJtlVVeVMBrNO1QQf3oeCAtAC3RDsSSg1DA8=;
        b=WsKr+6av97KiNhT3QpuWjAA29Z/97gAiQm3UHiTvD5hZdSk+zBswDONki7izIfX7vJ
         z+ZuQ8FkjREqd+7bd7lKal2G8PNd/PIu9BZeGJHzH9OfOtmoqUy304XZyGv1MzeRUgE/
         vpk5eUTZdod7Klco6MwK8DE/JOXg8Fj8WnBAP1eP1omTgE9iTDzfwBS6XZ+mYVSr0J7J
         ye+YhdPidZ3jHryZWp8W9In8gDWKk7uK6UI6PCFJpBgdzI6HdNA0MmxLr5F19yzrjqa1
         TPLCI2Zqcskeeihck7HuURlyzvpUH+bGfC4w2X1LtAgRmRwtkHjw2MfQ8XA7wyR8+13S
         R82Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXrRVALP1MsZ6f1Hwn17p2xWED2hFLlQoImbY+8UB1HePwIAOdd
	TfEurfSi1Ui634fTmXYZsfOq3w2dbq1YymmN3N1+zd4wljo5vVs1fv1Eng+dVae/EpO1d0sbXBV
	IDlT1UlrBY2JZj3OxSezF12V/H+D7L1QWzq/BGZ8XdMiPN+9rQLdbjvQKMUVU0R8=
X-Received: by 2002:a17:906:7f01:: with SMTP id d1mr6989478ejr.310.1565167611990;
        Wed, 07 Aug 2019 01:46:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOL8k2OXFXrO1ofmSvAIp6eqszFCHm3B5fKthsUlnOTXcytiA4bGI11cxlGe9mmUkgOAFf
X-Received: by 2002:a17:906:7f01:: with SMTP id d1mr6989433ejr.310.1565167611177;
        Wed, 07 Aug 2019 01:46:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565167611; cv=none;
        d=google.com; s=arc-20160816;
        b=B4ADEYV7qnTvod+iPQ4GCu/c6UdCD/2qQ9oT5eoxYHA5nQra6qYW5OWMu7SORS5lEq
         E4rElNRX0Il8wqGaH+OxCmU1UVaE2BOsaP9zEclH7kV6VuQT/n2Xm9rTMER9ahrOt4/0
         xTqC43DSzoTR+ZTTIzSHc1p/GaC0atuOKzcI/lAqpj44hyRQ2gr/vuwzOwvzc6MBLo9q
         crH0H+KP5wGtKGADw72EB8gr7sWwoGw9ZulCzkIzk1CPzfqLB5FFG0OxylvNh4K3lvJ3
         qvSZkHlBNiwzPM3iAUck883jbc6XVaLy1vVsGUtaeH+fo/zlAZfGu5IkKYyt0MfCUI9y
         Yk+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fSrr7hsfJtlVVeVMBrNO1QQf3oeCAtAC3RDsSSg1DA8=;
        b=qKs6/CPGh2QhAiE+juCeFlGRQzsjDxzDmXNwcEmpjsCvtpZPaY861nHAfEvrSQ/uF8
         ayrCEzDBgQsSGa7/UNppWDAXS3SUr3fjdalNY9FPfKLy4DuKjA4TWBI9mjqUBFfmu70E
         +iOIpPmU6lE6K+IFz/adrhSVlD5t9BK4OyafSWR/mKCNUjM5dd/VZbnoGjIQFP92d3gY
         zRRjvfG7ChA6iN0cy+gHeQc/nkwuCtpJUGhokF926nKceuo5CT1u6wr9SujApsSgZAbs
         rkE3Vw2NVcwmiuOFxdbxWWIkwqLlgEdG7mzgSwQ0MpHfbU00P6am5Gu0UJDer/m+gvY0
         7gxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18si32851219edd.34.2019.08.07.01.46.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 01:46:51 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8E81EAD29;
	Wed,  7 Aug 2019 08:46:50 +0000 (UTC)
Date: Wed, 7 Aug 2019 10:46:49 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: John Hubbard <jhubbard@nvidia.com>,
	Matthew Wilcox <willy@infradead.org>, john.hubbard@gmail.com,
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
Message-ID: <20190807084649.GQ11812@dhcp22.suse.cz>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802091244.GD6461@dhcp22.suse.cz>
 <20190802124146.GL25064@quack2.suse.cz>
 <20190802142443.GB5597@bombadil.infradead.org>
 <20190802145227.GQ25064@quack2.suse.cz>
 <076e7826-67a5-4829-aae2-2b90f302cebd@nvidia.com>
 <20190807083726.GA14658@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807083726.GA14658@quack2.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 07-08-19 10:37:26, Jan Kara wrote:
> On Fri 02-08-19 12:14:09, John Hubbard wrote:
> > On 8/2/19 7:52 AM, Jan Kara wrote:
> > > On Fri 02-08-19 07:24:43, Matthew Wilcox wrote:
> > > > On Fri, Aug 02, 2019 at 02:41:46PM +0200, Jan Kara wrote:
> > > > > On Fri 02-08-19 11:12:44, Michal Hocko wrote:
> > > > > > On Thu 01-08-19 19:19:31, john.hubbard@gmail.com wrote:
> > > > > > [...]
> > > > > > > 2) Convert all of the call sites for get_user_pages*(), to
> > > > > > > invoke put_user_page*(), instead of put_page(). This involves dozens of
> > > > > > > call sites, and will take some time.
> > > > > > 
> > > > > > How do we make sure this is the case and it will remain the case in the
> > > > > > future? There must be some automagic to enforce/check that. It is simply
> > > > > > not manageable to do it every now and then because then 3) will simply
> > > > > > be never safe.
> > > > > > 
> > > > > > Have you considered coccinele or some other scripted way to do the
> > > > > > transition? I have no idea how to deal with future changes that would
> > > > > > break the balance though.
> > 
> > Hi Michal,
> > 
> > Yes, I've thought about it, and coccinelle falls a bit short (it's not smart
> > enough to know which put_page()'s to convert). However, there is a debug
> > option planned: a yet-to-be-posted commit [1] uses struct page extensions
> > (obviously protected by CONFIG_DEBUG_GET_USER_PAGES_REFERENCES) to add
> > a redundant counter. That allows:
> > 
> > void __put_page(struct page *page)
> > {
> > 	...
> > 	/* Someone called put_page() instead of put_user_page() */
> > 	WARN_ON_ONCE(atomic_read(&page_ext->pin_count) > 0);
> > 
> > > > > 
> > > > > Yeah, that's why I've been suggesting at LSF/MM that we may need to create
> > > > > a gup wrapper - say vaddr_pin_pages() - and track which sites dropping
> > > > > references got converted by using this wrapper instead of gup. The
> > > > > counterpart would then be more logically named as unpin_page() or whatever
> > > > > instead of put_user_page().  Sure this is not completely foolproof (you can
> > > > > create new callsite using vaddr_pin_pages() and then just drop refs using
> > > > > put_page()) but I suppose it would be a high enough barrier for missed
> > > > > conversions... Thoughts?
> > 
> > The debug option above is still a bit simplistic in its implementation
> > (and maybe not taking full advantage of the data it has), but I think
> > it's preferable, because it monitors the "core" and WARNs.
> > 
> > Instead of the wrapper, I'm thinking: documentation and the passage of
> > time, plus the debug option (perhaps enhanced--probably once I post it
> > someone will notice opportunities), yes?
> 
> So I think your debug option and my suggested renaming serve a bit
> different purposes (and thus both make sense). If you do the renaming, you
> can just grep to see unconverted sites. Also when someone merges new GUP
> user (unaware of the new rules) while you switch GUP to use pins instead of
> ordinary references, you'll get compilation error in case of renaming
> instead of hard to debug refcount leak without the renaming. And such
> conflict is almost bound to happen given the size of GUP patch set... Also
> the renaming serves against the "coding inertia" - i.e., GUP is around for
> ages so people just use it without checking any documentation or comments.
> After switching how GUP works, what used to be correct isn't anymore so
> renaming the function serves as a warning that something has really
> changed.

Fully agreed!

> Your refcount debug patches are good to catch bugs in the conversions done
> but that requires you to be able to excercise the code path in the first
> place which may require particular HW or so, and you also have to enable
> the debug option which means you already aim at verifying the GUP
> references are treated properly.
> 
> 								Honza
> 
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

-- 
Michal Hocko
SUSE Labs


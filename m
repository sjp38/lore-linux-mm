Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9F3CC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 12:22:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8958E2175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 12:22:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="GX5RAa3T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8958E2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A0036B0003; Wed, 20 Mar 2019 08:22:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2503B6B0006; Wed, 20 Mar 2019 08:22:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13F226B0007; Wed, 20 Mar 2019 08:22:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6F166B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:22:51 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id y1so2575390pgo.0
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 05:22:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ejrv0nqkLXOAsoIVPvdcwyaIsyNTGVSm3cYDYSD+qBs=;
        b=gSNuvLvQs/Kwlk+ULdKDaAHyMpkSnRXevphwAeq4YmsytdbjCTGlcu6OsLqqIC0tNZ
         H1unJO7xd1jNhxnWutIFAsz1CCq6Ntb8HA3t1XpkkQ6HiPHd3xko7yEPk4Ng9fgFcHvg
         nTNV262+xhnXu61ttC6TkZ1HAcB6+/9mi4Zf69P+ke6ZV9a9WyzMA9oS8gL+eGo0Cpsx
         ikUTAjJWQrkWXeTf8cPZd3hv8aJfvtVvWNE+APolf5WbfDgRCVs63B2DtiZyt9P6UfjF
         wJW9O688LUHUGHB9dNJj769i8DD0x9fl+c4JdNLI/KWkgdsEJSVm/NAiNBGHE4V4sZbs
         DATA==
X-Gm-Message-State: APjAAAVMWR0bVVb/7rhpBgig8xiVQHsb0KlA8hfW7AhjyR3s2xQadOQ5
	v9W5ErW6dfptnF1ZkY37+a24FyIYmc43DhTN/s3eoWDCWCgAGJXRAxgiEiG0/IbiVPisQ1ijFFW
	qIE+tAALEi4gJc2a0y6qMg/InFJpgRCiN2GjJieQLwHpISCmOJzeSfuT8cF5PFfPFFg==
X-Received: by 2002:a63:4343:: with SMTP id q64mr6952368pga.105.1553084571226;
        Wed, 20 Mar 2019 05:22:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhp4UZqVcfaK6YzJM3wgo+qZXZ3XxwtGpds0moU4r9C8kQrdpCGBMiDF/uxEGgPHQX7dB4
X-Received: by 2002:a63:4343:: with SMTP id q64mr6952312pga.105.1553084570515;
        Wed, 20 Mar 2019 05:22:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553084570; cv=none;
        d=google.com; s=arc-20160816;
        b=kRircuhQKOFUPtxqpKrUkTyzuQmUxwnp+YE4T8pZEQb446EdcdTmbJejpF0ZWl1VUK
         M/ii3TyWI4j5C1aoqJL5tqtQxbKQGvyRR+oWVGQmtTk4dD0AuzH7R9BT4dEHM3jaAgq5
         ZmBYu4b71fl+HlaKoI+zetDVn0iBZ4FYYVL8K3hcuHjEd09uvIBuLeTf13SjGCO6rhK6
         2+Z+uIyoyXteC8lUX9FdO4h6E53I4UhQTiXkNEAfGuUNOD/R1w6Y2zBTmcXh6y1i5MMu
         NpFVghGBZxFN1JiGBQKe8s7G2VT9+ZxZn6kW3G2VpvPm+GTa/IfnWYwp9W8OfV/CVS+5
         GPcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ejrv0nqkLXOAsoIVPvdcwyaIsyNTGVSm3cYDYSD+qBs=;
        b=hekN5uPD0R8l+hZ5U9OTqxK/hXg86t8cXFS+6/Aw9tafaaK+mHoY9xdvNBJftvq5Nc
         1MzPX6h4OFkNML5X+DzlgzjpslWbmyzx0qIpVyH1Ku1Nye129uuurayd4WRXeP1gxl/L
         VLv/iAXiKqruqHOK2gmT+hLQvAGfKi+qIahU3Gsue2fRqZq8OCIpdEFE8ilhm67KA/I8
         GymBaYq1H/lvo+v1WZJdVANrDMd41Y+Vub6aXRSmmyrBJm9lpivxhd1ZQVkvicd7Zw7/
         GVDkpOzxTRh0BDNLqPXD/8am9IUFrkqyoqIIeEWa5lh7gN/IlOW/8EmxX2nxIPtBvRx7
         feXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GX5RAa3T;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i97si1923726plb.213.2019.03.20.05.22.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 05:22:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GX5RAa3T;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ejrv0nqkLXOAsoIVPvdcwyaIsyNTGVSm3cYDYSD+qBs=; b=GX5RAa3TvNQstzO1FefE+h/nH
	LSsPPn50RTM9BP3g+9uJboDdj1nDSvYlWtYDsFmgjL5YB6nzEya103QAOoIG90wCz6sfX98rsRgsX
	azIT2YcKnlGnWTJX0QEgSsa5eHnzeGIifpWjJLS41dYBEEMAvmfH0AkZaoB3yyBwCUl1+AWogfRK0
	dR8+IPK9CBJeyvTKu1R2miHNWfYcMWraaBQcrJEyxskgZV/AAQF9IOI0f/C4dSqHo8MgXDEzLMLQ9
	6v8W0j9Bzk8Fliao9jYHwrQz3WxMY1qZz3+iezeMf1C1AjNgJ0uv3c8V5Z4cB7A5Ja6fVAn3QkPdX
	V0ZYrn3/Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h6aF2-0005mM-2J; Wed, 20 Mar 2019 12:22:44 +0000
Date: Wed, 20 Mar 2019 05:22:43 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, pasha.tatashin@oracle.com,
	mhocko@suse.com, rppt@linux.vnet.ibm.com, richard.weiyang@gmail.com,
	linux-mm@kvack.org
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190320122243.GX19508@bombadil.infradead.org>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320111959.GV19508@bombadil.infradead.org>
 <20190320122011.stuoqugpjdt3d7cd@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320122011.stuoqugpjdt3d7cd@d104.suse.de>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 01:20:15PM +0100, Oscar Salvador wrote:
> On Wed, Mar 20, 2019 at 04:19:59AM -0700, Matthew Wilcox wrote:
> > On Wed, Mar 20, 2019 at 03:35:38PM +0800, Baoquan He wrote:
> > >  /*
> > > - * returns the number of sections whose mem_maps were properly
> > > - * set.  If this is <=0, then that means that the passed-in
> > > - * map was not consumed and must be freed.
> > > + * sparse_add_one_section - add a memory section
> > > + * @nid:	The node to add section on
> > > + * @start_pfn:	start pfn of the memory range
> > > + * @altmap:	device page map
> > > + *
> > > + * Return 0 on success and an appropriate error code otherwise.
> > >   */
> > 
> > I think it's worth documenting what those error codes are.  Seems to be
> > just -ENOMEM and -EEXIST, but it'd be nice for users to know what they
> > can expect under which circumstances.
> > 
> > Also, -EEXIST is a bad errno to return here:
> > 
> > $ errno EEXIST
> > EEXIST 17 File exists
> > 
> > What file?  I think we should be using -EBUSY instead in case this errno
> > makes it back to userspace:
> > 
> > $ errno EBUSY
> > EBUSY 16 Device or resource busy
> 
> We return -EEXIST in case the section we are trying to add is already
> there, and that error is being caught by __add_pages(), which ignores the
> error in case is -EXIST and keeps going with further sections.
> 
> Sure we can change that for -EBUSY, but I think -EEXIST makes more sense,
> plus that kind of error is never handed back to userspace.

Not returned to userspace today.  It's also bad precedent for other parts
of the kernel where errnos do get returned to userspace.


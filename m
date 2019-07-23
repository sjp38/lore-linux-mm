Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD7B3C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 18:06:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8333B218A6
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 18:06:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8333B218A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 341A08E0010; Tue, 23 Jul 2019 14:06:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F1B48E0002; Tue, 23 Jul 2019 14:06:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 192C08E0010; Tue, 23 Jul 2019 14:06:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D6BA88E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:06:15 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g21so26691533pfb.13
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 11:06:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=UcpYwgDngCnf4WL9gjTBN9UDviUZ6DZ0/PA93bwvVd0=;
        b=bL5jmTmx3Dg9gWZXsFxMy1RyTPlPBPpM4dM9F9ELqcHhMni7xCDadwe41w+aBeWrTd
         M5NnsSKxKI9dhfkItPWedbd9/rEJmeFlqyqJFw8XBueJ7jNTm7vYycOp5iK5wver7adj
         Q/KNNn7tLbUQBdfawDz2O2yQSynKS50MSZZ7os5WrnyThigJDAxzOSKF/XddEgv0mx6d
         bawiDpZ/jqZ8sixS7CgaUoY9cQomcyJfksn5AKoGTcB+BFqB+OEwK7k7ldGE7xrr2WDm
         ekhPGfPfb4CVKtqNH3+qIKVTiRzIW/Y5gaEipVLgX0Z4wkLU73yugP5FnJTe1ohd6t5X
         fgRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVzhQnY0Qz/8Yfsqf0IjlYyn5MOOt2iFZvJlH516u85d/N3Bpgw
	djrerGtq8x0geBnxCZco/HhpzIPAjoehaQoqynPA/v1x1pJc7xmlBVrh9aK+A0B2sbXP+2TeNca
	UHAfFaDk0VQ1EYug951FN+W96TDj0BOKiQ89vIiwZCn+5mPL4q09oMgsiPGvpzFU/Sg==
X-Received: by 2002:a17:90b:8cd:: with SMTP id ds13mr79281441pjb.141.1563905175475;
        Tue, 23 Jul 2019 11:06:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzw5xy4GuwlsHLgkFAsLHBmnwOMWdLcNMJhWtuFFd7spBJLnJ08vUNVM0DIl6j7i9+uCqes
X-Received: by 2002:a17:90b:8cd:: with SMTP id ds13mr79281369pjb.141.1563905174670;
        Tue, 23 Jul 2019 11:06:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563905174; cv=none;
        d=google.com; s=arc-20160816;
        b=HGLSafVbbhhwJr8C0jEdTMv3Nb5v4SQ3tDgX6+gWeQpwFfm3O3fw30XMMGGmCu/Ij2
         1cll4minB8YHVZYD9+KUeGkUOP0F6lPZ88Olz/cKPsKgv7JZoSma2iU+g5R6PPX8Ersa
         lPf/9un9UljPNEnX6r6rfBp2X8sWBE4LJ6E7HYlX8fYznoaSLgrWA839J3KrBxkqH3mw
         h/eYIxRvSkeWdQ+VTyz/lL62N4nKNOxz2I7y9AbPAdbomE3JCVmb+jXOQyjAU788Ht3L
         FBlFnvIiaVM15TAzeBzdDidGTKBiM0ofungqamodEdMREZlI19XX+a+AkH1fjNrqr1Tb
         9oKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=UcpYwgDngCnf4WL9gjTBN9UDviUZ6DZ0/PA93bwvVd0=;
        b=Ivdlzt0cXSTEMcfmQrSrf53KT6zWKUd1BtUVjLVWhi1FgD/btiLAGUlSMDO6zOjdkn
         zOFUuLmeAzO040DDwtjQM7WtMbtGaP1vHZWkWL1CXPzFfyIJzNhiv1sJ5WI6Oyr52oxp
         Y0KYVmjPh3WHAHhm7L0M8MiuNZLSYblISARdqLTN8IVrnIBUR83HSasvBDlVOzndF1Dt
         F9N5+fqSr8PjgLG1Q3iGcVJInXZQ8UN6IPFZew1O9OwZ0VcWGh7NOKOcoVXhwjfd0aJ/
         n+o6bybbpUnTNRmC+r9cIyTW6fjD8hQcTzDNMH6O65qLtmWErDu9DhCmTd2xeva29hJK
         qEEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id m37si12614685pje.45.2019.07.23.11.06.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 11:06:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jul 2019 11:06:13 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,299,1559545200"; 
   d="scan'208";a="177367161"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 23 Jul 2019 11:06:13 -0700
Date: Tue, 23 Jul 2019 11:06:13 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	=?iso-8859-1?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@lst.de>,
	Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>, David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jens Axboe <axboe@kernel.dk>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <miklos@szeredi.hu>, Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>, netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 3/3] net/xdp: convert put_page() to put_user_page*()
Message-ID: <20190723180612.GB29729@iweiny-DESK2.sc.intel.com>
References: <20190722223415.13269-1-jhubbard@nvidia.com>
 <20190722223415.13269-4-jhubbard@nvidia.com>
 <20190723002534.GA10284@iweiny-DESK2.sc.intel.com>
 <a4e9b293-11f8-6b3c-cf4d-308e3b32df34@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a4e9b293-11f8-6b3c-cf4d-308e3b32df34@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 09:41:34PM -0700, John Hubbard wrote:
> On 7/22/19 5:25 PM, Ira Weiny wrote:
> > On Mon, Jul 22, 2019 at 03:34:15PM -0700, john.hubbard@gmail.com wrote:
> > > From: John Hubbard <jhubbard@nvidia.com>
> > > 
> > > For pages that were retained via get_user_pages*(), release those pages
> > > via the new put_user_page*() routines, instead of via put_page() or
> > > release_pages().
> > > 
> > > This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> > > ("mm: introduce put_user_page*(), placeholder versions").
> > > 
> > > Cc: Björn Töpel <bjorn.topel@intel.com>
> > > Cc: Magnus Karlsson <magnus.karlsson@intel.com>
> > > Cc: David S. Miller <davem@davemloft.net>
> > > Cc: netdev@vger.kernel.org
> > > Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> > > ---
> > >   net/xdp/xdp_umem.c | 9 +--------
> > >   1 file changed, 1 insertion(+), 8 deletions(-)
> > > 
> > > diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
> > > index 83de74ca729a..0325a17915de 100644
> > > --- a/net/xdp/xdp_umem.c
> > > +++ b/net/xdp/xdp_umem.c
> > > @@ -166,14 +166,7 @@ void xdp_umem_clear_dev(struct xdp_umem *umem)
> > >   static void xdp_umem_unpin_pages(struct xdp_umem *umem)
> > >   {
> > > -	unsigned int i;
> > > -
> > > -	for (i = 0; i < umem->npgs; i++) {
> > > -		struct page *page = umem->pgs[i];
> > > -
> > > -		set_page_dirty_lock(page);
> > > -		put_page(page);
> > > -	}
> > > +	put_user_pages_dirty_lock(umem->pgs, umem->npgs);
> > 
> > What is the difference between this and
> > 
> > __put_user_pages(umem->pgs, umem->npgs, PUP_FLAGS_DIRTY_LOCK);
> > 
> > ?
> 
> No difference.
> 
> > 
> > I'm a bit concerned with adding another form of the same interface.  We should
> > either have 1 call with flags (enum in this case) or multiple calls.  Given the
> > previous discussion lets move in the direction of having the enum but don't
> > introduce another caller of the "old" interface.
> 
> I disagree that this is a "problem". There is no maintenance pitfall here; there
> are merely two ways to call the put_user_page*() API. Both are correct, and
> neither one will get you into trouble.
> 
> Not only that, but there is ample precedent for this approach in other
> kernel APIs.
> 
> > 
> > So I think on this patch NAK from me.
> > 
> > I also don't like having a __* call in the exported interface but there is a
> > __get_user_pages_fast() call so I guess there is precedent.  :-/
> > 
> 
> I thought about this carefully, and looked at other APIs. And I noticed that
> things like __get_user_pages*() are how it's often done:
> 
> * The leading underscores are often used for the more elaborate form of the
> call (as oppposed to decorating the core function name with "_flags", for
> example).
> 
> * There are often calls in which you can either call the simpler form, or the
> form with flags and additional options, and yes, you'll get the same result.
> 
> Obviously, this stuff is all subject to a certain amount of opinion, but I
> think I'm on really solid ground as far as precedent goes. So I'm pushing
> back on the NAK... :)

Fair enough...  However, we have discussed in the past how GUP can be a
confusing interface to use.

So I'd like to see it be more directed.  Only using the __put_user_pages()
version allows us to ID callers easier through a grep of PUP_FLAGS_DIRTY_LOCK
in addition to directing users to use that interface rather than having to read
the GUP code to figure out that the 2 calls above are equal.  It is not a huge
deal but...

Ira

> 
> thanks,
> -- 
> John Hubbard
> NVIDIA
> 


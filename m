Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE71CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 15:36:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7B522083D
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 15:36:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7B522083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 428B06B0003; Tue, 19 Mar 2019 11:36:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D84C6B0006; Tue, 19 Mar 2019 11:36:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CABB6B0007; Tue, 19 Mar 2019 11:36:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4C5F6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 11:36:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t13so8419678edw.13
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 08:36:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4HclYlxqZFClIDBSlq0fgR2k//e8VBAx9WbdxQZLJoM=;
        b=HOMEIyoFBwSOKyYFcXS3cwqGfVDKVWEaKKDpRZcMgu8/DqZ8j18pdbXAyyPyhNpaMY
         oq2ltTszZsh4xmr5iv737wVoHzRK7/yTIEKH/dIlJFw3oHSz6x+77QPR1+EvOisFPES9
         dMVljmYq+D0ft78BlsztGqB1CLYoMH13tzQzXpRPN+1lZixH86AByhSCoZbfOWEZ8Udt
         oD2+y+kxIcKrMp5Km5r3CUIbodI3E+NQIi4JrOUraZokraRoG/8XBs/XAbSeMBWUm+VK
         1nok4e8pUpHQ+TJ9SoPy5cR8D2gyDrarD4kokHHnSHhiulWVtjcUnh38dMB3xE40GUHP
         aBaw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUUhcWI1T+tAV/UjzFr5mheL72Cm7IFUt87hzeMwTYQ+OokRe76
	KvsWFQncG+JKmbzkAncZjVEYwvw2HSKeV6dENY8uJTbJpixVYqGmWugDVay4/NCo8gDOceirlWb
	RZEQcNOW5+637pZwtqPt2vGpYvJkEKJwNd7RP8rtIyLxXOH9Zs3YQpIGaz8r8vEGehA==
X-Received: by 2002:a17:906:1dd0:: with SMTP id v16mr14614860ejh.204.1553009808322;
        Tue, 19 Mar 2019 08:36:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytHzDIAV8gZ+bHT8+PlAXdtjU/h7DgaKFi/ysgsvqKtraQSQ/rvBJx2TLg3Tq5kwn5yvHX
X-Received: by 2002:a17:906:1dd0:: with SMTP id v16mr14614806ejh.204.1553009807121;
        Tue, 19 Mar 2019 08:36:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553009807; cv=none;
        d=google.com; s=arc-20160816;
        b=IgeUyB/DY5LOA56+DtHwbtu5f+TrDe+SVsfddA0MGWR3pdrEsFBaQ48pwOjsHRbyxU
         3lwdtBEbSM6lS7Imq3fzN/FTX3edOuAhuv09XXYaO27AiXQWwOBiBjGRL1K3xTd25j+d
         fWE3Fwb9GzMG8mmdGvvXa1sWUgh1RREcjxj24IqKFSECWyw5FhBVFL9Q5v8HtbAI/NcT
         wRdCrGHa0IT8ykvyZXWLoYx2OVJ/lq8nmB85OJIwt4HriuvxPQ7MKSEAVYxX9O/cl3zl
         WtKRdJEZXDpgFcUIqM5cwJio9tA5RA1AyMIpvfTy5DykxelMW+R+k5Q0S8WHXlSPzgL6
         shtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4HclYlxqZFClIDBSlq0fgR2k//e8VBAx9WbdxQZLJoM=;
        b=KFMdvYasiVJo++Y/K6eNtqMTBopnUB59Qe+dhRKXWHGPiOTMIrhJG6RBLeVX/fZWsR
         wPruDwnNqFONNxAD96xhFK2WF3f1/v8W+38TfPzkZG/BjmwwAqIRyUiCI29AFwUYFiku
         1z9h+Ay0HuV4vDv7xEQ0vpEQVBuwBtu6QCm2p+AbOMU8bvyG7xgrBxtz9CAD9jxiEJko
         iPBpIl5rlUKH6YlSqq82sjhPyQlcsJ87VSbi1VQx/iDQhf6yjR3Zd7gCyQG+J4IEsO2A
         40rxdmx22MlkL7UK0im6vdug4xtyJ2y4rFLDzuey/FDbV1zcSwK+vsEfFf69pJYyNwTX
         P1mw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si1184805ejb.221.2019.03.19.08.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 08:36:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 884FDAEA1;
	Tue, 19 Mar 2019 15:36:45 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 9ED241E429B; Tue, 19 Mar 2019 16:36:44 +0100 (CET)
Date: Tue, 19 Mar 2019 16:36:44 +0100
From: Jan Kara <jack@suse.cz>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jerome Glisse <jglisse@redhat.com>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190319153644.GB26099@quack2.suse.cz>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
 <20190319141416.GA3879@redhat.com>
 <20190319142918.6a5vom55aeojapjp@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319142918.6a5vom55aeojapjp@kshutemo-mobl1>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 19-03-19 17:29:18, Kirill A. Shutemov wrote:
> On Tue, Mar 19, 2019 at 10:14:16AM -0400, Jerome Glisse wrote:
> > On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
> > > On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
> > > > On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
> > > > > From: John Hubbard <jhubbard@nvidia.com>
> > > 
> > > [...]
> > > 
> > > > > diff --git a/mm/gup.c b/mm/gup.c
> > > > > index f84e22685aaa..37085b8163b1 100644
> > > > > --- a/mm/gup.c
> > > > > +++ b/mm/gup.c
> > > > > @@ -28,6 +28,88 @@ struct follow_page_context {
> > > > >  	unsigned int page_mask;
> > > > >  };
> > > > >  
> > > > > +typedef int (*set_dirty_func_t)(struct page *page);
> > > > > +
> > > > > +static void __put_user_pages_dirty(struct page **pages,
> > > > > +				   unsigned long npages,
> > > > > +				   set_dirty_func_t sdf)
> > > > > +{
> > > > > +	unsigned long index;
> > > > > +
> > > > > +	for (index = 0; index < npages; index++) {
> > > > > +		struct page *page = compound_head(pages[index]);
> > > > > +
> > > > > +		if (!PageDirty(page))
> > > > > +			sdf(page);
> > > > 
> > > > How is this safe? What prevents the page to be cleared under you?
> > > > 
> > > > If it's safe to race clear_page_dirty*() it has to be stated explicitly
> > > > with a reason why. It's not very clear to me as it is.
> > > 
> > > The PageDirty() optimization above is fine to race with clear the
> > > page flag as it means it is racing after a page_mkclean() and the
> > > GUP user is done with the page so page is about to be write back
> > > ie if (!PageDirty(page)) see the page as dirty and skip the sdf()
> > > call while a split second after TestClearPageDirty() happens then
> > > it means the racing clear is about to write back the page so all
> > > is fine (the page was dirty and it is being clear for write back).
> > > 
> > > If it does call the sdf() while racing with write back then we
> > > just redirtied the page just like clear_page_dirty_for_io() would
> > > do if page_mkclean() failed so nothing harmful will come of that
> > > neither. Page stays dirty despite write back it just means that
> > > the page might be write back twice in a row.
> > 
> > Forgot to mention one thing, we had a discussion with Andrea and Jan
> > about set_page_dirty() and Andrea had the good idea of maybe doing
> > the set_page_dirty() at GUP time (when GUP with write) not when the
> > GUP user calls put_page(). We can do that by setting the dirty bit
> > in the pte for instance. They are few bonus of doing things that way:
> >     - amortize the cost of calling set_page_dirty() (ie one call for
> >       GUP and page_mkclean()
> >     - it is always safe to do so at GUP time (ie the pte has write
> >       permission and thus the page is in correct state)
> >     - safe from truncate race
> >     - no need to ever lock the page
> > 
> > Extra bonus from my point of view, it simplify thing for my generic
> > page protection patchset (KSM for file back page).
> > 
> > So maybe we should explore that ? It would also be a lot less code.
> 
> Yes, please. It sounds more sensible to me to dirty the page on get, not
> on put.

I fully agree this is a desirable final state of affairs. And with changes
to how we treat pinned pages during writeback there won't have to be any
explicit dirtying at all in the end because the page is guaranteed to be
dirty after a write page fault and pin would make sure it stays dirty until
unpinned. However initially I want the helpers to be as close to code they
are replacing as possible. Because it will be hard to catch all the bugs
due to driver conversions even in that situation. So I still think that
these helpers as they are a good first step. Then we need to convert
GUP users to use them and then it is much easier to modify the behavior
since it is no longer opencoded in two hudred or how many places...

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR


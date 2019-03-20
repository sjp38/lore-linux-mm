Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 293E7C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:08:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D97E02085A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:08:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D97E02085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E4196B0003; Tue, 19 Mar 2019 20:08:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8936C6B0006; Tue, 19 Mar 2019 20:08:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75B896B0007; Tue, 19 Mar 2019 20:08:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD136B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:08:48 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c67so7977885qkg.5
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:08:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=WMpCBpeH0d/Xh7t5crLXCf18YVcTLjEHnKh9hMzlLeI=;
        b=P1FbJWNArJgT4RXoIBWmKOmsN+KfCyWbx7RxY+Uf7+wIZFwiqsUqtCubE7a1HSzQRj
         ptmcvXs58E9H2sjh5bcIA+AHjCh5+d1iYTFJd4e3ETMQ80OIM/xMTcFJg/WmO2/Ux/DM
         nWRALEk+ThRADM2XIHc/gLFjpIgQoNTYrSfRLUIj9dmWpSnfEOO5qTEH2zmkbpxknUX7
         SXMKCvQBh3uY6FOtJ5DCvrbCoh57OznNSfNh1A+aP0H5P3Uqtzn2D9ky2Rg4cFzzEgfr
         XCwbRN0dTDDrm+aLV3s9O3Ww+HuFQM+O/Rh5MWis8O4VoUZTR9hvskE0ksg6beLXTcCy
         C6MA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVGN6BXyEWsZGED7+lA1h2rc2Bk05fTKCAXvvnukLMYt97o7Tak
	KrnsczI9cFNiuP+YkfJrwCf5XWbx/7cRmPfUCExk8hDLcOfOpEowhRlH0Fkwg0D2YK6DYKvEjcg
	lk4lOTF2V5uX2FuB6TjbZL/puja9hlJ9yyuo8XMvY+Gmf3T9PTcUuy68ggueffVI48w==
X-Received: by 2002:a05:620a:13e2:: with SMTP id h2mr4171951qkl.217.1553040528065;
        Tue, 19 Mar 2019 17:08:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2iyxX+WluVHeYhQqpiXRJZKdoURAjfqKzqRDIGOy+6ejHetT4wRnD2m/z0XwAIeO0YW6A
X-Received: by 2002:a05:620a:13e2:: with SMTP id h2mr4171920qkl.217.1553040527160;
        Tue, 19 Mar 2019 17:08:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553040527; cv=none;
        d=google.com; s=arc-20160816;
        b=VirJhb28t45wsT1Nf0wngi0P+suR4Uh8GCd/CzSci8F1lGVO/+PL8EVJUQp2Gskcoo
         PhFrIniEeIjDzV/QJMI/WTBkl0UgkHjY2z7s1CV5jUBA0dQMIuw0FkYwuNFoMHUJVs2t
         pOdptGI5/rN7ESv1mwHZIez4CGyktY3BbF+BOyEeo6x7ekFShKjZwK15+Ob7huhYLgOR
         3TUis8VC/lBZS57HAdHpdMgBT9AYA1pAWoHjRQFBi7PgIYgnybKYqO9ib+9zceQMu1Tl
         eoHJey7WBS9PgUjrp2ag1aUtHS/m9CHgtTjq71B79rMcXxsuM0IOVs4U2yt4y0lKzpPd
         7i/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=WMpCBpeH0d/Xh7t5crLXCf18YVcTLjEHnKh9hMzlLeI=;
        b=HAiIYrBEllUBTBprXFD6X/bgCKAjzb19GClVaE1xABFxkTA1dK6SYEB8npHn2mJYDw
         uiB9nnrPm4jH5kVvanuPJlLq0uup2KI8gVkNMo2gC+g51xaPq9BHEdylZbBorsqlBhy+
         At5oACQMOzK2xZX1XJRWckBk26x1u2ZAhfNL1gqE2Fjcg7hl6G3qakBnTL3clxKwmVOh
         TIDNTlxIUJaZAGC5yUaZrJ+PdmGSImpnEPkqyLKGWb3AGuxXOc1GYWdHuS0xdrLP+g0M
         gpCoeWXewvE3dvL8TVHQNUC2+XeQL92tsAGo4f2ct76kzqyJ7ABjdY3eR5qdRxqN3gO3
         0t8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y35si116805qvc.159.2019.03.19.17.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 17:08:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B023E2D7E0;
	Wed, 20 Mar 2019 00:08:45 +0000 (UTC)
Received: from redhat.com (ovpn-120-246.rdu2.redhat.com [10.10.120.246])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7CA591973C;
	Wed, 20 Mar 2019 00:08:41 +0000 (UTC)
Date: Tue, 19 Mar 2019 20:08:39 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
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
Message-ID: <20190320000838.GA6364@redhat.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
 <20190319141416.GA3879@redhat.com>
 <20190319212346.GA26298@dastard>
 <20190319220654.GC3096@redhat.com>
 <20190319235752.GB26298@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190319235752.GB26298@dastard>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 20 Mar 2019 00:08:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 10:57:52AM +1100, Dave Chinner wrote:
> On Tue, Mar 19, 2019 at 06:06:55PM -0400, Jerome Glisse wrote:
> > On Wed, Mar 20, 2019 at 08:23:46AM +1100, Dave Chinner wrote:
> > > On Tue, Mar 19, 2019 at 10:14:16AM -0400, Jerome Glisse wrote:
> > > > On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
> > > > > On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
> > > > > > On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
> > > > > > > From: John Hubbard <jhubbard@nvidia.com>
> > > > > 
> > > > > [...]
> > > > > 
> > > > > > > diff --git a/mm/gup.c b/mm/gup.c
> > > > > > > index f84e22685aaa..37085b8163b1 100644
> > > > > > > --- a/mm/gup.c
> > > > > > > +++ b/mm/gup.c
> > > > > > > @@ -28,6 +28,88 @@ struct follow_page_context {
> > > > > > >  	unsigned int page_mask;
> > > > > > >  };
> > > > > > >  
> > > > > > > +typedef int (*set_dirty_func_t)(struct page *page);
> > > > > > > +
> > > > > > > +static void __put_user_pages_dirty(struct page **pages,
> > > > > > > +				   unsigned long npages,
> > > > > > > +				   set_dirty_func_t sdf)
> > > > > > > +{
> > > > > > > +	unsigned long index;
> > > > > > > +
> > > > > > > +	for (index = 0; index < npages; index++) {
> > > > > > > +		struct page *page = compound_head(pages[index]);
> > > > > > > +
> > > > > > > +		if (!PageDirty(page))
> > > > > > > +			sdf(page);
> > > > > > 
> > > > > > How is this safe? What prevents the page to be cleared under you?
> > > > > > 
> > > > > > If it's safe to race clear_page_dirty*() it has to be stated explicitly
> > > > > > with a reason why. It's not very clear to me as it is.
> > > > > 
> > > > > The PageDirty() optimization above is fine to race with clear the
> > > > > page flag as it means it is racing after a page_mkclean() and the
> > > > > GUP user is done with the page so page is about to be write back
> > > > > ie if (!PageDirty(page)) see the page as dirty and skip the sdf()
> > > > > call while a split second after TestClearPageDirty() happens then
> > > > > it means the racing clear is about to write back the page so all
> > > > > is fine (the page was dirty and it is being clear for write back).
> > > > > 
> > > > > If it does call the sdf() while racing with write back then we
> > > > > just redirtied the page just like clear_page_dirty_for_io() would
> > > > > do if page_mkclean() failed so nothing harmful will come of that
> > > > > neither. Page stays dirty despite write back it just means that
> > > > > the page might be write back twice in a row.
> > > > 
> > > > Forgot to mention one thing, we had a discussion with Andrea and Jan
> > > > about set_page_dirty() and Andrea had the good idea of maybe doing
> > > > the set_page_dirty() at GUP time (when GUP with write) not when the
> > > > GUP user calls put_page(). We can do that by setting the dirty bit
> > > > in the pte for instance. They are few bonus of doing things that way:
> > > >     - amortize the cost of calling set_page_dirty() (ie one call for
> > > >       GUP and page_mkclean()
> > > >     - it is always safe to do so at GUP time (ie the pte has write
> > > >       permission and thus the page is in correct state)
> > > >     - safe from truncate race
> > > >     - no need to ever lock the page
> > > 
> > > I seem to have missed this conversation, so please excuse me for
> > 
> > The set_page_dirty() at GUP was in a private discussion (it started
> > on another topic and drifted away to set_page_dirty()).
> > 
> > > asking a stupid question: if it's a file backed page, what prevents
> > > background writeback from cleaning the dirty page ~30s into a long
> > > term pin? i.e. I don't see anything in this proposal that prevents
> > > the page from being cleaned by writeback and putting us straight
> > > back into the situation where a long term RDMA is writing to a clean
> > > page....
> > 
> > So this patchset does not solve this issue.
> 
> OK, so it just kicks the can further down the road.
> 
> >     [3..N] decide what to do for GUPed page, so far the plans seems
> >          to be to keep the page always dirty and never allow page
> >          write back to restore the page in a clean state. This does
> >          disable thing like COW and other fs feature but at least
> >          it seems to be the best thing we can do.
> 
> So the plan for GUP vs writeback so far is "break fsync()"? :)
> 
> We might need to work on that a bit more...

Sorry forgot to say that we still do write back using a bounce page
so that at least we write something to disk that is just a snapshot
of the GUPed page everytime writeback kicks in (so either through
radix tree dirty page write back or fsync or any other sync events).
So many little details that i forgot the big chunk :)

Cheers,
Jérôme


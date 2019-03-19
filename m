Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E568C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:07:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A55F217F4
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:07:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A55F217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD9E16B0005; Tue, 19 Mar 2019 18:07:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B61DC6B0006; Tue, 19 Mar 2019 18:07:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A28D66B0007; Tue, 19 Mar 2019 18:07:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA2C6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:07:03 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id b1so361067qtk.11
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:07:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=JAiG8IsEZ5PS3MbSemDttG7DQdxkbibR+27tfOEovMc=;
        b=nHC9uR7hzNzCBdZilGXjDozNSCI/tnyajVjd3W36agMBL4OrJwRKYaeLxKgcBQ/7WV
         X4jPS91Bpiyza0dM075uHhRo7g4OT2OaUzWQMQSc0QVInq9LHpDla+W+ise08pkhXLwF
         JlJbyz6Qu4ON56GTsqSnjvEaIqpranBaLZvfX67HPO8XgWdGOM6RXuJmboa/uzXR9Z5h
         a6NnAWfkaK72NfirdMBNz1TPy+49iH5lpU3yxbgufA4J2E98zUbD8CDLMYKFgQxe71iY
         kbb0yHio2UKt54hRnPUuTnYnbOO8z7SXrAdL4CfudKnO/jzidd5JuqwdFWwwZW+N27PB
         cHEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVVf51lZ7XLfmwdhxoM+s6lxYhxabCtALzgWF0RMoHCbxliYV/+
	/IzrvDCIaiNlyZtmOqK8NWhGePVisrqzGCZxlgayyDwRqWlK6Om8Zl+Ct8IxR3tVctcCiAZVuSm
	neg/yYO7jKaxOYRtV9rOlwNJfxO0MjKOoE/s2xqbH4Rn+3hWT3+ixNva13o73e09itA==
X-Received: by 2002:ac8:2598:: with SMTP id e24mr4146420qte.27.1553033223203;
        Tue, 19 Mar 2019 15:07:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkokuVu6d8uNJ19Ikcwjchkfb9vKIwhlKHCAq8tSMDEGEf1ZLcf8PAkKAiDUUbdCcB+AKg
X-Received: by 2002:ac8:2598:: with SMTP id e24mr4146350qte.27.1553033222212;
        Tue, 19 Mar 2019 15:07:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553033222; cv=none;
        d=google.com; s=arc-20160816;
        b=ga3aa7yovfCgag9dyN4WdoJCEK/H+wtPrTK3fLy5pKIffKxko7RTh1a37BPjEAZ28T
         UWz/dVydndXBP1YV5DO7CgSkizL9y6Ay98QYdQ/KCN1Knt9FO16oywqSJ8W0enFhzfss
         qs6w7IQqhBvbt6oiL+Av7CbOs0UaqLG669DPGWtmfeeuj50l+TTOK1T13ltjLxU9n/Gw
         rF+Pf4K+RD3ZC7NKwxLGxMvMB4jjjG2yj345t/YEZpS3vHth5Q1z2oC5faPyY4pCg9mR
         Lk/4UhDJFHPMoJPvFIitWihWHY/GCjal/0ywtSH6zWDgbYYe8r3SqC2YnLm3oIi5PgmI
         tkqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=JAiG8IsEZ5PS3MbSemDttG7DQdxkbibR+27tfOEovMc=;
        b=cLLXTyT0ep+SFEwc0LinAYECqgsjkYGHrIlBVo5cuokty8s/UR6GjYmYRLaWGEmCVe
         QwUDXXI1KRvjjKQzo4EG9u56fiid0SX1j+2lcBxSvCcJbZPOYOLDAf5L17k+VYiUmvsB
         5Ug4cLZcFR2yw2CaCk+rs01ZXPqFvFB+A8MyUUh6VhTQcxB2SHMCkg5KAizZ8AxJYnmv
         bwUxAa7vs8lfg/Yd0RscqiCddSLAqW+H9zrfxRpZCdnt8vzHo/R21nuCVD4zPqwiwIxz
         BdZXQPyaAfj7GUoeWdAv+u2Tx9StJi708Vds/yFjjh+KZc31tKgQNawNJ1lJxqaZXruZ
         JUGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q2si2728133qvf.2.2019.03.19.15.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 15:07:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F2D4589C3A;
	Tue, 19 Mar 2019 22:07:00 +0000 (UTC)
Received: from redhat.com (ovpn-120-246.rdu2.redhat.com [10.10.120.246])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5779917DF3;
	Tue, 19 Mar 2019 22:06:57 +0000 (UTC)
Date: Tue, 19 Mar 2019 18:06:55 -0400
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
Message-ID: <20190319220654.GC3096@redhat.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
 <20190319141416.GA3879@redhat.com>
 <20190319212346.GA26298@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190319212346.GA26298@dastard>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 19 Mar 2019 22:07:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 08:23:46AM +1100, Dave Chinner wrote:
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
> 
> I seem to have missed this conversation, so please excuse me for

The set_page_dirty() at GUP was in a private discussion (it started
on another topic and drifted away to set_page_dirty()).

> asking a stupid question: if it's a file backed page, what prevents
> background writeback from cleaning the dirty page ~30s into a long
> term pin? i.e. I don't see anything in this proposal that prevents
> the page from being cleaned by writeback and putting us straight
> back into the situation where a long term RDMA is writing to a clean
> page....

So this patchset does not solve this issue. The plan is multi-step
(with different patchset for each steps):
    [1] convert all places that do gup() and then put_page() to
        use gup_put_page() instead. This is what this present
        patchset is about.
    [2] use bias pin count so that we can identify GUPed page from
        non GUPed page. So instead of incrementing page refcount
        by 1 on GUP we increment it by GUP_BIAS and in gup_put_page()
        we decrement it by GUP_BIAS. This means that page with a
        refcount > GUP_BIAS can be considered as GUP (more on false
        positive below)
    [3..N] decide what to do for GUPed page, so far the plans seems
         to be to keep the page always dirty and never allow page
         write back to restore the page in a clean state. This does
         disable thing like COW and other fs feature but at least
         it seems to be the best thing we can do.

For race between clear_page_for_io() and GUP this was extensively
discuss and IIRC you were on that thread. Basicly we can only race
with page_mkclean() (as GUP can only succeed if there is a pte with
write permission) and page cleaning happens after page_mkclean() and
they are barrier between page_mkclean() and what's after. Hence we
will be able to see the page as GUPed before cleaning it without
any race.

For false positive i think we agreed that it is something we can
live with. It could only happen to page that are share more than
GUP_BIAS times, it should be rare enough and false positive means
you get the same treatement as a GUPed page.

Cheers,
Jérôme


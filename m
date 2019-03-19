Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26857C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:29:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDDE72085A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:29:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="dsShfLT5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDDE72085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EAC26B0003; Tue, 19 Mar 2019 10:29:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69B0F6B0006; Tue, 19 Mar 2019 10:29:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B21E6B0007; Tue, 19 Mar 2019 10:29:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1ACBE6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:29:25 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h15so23005598pfj.22
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 07:29:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9om5QJZsJKNhMP+qIVE/OgL0ptHNmMTB1Erc9MBg9Gs=;
        b=qJlTTjukvXP77Sc3zFNHbbSk3dQS9t7DjSmy0nKB43dueMFNIHG86HCQgMyCGE9JRm
         5wha5/reBhXM7PvdRo+LOJaeo1poRTK88epi2+ciUfc0KmWht50xRwh1u0KA4MjpK4ML
         90orE60tPWktyPc3/X2imF+Kb6nUaY0uC/AFxs+wU1duSqqVGdhK3XIJHbbNJHcYaHJx
         h1WFbmH2t0/lGUc4KLEHlpJlVIAs8oybTWeb9wJcI+bN2UR0M3Pl8S2DTTj/LBRcGULy
         aFmvxMLZ0frb3ieC3YzRzRdxTDEcK+q+xPAZFCMBlwA30Jeffz0O+hssaFtkoA9r8yY3
         JsRQ==
X-Gm-Message-State: APjAAAUlpiPlGN7r9tdvCgPxCFCrSLXfOLyT/nvqlUXT8Ks2sY1+qZT9
	SMHugpWGYKbqw1hGKRE+lJIbz2B40YUpcRd1D8OqxWSmjA7HLBiDEe2tUVhEIxR/tmEAsf47SCX
	fVmGRUMetSfGXtltCFHaWxyouekWPsqrOB/xDnj57V3bZ4cWMDoMqeN5oL86+FdtaWA==
X-Received: by 2002:a63:b52:: with SMTP id a18mr2143223pgl.393.1553005764735;
        Tue, 19 Mar 2019 07:29:24 -0700 (PDT)
X-Received: by 2002:a63:b52:: with SMTP id a18mr2143151pgl.393.1553005763665;
        Tue, 19 Mar 2019 07:29:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553005763; cv=none;
        d=google.com; s=arc-20160816;
        b=UxZd0aeWxSqLPSpk/a6UUmpUEyr/Z0iLpvCVxoHkqtiCN9SqxNudUVBCm3fytBGlQO
         d4nrqNuLgBEAWfCzb3MRmKJxXiqHMygroJq2+f/vhvmSXJu4o4j1E0dcr4SJ2Pq0u7YW
         kxkWjYBm0zCOuCs3t399ZtB5yO/u+Np6gHUF0ggxb+usGz9gQ0u4mRlI9Untt6SwIJOZ
         Pj5Sifwr13h7JagiSeXgUXg+GvHPECI2/vdC0qjMlVPVShA7e7tfnXW4fx4s9uH+gZml
         ZoOVEPi8+XfAev0zH8HlvuIYSc3+cge+tTNP/7j95aNORaQFILRasE3Jru57WjWvHwgN
         iqYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9om5QJZsJKNhMP+qIVE/OgL0ptHNmMTB1Erc9MBg9Gs=;
        b=fpuZGHfcyPWgcW6bcM5nqxMWQ1norDSLKKXshKqCr8dFAYeu2zhu524TRdZtNW2c2X
         tGRd8trSNNnPQ0uqLL8tQRB/aA27AVNjgzvAZw6MyDJnJwQjI9nCGGddFtNyxg+evykm
         ACZSet9OiEu68XdFSdXuOl1LCRGbqXfWztBH2nTKNorjBNQPGjZTHXYNoaO0SnCDKyrW
         qfNCKpTtifvaj95HEZ8Y47YND0tN/kUPr1rvHaG63+zSKrAw60WkTyXuYlYRPTld92sM
         iQMEspc9Ld0fXctq0zZHzWHhdu/mw0V23RrB8e//F0tXwjEkJCSRsVYh1jK+4OkN44OY
         MkeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=dsShfLT5;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s18sor20129430plq.22.2019.03.19.07.29.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 07:29:23 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=dsShfLT5;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9om5QJZsJKNhMP+qIVE/OgL0ptHNmMTB1Erc9MBg9Gs=;
        b=dsShfLT5ONbIyV9P7eRs1l/EGJTZUK1Wx/pyJu1mXTBZUOiNW01pRqIGgSS745AQT9
         mslmk0ARTFjsgy9s2CboNPlVYLeO8EL9QcMNAYsevKih8GhtHOqnDwQyZAgaaI/OF8Aw
         CQoy1lJPmeNhmBUaubMRQrbkbch8eH0QjMBkegJ1VtEM6VOo14XwXOU5VvL0cA67RfTb
         TpKzZQPAZUyV5ffp9ClckR4KTBlT1H8qGxf3pZas30ng/5md12Hpwpm0qNIUcMMwyTWF
         MyOIOsgcpeVCIH5xM5xiq6DkkgSsvCObtTlelL2yD6TbavY8uMXoWVLs8ZCOXOZMiSnz
         JWwA==
X-Google-Smtp-Source: APXvYqwVlnkNNeWECRvv0LgzsnPJkLdTZl0ZYqkVgXeRvM69+DJG+xllmrD9YvrSDgTnYy8wdGHdNw==
X-Received: by 2002:a17:902:168:: with SMTP id 95mr2414703plb.212.1553005763360;
        Tue, 19 Mar 2019 07:29:23 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id b7sm28545812pff.136.2019.03.19.07.29.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 07:29:22 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id C09CC3011DA; Tue, 19 Mar 2019 17:29:18 +0300 (+03)
Date: Tue, 19 Mar 2019 17:29:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Jerome Glisse <jglisse@redhat.com>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>,
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
Message-ID: <20190319142918.6a5vom55aeojapjp@kshutemo-mobl1>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
 <20190319141416.GA3879@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319141416.GA3879@redhat.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 10:14:16AM -0400, Jerome Glisse wrote:
> On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
> > On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
> > > On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
> > > > From: John Hubbard <jhubbard@nvidia.com>
> > 
> > [...]
> > 
> > > > diff --git a/mm/gup.c b/mm/gup.c
> > > > index f84e22685aaa..37085b8163b1 100644
> > > > --- a/mm/gup.c
> > > > +++ b/mm/gup.c
> > > > @@ -28,6 +28,88 @@ struct follow_page_context {
> > > >  	unsigned int page_mask;
> > > >  };
> > > >  
> > > > +typedef int (*set_dirty_func_t)(struct page *page);
> > > > +
> > > > +static void __put_user_pages_dirty(struct page **pages,
> > > > +				   unsigned long npages,
> > > > +				   set_dirty_func_t sdf)
> > > > +{
> > > > +	unsigned long index;
> > > > +
> > > > +	for (index = 0; index < npages; index++) {
> > > > +		struct page *page = compound_head(pages[index]);
> > > > +
> > > > +		if (!PageDirty(page))
> > > > +			sdf(page);
> > > 
> > > How is this safe? What prevents the page to be cleared under you?
> > > 
> > > If it's safe to race clear_page_dirty*() it has to be stated explicitly
> > > with a reason why. It's not very clear to me as it is.
> > 
> > The PageDirty() optimization above is fine to race with clear the
> > page flag as it means it is racing after a page_mkclean() and the
> > GUP user is done with the page so page is about to be write back
> > ie if (!PageDirty(page)) see the page as dirty and skip the sdf()
> > call while a split second after TestClearPageDirty() happens then
> > it means the racing clear is about to write back the page so all
> > is fine (the page was dirty and it is being clear for write back).
> > 
> > If it does call the sdf() while racing with write back then we
> > just redirtied the page just like clear_page_dirty_for_io() would
> > do if page_mkclean() failed so nothing harmful will come of that
> > neither. Page stays dirty despite write back it just means that
> > the page might be write back twice in a row.
> 
> Forgot to mention one thing, we had a discussion with Andrea and Jan
> about set_page_dirty() and Andrea had the good idea of maybe doing
> the set_page_dirty() at GUP time (when GUP with write) not when the
> GUP user calls put_page(). We can do that by setting the dirty bit
> in the pte for instance. They are few bonus of doing things that way:
>     - amortize the cost of calling set_page_dirty() (ie one call for
>       GUP and page_mkclean()
>     - it is always safe to do so at GUP time (ie the pte has write
>       permission and thus the page is in correct state)
>     - safe from truncate race
>     - no need to ever lock the page
> 
> Extra bonus from my point of view, it simplify thing for my generic
> page protection patchset (KSM for file back page).
> 
> So maybe we should explore that ? It would also be a lot less code.

Yes, please. It sounds more sensible to me to dirty the page on get, not
on put.

-- 
 Kirill A. Shutemov


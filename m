Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB436C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 13:58:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62C46214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 13:58:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62C46214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0ECEE6B0003; Fri,  9 Aug 2019 09:58:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09E7B6B0006; Fri,  9 Aug 2019 09:58:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECE8A6B0007; Fri,  9 Aug 2019 09:58:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1CA6B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 09:58:16 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m30so1007630eda.11
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 06:58:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/qUJhYm2MhNMXvXobP3yuKVscY8LCFIljXVP9AOHw5w=;
        b=Exy6F6Lx2xCmHomonTFf6LMgDSU8ZibGHS93HusPTPRwgaAEFLM2UCXwJzcni1yzTv
         dSXpP1DhuXBGyy7oUkrVROuNZIZSuuKDW59Jj109H0xzzlhudyre758aQfhaCJAvH0ee
         rseGYL2CQOzov0BV0MmLBBWaRBbZwXC6dC7jZRPu9RkqtYQ+qDged/byWuxJNcaLQBES
         aQ6+o+gmO1uoHJv7YFm/BraIMFlQcv0VdNBp1B/qqlb/NK2xwCOgi+lkZcoKo50dr5w6
         JDicG7bD7eKDAU7YgkLeF440FdeHEtcWHmTfxXd3QCGX8L7NUBz3ftqncRiarR0P9saX
         N6Ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAWzUtCZVf/5kzrMFxVIDOnGpdP6EPNzzha1Wkq1QOvRzblIBIkt
	5vhnP5bEMUn3xj8hyJCj5IpUudDuBJKj2UNO3pT8q1RZFdbnXuUVCyD0xfZjbcum+lvwgDDJ5tE
	HIWan18ZvIyzUfHwYpodJf93G+60tZOYzmFS0jkRItBTjVBrLepY7fBITc4k1T3xU4Q==
X-Received: by 2002:a50:a784:: with SMTP id i4mr21772732edc.3.1565359096146;
        Fri, 09 Aug 2019 06:58:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyO2L85P9VCSwZtJM6yWlmPbTsQOFvlrCr4kD1Y2iV47C2VNl6xM8IYroZj6WD6mzDB66Qc
X-Received: by 2002:a50:a784:: with SMTP id i4mr21772655edc.3.1565359095389;
        Fri, 09 Aug 2019 06:58:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565359095; cv=none;
        d=google.com; s=arc-20160816;
        b=h8FGf96vDGyjEp3K8CEyGojirEDdpTfdx2Wt+EizlsTDoArfeSPoNxpd16w+fAxCGt
         TunD6AILCgGuk669ty69I8zrGJVWgY5a3wPCBl8WsAftmX/9/ynhDJUxDsxSOkpINc8Z
         Dbhl4Mpsm2LBONXYHtlpSSwFeVIUcSjWb8E1eFwQXS8OLUiN79Z6v9lVUECkNrXNj27J
         TGiAgo7SA+ry+AIPJUbWg6sL7QWecldMYfarG/f4R2p9Ht38rJsB1gwm220gkjPAmbaf
         hvkaBxRW+cOUDPNmRHTIMfla/3ElY+SKgDluNaxEtM+E+sOgjPf4l3/gAlOpGSynD/h3
         WJmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/qUJhYm2MhNMXvXobP3yuKVscY8LCFIljXVP9AOHw5w=;
        b=K1l817cx3+X6On0KEkqaPts6rY3isYXmuDbY61JtflfgKLqXDkZMsMwcHq7PVXNrgO
         2xczlN0hJ2WdWYrCL5sl3KYik6VqSjP6hvlt9Or6vItwbgn5gDXCxH4PpPDKYx/mQsI+
         +reDxy5asT1w4KTzsWVxnO0oRqUhxmHCmrPJCbw0wrcuewIbM0E/flD/+npaMGe4d1/A
         QvpLFEfRZTP7Lb/izMIBOn2K8etbHi5vE+6j8+FqEGGAfxHX6RBG36AnrooqqNNAsKBj
         z49nISZZQdOLg+ulYuAtR1g3PjF6lzzuqiH11bEsceNMbd5L4wIMmmKbHVB2qOPl1QOc
         sdDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k57si26066783edd.28.2019.08.09.06.58.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 06:58:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C3118ACC2;
	Fri,  9 Aug 2019 13:58:14 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id E87631E46DD; Fri,  9 Aug 2019 15:58:13 +0200 (CEST)
Date: Fri, 9 Aug 2019 15:58:13 +0200
From: Jan Kara <jack@suse.cz>
To: Michal Hocko <mhocko@kernel.org>
Cc: John Hubbard <jhubbard@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Dan Williams <dan.j.williams@intel.com>,
	Daniel Black <daniel@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
Message-ID: <20190809135813.GF17568@quack2.suse.cz>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
 <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
 <20190808062155.GF11812@dhcp22.suse.cz>
 <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
 <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
 <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
 <420a5039-a79c-3872-38ea-807cedca3b8a@suse.cz>
 <20190809082307.GL18351@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809082307.GL18351@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 09-08-19 10:23:07, Michal Hocko wrote:
> On Fri 09-08-19 10:12:48, Vlastimil Babka wrote:
> > On 8/9/19 12:59 AM, John Hubbard wrote:
> > >>> That's true. However, I'm not sure munlocking is where the
> > >>> put_user_page() machinery is intended to be used anyway? These are
> > >>> short-term pins for struct page manipulation, not e.g. dirtying of page
> > >>> contents. Reading commit fc1d8e7cca2d I don't think this case falls
> > >>> within the reasoning there. Perhaps not all GUP users should be
> > >>> converted to the planned separate GUP tracking, and instead we should
> > >>> have a GUP/follow_page_mask() variant that keeps using get_page/put_page?
> > >>>  
> > >>
> > >> Interesting. So far, the approach has been to get all the gup callers to
> > >> release via put_user_page(), but if we add in Jan's and Ira's vaddr_pin_pages()
> > >> wrapper, then maybe we could leave some sites unconverted.
> > >>
> > >> However, in order to do so, we would have to change things so that we have
> > >> one set of APIs (gup) that do *not* increment a pin count, and another set
> > >> (vaddr_pin_pages) that do. 
> > >>
> > >> Is that where we want to go...?
> > >>
> > 
> > We already have a FOLL_LONGTERM flag, isn't that somehow related? And if
> > it's not exactly the same thing, perhaps a new gup flag to distinguish
> > which kind of pinning to use?
> 
> Agreed. This is a shiny example how forcing all existing gup users into
> the new scheme is subotimal at best. Not the mention the overal
> fragility mention elsewhere. I dislike the conversion even more now.
> 
> Sorry if this was already discussed already but why the new pinning is
> not bound to FOLL_LONGTERM (ideally hidden by an interface so that users
> do not have to care about the flag) only?

The new tracking cannot be bound to FOLL_LONGTERM. Anything that gets page
reference and then touches page data (e.g. direct IO) needs the new kind of
tracking so that filesystem knows someone is messing with the page data.
So what John is trying to address is a different (although related) problem
to someone pinning a page for a long time.

In principle, I'm not strongly opposed to a new FOLL flag to determine
whether a pin or an ordinary page reference will be acquired at least as an
internal implementation detail inside mm/gup.c. But I would really like to
discourage new GUP users taking just page reference as the most clueless
users (drivers) usually need a pin in the sense John implements. So in
terms of API I'd strongly prefer to deprecate GUP as an API, provide
vaddr_pin_pages() for drivers to get their buffer pages pinned and then for
those few users who really know what they are doing (and who are not
interested in page contents) we can have APIs like follow_page() to get a
page reference from a virtual address.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR


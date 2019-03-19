Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18BEDC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 20:45:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C93C72177E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 20:45:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C93C72177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E2CC6B0007; Tue, 19 Mar 2019 16:45:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 691ED6B0008; Tue, 19 Mar 2019 16:45:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 582146B000A; Tue, 19 Mar 2019 16:45:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 395DE6B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:45:22 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id y64so11138237qka.3
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 13:45:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=wrMre4ACpSfF2bgXwKmUw0SXnW6Ff5oF8GzytSeHbSI=;
        b=BGk3w7vknpIDZPRgdC8eM0ZLKQLOHkrzx5+sZMb2uwERgdrDokFoG/WBV1uGEMJO9u
         CAyjJogxMZ1czB6cRHCDzPhJsdXU+iTHc3FOmc27jwPiDs8XlP/RBIOEF96Ci05h0QjL
         8v8QuNQcee5BZeai2MV40PdyrBu7jbkaMCppp6WrKQOD6isyy9vEC7U0qI+5D3Jc78JA
         aM1RqjqScYRSMfpl/8XJ0b8Nss2p7Ni7I5+mKRaIgLFnN7kr6Wk8KwlD3yIan9C94Ss8
         E89GlCZ/c4/DpUZh/f77jjkyh0l+qPsjN3bde7XlvylGmDEmS4ux/zGzIMCfOSPVN/vp
         NoNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUwzMDUwO6buM/Dc+LmqWL6MYs4MLJY1vx4JM1OHD2K3OOlUHeR
	QCXx1Ep/xY6zoEYH1F/8UvRcdKC0xe5fepMwxEJ/Vs5naqAFPFz0x/QH4PGr09xzmJ667I3k6u2
	OL4+1LdV0CKQw+9he+JBl/BWgSpNfIkMuulUH2nRd40L5Wr7l61KGuCaHA+bItkNcJQ==
X-Received: by 2002:a37:dd1:: with SMTP id 200mr17962902qkn.344.1553028321998;
        Tue, 19 Mar 2019 13:45:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVDxgZYdSJDvUJpRTTUh+QdhnBuK/ecmX1PBK4tjVXkwnEM9uMUzLttLl+2snaXPrcVJew
X-Received: by 2002:a37:dd1:: with SMTP id 200mr17962858qkn.344.1553028321242;
        Tue, 19 Mar 2019 13:45:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553028321; cv=none;
        d=google.com; s=arc-20160816;
        b=rW51xvP8ArFxdyHLCNNuVSRkkh12/DnBiynHXb8ax4vJPg+IsRt12vgzIa7/oc1eVH
         xnPx1DpX+FYhkVMPxLAU9iAUcj2OGLeX5tVNRunDIZlYAiV9SR3t1VvZW2ZaXlfkBL9U
         ZUcOsFyFAzWSdZ6bIhwtd3akn0ZDRzifd8dqqdAWH1vXCbVs824lvpNZvJbVNXCEorGv
         AJxd1dR9TgMXtEH46ZWTSWH6ZqPZy7uNo3FhbD5tuMGZ/8OUIY7V/rsS3KFM29z4OGYu
         PiCrjPWrjnB3AogEaiKY0kvOUpoL9nsYG0JqJ19cCZoawjn1sBnPF9LQQDZyq3kXBnJO
         as2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=wrMre4ACpSfF2bgXwKmUw0SXnW6Ff5oF8GzytSeHbSI=;
        b=hyU2gAfAm10pzxPxl24fu6+QltcEY2IQTg0HXQZbjbNWWLIQRWXgC+z7kG5kSrI4Af
         KKSM2kBrP/hpCR6oc99h/v6ofzuY79tFzfOuxtO+f6qvlOD2dlxjkguwGIPe8b8vICKF
         2lsHwa659MfXKQm1Sygx6MrNHIOeApK21Mz3SIZ99EShbeDkUFFE05bVvFd1jFE+HQwn
         lqScSLffvsgMDAtUbnM/T7wsdw4oOx1i2ljAuf+nbJlE6lAYHy6PoYMb3NUVY2dj1V+k
         zzWK++jBu83rt5qHDbiB7LEDMbTg7FdFwq81XrVxy5YDL32zC0EJL83okRLMvHkCBE6f
         WJMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e73si1146783qkj.203.2019.03.19.13.45.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 13:45:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 05578F74AC;
	Tue, 19 Mar 2019 20:45:20 +0000 (UTC)
Received: from redhat.com (ovpn-120-246.rdu2.redhat.com [10.10.120.246])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A402D60C7F;
	Tue, 19 Mar 2019 20:45:15 +0000 (UTC)
Date: Tue, 19 Mar 2019 16:45:13 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Tom Talpey <tom@talpey.com>
Cc: Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	"Kirill A. Shutemov" <kirill@shutemov.name>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190319204512.GB3096@redhat.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
 <20190319141416.GA3879@redhat.com>
 <20190319142918.6a5vom55aeojapjp@kshutemo-mobl1>
 <20190319153644.GB26099@quack2.suse.cz>
 <20190319090322.GE7485@iweiny-DESK2.sc.intel.com>
 <f9195df4-66ca-95f6-874e-d19cd775794d@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f9195df4-66ca-95f6-874e-d19cd775794d@talpey.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 19 Mar 2019 20:45:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 03:43:44PM -0500, Tom Talpey wrote:
> On 3/19/2019 4:03 AM, Ira Weiny wrote:
> > On Tue, Mar 19, 2019 at 04:36:44PM +0100, Jan Kara wrote:
> > > On Tue 19-03-19 17:29:18, Kirill A. Shutemov wrote:
> > > > On Tue, Mar 19, 2019 at 10:14:16AM -0400, Jerome Glisse wrote:
> > > > > On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
> > > > > > On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
> > > > > > > On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
> > > > > > > > From: John Hubbard <jhubbard@nvidia.com>
> > > > > > 
> > > > > > [...]
> > > > > > 
> > > > > > > > diff --git a/mm/gup.c b/mm/gup.c
> > > > > > > > index f84e22685aaa..37085b8163b1 100644
> > > > > > > > --- a/mm/gup.c
> > > > > > > > +++ b/mm/gup.c
> > > > > > > > @@ -28,6 +28,88 @@ struct follow_page_context {
> > > > > > > >   	unsigned int page_mask;
> > > > > > > >   };
> > > > > > > > +typedef int (*set_dirty_func_t)(struct page *page);
> > > > > > > > +
> > > > > > > > +static void __put_user_pages_dirty(struct page **pages,
> > > > > > > > +				   unsigned long npages,
> > > > > > > > +				   set_dirty_func_t sdf)
> > > > > > > > +{
> > > > > > > > +	unsigned long index;
> > > > > > > > +
> > > > > > > > +	for (index = 0; index < npages; index++) {
> > > > > > > > +		struct page *page = compound_head(pages[index]);
> > > > > > > > +
> > > > > > > > +		if (!PageDirty(page))
> > > > > > > > +			sdf(page);
> > > > > > > 
> > > > > > > How is this safe? What prevents the page to be cleared under you?
> > > > > > > 
> > > > > > > If it's safe to race clear_page_dirty*() it has to be stated explicitly
> > > > > > > with a reason why. It's not very clear to me as it is.
> > > > > > 
> > > > > > The PageDirty() optimization above is fine to race with clear the
> > > > > > page flag as it means it is racing after a page_mkclean() and the
> > > > > > GUP user is done with the page so page is about to be write back
> > > > > > ie if (!PageDirty(page)) see the page as dirty and skip the sdf()
> > > > > > call while a split second after TestClearPageDirty() happens then
> > > > > > it means the racing clear is about to write back the page so all
> > > > > > is fine (the page was dirty and it is being clear for write back).
> > > > > > 
> > > > > > If it does call the sdf() while racing with write back then we
> > > > > > just redirtied the page just like clear_page_dirty_for_io() would
> > > > > > do if page_mkclean() failed so nothing harmful will come of that
> > > > > > neither. Page stays dirty despite write back it just means that
> > > > > > the page might be write back twice in a row.
> > > > > 
> > > > > Forgot to mention one thing, we had a discussion with Andrea and Jan
> > > > > about set_page_dirty() and Andrea had the good idea of maybe doing
> > > > > the set_page_dirty() at GUP time (when GUP with write) not when the
> > > > > GUP user calls put_page(). We can do that by setting the dirty bit
> > > > > in the pte for instance. They are few bonus of doing things that way:
> > > > >      - amortize the cost of calling set_page_dirty() (ie one call for
> > > > >        GUP and page_mkclean()
> > > > >      - it is always safe to do so at GUP time (ie the pte has write
> > > > >        permission and thus the page is in correct state)
> > > > >      - safe from truncate race
> > > > >      - no need to ever lock the page
> > > > > 
> > > > > Extra bonus from my point of view, it simplify thing for my generic
> > > > > page protection patchset (KSM for file back page).
> > > > > 
> > > > > So maybe we should explore that ? It would also be a lot less code.
> > > > 
> > > > Yes, please. It sounds more sensible to me to dirty the page on get, not
> > > > on put.
> > > 
> > > I fully agree this is a desirable final state of affairs.
> > 
> > I'm glad to see this presented because it has crossed my mind more than once
> > that effectively a GUP pinned page should be considered "dirty" at all times
> > until the pin is removed.  This is especially true in the RDMA case.
> 
> But, what if the RDMA registration is readonly? That's not uncommon, and
> marking dirty unconditonally would add needless overhead to such pages.

Yes and this is only when FOLL_WRITE is set ie when you are doing GUP and
asking for write. Doing GUP and asking for read is always safe.

Cheers,
Jérôme


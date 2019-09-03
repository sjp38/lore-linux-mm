Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47775C3A5A5
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 12:51:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16F5122CF8
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 12:51:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16F5122CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DE646B0003; Tue,  3 Sep 2019 08:51:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88E636B0005; Tue,  3 Sep 2019 08:51:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77CDA6B0006; Tue,  3 Sep 2019 08:51:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0230.hostedemail.com [216.40.44.230])
	by kanga.kvack.org (Postfix) with ESMTP id 5146C6B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 08:51:53 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 06F7C824CA2D
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:51:53 +0000 (UTC)
X-FDA: 75893596506.24.doll03_1063fb642eb2a
X-HE-Tag: doll03_1063fb642eb2a
X-Filterd-Recvd-Size: 3471
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:51:52 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C1AB5B07D;
	Tue,  3 Sep 2019 12:51:50 +0000 (UTC)
Date: Tue, 3 Sep 2019 14:51:50 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: William Kucharski <william.kucharski@oracle.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Song Liu <songliubraving@fb.com>,
	Bob Kasten <robert.a.kasten@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Chad Mynhier <chad.mynhier@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH v5 2/2] mm,thp: Add experimental config option
 RO_EXEC_FILEMAP_HUGE_FAULT_THP
Message-ID: <20190903125150.GW14028@dhcp22.suse.cz>
References: <20190902092341.26712-1-william.kucharski@oracle.com>
 <20190902092341.26712-3-william.kucharski@oracle.com>
 <20190903121424.GT14028@dhcp22.suse.cz>
 <20190903122208.GE29434@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190903122208.GE29434@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 03-09-19 05:22:08, Matthew Wilcox wrote:
> On Tue, Sep 03, 2019 at 02:14:24PM +0200, Michal Hocko wrote:
> > On Mon 02-09-19 03:23:41, William Kucharski wrote:
> > > Add filemap_huge_fault() to attempt to satisfy page
> > > faults on memory-mapped read-only text pages using THP when possible.
> > 
> > This deserves much more description of how the thing is implemented and
> > expected to work. For one thing it is not really clear to me why you
> > need CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP at all. You need a support
> > from the filesystem anyway. So who is going to enable/disable this
> > config?
> 
> There are definitely situations in which enabling this code will crash
> the kernel.  But we want to get filesystems to a point where they can
> start working on their support for large pages.  So our workaround is
> to try to get the core pieces merged under a CONFIG_I_KNOW_WHAT_IM_DOING
> flag and let people play with it.  Then continue to work on the core
> to eliminate those places that are broken.

I am not sure I understand. Each fs has to opt in to the feature
anyway. If it doesn't then there should be no risk of regression, right?
I do not expect any fs would rush an implementation in while not being
sure about the correctness. So how exactly does a config option help
here.
 
> > I cannot really comment on fs specific parts but filemap_huge_fault
> > sounds convoluted so much I cannot wrap my head around it. One thing
> > stand out though. The generic filemap_huge_fault depends on ->readpage
> > doing the right thing which sounds quite questionable to me. If nothing
> > else  I would expect ->readpages to do the job.
> 
> Ah, that's because you're not a filesystem person ;-)  ->readpages is
> really ->readahead.  It's a crappy interface and should be completely
> redesigned.

OK, the interface looked like the right fit for this purpose. Thanks for
clarifying.
-- 
Michal Hocko
SUSE Labs


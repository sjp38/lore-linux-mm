Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2B72C3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 08:28:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72A612077B
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 08:28:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72A612077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 127656B0003; Wed,  4 Sep 2019 04:28:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DF4B6B0006; Wed,  4 Sep 2019 04:28:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F07286B0007; Wed,  4 Sep 2019 04:28:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0246.hostedemail.com [216.40.44.246])
	by kanga.kvack.org (Postfix) with ESMTP id C96146B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 04:28:07 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 65FD0A2A7
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 08:28:07 +0000 (UTC)
X-FDA: 75896560614.18.baby08_63fcc7a16be53
X-HE-Tag: baby08_63fcc7a16be53
X-Filterd-Recvd-Size: 3053
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 08:28:06 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 77B1EAE91;
	Wed,  4 Sep 2019 08:28:05 +0000 (UTC)
Date: Wed, 4 Sep 2019 10:28:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Song Liu <songliubraving@fb.com>,
	Bob Kasten <robert.a.kasten@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Chad Mynhier <chad.mynhier@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Johannes Weiner <jweiner@fb.com>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v5 1/2] mm: Allow the page cache to allocate large pages
Message-ID: <20190904082805.GJ3838@dhcp22.suse.cz>
References: <20190902092341.26712-1-william.kucharski@oracle.com>
 <20190902092341.26712-2-william.kucharski@oracle.com>
 <20190903115748.GS14028@dhcp22.suse.cz>
 <68E123A9-22A8-40ED-B2ED-897FC02D7D75@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <68E123A9-22A8-40ED-B2ED-897FC02D7D75@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 03-09-19 21:30:30, William Kucharski wrote:
> 
> 
> > On Sep 3, 2019, at 5:57 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > On Mon 02-09-19 03:23:40, William Kucharski wrote:
> >> Add an 'order' argument to __page_cache_alloc() and
> >> do_read_cache_page(). Ensure the allocated pages are compound pages.
> > 
> > Why do we need to touch all the existing callers and change them to use
> > order 0 when none is actually converted to a different order? This just
> > seem to add a lot of code churn without a good reason. If anything I
> > would simply add __page_cache_alloc_order and make __page_cache_alloc
> > call it with order 0 argument.
> 
> All the EXISTING code in patch [1/2] is changed to call it with an order
> of 0, as you would expect.
> 
> However, new code in part [2/2] of the patch calls it with an order of
> HPAGE_PMD_ORDER, as it seems cleaner to have those routines operate on
> a page, regardless of the order of the page desired.
> 
> I certainly can change this as you request, but once again the question
> is whether "page" should MEAN "page" regardless of the order desired,
> or whether the assumption will always be "page" means base PAGESIZE.
> 
> Either approach works, but what is the semantic we want going forward?

I do not have anything against handling page as compound, if that is the
question. All I was interested in whether adding a new helper to
_allocate_ the comound page wouldn't be easier than touching all
existing __page_cache_alloc users.
-- 
Michal Hocko
SUSE Labs


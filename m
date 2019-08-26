Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 220B4C3A5A5
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:43:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E497C2173E
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:43:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E497C2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75D726B0541; Mon, 26 Aug 2019 03:43:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70E0F6B0543; Mon, 26 Aug 2019 03:43:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64B746B0544; Mon, 26 Aug 2019 03:43:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0095.hostedemail.com [216.40.44.95])
	by kanga.kvack.org (Postfix) with ESMTP id 433FA6B0541
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 03:43:53 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E56B5180AD805
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:43:52 +0000 (UTC)
X-FDA: 75863789904.27.feast24_3ef349f41d05f
X-HE-Tag: feast24_3ef349f41d05f
X-Filterd-Recvd-Size: 3050
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:43:52 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ED493AE79;
	Mon, 26 Aug 2019 07:43:50 +0000 (UTC)
Date: Mon, 26 Aug 2019 09:43:50 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, vbabka@suse.cz,
	rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH -mm] mm: account deferred split THPs into MemAvailable
Message-ID: <20190826074350.GE7538@dhcp22.suse.cz>
References: <1566410125-66011-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190822080434.GF12785@dhcp22.suse.cz>
 <9e4ba38e-0670-7292-ab3a-38af391598ec@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9e4ba38e-0670-7292-ab3a-38af391598ec@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 22-08-19 08:33:40, Yang Shi wrote:
> 
> 
> On 8/22/19 1:04 AM, Michal Hocko wrote:
> > On Thu 22-08-19 01:55:25, Yang Shi wrote:
[...]
> > > And, they seems very common with the common workloads when THP is
> > > enabled.  A simple run with MariaDB test of mmtest with THP enabled as
> > > always shows it could generate over fifteen thousand deferred split THPs
> > > (accumulated around 30G in one hour run, 75% of 40G memory for my VM).
> > > It looks worth accounting in MemAvailable.
> > OK, this makes sense. But your above numbers are really worrying.
> > Accumulating such a large amount of pages that are likely not going to
> > be used is really bad. They are essentially blocking any higher order
> > allocations and also push the system towards more memory pressure.
> 
> That is accumulated number, during the running of the test, some of them
> were freed by shrinker already. IOW, it should not reach that much at any
> given time.

Then the above description is highly misleading. What is the actual
number of lingering THPs that wait for the memory pressure in the peak?
 
> > IIUC deferred splitting is mostly a workaround for nasty locking issues
> > during splitting, right? This is not really an optimization to cache
> > THPs for reuse or something like that. What is the reason this is not
> > done from a worker context? At least THPs which would be freed
> > completely sound like a good candidate for kworker tear down, no?
> 
> Yes, deferred split THP was introduced to avoid locking issues according to
> the document. Memcg awareness would help to trigger the shrinker more often.
> 
> I think it could be done in a worker context, but when to trigger to worker
> is a subtle problem.

Why? What is the problem to trigger it after unmap of a batch worth of
THPs?
-- 
Michal Hocko
SUSE Labs


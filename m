Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 058F2C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:18:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C16C6233A1
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:18:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C16C6233A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 663AB6B0010; Thu, 29 Aug 2019 03:18:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 612CE6B0266; Thu, 29 Aug 2019 03:18:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D93B6B0269; Thu, 29 Aug 2019 03:18:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0155.hostedemail.com [216.40.44.155])
	by kanga.kvack.org (Postfix) with ESMTP id 248896B0010
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:18:10 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C1329AF97
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:18:09 +0000 (UTC)
X-FDA: 75874611498.09.low18_d05238c36e4e
X-HE-Tag: low18_d05238c36e4e
X-Filterd-Recvd-Size: 3355
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:18:09 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EA865B116;
	Thu, 29 Aug 2019 07:18:07 +0000 (UTC)
Date: Thu, 29 Aug 2019 09:18:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mina Almasry <almasrymina@google.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, shuah <shuah@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Greg Thelen <gthelen@google.com>,
	Andrew Morton <akpm@linux-foundation.org>, khalid.aziz@oracle.com,
	open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org,
	Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>,
	Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>,
	Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Li Zefan <lizefan@huawei.com>
Subject: Re: [PATCH v3 0/6] hugetlb_cgroup: Add hugetlb_cgroup reservation
 limits
Message-ID: <20190829071807.GR28313@dhcp22.suse.cz>
References: <20190826233240.11524-1-almasrymina@google.com>
 <20190828112340.GB7466@dhcp22.suse.cz>
 <CAHS8izPPhPoqh-J9LJ40NJUCbgTFS60oZNuDSHmgtMQiYw72RA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHS8izPPhPoqh-J9LJ40NJUCbgTFS60oZNuDSHmgtMQiYw72RA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc cgroups maintainers]

On Wed 28-08-19 10:58:00, Mina Almasry wrote:
> On Wed, Aug 28, 2019 at 4:23 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 26-08-19 16:32:34, Mina Almasry wrote:
> > >  mm/hugetlb.c                                  | 493 ++++++++++++------
> > >  mm/hugetlb_cgroup.c                           | 187 +++++--
> >
> > This is a lot of changes to an already subtle code which hugetlb
> > reservations undoubly are.
> 
> For what it's worth, I think this patch series is a net decrease in
> the complexity of the reservation code, especially the region_*
> functions, which is where a lot of the complexity lies. I removed the
> race between region_del and region_{add|chg}, refactored the main
> logic into smaller code, moved common code to helpers and deleted the
> duplicates, and finally added lots of comments to the hard to
> understand pieces. I hope that when folks review the changes they will
> see that! :)

Post those improvements as standalone patches and sell them as
improvements. We can talk about the net additional complexity of the
controller much easier then.

> > Moreover cgroupv1 is feature frozen and I am
> > not aware of any plans to port the controller to v2.
> 
> Also for what it's worth, if porting the controller to v2 is a
> requisite to take this, I'm happy to do that. As far as I understand
> there is no reason hugetlb_cgroups shouldn't be in cgroups v2, and we
> see value in them.

Talk to cgroups maintainers why the hugegetlb controller hasn't been
enabled in v2. All I am saing is that v1 only features are really a hard
sell. Even without adding a lot of code to hugetlb which is quite
complex on its own.
-- 
Michal Hocko
SUSE Labs


Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02FA0C3A5AB
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:54:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5B342184B
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:54:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5B342184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D52F6B0289; Thu,  5 Sep 2019 06:54:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3856C6B028A; Thu,  5 Sep 2019 06:54:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29B576B028B; Thu,  5 Sep 2019 06:54:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0221.hostedemail.com [216.40.44.221])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6866B0289
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 06:54:29 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 83DA6824CA3B
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:54:28 +0000 (UTC)
X-FDA: 75900558216.21.step96_7e5456aeaa035
X-HE-Tag: step96_7e5456aeaa035
X-Filterd-Recvd-Size: 3406
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:54:27 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2D7E8AC50;
	Thu,  5 Sep 2019 10:54:26 +0000 (UTC)
Date: Thu, 5 Sep 2019 12:54:24 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, Tim Murray <timmurray@google.com>,
	carmenjackson@google.com, mayankgupta@google.com, dancol@google.com,
	rostedt@goodmis.org, minchan@kernel.org, akpm@linux-foundation.org,
	kernel-team@android.com,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org,
	Matthew Wilcox <willy@infradead.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
Message-ID: <20190905105424.GG3838@dhcp22.suse.cz>
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz>
 <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz>
 <20190904162808.GO240514@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190904162808.GO240514@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 04-09-19 12:28:08, Joel Fernandes wrote:
> On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Wed 04-09-19 11:32:58, Joel Fernandes wrote:
> > > On Wed, Sep 04, 2019 at 10:45:08AM +0200, Michal Hocko wrote:
> > > > On Tue 03-09-19 16:09:05, Joel Fernandes (Google) wrote:
> > > > > Useful to track how RSS is changing per TGID to detect spikes in RSS and
> > > > > memory hogs. Several Android teams have been using this patch in various
> > > > > kernel trees for half a year now. Many reported to me it is really
> > > > > useful so I'm posting it upstream.
> > > > >
> > > > > Initial patch developed by Tim Murray. Changes I made from original patch:
> > > > > o Prevent any additional space consumed by mm_struct.
> > > > > o Keep overhead low by checking if tracing is enabled.
> > > > > o Add some noise reduction and lower overhead by emitting only on
> > > > >   threshold changes.
> > > >
> > > > Does this have any pre-requisite? I do not see trace_rss_stat_enabled in
> > > > the Linus tree (nor in linux-next).
> > >
> > > No, this is generated automatically by the tracepoint infrastructure when a
> > > tracepoint is added.
> >
> > OK, I was not aware of that.
> >
> > > > Besides that why do we need batching in the first place. Does this have a
> > > > measurable overhead? How does it differ from any other tracepoints that we
> > > > have in other hotpaths (e.g.  page allocator doesn't do any checks).
> > >
> > > We do need batching not only for overhead reduction,
> >
> > What is the overhead?
> 
> The overhead is occasionally higher without the threshold (that is if we
> trace every counter change). I would classify performance benefit to be
> almost the same and within the noise.

OK, so the additional code is not really justified.
-- 
Michal Hocko
SUSE Labs


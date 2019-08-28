Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D771C3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:57:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28C8E22CF8
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:57:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28C8E22CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B66986B0003; Wed, 28 Aug 2019 03:57:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B16A86B0008; Wed, 28 Aug 2019 03:57:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A05086B000D; Wed, 28 Aug 2019 03:57:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0003.hostedemail.com [216.40.44.3])
	by kanga.kvack.org (Postfix) with ESMTP id 798886B0003
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 03:57:12 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 23E7075A0
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:57:12 +0000 (UTC)
X-FDA: 75871081104.10.peace14_49cc8546ff16
X-HE-Tag: peace14_49cc8546ff16
X-Filterd-Recvd-Size: 6007
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:57:11 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 62BC6AB98;
	Wed, 28 Aug 2019 07:57:09 +0000 (UTC)
Date: Wed, 28 Aug 2019 09:57:08 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org, rientjes@google.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH -mm] mm: account deferred split THPs into MemAvailable
Message-ID: <20190828075708.GF7386@dhcp22.suse.cz>
References: <20190822152934.w6ztolutdix6kbvc@box>
 <20190826074035.GD7538@dhcp22.suse.cz>
 <20190826131538.64twqx3yexmhp6nf@box>
 <20190827060139.GM7538@dhcp22.suse.cz>
 <20190827110210.lpe36umisqvvesoa@box>
 <aaaf9742-56f7-44b7-c3db-ad078b7b2220@suse.cz>
 <20190827120923.GB7538@dhcp22.suse.cz>
 <20190827121739.bzbxjloq7bhmroeq@box>
 <20190827125911.boya23eowxhqmopa@box>
 <d76ec546-7ae8-23a3-4631-5c531c1b1f40@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d76ec546-7ae8-23a3-4631-5c531c1b1f40@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 10:06:20, Yang Shi wrote:
> 
> 
> On 8/27/19 5:59 AM, Kirill A. Shutemov wrote:
> > On Tue, Aug 27, 2019 at 03:17:39PM +0300, Kirill A. Shutemov wrote:
> > > On Tue, Aug 27, 2019 at 02:09:23PM +0200, Michal Hocko wrote:
> > > > On Tue 27-08-19 14:01:56, Vlastimil Babka wrote:
> > > > > On 8/27/19 1:02 PM, Kirill A. Shutemov wrote:
> > > > > > On Tue, Aug 27, 2019 at 08:01:39AM +0200, Michal Hocko wrote:
> > > > > > > On Mon 26-08-19 16:15:38, Kirill A. Shutemov wrote:
> > > > > > > > Unmapped completely pages will be freed with current code. Deferred split
> > > > > > > > only applies to partly mapped THPs: at least on 4k of the THP is still
> > > > > > > > mapped somewhere.
> > > > > > > Hmm, I am probably misreading the code but at least current Linus' tree
> > > > > > > reads page_remove_rmap -> [page_remove_anon_compound_rmap ->\ deferred_split_huge_page even
> > > > > > > for fully mapped THP.
> > > > > > Well, you read correctly, but it was not intended. I screwed it up at some
> > > > > > point.
> > > > > > 
> > > > > > See the patch below. It should make it work as intened.
> > > > > > 
> > > > > > It's not bug as such, but inefficientcy. We add page to the queue where
> > > > > > it's not needed.
> > > > > But that adding to queue doesn't affect whether the page will be freed
> > > > > immediately if there are no more partial mappings, right? I don't see
> > > > > deferred_split_huge_page() pinning the page.
> > > > > So your patch wouldn't make THPs freed immediately in cases where they
> > > > > haven't been freed before immediately, it just fixes a minor
> > > > > inefficiency with queue manipulation?
> > > > Ohh, right. I can see that in free_transhuge_page now. So fully mapped
> > > > THPs really do not matter and what I have considered an odd case is
> > > > really happening more often.
> > > > 
> > > > That being said this will not help at all for what Yang Shi is seeing
> > > > and we need a more proactive deferred splitting as I've mentioned
> > > > earlier.
> > > It was not intended to fix the issue. It's fix for current logic. I'm
> > > playing with the work approach now.
> > Below is what I've come up with. It appears to be functional.
> > 
> > Any comments?
> 
> Thanks, Kirill and Michal. Doing split more proactive is definitely a choice
> to eliminate huge accumulated deferred split THPs, I did think about this
> approach before I came up with memcg aware approach. But, I thought this
> approach has some problems:
> 
> First of all, we can't prove if this is a universal win for the most
> workloads or not. For some workloads (as I mentioned about our usecase), we
> do see a lot THPs accumulated for a while, but they are very short-lived for
> other workloads, i.e. kernel build.
> 
> Secondly, it may be not fair for some workloads which don't generate too
> many deferred split THPs or those THPs are short-lived. Actually, the cpu
> time is abused by the excessive deferred split THPs generators, isn't it?

Yes this is indeed true. Do we have any idea on how much time that
actually is?

> With memcg awareness, the deferred split THPs actually are isolated and
> capped by memcg. The long-lived deferred split THPs can't be accumulated too
> many due to the limit of memcg. And, cpu time spent in splitting them would
> just account to the memcgs who generate that many deferred split THPs, who
> generate them who pay for it. This sounds more fair and we could achieve
> much better isolation.

On the other hand, deferring the split and free up a non trivial amount
of memory is a problem I consider quite serious because it affects not
only the memcg workload which has to do the reclaim but also other
consumers of memory beucase large memory blocks could be used for higher
order allocations.

> And, I think the discussion is diverted and mislead by the number of
> excessive deferred split THPs. To be clear, I didn't mean the excessive
> deferred split THPs are problem for us (I agree it may waste memory to have
> that many deferred split THPs not usable), the problem is the oom since they
> couldn't be split by memcg limit reclaim since the shrinker was not memcg
> aware.

Well, I would like to see how much of a problem the memcg OOM really is
after deferred splitting is more time constrained. Maybe we will find
that there is no special memcg aware solution really needed.
-- 
Michal Hocko
SUSE Labs


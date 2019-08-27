Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CE41C41514
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 12:09:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18B45206BF
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 12:09:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18B45206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5EBA6B0006; Tue, 27 Aug 2019 08:09:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B35566B000C; Tue, 27 Aug 2019 08:09:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A73806B000D; Tue, 27 Aug 2019 08:09:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0100.hostedemail.com [216.40.44.100])
	by kanga.kvack.org (Postfix) with ESMTP id 885096B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 08:09:27 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 3CE884FE6
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 12:09:27 +0000 (UTC)
X-FDA: 75868087974.10.alley49_6f91ee2753335
X-HE-Tag: alley49_6f91ee2753335
X-Filterd-Recvd-Size: 3110
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 12:09:26 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 284E9AF19;
	Tue, 27 Aug 2019 12:09:25 +0000 (UTC)
Date: Tue, 27 Aug 2019 14:09:23 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	kirill.shutemov@linux.intel.com,
	Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org,
	rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH -mm] mm: account deferred split THPs into MemAvailable
Message-ID: <20190827120923.GB7538@dhcp22.suse.cz>
References: <1566410125-66011-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190822080434.GF12785@dhcp22.suse.cz>
 <ee048bbf-3563-d695-ea58-5f1504aee35c@suse.cz>
 <20190822152934.w6ztolutdix6kbvc@box>
 <20190826074035.GD7538@dhcp22.suse.cz>
 <20190826131538.64twqx3yexmhp6nf@box>
 <20190827060139.GM7538@dhcp22.suse.cz>
 <20190827110210.lpe36umisqvvesoa@box>
 <aaaf9742-56f7-44b7-c3db-ad078b7b2220@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aaaf9742-56f7-44b7-c3db-ad078b7b2220@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 14:01:56, Vlastimil Babka wrote:
> On 8/27/19 1:02 PM, Kirill A. Shutemov wrote:
> > On Tue, Aug 27, 2019 at 08:01:39AM +0200, Michal Hocko wrote:
> >> On Mon 26-08-19 16:15:38, Kirill A. Shutemov wrote:
> >>>
> >>> Unmapped completely pages will be freed with current code. Deferred split
> >>> only applies to partly mapped THPs: at least on 4k of the THP is still
> >>> mapped somewhere.
> >>
> >> Hmm, I am probably misreading the code but at least current Linus' tree
> >> reads page_remove_rmap -> [page_remove_anon_compound_rmap ->\ deferred_split_huge_page even
> >> for fully mapped THP.
> > 
> > Well, you read correctly, but it was not intended. I screwed it up at some
> > point.
> > 
> > See the patch below. It should make it work as intened.
> > 
> > It's not bug as such, but inefficientcy. We add page to the queue where
> > it's not needed.
> 
> But that adding to queue doesn't affect whether the page will be freed
> immediately if there are no more partial mappings, right? I don't see
> deferred_split_huge_page() pinning the page.
> So your patch wouldn't make THPs freed immediately in cases where they
> haven't been freed before immediately, it just fixes a minor
> inefficiency with queue manipulation?

Ohh, right. I can see that in free_transhuge_page now. So fully mapped
THPs really do not matter and what I have considered an odd case is
really happening more often.

That being said this will not help at all for what Yang Shi is seeing
and we need a more proactive deferred splitting as I've mentioned
earlier.

-- 
Michal Hocko
SUSE Labs


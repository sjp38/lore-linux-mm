Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9FB1ECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 12:00:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7748D2168B
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 12:00:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7748D2168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E564D6B0005; Wed, 11 Sep 2019 08:00:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E06DA6B0006; Wed, 11 Sep 2019 08:00:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1CCB6B0007; Wed, 11 Sep 2019 08:00:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0092.hostedemail.com [216.40.44.92])
	by kanga.kvack.org (Postfix) with ESMTP id B14756B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 08:00:07 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id EE8E6BEF6
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 12:00:06 +0000 (UTC)
X-FDA: 75922496412.05.hook96_1e0e8597b8d61
X-HE-Tag: hook96_1e0e8597b8d61
X-Filterd-Recvd-Size: 2841
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 12:00:06 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7A9D9B64B;
	Wed, 11 Sep 2019 12:00:04 +0000 (UTC)
Date: Wed, 11 Sep 2019 14:00:02 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Thomas Lindroth <thomas.lindroth@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH] memcg, kmem: do not fail __GFP_NOFAIL charges
Message-ID: <20190911120002.GQ4023@dhcp22.suse.cz>
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
 <20190906125608.32129-1-mhocko@kernel.org>
 <CALvZod5w72jH8fJSFRaw7wgQTnzF6nb=+St-sSXVGSiG6Bs3Lg@mail.gmail.com>
 <20190909112245.GH27159@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190909112245.GH27159@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 09-09-19 13:22:45, Michal Hocko wrote:
> On Fri 06-09-19 11:24:55, Shakeel Butt wrote:
[...]
> > I wonder what has changed since
> > <http://lkml.kernel.org/r/20180525185501.82098-1-shakeelb@google.com/>.
> 
> I have completely forgot about that one. It seems that we have just
> repeated the same discussion again. This time we have a poor user who
> actually enabled the kmem limit.
> 
> I guess there was no real objection to the change back then. The primary
> discussion revolved around the fact that the accounting will stay broken
> even when this particular part was fixed. Considering this leads to easy
> to trigger crash (with the limit enabled) then I guess we should just
> make it less broken and backport to stable trees and have a serious
> discussion about discontinuing of the limit. Start by simply failing to
> set any limit in the current upstream kernels.

Any more concerns/objections to the patch? I can add a reference to your
earlier post Shakeel if you want or to credit you the way you prefer.

Also are there any objections to start deprecating process of kmem
limit? I would see it in two stages
- 1st warn in the kernel log
	pr_warn("kmem.limit_in_bytes is deprecated and will be removed.
	        "Please report your usecase to linux-mm@kvack.org if you "
		"depend on this functionality."
- 2nd fail any write to kmem.limit_in_bytes
- 3rd remove the control file completely
-- 
Michal Hocko
SUSE Labs


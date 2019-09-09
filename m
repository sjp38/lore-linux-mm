Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C634C00307
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 08:37:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF5A5218AC
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 08:37:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF5A5218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8921E6B0005; Mon,  9 Sep 2019 04:37:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 841EE6B0007; Mon,  9 Sep 2019 04:37:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 730176B0008; Mon,  9 Sep 2019 04:37:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0052.hostedemail.com [216.40.44.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB136B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 04:37:50 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E7F3B180AD7C3
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:37:49 +0000 (UTC)
X-FDA: 75914729058.06.rule72_2735f2fbe8b0c
X-HE-Tag: rule72_2735f2fbe8b0c
X-Filterd-Recvd-Size: 2954
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:37:49 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E10FFAC37;
	Mon,  9 Sep 2019 08:37:47 +0000 (UTC)
Date: Mon, 9 Sep 2019 10:37:47 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>
Subject: Re: [patch for-5.3 0/4] revert immediate fallback to remote hugepages
Message-ID: <20190909083747.GD27159@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com>
 <CAHk-=wjmF_MGe5sBDmQB1WGpr+QFWkqboHpL37JYB5WgnG8nMA@mail.gmail.com>
 <alpine.DEB.2.21.1909051345030.217933@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1909071249180.81471@chino.kir.corp.google.com>
 <CAHk-=wifuQ68e6Q4F2txGS48WgcoX2REE4te5_j36ypV-T2ZKw@mail.gmail.com>
 <alpine.DEB.2.21.1909071829440.200558@chino.kir.corp.google.com>
 <d76f8cc3-97aa-8da5-408d-397467ea768b@suse.cz>
 <alpine.DEB.2.21.1909081328220.178796@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1909081328220.178796@chino.kir.corp.google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 08-09-19 13:45:13, David Rientjes wrote:
> If the reverts to 5.3 are not 
> applied, then I'm not at all confident that forward progress on this issue 
> will be made:

David, could you stop this finally? I think there is a good consensus
that the current (even after reverts) behavior is not going all the way
down where we want to get. There have been different ways forward
suggested to not fallback to remote nodes too easily, not to mention
a specialized memory policy to explicitly request the behavior you
presumably need (and as a bonus it wouldn't be THP specific which is
even better).

You seem to be deadlocked in "we've used to do something for 4 years
so we must preserve that behavior". All that based on a single and
odd workload which you are hand waving about without anything for
the rest of the community to reproduce. Please try to get out of the
argumentation loop. We are more likely to make a forward progress.

5.3 managed to fix the worst case behavior, now let's talk about more
clever tuning. You cannot expect such a tuning is an overnight work.
This area is full of subtle side effects and few liners might have hard
to predict consequences.
-- 
Michal Hocko
SUSE Labs


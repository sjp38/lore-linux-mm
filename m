Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 714FBC3A5A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:06:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F794233A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:06:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F794233A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C61C66B02BF; Wed, 21 Aug 2019 10:06:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C12CC6B02C0; Wed, 21 Aug 2019 10:06:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B01A16B02C1; Wed, 21 Aug 2019 10:06:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0141.hostedemail.com [216.40.44.141])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9136B02BF
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:06:36 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 25DD87596
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:06:36 +0000 (UTC)
X-FDA: 75846610392.03.fog60_39900ede5c223
X-HE-Tag: fog60_39900ede5c223
X-Filterd-Recvd-Size: 2826
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:06:35 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7C940AF59;
	Wed, 21 Aug 2019 14:06:33 +0000 (UTC)
Date: Wed, 21 Aug 2019 16:06:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net,
	dan.j.williams@intel.com, osalvador@suse.de,
	richard.weiyang@gmail.com, hannes@cmpxchg.org,
	arunks@codeaurora.org, rppt@linux.vnet.ibm.com, jgg@ziepe.ca,
	amir73il@gmail.com, alexander.h.duyck@linux.intel.com,
	linux-mm@kvack.org, linux-kernel-mentees@lists.linuxfoundation.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 0/2] Add predictive memory reclamation and compaction
Message-ID: <20190821140632.GI3111@dhcp22.suse.cz>
References: <20190813014012.30232-1-khalid.aziz@oracle.com>
 <20190813140553.GK17933@dhcp22.suse.cz>
 <3cb0af00-f091-2f3e-d6cc-73a5171e6eda@oracle.com>
 <20190814085831.GS17933@dhcp22.suse.cz>
 <d3895804-7340-a7ae-d611-62913303e9c5@oracle.com>
 <20190815170215.GQ9477@dhcp22.suse.cz>
 <2668ad2e-ee52-8c88-22c0-1952243af5a1@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2668ad2e-ee52-8c88-22c0-1952243af5a1@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 14:51:04, Khalid Aziz wrote:
> Hi Michal,
> 
> The smarts for tuning these knobs can be implemented in userspace and
> more knobs added to allow for what is missing today, but we get back to
> the same issue as before. That does nothing to make kernel self-tuning
> and adds possibly even more knobs to userspace. Something so fundamental
> to kernel memory management as making free pages available when they are
> needed really should be taken care of in the kernel itself. Moving it to
> userspace just means the kernel is hobbled unless one installs and tunes
> a userspace package correctly.

From my past experience the existing autotunig works mostly ok for a
vast variety of workloads. A more clever tuning is possible and people
are doing that already. Especially for cases when the machine is heavily
overcommited. There are different ways to achieve that. Your new
in-kernel auto tuning would have to be tested on a large variety of
workloads to be proven and riskless. So I am quite skeptical to be
honest.

Therefore I would really focus on discussing whether we have sufficient
APIs to tune the kernel to do the right thing when needed. That requires
to identify gaps in that area.
-- 
Michal Hocko
SUSE Labs


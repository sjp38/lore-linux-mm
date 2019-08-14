Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1051C32757
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:58:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A17F4208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:58:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A17F4208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 410F76B000A; Wed, 14 Aug 2019 04:58:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39AEC6B000D; Wed, 14 Aug 2019 04:58:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 289336B000E; Wed, 14 Aug 2019 04:58:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0231.hostedemail.com [216.40.44.231])
	by kanga.kvack.org (Postfix) with ESMTP id 010DD6B000A
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 04:58:38 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 94B0D181AC9AE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:58:38 +0000 (UTC)
X-FDA: 75820432716.17.plot37_113269fbc265a
X-HE-Tag: plot37_113269fbc265a
X-Filterd-Recvd-Size: 3863
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:58:38 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 325FAAD4E;
	Wed, 14 Aug 2019 08:58:33 +0000 (UTC)
Date: Wed, 14 Aug 2019 10:58:31 +0200
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
Message-ID: <20190814085831.GS17933@dhcp22.suse.cz>
References: <20190813014012.30232-1-khalid.aziz@oracle.com>
 <20190813140553.GK17933@dhcp22.suse.cz>
 <3cb0af00-f091-2f3e-d6cc-73a5171e6eda@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3cb0af00-f091-2f3e-d6cc-73a5171e6eda@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 13-08-19 09:20:51, Khalid Aziz wrote:
> On 8/13/19 8:05 AM, Michal Hocko wrote:
> > On Mon 12-08-19 19:40:10, Khalid Aziz wrote:
> > [...]
> >> Patch 1 adds code to maintain a sliding lookback window of (time, number
> >> of free pages) points which can be updated continuously and adds code to
> >> compute best fit line across these points. It also adds code to use the
> >> best fit lines to determine if kernel must start reclamation or
> >> compaction.
> >>
> >> Patch 2 adds code to collect data points on free pages of various orders
> >> at different points in time, uses code in patch 1 to update sliding
> >> lookback window with these points and kicks off reclamation or
> >> compaction based upon the results it gets.
> > 
> > An important piece of information missing in your description is why
> > do we need to keep that logic in the kernel. In other words, we have
> > the background reclaim that acts on a wmark range and those are tunable
> > from the userspace. The primary point of this background reclaim is to
> > keep balance and prevent from direct reclaim. Why cannot you implement
> > this or any other dynamic trend watching watchdog and tune watermarks
> > accordingly? Something similar applies to kcompactd although we might be
> > lacking a good interface.
> > 
> 
> Hi Michal,
> 
> That is a very good question. As a matter of fact the initial prototype
> to assess the feasibility of this approach was written in userspace for
> a very limited application. We wrote the initial prototype to monitor
> fragmentation and used /sys/devices/system/node/node*/compact to trigger
> compaction. The prototype demonstrated this approach has merits.
> 
> The primary reason to implement this logic in the kernel is to make the
> kernel self-tuning.

What makes this particular self-tuning an universal win? In other words
there are many ways to analyze the memory pressure and feedback it back
that I can think of. It is quite likely that very specific workloads
would have very specific demands there. I have seen cases where are
trivial increase of min_free_kbytes to normally insane value worked
really great for a DB workload because the wasted memory didn't matter
for example.

> The more knobs we have externally, the more complex
> it becomes to tune the kernel externally.

I agree on this point. Is the current set of tunning sufficient? What
would be missing if not?
-- 
Michal Hocko
SUSE Labs


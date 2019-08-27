Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B62DC3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 06:16:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16E172173E
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 06:16:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16E172173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A9466B000A; Tue, 27 Aug 2019 02:16:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 958AE6B000C; Tue, 27 Aug 2019 02:16:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86F0D6B000D; Tue, 27 Aug 2019 02:16:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0092.hostedemail.com [216.40.44.92])
	by kanga.kvack.org (Postfix) with ESMTP id 68D1D6B000A
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 02:16:10 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 2361918DD
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 06:16:10 +0000 (UTC)
X-FDA: 75867197700.11.rod07_52e7b1f40e445
X-HE-Tag: rod07_52e7b1f40e445
X-Filterd-Recvd-Size: 5639
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 06:16:09 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9400EB009;
	Tue, 27 Aug 2019 06:16:07 +0000 (UTC)
Date: Tue, 27 Aug 2019 08:16:06 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, akpm@linux-foundation.org,
	vbabka@suse.cz, mgorman@techsingularity.net,
	dan.j.williams@intel.com, osalvador@suse.de,
	richard.weiyang@gmail.com, hannes@cmpxchg.org,
	arunks@codeaurora.org, rppt@linux.vnet.ibm.com, jgg@ziepe.ca,
	amir73il@gmail.com, alexander.h.duyck@linux.intel.com,
	linux-mm@kvack.org, linux-kernel-mentees@lists.linuxfoundation.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 0/2] Add predictive memory reclamation and compaction
Message-ID: <20190827061606.GN7538@dhcp22.suse.cz>
References: <20190813014012.30232-1-khalid.aziz@oracle.com>
 <20190813140553.GK17933@dhcp22.suse.cz>
 <3cb0af00-f091-2f3e-d6cc-73a5171e6eda@oracle.com>
 <20190814085831.GS17933@dhcp22.suse.cz>
 <d3895804-7340-a7ae-d611-62913303e9c5@oracle.com>
 <20190815170215.GQ9477@dhcp22.suse.cz>
 <2668ad2e-ee52-8c88-22c0-1952243af5a1@oracle.com>
 <20190821140632.GI3111@dhcp22.suse.cz>
 <20190826204420.GA16800@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190826204420.GA16800@bharath12345-Inspiron-5559>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 02:14:20, Bharath Vedartham wrote:
> Hi Michal,
> 
> Here are some of my thoughts,
> On Wed, Aug 21, 2019 at 04:06:32PM +0200, Michal Hocko wrote:
> > On Thu 15-08-19 14:51:04, Khalid Aziz wrote:
> > > Hi Michal,
> > > 
> > > The smarts for tuning these knobs can be implemented in userspace and
> > > more knobs added to allow for what is missing today, but we get back to
> > > the same issue as before. That does nothing to make kernel self-tuning
> > > and adds possibly even more knobs to userspace. Something so fundamental
> > > to kernel memory management as making free pages available when they are
> > > needed really should be taken care of in the kernel itself. Moving it to
> > > userspace just means the kernel is hobbled unless one installs and tunes
> > > a userspace package correctly.
> > 
> > From my past experience the existing autotunig works mostly ok for a
> > vast variety of workloads. A more clever tuning is possible and people
> > are doing that already. Especially for cases when the machine is heavily
> > overcommited. There are different ways to achieve that. Your new
> > in-kernel auto tuning would have to be tested on a large variety of
> > workloads to be proven and riskless. So I am quite skeptical to be
> > honest.
> Could you give some references to such works regarding tuning the kernel? 

Talk to Facebook guys and their usage of PSI to control the memory
distribution and OOM situations.

> Essentially, Our idea here is to foresee potential memory exhaustion.
> This foreseeing is done by observing the workload, observing the memory
> usage of the workload. Based on this observations, we make a prediction
> whether or not memory exhaustion could occur.

I understand that and I am not disputing this can be useful. All I do
argue here is that there is unlikely a good "crystall ball" for most/all
workloads that would justify its inclusion into the kernel and that this
is something better done in the userspace where you can experiment and
tune the behavior for a particular workload of your interest.

Therefore I would like to shift the discussion towards existing APIs and
whether they are suitable for such an advance auto-tuning. I haven't
heard any arguments about missing pieces.

> If memory exhaustion
> occurs, we reclaim some more memory. kswapd stops reclaim when
> hwmark is reached. hwmark is usually set to a fairly low percentage of
> total memory, in my system for zone Normal hwmark is 13% of total pages.
> So there is scope for reclaiming more pages to make sure system does not
> suffer from a lack of pages. 

Yes and we have ways to control those watermarks that your monitoring
tool can use to alter the reclaim behavior.
 
[...]
> > Therefore I would really focus on discussing whether we have sufficient
> > APIs to tune the kernel to do the right thing when needed. That requires
> > to identify gaps in that area. 
> One thing that comes to my mind is based on the issue Khalid mentioned
> earlier on how his desktop took more than 30secs to boot up because of
> the caches using up a lot of memory.
> Rather than allowing any unused memory to be the page cache, would it be
> a good idea to fix a size for the caches and elastically change the size
> based on the workload?

I do not think so. Limiting the pagecache is unlikely to help as it is
really cheap to reclaim most of the time. In those cases when this is
not the case (e.g. the underlying FS needs to flush and/or metadata)
then the same would be possible in a restricted page cache situation
and you could easily end up stalled waiting for pagecache (e.g. any
executable/library) while there is a lot of memory.

I cannot comment on the Khalid's example because there were no details
there but I would be really surprised if the primary source of stall was
the pagecache.
-- 
Michal Hocko
SUSE Labs


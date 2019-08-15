Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FF99C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:02:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F091E206C1
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:02:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F091E206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BAF06B02D6; Thu, 15 Aug 2019 13:02:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76C186B02D8; Thu, 15 Aug 2019 13:02:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 681776B02D9; Thu, 15 Aug 2019 13:02:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0016.hostedemail.com [216.40.44.16])
	by kanga.kvack.org (Postfix) with ESMTP id 43E516B02D6
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:02:50 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0060663E6
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:02:49 +0000 (UTC)
X-FDA: 75825281700.16.hope81_52e15058a370c
X-HE-Tag: hope81_52e15058a370c
X-Filterd-Recvd-Size: 7792
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:02:49 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 95638AFF3;
	Thu, 15 Aug 2019 17:02:47 +0000 (UTC)
Date: Thu, 15 Aug 2019 19:02:15 +0200
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
Message-ID: <20190815170215.GQ9477@dhcp22.suse.cz>
References: <20190813014012.30232-1-khalid.aziz@oracle.com>
 <20190813140553.GK17933@dhcp22.suse.cz>
 <3cb0af00-f091-2f3e-d6cc-73a5171e6eda@oracle.com>
 <20190814085831.GS17933@dhcp22.suse.cz>
 <d3895804-7340-a7ae-d611-62913303e9c5@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d3895804-7340-a7ae-d611-62913303e9c5@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 10:27:26, Khalid Aziz wrote:
> On 8/14/19 2:58 AM, Michal Hocko wrote:
> > On Tue 13-08-19 09:20:51, Khalid Aziz wrote:
> >> On 8/13/19 8:05 AM, Michal Hocko wrote:
> >>> On Mon 12-08-19 19:40:10, Khalid Aziz wrote:
> >>> [...]
> >>>> Patch 1 adds code to maintain a sliding lookback window of (time, number
> >>>> of free pages) points which can be updated continuously and adds code to
> >>>> compute best fit line across these points. It also adds code to use the
> >>>> best fit lines to determine if kernel must start reclamation or
> >>>> compaction.
> >>>>
> >>>> Patch 2 adds code to collect data points on free pages of various orders
> >>>> at different points in time, uses code in patch 1 to update sliding
> >>>> lookback window with these points and kicks off reclamation or
> >>>> compaction based upon the results it gets.
> >>>
> >>> An important piece of information missing in your description is why
> >>> do we need to keep that logic in the kernel. In other words, we have
> >>> the background reclaim that acts on a wmark range and those are tunable
> >>> from the userspace. The primary point of this background reclaim is to
> >>> keep balance and prevent from direct reclaim. Why cannot you implement
> >>> this or any other dynamic trend watching watchdog and tune watermarks
> >>> accordingly? Something similar applies to kcompactd although we might be
> >>> lacking a good interface.
> >>>
> >>
> >> Hi Michal,
> >>
> >> That is a very good question. As a matter of fact the initial prototype
> >> to assess the feasibility of this approach was written in userspace for
> >> a very limited application. We wrote the initial prototype to monitor
> >> fragmentation and used /sys/devices/system/node/node*/compact to trigger
> >> compaction. The prototype demonstrated this approach has merits.
> >>
> >> The primary reason to implement this logic in the kernel is to make the
> >> kernel self-tuning.
> > 
> > What makes this particular self-tuning an universal win? In other words
> > there are many ways to analyze the memory pressure and feedback it back
> > that I can think of. It is quite likely that very specific workloads
> > would have very specific demands there. I have seen cases where are
> > trivial increase of min_free_kbytes to normally insane value worked
> > really great for a DB workload because the wasted memory didn't matter
> > for example.
> 
> Hi Michal,
> 
> The problem is not so much as do we have enough knobs available, rather
> how do we tweak them dynamically to avoid allocation stalls. Knobs like
> watermarks and min_free_kbytes are set once typically and left alone.

Does anything prevent from tuning these knobs more dynamically based on
already exported metrics?

> Allocation stalls show up even on much smaller scale than large DB or
> cloud platforms. I have seen it on a desktop class machine running a few
> services in the background. Desktop is running gnome3, I would lock the
> screen and come back to unlock it a day or two later. In that time most
> of memory has been consumed by buffer/page cache. Just unlocking the
> screen can take 30+ seconds while system reclaims pages to be able swap
> back in all the processes that were inactive so far.

This sounds like a bug to me.

> It is true different workloads will have different requirements and that
> is what I am attempting to address here. Instead of tweaking the knobs
> statically based upon one workload requirements, I am looking at the
> trend of memory consumption instead. A best fit line showing recent
> trend can be quite indicative of what the workload is doing in terms of
> memory.

Is there anything preventing from following that trend from the
userspace and trigger background reclaim earlier to not even get to the
direct reclaim though?

> For instance, a cloud server might be running a certain number
> of instances for a few days and it can end up using any memory not used
> up by tasks, for buffer/page cache. Now the sys admin gets a request to
> launch another instance and when they try to to do that, system starts
> to allocate pages and soon runs out of free pages. We are now in direct
> reclaim path and it can take significant amount of time to find all free
> pages the new task needs. If the kernel were watching the memory
> consumption trend instead, it could see that the trend line shows a
> complete exhaustion of free pages or 100% fragmentation in near future,
> irrespective of what the workload is.

I am confused now. How can an unpredictable action (like sys admin
starting a new workload) be handled by watching a memory consumption
history trend? From the above description I would expect that the system
would be in a balanced state for few days when a new instance is
launched. The only reasonable thing to do then is to trigger the reclaim
before the workload is spawned but then what is the actual difference
between direct reclaim and an early reclaim?

[...]
> > I agree on this point. Is the current set of tunning sufficient? What
> > would be missing if not?
> > 
> 
> We have knob available to force compaction immediately. That is helpful
> and in some case, sys admins have resorted to forcing compaction on all
> zones before launching a new cloud instance or loading a new database.
> Some admins have resorted to using /proc/sys/vm/drop_caches to force
> buffer/page cache pages to be freed up. Either of these solutions causes
> system load to go up immediately while kswapd/kcompactd run to free up
> and compact pages. This is far from ideal. Other knobs available seem to
> be hard to set correctly especially on servers that run mixed workloads
> which results in a regular stream of customer complaints coming in about
> system stalling at most inopportune times.

Then let's talk about what is missing in the existing tuning we already
provide. I do agree that compaction needs some love but I am under
impression that min_free_kbytes and watermark_*_factor should give a
decent abstraction to control the background reclaim. If that is not the
case then I am really interested on examples because I might be easily
missing something there.

Thanks!
-- 
Michal Hocko
SUSE Labs


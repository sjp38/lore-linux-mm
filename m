Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54136C3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 13:15:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 234542070B
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 13:15:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 234542070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A768F6B0005; Wed, 28 Aug 2019 09:15:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A27686B000E; Wed, 28 Aug 2019 09:15:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9167C6B0010; Wed, 28 Aug 2019 09:15:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0235.hostedemail.com [216.40.44.235])
	by kanga.kvack.org (Postfix) with ESMTP id 7109C6B0005
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 09:15:05 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 01118180AD802
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 13:15:05 +0000 (UTC)
X-FDA: 75871882170.05.shirt36_f379cbc73e16
X-HE-Tag: shirt36_f379cbc73e16
X-Filterd-Recvd-Size: 2873
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 13:15:04 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9C991AFA4;
	Wed, 28 Aug 2019 13:15:02 +0000 (UTC)
Date: Wed, 28 Aug 2019 15:15:01 +0200
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
Message-ID: <20190828131501.GK28313@dhcp22.suse.cz>
References: <20190813140553.GK17933@dhcp22.suse.cz>
 <3cb0af00-f091-2f3e-d6cc-73a5171e6eda@oracle.com>
 <20190814085831.GS17933@dhcp22.suse.cz>
 <d3895804-7340-a7ae-d611-62913303e9c5@oracle.com>
 <20190815170215.GQ9477@dhcp22.suse.cz>
 <2668ad2e-ee52-8c88-22c0-1952243af5a1@oracle.com>
 <20190821140632.GI3111@dhcp22.suse.cz>
 <20190826204420.GA16800@bharath12345-Inspiron-5559>
 <20190827061606.GN7538@dhcp22.suse.cz>
 <20190828130922.GA10127@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190828130922.GA10127@bharath12345-Inspiron-5559>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 28-08-19 18:39:22, Bharath Vedartham wrote:
[...]
> > Therefore I would like to shift the discussion towards existing APIs and
> > whether they are suitable for such an advance auto-tuning. I haven't
> > heard any arguments about missing pieces.
> I understand your concern here. Just confirming, by APIs you are
> referring to sysctls, sysfs files and stuff like that right?

Yup

> > > If memory exhaustion
> > > occurs, we reclaim some more memory. kswapd stops reclaim when
> > > hwmark is reached. hwmark is usually set to a fairly low percentage of
> > > total memory, in my system for zone Normal hwmark is 13% of total pages.
> > > So there is scope for reclaiming more pages to make sure system does not
> > > suffer from a lack of pages. 
> > 
> > Yes and we have ways to control those watermarks that your monitoring
> > tool can use to alter the reclaim behavior.
> Just to confirm here, I am aware of one way which is to alter
> min_kfree_bytes values. What other ways are there to alter watermarks
> from user space? 

/proc/sys/vm/watermark_*factor
-- 
Michal Hocko
SUSE Labs


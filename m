Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBA13C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 11:07:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95680207FC
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 11:07:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95680207FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FEFD6B0003; Tue, 10 Sep 2019 07:07:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AE996B0006; Tue, 10 Sep 2019 07:07:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C55F6B0007; Tue, 10 Sep 2019 07:07:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0107.hostedemail.com [216.40.44.107])
	by kanga.kvack.org (Postfix) with ESMTP id EE5AE6B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:07:47 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9F900181AC9B6
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 11:07:47 +0000 (UTC)
X-FDA: 75918735774.29.house23_611c369ca8b28
X-HE-Tag: house23_611c369ca8b28
X-Filterd-Recvd-Size: 2297
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 11:07:47 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 63F6FB71D;
	Tue, 10 Sep 2019 11:07:45 +0000 (UTC)
Date: Tue, 10 Sep 2019 13:07:41 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, l.roehrs@profihost.ag,
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: lot of MemAvailable but falling cache and raising PSI
Message-ID: <20190910110741.GR2063@dhcp22.suse.cz>
References: <88ff0310-b9ab-36b6-d8ab-b6edd484d973@profihost.ag>
 <20190909122852.GM27159@dhcp22.suse.cz>
 <2d04fc69-8fac-2900-013b-7377ca5fd9a8@profihost.ag>
 <20190909124950.GN27159@dhcp22.suse.cz>
 <10fa0b97-631d-f82b-0881-89adb9ad5ded@profihost.ag>
 <52235eda-ffe2-721c-7ad7-575048e2d29d@profihost.ag>
 <20190910082919.GL2063@dhcp22.suse.cz>
 <132e1fd0-c392-c158-8f3a-20e340e542f0@profihost.ag>
 <20190910090241.GM2063@dhcp22.suse.cz>
 <743a047e-a46f-32fa-1fe4-a9bd8f09ed87@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <743a047e-a46f-32fa-1fe4-a9bd8f09ed87@profihost.ag>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 10-09-19 11:37:19, Stefan Priebe - Profihost AG wrote:
> 
> Am 10.09.19 um 11:02 schrieb Michal Hocko:
> > On Tue 10-09-19 10:38:25, Stefan Priebe - Profihost AG wrote:
[...]
> >> /sys/kernel/mm/transparent_hugepage/defrag:always defer [defer+madvise]
> >> madvise never
[...]
> > Many processes hitting the reclaim are php5 others I cannot say because
> > their cmd is not reflected in the trace. I suspect those are using
> > madvise. I haven't really seen kcompactd interfering much. That would
> > suggest using defer.
> 
> You mean i should set transparent_hugepage to defer?

Let's try with 5.3 without any changes first and then if the problem is
still reproducible then limit the THP load by setting
transparent_hugepage to defer.
-- 
Michal Hocko
SUSE Labs


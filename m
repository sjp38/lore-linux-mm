Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9573BC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:05:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44CD02085A
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:05:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44CD02085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDDC16B0006; Tue, 13 Aug 2019 10:05:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB5BA6B0007; Tue, 13 Aug 2019 10:05:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCB296B0008; Tue, 13 Aug 2019 10:05:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0022.hostedemail.com [216.40.44.22])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1AC6B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:05:56 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 44CCF8248AA2
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:05:56 +0000 (UTC)
X-FDA: 75817578312.17.form87_16ad66d50ac30
X-HE-Tag: form87_16ad66d50ac30
X-Filterd-Recvd-Size: 2465
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:05:55 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 06D4CADF1;
	Tue, 13 Aug 2019 14:05:53 +0000 (UTC)
Date: Tue, 13 Aug 2019 16:05:53 +0200
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
Message-ID: <20190813140553.GK17933@dhcp22.suse.cz>
References: <20190813014012.30232-1-khalid.aziz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813014012.30232-1-khalid.aziz@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 12-08-19 19:40:10, Khalid Aziz wrote:
[...]
> Patch 1 adds code to maintain a sliding lookback window of (time, number
> of free pages) points which can be updated continuously and adds code to
> compute best fit line across these points. It also adds code to use the
> best fit lines to determine if kernel must start reclamation or
> compaction.
> 
> Patch 2 adds code to collect data points on free pages of various orders
> at different points in time, uses code in patch 1 to update sliding
> lookback window with these points and kicks off reclamation or
> compaction based upon the results it gets.

An important piece of information missing in your description is why
do we need to keep that logic in the kernel. In other words, we have
the background reclaim that acts on a wmark range and those are tunable
from the userspace. The primary point of this background reclaim is to
keep balance and prevent from direct reclaim. Why cannot you implement
this or any other dynamic trend watching watchdog and tune watermarks
accordingly? Something similar applies to kcompactd although we might be
lacking a good interface.
-- 
Michal Hocko
SUSE Labs


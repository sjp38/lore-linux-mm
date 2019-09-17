Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 900A0C4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 19:46:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2298420862
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 19:46:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="H3lwO7CA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2298420862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C86B96B0005; Tue, 17 Sep 2019 15:46:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C122D6B0006; Tue, 17 Sep 2019 15:46:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB0E46B0007; Tue, 17 Sep 2019 15:46:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0106.hostedemail.com [216.40.44.106])
	by kanga.kvack.org (Postfix) with ESMTP id 84DBF6B0005
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 15:46:34 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 17E538243773
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 19:46:34 +0000 (UTC)
X-FDA: 75945444708.02.wash31_56594d6542f20
X-HE-Tag: wash31_56594d6542f20
X-Filterd-Recvd-Size: 4466
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 19:46:33 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d81381c0000>; Tue, 17 Sep 2019 12:46:36 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 17 Sep 2019 12:46:31 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 17 Sep 2019 12:46:31 -0700
Received: from DRHQMAIL107.nvidia.com (10.27.9.16) by HQMAIL111.nvidia.com
 (172.20.187.18) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 17 Sep
 2019 19:46:31 +0000
Received: from [10.110.48.28] (10.124.1.5) by DRHQMAIL107.nvidia.com
 (10.27.9.16) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 17 Sep
 2019 19:46:30 +0000
Subject: Re: [RFC] mm: Proactive compaction
To: David Rientjes <rientjes@google.com>, Nitin Gupta <nigupta@nvidia.com>
CC: <akpm@linux-foundation.org>, <vbabka@suse.cz>,
	<mgorman@techsingularity.net>, <mhocko@suse.com>, <dan.j.williams@intel.com>,
	Yu Zhao <yuzhao@google.com>, Matthew Wilcox <willy@infradead.org>, Qian Cai
	<cai@lca.pw>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Gushchin
	<guro@fb.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook
	<keescook@chromium.org>, Jann Horn <jannh@google.com>, Johannes Weiner
	<hannes@cmpxchg.org>, Arun KS <arunks@codeaurora.org>, Janne Huttunen
	<janne.huttunen@nokia.com>, Konstantin Khlebnikov
	<khlebnikov@yandex-team.ru>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>
References: <20190816214413.15006-1-nigupta@nvidia.com>
 <alpine.DEB.2.21.1909161312050.118156@chino.kir.corp.google.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <f4a74669-b86b-741a-1c2b-c117878734c6@nvidia.com>
Date: Tue, 17 Sep 2019 12:46:30 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1909161312050.118156@chino.kir.corp.google.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL111.nvidia.com (172.20.187.18) To
 DRHQMAIL107.nvidia.com (10.27.9.16)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1568749596; bh=ICApskehWZ+VHjtM6MdvX/EWpZT2hl1TSrK5Y2YuIuA=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=H3lwO7CAA2MX6AHwC83mYZwlAuWg8YsR3YGYA7ln6wY8fXQooVBFBY+9uLFs4kC16
	 8j6CFK0qwbsk51qmDxNk4eymo+M+q7WrvbBhYSzmRf7NYCcp8VEGVallaJQgLWDLix
	 J93s0HhFMSkzzqIE/EJunEuSZxxApWJ2Rt6yY0YYXfoVrnYcTLBeaiycJMeWwvYV0t
	 Qq9qPep71ROiwepIVFo0xwXuWnHkwtyovUMswHznXSahDT6Dr4R2Wz3v0KP5nRoHe8
	 wO3UL/KDMfNTv1VJe8oVcLXcSDQVbTFprTO9gJphAMQkJWLFMSg1r1AeH/wGWAMuys
	 5HznIP7KZkP0g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/16/19 1:16 PM, David Rientjes wrote:
> On Fri, 16 Aug 2019, Nitin Gupta wrote:
...
> 
> We've had good success with periodically compacting memory on a regular 
> cadence on systems with hugepages enabled.  The cadence itself is defined 
> by the admin but it causes khugepaged[*] to periodically wakeup and invoke 
> compaction in an attempt to keep zones as defragmented as possible 

That's an important data point, thanks for reporting it. 

And given that we have at least one data point validating it, I think we
should feel fairly comfortable with this approach. Because the sys admin 
probably knows  when are the best times to steal cpu cycles and recover 
some huge pages. Unlike the kernel, the sys admin can actually see the 
future sometimes, because he/she may know what is going to be run.

It's still sounding like we can expect excellent results from simply 
defragmenting from user space, via a chron job and/or before running
important tests, rather than trying to have the kernel guess whether 
it's a performance win to defragment at some particular time.

Are you using existing interfaces, or did you need to add something? How
exactly are you triggering compaction?

thanks,
-- 
John Hubbard
NVIDIA


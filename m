Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 703C4C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 15:33:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F1532085A
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 15:33:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="e8BegBER"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F1532085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE1346B0003; Mon, 12 Aug 2019 11:33:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A91D06B0005; Mon, 12 Aug 2019 11:33:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A72C6B0006; Mon, 12 Aug 2019 11:33:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0110.hostedemail.com [216.40.44.110])
	by kanga.kvack.org (Postfix) with ESMTP id 731C76B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 11:33:30 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 230F02C34
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:33:30 +0000 (UTC)
X-FDA: 75814170180.20.rings08_164da9bf0944
X-HE-Tag: rings08_164da9bf0944
X-Filterd-Recvd-Size: 5263
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:33:29 +0000 (UTC)
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2A56B20842;
	Mon, 12 Aug 2019 15:33:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565624008;
	bh=QtfQ78Bnjj9j6GAMKkCbTh3I+CsGlnBb8q2o4h3Zh7c=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=e8BegBER7yTbxIT/bYQSs8dCHdrpvdJz0W3VZcE8SP3XJ3o4kkUl9VdM8ZVLYYLH8
	 VJ6dH7MkUQ4E0OudYaA2pGQyATkVuNf2zmreph3KVSNKJZ30DbsRsiCYcjIZmuf2jD
	 6LewvgKi7OlexmQY7n0nUhxtUH8aZP65luN64uBY=
Date: Mon, 12 Aug 2019 11:33:26 -0400
From: Sasha Levin <sashal@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, ltp@lists.linux.it,
	Li Wang <liwang@redhat.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Cyril Hrubis <chrubis@suse.cz>, xishi.qiuxishi@alibaba-inc.com
Subject: Re: [PATCH] hugetlbfs: fix hugetlb page migration/fault race causing
 SIGBUS
Message-ID: <20190812153326.GB17747@sasha-vm>
References: <20190808074736.GJ11812@dhcp22.suse.cz>
 <416ee59e-9ae8-f72d-1b26-4d3d31501330@oracle.com>
 <20190808185313.GG18351@dhcp22.suse.cz>
 <20190808163928.118f8da4f4289f7c51b8ffd4@linux-foundation.org>
 <20190809064633.GK18351@dhcp22.suse.cz>
 <20190809151718.d285cd1f6d0f1cf02cb93dc8@linux-foundation.org>
 <20190811234614.GZ17747@sasha-vm>
 <20190812084524.GC5117@dhcp22.suse.cz>
 <39b59001-55c1-a98b-75df-3a5dcec74504@suse.cz>
 <20190812132226.GI5117@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190812132226.GI5117@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 03:22:26PM +0200, Michal Hocko wrote:
>On Mon 12-08-19 15:14:12, Vlastimil Babka wrote:
>> On 8/12/19 10:45 AM, Michal Hocko wrote:
>> > On Sun 11-08-19 19:46:14, Sasha Levin wrote:
>> >> On Fri, Aug 09, 2019 at 03:17:18PM -0700, Andrew Morton wrote:
>> >>> On Fri, 9 Aug 2019 08:46:33 +0200 Michal Hocko <mhocko@kernel.org> wrote:
>> >>>
>> >>> It should work if we ask stable trees maintainers not to backport
>> >>> such patches.
>> >>>
>> >>> Sasha, please don't backport patches which are marked Fixes-no-stable:
>> >>> and which lack a cc:stable tag.
>> >>
>> >> I'll add it to my filter, thank you!
>> >
>> > I would really prefer to stick with Fixes: tag and stable only picking
>> > up cc: stable patches. I really hate to see workarounds for sensible
>> > workflows (marking the Fixes) just because we are trying to hide
>> > something from stable maintainers. Seriously, if stable maintainers have
>> > a different idea about what should be backported, it is their call. They
>> > are the ones to deal with regressions and the backporting effort in
>> > those cases of disagreement.
>>
>> +1 on not replacing Fixes: tag with some other name, as there might be
>> automation (not just at SUSE) relying on it.
>> As a compromise, we can use something else to convey the "maintainers
>> really don't recommend a stable backport", that Sasha can add to his filter.
>> Perhaps counter-intuitively, but it could even look like this:
>> Cc: stable@vger.kernel.org # not recommended at all by maintainer
>
>I thought that absence of the Cc is the indication :P. Anyway, I really
>do not understand why should we bother, really. I have tried to explain
>that stable maintainers should follow Cc: stable because we bother to
>consider that part and we are quite good at not forgetting (Thanks
>Andrew for persistence). Sasha has told me that MM will be blacklisted
>from automagic selection procedure.

I'll add mm/ to the ignore list for AUTOSEL patches.

>I really do not know much more we can do and I really have strong doubts
>we should care at all. What is the worst that can happen? A potentially
>dangerous commit gets to the stable tree and that blows up? That is
>something that is something inherent when relying on AI and
>aplies-it-must-be-ok workflow.

The issue I see here is that there's no way to validate the patches that
go in mm/. I'd happily run whatever test suite you use to validate these
patches, but it doesn't exist.

I can run xfstests for fs/, I can run blktests for block/, I can run
kselftests for quite a few other subsystems in the kernel. What can I
run for mm?

I'd be happy to run whatever validation/regression suite for mm/ you
would suggest.

I've heard the "every patch is a snowflake" story quite a few times, and
I understand that most mm/ patches are complex, but we agree that
manually testing every patch isn't scalable, right? Even for patches
that mm/ tags for stable, are they actually tested on every stable tree?
How is it different from the "aplies-it-must-be-ok workflow"?

--
Thanks,
Sasha


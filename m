Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18E27C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:37:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C56DF2070C
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:37:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="xHPKjAQr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C56DF2070C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E9136B0003; Mon, 12 Aug 2019 17:37:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6730E6B0005; Mon, 12 Aug 2019 17:37:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5396D6B0006; Mon, 12 Aug 2019 17:37:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0211.hostedemail.com [216.40.44.211])
	by kanga.kvack.org (Postfix) with ESMTP id 2AE396B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:37:34 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D7BA3181AC9B4
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:37:33 +0000 (UTC)
X-FDA: 75815087586.21.sense58_7c33cffe2711c
X-HE-Tag: sense58_7c33cffe2711c
X-Filterd-Recvd-Size: 3238
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:37:33 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 25FB2206C1;
	Mon, 12 Aug 2019 21:37:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565645852;
	bh=07tJJiA2VR08JnF9uwMOoDCaKsZwYqGb2v9SvApZzMc=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=xHPKjAQr8eR3Ys5t2F8n8lhJx/sQg6Qgi3Km8sf0/tf137IyaQhuxWflV6htZbHui
	 kpSIg+UULX+BoKkMpAo+Sx8XyPE8Jl/KJ3HJq7Aevp+VoNDiBBFPV+L4dhqxK59Toh
	 kUg/XzZ9wWOiMo6oYMgEAxSGz3yUuPiS3S+nDnYg=
Date: Mon, 12 Aug 2019 14:37:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mike
 Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, ltp@lists.linux.it, Li Wang
 <liwang@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Cyril
 Hrubis <chrubis@suse.cz>, xishi.qiuxishi@alibaba-inc.com
Subject: Re: [PATCH] hugetlbfs: fix hugetlb page migration/fault race
 causing SIGBUS
Message-Id: <20190812143731.3f46b952e53ff3434e04bcf9@linux-foundation.org>
In-Reply-To: <20190812153326.GB17747@sasha-vm>
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
	<20190812153326.GB17747@sasha-vm>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Aug 2019 11:33:26 -0400 Sasha Levin <sashal@kernel.org> wrote:

> >I thought that absence of the Cc is the indication :P. Anyway, I really
> >do not understand why should we bother, really. I have tried to explain
> >that stable maintainers should follow Cc: stable because we bother to
> >consider that part and we are quite good at not forgetting (Thanks
> >Andrew for persistence). Sasha has told me that MM will be blacklisted
> >from automagic selection procedure.
> 
> I'll add mm/ to the ignore list for AUTOSEL patches.

Thanks, I'm OK with that.  I'll undo Fixes-no-stable.

Although I'd prefer that "akpm" was ignored, rather than "./mm/". 
Plenty of "mm" patches don't touch mm/, such as drivers/base/memory.c,
include/linux/blah, fs/, etc.  And I am diligent about considering
-stable for all the other code I look after.

This doesn't mean that I'm correct all the time, by any means - I'd
like to hear about patches which autosel thinks should be backported
but which don't include the c:stable tag.



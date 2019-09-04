Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8AABC3A59E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 23:12:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F5EA21726
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 23:12:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="G4fn03uV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F5EA21726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9AEF6B0005; Wed,  4 Sep 2019 19:12:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4BB36B0006; Wed,  4 Sep 2019 19:12:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3A246B0007; Wed,  4 Sep 2019 19:12:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0020.hostedemail.com [216.40.44.20])
	by kanga.kvack.org (Postfix) with ESMTP id 91A986B0005
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 19:12:38 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2784C18DD
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 23:12:38 +0000 (UTC)
X-FDA: 75898789596.08.robin71_6e378cc31b853
X-HE-Tag: robin71_6e378cc31b853
X-Filterd-Recvd-Size: 4277
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com [216.228.121.143])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 23:12:37 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d7044e40000>; Wed, 04 Sep 2019 16:12:36 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 04 Sep 2019 16:12:35 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 04 Sep 2019 16:12:35 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 4 Sep
 2019 23:12:35 +0000
Subject: Re: [RFC PATCH v2 02/19] fs/locks: Add Exclusive flag to user Layout
 lease
To: <ira.weiny@intel.com>, Andrew Morton <akpm@linux-foundation.org>
CC: Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Theodore Ts'o
	<tytso@mit.edu>, Michal Hocko <mhocko@suse.com>, Dave Chinner
	<david@fromorbit.com>, <linux-xfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-nvdimm@lists.01.org>,
	<linux-ext4@vger.kernel.org>, <linux-mm@kvack.org>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-3-ira.weiny@intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <69a7c037-6b4b-dbe3-2b42-77f85043b9eb@nvidia.com>
Date: Wed, 4 Sep 2019 16:12:35 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809225833.6657-3-ira.weiny@intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1567638756; bh=KcHEqM2TNQedobjZznlViJ4AvUuHmWBw0j98IvGFhfc=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=G4fn03uVMA7J4UC1m9Yj7DhfsqKE5JCNHVM+oBqTe0AR3ZAlGEFmH7YKmkjPCmtCQ
	 LUvXJdUANpLjlNJVqXY9TBqjeHx+L53SCBVVR7cf/kJBTDzGJICMvneFxnJ/bznKdv
	 dNrJ4yQD+F1DCobVh03UMVVgaQfrILzPPrM7GeO2NaLVNZG5LHBQIJvvbOmoaMH7bs
	 msCDq0E+I3UeIhdWC/toHOT1SlxdWDyKPOg3HjVgFJReZrxpb8PrvSxEcypog9tmYA
	 zj992eW84rG8B8gGL5qOlDh0yQONipgKi9UW/dLLh2vAF7f5ffKJVuuRAS6ttv/Rev
	 x8kDOD2mdY4mQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/9/19 3:58 PM, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> Add an exclusive lease flag which indicates that the layout mechanism
> can not be broken.

After studying the rest of these discussions extensively, I think in all
cases FL_EXCLUSIVE is better named "unbreakable", rather than exclusive.

If you read your sentence above, it basically reinforces that idea: "add an
exclusive flag to mean it is unbreakable" is a bit of a disconnect. It 
would be better to say,

Add an "unbreakable" lease flag which indicates that the layout lease
cannot be broken.

Furthermore, while this may or may not be a way forward on the "we cannot
have more than one process take a layout lease on a file/range", it at
least stops making it impossible. In other words, no one is going to
write a patch that allows sharing an exclusive layout lease--but someone
might well update some of these patches here to make it possible to
have multiple processes take unbreakable leases on the same file/range.

I haven't worked through everything there yet, but again:

* FL_UNBREAKABLE is the name you're looking for here, and

* I think we want to allow multiple processes to take FL_UNBREAKABLE
leases on the same file/range, so that we can make RDMA setups
reasonable. By "reasonable" I mean, "no need to have a lead process
that owns all the leases".



thanks,
-- 
John Hubbard
NVIDIA


Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C910C32753
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 17:56:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C89282064A
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 17:56:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="r1myjWjQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C89282064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68D616B0005; Tue, 13 Aug 2019 13:56:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63F686B0006; Tue, 13 Aug 2019 13:56:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 505B96B0007; Tue, 13 Aug 2019 13:56:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0080.hostedemail.com [216.40.44.80])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5D96B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:56:55 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D4B4A181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:56:54 +0000 (UTC)
X-FDA: 75818160348.25.edge91_20d374a4b104
X-HE-Tag: edge91_20d374a4b104
X-Filterd-Recvd-Size: 4001
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com [216.228.121.64])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:56:53 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d52f9ef0000>; Tue, 13 Aug 2019 10:57:03 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 13 Aug 2019 10:56:52 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 13 Aug 2019 10:56:52 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 13 Aug
 2019 17:56:51 +0000
Subject: Re: [RFC PATCH v2 15/19] mm/gup: Introduce vaddr_pin_pages()
To: Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>
CC: Andrew Morton <akpm@linux-foundation.org>, Dan Williams
	<dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Jan Kara
	<jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, Michal Hocko
	<mhocko@suse.com>, Dave Chinner <david@fromorbit.com>,
	<linux-xfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-nvdimm@lists.01.org>, <linux-ext4@vger.kernel.org>,
	<linux-mm@kvack.org>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-16-ira.weiny@intel.com>
 <20190812122814.GC24457@ziepe.ca>
 <20190812214854.GF20634@iweiny-DESK2.sc.intel.com>
 <20190813114706.GA29508@ziepe.ca>
 <20190813174635.GC11882@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <95b05c4f-0bd6-ac31-20a2-28ee761c6238@nvidia.com>
Date: Tue, 13 Aug 2019 10:56:51 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190813174635.GC11882@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565719023; bh=KDoBH7FMcOFVaHbTNky7KSvvCBIevQY0atcdz7yZpyo=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=r1myjWjQb9mZf2jmH/nl8EOm2qt2HUka2TVsF2Jum+qndnndTVwaD2327vhXLSeCi
	 XIpGwaKAZwWCMLAlTX/kfRa98I9xBwpMhAZ6eTqZRPz4zmMPa7tC2viy+Eub4ulUG/
	 fSd52XCv1zuDNwzHlnr6RMY/WlH/M4OFEPUek/8HPyi9Vdb1JGuOUy8IiDorNa+3Ua
	 2c/160jTWmEuUnof8/fNzqwgbNxD4seyIajR2G3YwfSZ/dqoIJN7D6+C64cqw5CxFF
	 Q03mIRJipiEmdnJCLEzKxeQsVQgOdkVfG2OprbuepROCdrgWbL6zWz92e+Qp+ecaJ4
	 wPrDn3x7NUcew==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/13/19 10:46 AM, Ira Weiny wrote:
> On Tue, Aug 13, 2019 at 08:47:06AM -0300, Jason Gunthorpe wrote:
>> On Mon, Aug 12, 2019 at 02:48:55PM -0700, Ira Weiny wrote:
>>> On Mon, Aug 12, 2019 at 09:28:14AM -0300, Jason Gunthorpe wrote:
>>>> On Fri, Aug 09, 2019 at 03:58:29PM -0700, ira.weiny@intel.com wrote:
>>>>> From: Ira Weiny <ira.weiny@intel.com>
...
>>> So I'm open to suggestions.  Jan gave me this one, so I figured it was safer to
>>> suggest it...
>>
>> Should have the word user in it, imho
> 
> Fair enough...
> 
> user_addr_pin_pages(void __user * addr, ...) ?
> 
> uaddr_pin_pages(void __user * addr, ...) ?
> 
> I think I like uaddr...
> 

Better to spell out "user". "u" prefixes are used for "unsigned" and it
is just too ambiguous here. Maybe:

    vaddr_pin_user_pages()

...which also sounds close enough to get_user_pages() that a bit of
history and continuity is preserved, too.



thanks,
-- 
John Hubbard
NVIDIA


Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1C90C3A5A1
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 03:11:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 860B1218BA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 03:11:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="CZ4ZI+y0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 860B1218BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 259866B0007; Mon, 19 Aug 2019 23:11:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 209B26B0008; Mon, 19 Aug 2019 23:11:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F7A96B000A; Mon, 19 Aug 2019 23:11:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0128.hostedemail.com [216.40.44.128])
	by kanga.kvack.org (Postfix) with ESMTP id DCBA36B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 23:11:30 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 89BA9181AC9AE
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 03:11:30 +0000 (UTC)
X-FDA: 75841330740.12.frog41_643d482d78343
X-HE-Tag: frog41_643d482d78343
X-Filterd-Recvd-Size: 5230
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 03:11:28 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d5b64df0000>; Mon, 19 Aug 2019 20:11:27 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 19 Aug 2019 20:11:27 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 19 Aug 2019 20:11:27 -0700
Received: from DRHQMAIL107.nvidia.com (10.27.9.16) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 20 Aug
 2019 03:11:26 +0000
Received: from [10.2.161.11] (10.124.1.5) by DRHQMAIL107.nvidia.com
 (10.27.9.16) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 20 Aug
 2019 03:11:26 +0000
Subject: Re: [RFC PATCH v2 00/19] RDMA/FS DAX truncate proposal V1,000,002 ;-)
To: Dave Chinner <david@fromorbit.com>
CC: Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>, Andrew Morton
	<akpm@linux-foundation.org>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams
	<dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, "Theodore
 Ts'o" <tytso@mit.edu>, Michal Hocko <mhocko@suse.com>,
	<linux-xfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-nvdimm@lists.01.org>, <linux-ext4@vger.kernel.org>,
	<linux-mm@kvack.org>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190814101714.GA26273@quack2.suse.cz>
 <20190814180848.GB31490@iweiny-DESK2.sc.intel.com>
 <20190815130558.GF14313@quack2.suse.cz>
 <20190816190528.GB371@iweiny-DESK2.sc.intel.com>
 <20190817022603.GW6129@dread.disaster.area>
 <20190819063412.GA20455@quack2.suse.cz>
 <20190819092409.GM7777@dread.disaster.area>
 <ae64491b-85f8-eeca-14e8-2f09caf8abd2@nvidia.com>
 <20190820012021.GQ7777@dread.disaster.area>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <84318b51-bd07-1d9b-d842-e65cac2ff484@nvidia.com>
Date: Mon, 19 Aug 2019 20:09:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190820012021.GQ7777@dread.disaster.area>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 DRHQMAIL107.nvidia.com (10.27.9.16)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566270687; bh=AKYDp6zi8g/3Ey7Fk8otUT5V262BqzkSQ0q+IcrDmeo=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=CZ4ZI+y0zL6VhLHNeKaQ2BvucdquPt4NgzTapmdwmc3GH3ircx3XCkVaxgGV+d4sV
	 NV4xzAxkdZ0qipuq6cmTMvEo0GkMUZ0LA3h8jLsrhtdUSK7LJYDcORQUkb27HU5iJS
	 D8J/timtnz1ic6DmnMqDlno5UI+SPuaRVL4k6cJ9e1Yy2OisErHDl40bOiFkRHVohj
	 dvzXeKjnkRwCke55psIxtF5KXQ3oFpQTgwnRbtrvqucZqN39Wqb3XG4Rtkggo8WdSf
	 UF27W8iph40Uw6qp5h0XPXa7CrDBm9DA/1RdEpAz6OMTNS7ZEHj/b9rS0k4Y8oW/rq
	 ihGqFKtG8v2lg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/19/19 6:20 PM, Dave Chinner wrote:
> On Mon, Aug 19, 2019 at 05:05:53PM -0700, John Hubbard wrote:
>> On 8/19/19 2:24 AM, Dave Chinner wrote:
>>> On Mon, Aug 19, 2019 at 08:34:12AM +0200, Jan Kara wrote:
>>>> On Sat 17-08-19 12:26:03, Dave Chinner wrote:
>>>>> On Fri, Aug 16, 2019 at 12:05:28PM -0700, Ira Weiny wrote:
>>>>>> On Thu, Aug 15, 2019 at 03:05:58PM +0200, Jan Kara wrote:
>>>>>>> On Wed 14-08-19 11:08:49, Ira Weiny wrote:
>>>>>>>> On Wed, Aug 14, 2019 at 12:17:14PM +0200, Jan Kara wrote:
>> ...
>>
>> Any thoughts about sockets? I'm looking at net/xdp/xdp_umem.c which pins
>> memory with FOLL_LONGTERM, and wondering how to make that work here.
> 
> I'm not sure how this interacts with file mappings? I mean, this
> is just pinning anonymous pages for direct data placement into
> userspace, right?
> 
> Are you asking "what if this pinned memory was a file mapping?",
> or something else?

Yes, mainly that one. Especially since the FOLL_LONGTERM flag is
already there in xdp_umem_pin_pages(), unconditionally. So the
simple rules about struct *vaddr_pin usage (set it to NULL if FOLL_LONGTERM is
not set) are not going to work here.


> 
>> These are close to files, in how they're handled, but just different
>> enough that it's not clear to me how to make work with this system.
> 
> I'm guessing that if they are pinning a file backed mapping, they
> are trying to dma direct to the file (zero copy into page cache?)
> and so they'll need to either play by ODP rules or take layout
> leases, too....
> 

OK. I was just wondering if there was some simple way to dig up a
struct file associated with a socket (I don't think so), but it sounds
like this is an exercise that's potentially different for each subsystem.

thanks,
-- 
John Hubbard
NVIDIA


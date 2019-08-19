Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D561C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 19:32:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33D27206C1
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 19:32:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="LlnJzVxf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33D27206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A4D86B0007; Mon, 19 Aug 2019 15:32:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 954C76B0008; Mon, 19 Aug 2019 15:32:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86B7D6B000A; Mon, 19 Aug 2019 15:32:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0229.hostedemail.com [216.40.44.229])
	by kanga.kvack.org (Postfix) with ESMTP id 678016B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:32:20 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 1030D52D8
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:32:20 +0000 (UTC)
X-FDA: 75840173640.14.wing48_1423eb2b9d65c
X-HE-Tag: wing48_1423eb2b9d65c
X-Filterd-Recvd-Size: 4908
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:32:18 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d5af93b0001>; Mon, 19 Aug 2019 12:32:11 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 19 Aug 2019 12:32:11 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 19 Aug 2019 12:32:11 -0700
Received: from DRHQMAIL107.nvidia.com (10.27.9.16) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 19 Aug
 2019 19:32:11 +0000
Received: from [10.2.161.11] (10.124.1.5) by DRHQMAIL107.nvidia.com
 (10.27.9.16) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 19 Aug
 2019 19:32:11 +0000
Subject: Re: [Linux-kernel-mentees][PATCH v6 1/2] sgi-gru: Convert put_page()
 to put_user_page*()
To: Bharath Vedartham <linux.bhar@gmail.com>, Dimitri Sivanich
	<sivanich@hpe.com>, Andrew Morton <akpm@linux-foundation.org>
CC: <jglisse@redhat.com>, <ira.weiny@intel.com>, <gregkh@linuxfoundation.org>,
	<arnd@arndb.de>, <william.kucharski@oracle.com>, <hch@lst.de>,
	<inux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-kernel-mentees@lists.linuxfoundation.org>,
	<linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>
References: <1566157135-9423-1-git-send-email-linux.bhar@gmail.com>
 <1566157135-9423-2-git-send-email-linux.bhar@gmail.com>
 <20190819125611.GA5808@hpe.com>
 <20190819190647.GA6261@bharath12345-Inspiron-5559>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <0c2ad29b-934c-ec30-66c3-b153baf1fba5@nvidia.com>
Date: Mon, 19 Aug 2019 12:30:18 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190819190647.GA6261@bharath12345-Inspiron-5559>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 DRHQMAIL107.nvidia.com (10.27.9.16)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566243131; bh=O1+zBKqCqZBRfmN9e8CVp5s+/FmYKv98YGRf5sf04P8=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=LlnJzVxff7rSopb5VOlbQQEyBfR8LJGnJjJtr6ctEwJXHz9nCk3t12nYZtK9E/pb4
	 NPiVaZegJA4RzmJAZfXJa7RTIcCUj2pDko281vNI4rt3to4zQwE5uNlqU2C8OA/CFw
	 2m5BK32y9ezYhJqt7xsNZ3NB3m53IN01dDOoJ1C8EMqPKaozA3vv9ATO3gQCSdXrwO
	 50OqgKs052g7MMdjIa57lKayaVgPrfP2X8VqXEHSrh9Uqlv6Ek4jDzGP9hX7VTjVRi
	 l/yZp/dyHaFYqUcnIeCalSS9LohslZVRzCGaCO+5vOzl8e2mEx1sYpNhTxj9IsuQfr
	 DzB8xF6Vdu7zQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/19/19 12:06 PM, Bharath Vedartham wrote:
> On Mon, Aug 19, 2019 at 07:56:11AM -0500, Dimitri Sivanich wrote:
>> Reviewed-by: Dimitri Sivanich <sivanich@hpe.com>
> Thanks!
> 
> John, would you like to take this patch into your miscellaneous
> conversions patch set?
> 

(+Andrew and Michal, so they know where all this is going.)

Sure, although that conversion series [1] is on a brief hold, because
there are additional conversions desired, and the API is still under
discussion. Also, reading between the lines of Michal's response [2]
about it, I think people would prefer that the next revision include
the following, for each conversion site:

Conversion of gup/put_page sites:

Before:

	get_user_pages(...);
	...
	for each page:
		put_page();

After:
	
	gup_flags |= FOLL_PIN; (maybe FOLL_LONGTERM in some cases)
	vaddr_pin_user_pages(...gup_flags...)
	...
	vaddr_unpin_user_pages(); /* which invokes put_user_page() */

Fortunately, it's not harmful for the simpler conversion from put_page()
to put_user_page() to happen first, and in fact those have usually led
to simplifications, paving the way to make it easier to call
vaddr_unpin_user_pages(), once it's ready. (And showing exactly what
to convert, too.)

So for now, I'm going to just build on top of Ira's tree, and once the
vaddr*() API settles down, I'll send out an updated series that attempts
to include the reviews and ACKs so far (I'll have to review them, but
make a note that review or ACK was done for part of the conversion),
and adds the additional gup(FOLL_PIN), and uses vaddr*() wrappers instead of
gup/pup.

[1] https://lore.kernel.org/r/20190807013340.9706-1-jhubbard@nvidia.com

[2] https://lore.kernel.org/r/20190809175210.GR18351@dhcp22.suse.cz


thanks,
-- 
John Hubbard
NVIDIA


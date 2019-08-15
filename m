Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31C26C433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 03:28:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3E47208C2
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 03:28:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3E47208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 981BF6B0003; Wed, 14 Aug 2019 23:28:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 931406B0005; Wed, 14 Aug 2019 23:28:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8210E6B0007; Wed, 14 Aug 2019 23:28:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0150.hostedemail.com [216.40.44.150])
	by kanga.kvack.org (Postfix) with ESMTP id 5D14A6B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 23:28:15 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C6B913AA8
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 03:28:14 +0000 (UTC)
X-FDA: 75823228908.21.power32_64efa2a206449
X-HE-Tag: power32_64efa2a206449
X-Filterd-Recvd-Size: 2683
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 03:28:13 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BD71CC055673;
	Thu, 15 Aug 2019 03:28:12 +0000 (UTC)
Received: from [10.72.12.184] (ovpn-12-184.pek2.redhat.com [10.72.12.184])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8A9C85D9DC;
	Thu, 15 Aug 2019 03:28:07 +0000 (UTC)
Subject: Re: [PATCH V5 0/9] Fixes for vhost metadata acceleration
To: Christoph Hellwig <hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190809054851.20118-1-jasowang@redhat.com>
 <20190810134948-mutt-send-email-mst@kernel.org>
 <360a3b91-1ac5-84c0-d34b-a4243fa748c4@redhat.com>
 <20190812054429-mutt-send-email-mst@kernel.org>
 <20190812130252.GE24457@ziepe.ca>
 <9a9641fe-b48f-f32a-eecc-af9c2f4fbe0e@redhat.com>
 <20190813115707.GC29508@ziepe.ca> <20190813164105.GD22640@infradead.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <bba46127-ea43-f9f3-eece-0910243782c5@redhat.com>
Date: Thu, 15 Aug 2019 11:28:05 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190813164105.GD22640@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 15 Aug 2019 03:28:12 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/14 =E4=B8=8A=E5=8D=8812:41, Christoph Hellwig wrote:
> On Tue, Aug 13, 2019 at 08:57:07AM -0300, Jason Gunthorpe wrote:
>> On Tue, Aug 13, 2019 at 04:31:07PM +0800, Jason Wang wrote:
>>
>>> What kind of issues do you see? Spinlock is to synchronize GUP with M=
MU
>>> notifier in this series.
>> A GUP that can't sleep can't pagefault which makes it a really weird
>> pattern
> get_user_pages/get_user_pages_fast must not be called under a spinlock.
> We have the somewhat misnamed __get_user_page_fast that just does a
> lookup for existing pages and never faults for a few places that need
> to do that lookup from contexts where we can't sleep.


Yes, I do use __get_user_pages_fast() in the code.

Thanks



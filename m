Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00EE9C0650F
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 02:45:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEE4F20651
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 02:44:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEE4F20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CD2D6B0003; Sun, 11 Aug 2019 22:44:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57E2F6B0005; Sun, 11 Aug 2019 22:44:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46D286B0006; Sun, 11 Aug 2019 22:44:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0112.hostedemail.com [216.40.44.112])
	by kanga.kvack.org (Postfix) with ESMTP id 20FB96B0003
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 22:44:59 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C187945A8
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 02:44:58 +0000 (UTC)
X-FDA: 75812233476.06.rings54_82bcb52fcf62c
X-HE-Tag: rings54_82bcb52fcf62c
X-Filterd-Recvd-Size: 3488
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 02:44:58 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DBAC63090FCF;
	Mon, 12 Aug 2019 02:44:56 +0000 (UTC)
Received: from [10.72.12.78] (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0273610016E8;
	Mon, 12 Aug 2019 02:44:51 +0000 (UTC)
Subject: Re: [PATCH V5 0/9] Fixes for vhost metadata acceleration
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 jgg@ziepe.ca
References: <20190809054851.20118-1-jasowang@redhat.com>
 <20190810134948-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <360a3b91-1ac5-84c0-d34b-a4243fa748c4@redhat.com>
Date: Mon, 12 Aug 2019 10:44:51 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190810134948-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Mon, 12 Aug 2019 02:44:57 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/11 =E4=B8=8A=E5=8D=881:52, Michael S. Tsirkin wrote:
> On Fri, Aug 09, 2019 at 01:48:42AM -0400, Jason Wang wrote:
>> Hi all:
>>
>> This series try to fix several issues introduced by meta data
>> accelreation series. Please review.
>>
>> Changes from V4:
>> - switch to use spinlock synchronize MMU notifier with accessors
>>
>> Changes from V3:
>> - remove the unnecessary patch
>>
>> Changes from V2:
>> - use seqlck helper to synchronize MMU notifier with vhost worker
>>
>> Changes from V1:
>> - try not use RCU to syncrhonize MMU notifier with vhost worker
>> - set dirty pages after no readers
>> - return -EAGAIN only when we find the range is overlapped with
>>    metadata
>>
>> Jason Wang (9):
>>    vhost: don't set uaddr for invalid address
>>    vhost: validate MMU notifier registration
>>    vhost: fix vhost map leak
>>    vhost: reset invalidate_count in vhost_set_vring_num_addr()
>>    vhost: mark dirty pages during map uninit
>>    vhost: don't do synchronize_rcu() in vhost_uninit_vq_maps()
>>    vhost: do not use RCU to synchronize MMU notifier with worker
>>    vhost: correctly set dirty pages in MMU notifiers callback
>>    vhost: do not return -EAGAIN for non blocking invalidation too earl=
y
>>
>>   drivers/vhost/vhost.c | 202 +++++++++++++++++++++++++---------------=
--
>>   drivers/vhost/vhost.h |   6 +-
>>   2 files changed, 122 insertions(+), 86 deletions(-)
> This generally looks more solid.
>
> But this amounts to a significant overhaul of the code.
>
> At this point how about we revert 7f466032dc9e5a61217f22ea34b2df932786b=
bfc
> for this release, and then re-apply a corrected version
> for the next one?


If possible, consider we've actually disabled the feature. How about=20
just queued those patches for next release?

Thanks


>
>> --=20
>> 2.18.1


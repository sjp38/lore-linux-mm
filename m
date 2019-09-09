Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87567C433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 07:24:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 560D1222C5
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 07:24:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 560D1222C5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0176F6B000A; Mon,  9 Sep 2019 03:24:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F099B6B000C; Mon,  9 Sep 2019 03:24:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF76C6B000D; Mon,  9 Sep 2019 03:24:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0187.hostedemail.com [216.40.44.187])
	by kanga.kvack.org (Postfix) with ESMTP id C081A6B000A
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 03:24:09 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 36B0E87C7
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:24:09 +0000 (UTC)
X-FDA: 75914543418.25.cats45_7b865ece05e58
X-HE-Tag: cats45_7b865ece05e58
X-Filterd-Recvd-Size: 2630
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:24:08 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E367E18C428C;
	Mon,  9 Sep 2019 07:24:07 +0000 (UTC)
Received: from [10.72.12.61] (ovpn-12-61.pek2.redhat.com [10.72.12.61])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 970AF1001948;
	Mon,  9 Sep 2019 07:24:00 +0000 (UTC)
Subject: Re: [PATCH 2/2] vhost: re-introducing metadata acceleration through
 kernel virtual address
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, jgg@mellanox.com,
 aarcange@redhat.com, jglisse@redhat.com, linux-mm@kvack.org,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Christoph Hellwig <hch@infradead.org>, David Miller <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
References: <20190905122736.19768-1-jasowang@redhat.com>
 <20190905122736.19768-3-jasowang@redhat.com>
 <20190908063618-mutt-send-email-mst@kernel.org>
 <1cb5aa8d-6213-5fce-5a77-fcada572c882@redhat.com>
 <20190909004504-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <4ee20058-0beb-111c-6750-556965423f04@redhat.com>
Date: Mon, 9 Sep 2019 15:23:58 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190909004504-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.62]); Mon, 09 Sep 2019 07:24:08 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/9/9 =E4=B8=8B=E5=8D=8812:45, Michael S. Tsirkin wrote:
>>> Since idx can be speculated, I guess we need array_index_nospec here?
>> So we have
>>
>> ACQUIRE(mmu_lock)
>>
>> get idx
>>
>> RELEASE(mmu_lock)
>>
>> ACQUIRE(mmu_lock)
>>
>> read array[idx]
>>
>> RELEASE(mmu_lock)
>>
>> Then I think idx can't be speculated consider we've passed RELEASE +
>> ACQUIRE?
> I don't think memory barriers have anything to do with speculation,
> they are architectural.
>

Oh right. Let me add array_index_nospec() in next version.

Thanks



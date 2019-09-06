Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0101AC00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:51:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C62822082C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:51:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C62822082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5600C6B0003; Fri,  6 Sep 2019 08:51:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 510A56B0006; Fri,  6 Sep 2019 08:51:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FE756B0007; Fri,  6 Sep 2019 08:51:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0101.hostedemail.com [216.40.44.101])
	by kanga.kvack.org (Postfix) with ESMTP id 184906B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 08:51:41 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id AD78E180AD7C3
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:51:40 +0000 (UTC)
X-FDA: 75904482360.28.rice29_2bb481d00c660
X-HE-Tag: rice29_2bb481d00c660
X-Filterd-Recvd-Size: 2581
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:51:40 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 383D38980E3;
	Fri,  6 Sep 2019 12:51:39 +0000 (UTC)
Received: from [10.72.12.95] (ovpn-12-95.pek2.redhat.com [10.72.12.95])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1D1A260605;
	Fri,  6 Sep 2019 12:51:30 +0000 (UTC)
Subject: Re: [PATCH 2/2] vhost: re-introducing metadata acceleration through
 kernel virtual address
To: Hillf Danton <hdanton@sina.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, jgg@mellanox.com, aarcange@redhat.com,
 jglisse@redhat.com, linux-mm@kvack.org,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Christoph Hellwig <hch@infradead.org>, David Miller <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
References: <20190905122736.19768-1-jasowang@redhat.com>
 <20190906032154.9376-1-hdanton@sina.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <cd2ed116-4b19-73b2-a3f0-4377cc0f2db3@redhat.com>
Date: Fri, 6 Sep 2019 20:51:29 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190906032154.9376-1-hdanton@sina.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.67]); Fri, 06 Sep 2019 12:51:39 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/9/6 =E4=B8=8A=E5=8D=8811:21, Hillf Danton wrote:
> On Thu,  5 Sep 2019 20:27:36 +0800 From:   Jason Wang <jasowang@redhat.=
com>
>> +static void vhost_set_map_dirty(struct vhost_virtqueue *vq,
>> +				struct vhost_map *map, int index)
>> +{
>> +	struct vhost_uaddr *uaddr =3D &vq->uaddrs[index];
>> +	int i;
>> +
>> +	if (uaddr->write) {
>> +		for (i =3D 0; i < map->npages; i++)
>> +			set_page_dirty(map->pages[i]);
>> +	}
> Not sure need to set page dirty under page lock.


Just to make sure I understand the issue. Do you mean there's no need=20
for set_page_dirty() here? If yes, is there any other function that=20
already did this?

Thanks



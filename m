Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FBC2C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 05:03:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E91D020B7C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 05:03:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E91D020B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 964D18E0005; Thu,  1 Aug 2019 01:03:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 915348E0001; Thu,  1 Aug 2019 01:03:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82B568E0005; Thu,  1 Aug 2019 01:03:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 633278E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 01:03:33 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r58so63669463qtb.5
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:03:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=iCjJo7mrFzb1XIzpTVullGqox/ClF+FpgMq6qBAcRKc=;
        b=s7lpJcZxwCZhk0vfALgInhX04ECP9/MjrowLhlWCEv7FmSAbw7o/NPhQU8vfVpSWU+
         UuDN6+sBgzNT900Ve1j4/0wIgrotCORsToKn1FDo4K3uXPo3C4CIC+FPavApRIIU2DNi
         us01r3LmTi4J02S0d68k2bsNJCYYnExurmgO4myCkF0V+ow9D2YNZQjno2lozSwJrYrL
         wprg5lMotX4COe9MYPkBi9oXAQhLUn8xERdnK1ShmcwOWv2QGgn+ztfFjPETTSFHgV/4
         QzAHaTwdwaKCf4d9ndOhkmLaaWm0GnnfKVz/3PPeEAi1+GNJBqXtvzBiTXnHpoDycKLy
         FrbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUaqQX0qq5jYi5l8b/WtA7imXCkaWbOy7J/3ngATOn7/E0q61WR
	o/Pww9+degiEt5wwmqqJJhn0ukFq2F6vg6Uu6g/GIsT9hJHU2sSZ+cLE9bNjPrAmiIQ2VL9liKi
	RKYlPGlhAmMtIvbMXwseOXT+Vw6sfYl1N0UZ2rN7/zqvaJ9VN5y6bhIK79jouqA56eg==
X-Received: by 2002:ac8:1c65:: with SMTP id j34mr88135644qtk.323.1564635813194;
        Wed, 31 Jul 2019 22:03:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxERi28h8xmSF9ZM5wCQs1SO6yEQVmnjgC2aBUwE+O2OLd25I619On/1gdy3MN6Z/uYDqnt
X-Received: by 2002:ac8:1c65:: with SMTP id j34mr88135597qtk.323.1564635812615;
        Wed, 31 Jul 2019 22:03:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564635812; cv=none;
        d=google.com; s=arc-20160816;
        b=BZpuH7ndm4waq9vZjbdv2rnf0sDyOcO3TfrzumhyGiZ8gSRYaIAoLTk7oqS+0CZPmZ
         tdWKmztvcAUvq4Io4jiMppZOV2DXApc7PzD6FfM9SbksjuQBzz/+ei6Gc1mtU1sHyLBn
         SrvS86UcGT9eWr1wkKFViC3qK6w2YzbHFjCTtWeKwRzjGqwlQ6LpNtKeqxTiIa/4EUyf
         PThIX7z/ZrPYcGhOTJSEaDKrkw2qxD086FSRim5hPIJ4dIOvvDKY+emdm5qdC58nHmmx
         1zHv0K+dm3sv0X5Dif5DRzHcE3xu7zpCnC82/K/NZOqhC/Dx5vqCLHUxnW8rFkfu1S6X
         nadw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=iCjJo7mrFzb1XIzpTVullGqox/ClF+FpgMq6qBAcRKc=;
        b=KL+oY5lzp34rUEet6Ad7+8PhuhTZwIHRgkQwMralL6N20FXFDtxlEQE1hQbpobp7JA
         IveRc5x6IVP1+fY7T72qDbfT0FDyW3ECF0UEQxTGcZ04ubo2hrkdUqNWFr7fZ9YtiL/h
         +Ixt1B6aACH9U5M9yOhcqZFLdzhKQTU16v3Vo3RF67cfA2bjYmWRy0jKLzX3Ng69eK+y
         ih9ft+JVWNT0GDjlkBvlDE563azvc3//9sIf057jT5lTMCu5zpLY0eMIImfrpoPcZHPU
         twK9dKDW40zRF2IBpk7byjOrescDCRgJMynkCLkzqnkOhXl0CWPEllwRcY33J2EyTDhd
         8ZLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m9si39473941qke.19.2019.07.31.22.03.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 22:03:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D7CC330044CC;
	Thu,  1 Aug 2019 05:03:31 +0000 (UTC)
Received: from [10.72.12.66] (ovpn-12-66.pek2.redhat.com [10.72.12.66])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 042175D9C9;
	Thu,  1 Aug 2019 05:03:25 +0000 (UTC)
Subject: Re: [PATCH V2 4/9] vhost: reset invalidate_count in
 vhost_set_vring_num_addr()
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-5-jasowang@redhat.com> <20190731124124.GD3946@ziepe.ca>
 <31ef9ed4-d74a-3454-a57d-fa843a3a802b@redhat.com>
 <20190731193252.GH3946@ziepe.ca>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <0a4deb4e-92e8-44e1-b20e-05767641b6ba@redhat.com>
Date: Thu, 1 Aug 2019 13:03:24 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190731193252.GH3946@ziepe.ca>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 01 Aug 2019 05:03:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/1 上午3:32, Jason Gunthorpe wrote:
> On Wed, Jul 31, 2019 at 09:29:28PM +0800, Jason Wang wrote:
>> On 2019/7/31 下午8:41, Jason Gunthorpe wrote:
>>> On Wed, Jul 31, 2019 at 04:46:50AM -0400, Jason Wang wrote:
>>>> The vhost_set_vring_num_addr() could be called in the middle of
>>>> invalidate_range_start() and invalidate_range_end(). If we don't reset
>>>> invalidate_count after the un-registering of MMU notifier, the
>>>> invalidate_cont will run out of sync (e.g never reach zero). This will
>>>> in fact disable the fast accessor path. Fixing by reset the count to
>>>> zero.
>>>>
>>>> Reported-by: Michael S. Tsirkin <mst@redhat.com>
>>> Did Michael report this as well?
>>
>> Correct me if I was wrong. I think it's point 4 described in
>> https://lkml.org/lkml/2019/7/21/25.
> I'm not sure what that is talking about
>
> But this fixes what I described:
>
> https://lkml.org/lkml/2019/7/22/554
>
> Jason


I'm sorry I miss this, will add your name as reported-by in the next 
version.

Thanks


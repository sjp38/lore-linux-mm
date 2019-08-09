Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 024F6C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:35:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4B822171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:35:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4B822171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 489A96B0007; Fri,  9 Aug 2019 01:35:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43A066B0008; Fri,  9 Aug 2019 01:35:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3028B6B000A; Fri,  9 Aug 2019 01:35:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19EAF6B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 01:35:43 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id z2so3939913qkf.2
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 22:35:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=kowFCnC+sC8EP+VWi7lbv0hOT5p2YHYna9sbHJ8sXRA=;
        b=mi2Un13qrYi05GG7DjIwFzgaPeFW8ejYHWfBgGc3LfwMc1q/rTiBh0SHSnrdMdRxeG
         NyQ1fxZuu/id1mXXIjaUN40J1uQaSmZpMEqL9IOG3f9AuCu930FxP7Hk3TjWGkcsO7B7
         y5jwrKY5Z+fW4NavZ+LANr1kSeAXkCPbZBsffj2TisdGVVxEWhP55dUHJwA4PDOKo5IM
         W5ahaNVkkvGts0BtdY7pw8jfdBEZ/aa6LlMFlaBCC5yQcodB6oAQC81/kzZ99Rvm3DCU
         mLnq3IlnJjwMkCXkLqf0qjBqeVsDP+6T7z6o6vae/6/GaJ18a1DqLSLGkncR2j2QW3Ne
         Pavg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVxr/4eFjkbl74TEHsS4IkgUlMQyTMt9xk0guuPNSKO3bWq3zCL
	DxXfBgNegz6pWhMCfDH7OXCtze9GyM1vWpg3BEr6pPjM5bXRWLu/kDQocKZrWeC3m7nnBMCdoYA
	aaH/zPwImtfvVShVpnzBwkuMe03oqSX+awH4GM/jnOXU8QYyy26R0140XSivoSfflUQ==
X-Received: by 2002:a05:620a:12c3:: with SMTP id e3mr7598625qkl.165.1565328942881;
        Thu, 08 Aug 2019 22:35:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/nk07pKDThxK251RUKmy8NITbPMwawKjkJGUNQWYcArB/cnXpoM4VwGNIngpzELDrCzVC
X-Received: by 2002:a05:620a:12c3:: with SMTP id e3mr7598606qkl.165.1565328942342;
        Thu, 08 Aug 2019 22:35:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565328942; cv=none;
        d=google.com; s=arc-20160816;
        b=Z/rNbE60FeNSM84qiSJAHe+SFJDK/CpoF3iT1XlnDF96StkupRZP0utV5kyrq6XrED
         VosPZsQVYjOy1m8edfrpIiKmgiOqds5s8TLg0PsDf/PZ4so44O/3inOflQ1khk/57xT6
         iGVCaQcoymIOuYMkwVKkpJLV1H6eoHhnXKCVFSB10Dwj5Z+fYO4jpM8Y1TK7ZMpP8PzJ
         TTPvNyZH2UqxmL9zFWP4POebc3pG9jqRKRZZlgtUUUyNKFv9VyVcOemqw/GkfNmvg/2z
         0RKtrL3Vl233Yi+GcHWzDhxBzAAzQJySoAzMXMWntroBrI6bvJYpn+hOowyv9Gp9NCYp
         kYqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=kowFCnC+sC8EP+VWi7lbv0hOT5p2YHYna9sbHJ8sXRA=;
        b=apcB5YIhuLZzwimrJix4Biv5+hmngLwG4WrEq/vjrRN8wy47Ymyt+mqLewNwShO86J
         69+3Obg4A1rRKW0AFFxhsjaUmilIm+FeAlP5k+BW1tJjmoqwFls9e4nCeh7H/vwsZwNC
         n0S6XPYFxNIL9us1TJDgtP/78Wbv30NH13RXjbKO6WRSO9ER/gWZMSQGWivm5GXsfHNc
         HTKw69K3Xvg2gmvuhBl7o5S8zwSA74ouPdk6p6FS2rMDJwVyV99AKAPONihTZD18MFhZ
         55JADxmqujsWk7hegEtH9/cBfdO1uecYdVQ9pxDNCO1ZMIr+1huXefjTh3MQS6/QDFSk
         MaMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i14si2494181qki.366.2019.08.08.22.35.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 22:35:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 76B7B8E90C;
	Fri,  9 Aug 2019 05:35:41 +0000 (UTC)
Received: from [10.72.12.241] (ovpn-12-241.pek2.redhat.com [10.72.12.241])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1F54C60BF3;
	Fri,  9 Aug 2019 05:35:33 +0000 (UTC)
Subject: Re: [PATCH V4 0/9] Fixes for metadata accelreation
To: David Miller <davem@davemloft.net>
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, jgg@ziepe.ca
References: <20190807070617.23716-1-jasowang@redhat.com>
 <20190808.221543.450194346419371363.davem@davemloft.net>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <1aaec9aa-7832-35e2-a58d-99bcc2998ce8@redhat.com>
Date: Fri, 9 Aug 2019 13:35:32 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190808.221543.450194346419371363.davem@davemloft.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 09 Aug 2019 05:35:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/9 下午1:15, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Wed,  7 Aug 2019 03:06:08 -0400
>
>> This series try to fix several issues introduced by meta data
>> accelreation series. Please review.
>   ...
>
> My impression is that patch #7 will be changed to use spinlocks so there
> will be a v5.
>

Yes. V5 is on the way.

Thanks


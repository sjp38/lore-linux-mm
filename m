Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10F9FC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 07:13:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1C7D206DF
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 07:13:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1C7D206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E46448E0004; Mon, 11 Mar 2019 03:13:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF5AD8E0002; Mon, 11 Mar 2019 03:13:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE5008E0004; Mon, 11 Mar 2019 03:13:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF1338E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 03:13:29 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d8so1169590qkk.17
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 00:13:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=R2nubnFMeBwmOCMqEpfenKUoc6Sd41bpyBZ4Ri7Ah9s=;
        b=Iant3qkiE6UGmjuAUYS6A3tdJzrdBqnRwu/fSnm+VpMu2GAMCN4bE5QwS0HmhBWItO
         n1Y2TP15U6zAMw7fIdqolwXXfbq/bSv2dgqlR1xrCbPwvGsG3EXPuS0J+zovGavp1ogc
         gw9JFwmRqQwY2prqynUWDsL+JlaLMXYm+mqeQ2nRYdT4FcrDd+gJG008LzCT7edf+LJW
         Ts/JUt2iejjSw35PichBpCuqRhYo7TNTzptHsYVYlb3cQ0bStcT2X1/EG3zb9v1C/mJC
         Tf2GMISwQajI2EhIhRcwihneA4G9psv+w0Ebla4VyLJFtWbSEwQRP8cBpVWG3GBm3it4
         onpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVGfRsEPomVZP19HV1/dpQFcKJ953lXLwMGcSU0saDifGU89nvm
	gilGf2vc/KA9XFL4z4/nO3y3lG01na52iAcN6WZM3a2/TCj0ffM3XWkXZSL6bJQ6KU9olRc5vKR
	Rt3uNCBXqShZ9Q8/FCIdTpyudinJO7Gol9cEXd+vlA1+8r1oqz9sNac7B10vg/4YGIw==
X-Received: by 2002:aed:3534:: with SMTP id a49mr24549758qte.39.1552288409444;
        Mon, 11 Mar 2019 00:13:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSyaNuZfEgFon8ggszze0H983VA5NDOJkOHGLsdjKZq6Tfqgw+yfI8UnmgLuzgQ45LKO3W
X-Received: by 2002:aed:3534:: with SMTP id a49mr24549726qte.39.1552288408691;
        Mon, 11 Mar 2019 00:13:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552288408; cv=none;
        d=google.com; s=arc-20160816;
        b=zIbXB5GwTdrr2SxN5MOFKRkwjEaR3C7AK9/2Pf5x+vr42pt7rX/v8onw2l50Am0u3F
         LOl+5KD1TUiaRqfAkEtR7aCIYK7VpGqE1N8nSQjOHG3wNQIgruxZyGvtMNmon4zRv4mG
         w/rlkISRCD0vdvd4oUfDMp41O7rcKkMrAO4aCFwMYcfEzV9f8MgmzSSCxJRI/PfsHVLp
         NTKnb6Rua/s8QhnQXUFJqw/FwfBctB2ZYuQIwCVL9HTUF4TcwEHpOwhGcul0WP6GNPOZ
         7zYDMOwezTdZ/cmq2ORaxPcyMesOTBZWiV4wZHEuwO5AfCreni1dr0KZec/l8zzIzIsU
         9dpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=R2nubnFMeBwmOCMqEpfenKUoc6Sd41bpyBZ4Ri7Ah9s=;
        b=YcLlEF6ur3WxZun02lwqpfiiEqfH08FfdjEb8r8XZ0grd91M69bmuERyH0diM1adxV
         uY0jHMB/hRtal7GxKsSw/rhtJ2trDCq4oEG1WZyxHl0DhmwSqYMaHvxvONowTjZleCIN
         L/TCmYdlX+/DEJTdvfCPcuRw/H09wYo9z1aIEuk/AfFfXnEIOT7hOlksU7zetY4+yU9U
         3LspYQavuaZRZj9zTdb8dQi8bWrICNg5+iDIy7JjoHEG7lNXw3N1d7/uPV6SW0nM2FKc
         ty+FUX4wttRKF6vKdvxzZ5EE3ThMhlTQtwNQz/OrrcbdM1gqehnKncV0uacZTpDQ8iXw
         dKJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n85si207270qkl.139.2019.03.11.00.13.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 00:13:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BEF7630832CF;
	Mon, 11 Mar 2019 07:13:27 +0000 (UTC)
Received: from [10.72.12.54] (ovpn-12-54.pek2.redhat.com [10.72.12.54])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 288C75DA27;
	Mon, 11 Mar 2019 07:13:18 +0000 (UTC)
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
To: Christoph Hellwig <hch@infradead.org>
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
 aarcange@redhat.com, linux-arm-kernel@lists.infradead.org,
 linux-parisc@vger.kernel.org
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <20190308141220.GA21082@infradead.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
Date: Mon, 11 Mar 2019 15:13:17 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190308141220.GA21082@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 11 Mar 2019 07:13:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/8 下午10:12, Christoph Hellwig wrote:
> On Wed, Mar 06, 2019 at 02:18:07AM -0500, Jason Wang wrote:
>> This series tries to access virtqueue metadata through kernel virtual
>> address instead of copy_user() friends since they had too much
>> overheads like checks, spec barriers or even hardware feature
>> toggling. This is done through setup kernel address through vmap() and
>> resigter MMU notifier for invalidation.
>>
>> Test shows about 24% improvement on TX PPS. TCP_STREAM doesn't see
>> obvious improvement.
> How is this going to work for CPUs with virtually tagged caches?


Anything different that you worry? I can have a test but do you know any 
archs that use virtual tag cache?

Thanks


Return-Path: <SRS0=X77i=TF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20D9EC04AAC
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 09:20:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC55A2082F
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 09:20:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC55A2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7934A6B0003; Sun,  5 May 2019 05:20:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 743486B0006; Sun,  5 May 2019 05:20:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3D46B0007; Sun,  5 May 2019 05:20:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC9E6B0003
	for <linux-mm@kvack.org>; Sun,  5 May 2019 05:20:44 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id y10so4652122qti.22
        for <linux-mm@kvack.org>; Sun, 05 May 2019 02:20:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=IivF5H363YfmbV0lg/ObuFkktGg4Fz7JqwSg9qtGZOI=;
        b=TonTXOJUU2AVTnhfLNsRxe6jXp2+YKAzg1JiqiOlLGHNe0yE5Ye4SG9iec639oXLI5
         Y5TbAQ4jsnwx8yTlIZrGnHRXNdU0pn+H3hjIWVeMqdsU5Rza+ZMHYR2ySw39GPb/JixM
         bUCOOh4m/dVKQxzcNGA2NMPaoV20wf4wjo8fGG+O3UdrSrUqfC+nA6A7q0wBVrc8L/yi
         CeKJmVs/CZuOL083DGt6IJZ3qQhzqRsZhHtkxB1AGOy442nK5O0YCvaJ/QReCtX1mvtI
         czGcmE1Z9HD58fs0UKGrXSgG22KH20s6aR0NVubY8XnYqQRF7NUsMaRUS3Pyk9TUH15G
         OqrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU8gQvq5OXqDTGO6RWZwsSY8u8Y2jNG5ujFWklwL1vR/EOalsmU
	9/ECgumyGYS04ISxRR4oQX58azBd9OqIDhiSa+KJGzIcoNmCRMEqL+CF0FqAk0zIZGGj/ZJGrt8
	wLMWLbEsQtLLU8tL5vedVViQqm2jAHxGNb1trqFuOpc1ETkM4dsml8N4Q0KtW8iydhg==
X-Received: by 2002:a05:620a:124b:: with SMTP id a11mr6500696qkl.128.1557048043947;
        Sun, 05 May 2019 02:20:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrJerXmtRauSBipbwYfiWGlQ3TNnZPJsr4vrh7hcwmcG93ViKLI3cV3KeNIRN2U5FU6xJN
X-Received: by 2002:a05:620a:124b:: with SMTP id a11mr6500673qkl.128.1557048043187;
        Sun, 05 May 2019 02:20:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557048043; cv=none;
        d=google.com; s=arc-20160816;
        b=DZOee0gnr6/QpZUnNea/yKtsFHw5ZtC422QRF7aN9Uu+3+GhoQqTqktkgU8ZFbtdbd
         3prUVIQCJKjonHRBjybLrmyCYidVVBhUhi6TnAqzuodYpr2COavzwb9y6CSa6vPPM9Wv
         Ved8WwQTBJJAkGjkNk0QlWQPrxV5ZvloBKUPc1o3Egfp2YycIS+zFlb0NWHVGaxHZiA1
         /ROqABQ3lUsCza3sLMe+Bj31LsDc8UM5mbEuoLbn/sWr2qipVpHoGk5+5l60v28sM3U0
         4EbOhNcmQ+dFGcgejtp+MVBf0KPFCvg+HXOQOpiMcP39+9OvKdf+rMy01A++l/UfQDAG
         oz8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=IivF5H363YfmbV0lg/ObuFkktGg4Fz7JqwSg9qtGZOI=;
        b=yseH3UOelJO+ZnPud8h6RbdiqATtlftrqAxujk/MqLkqblNjtqOv+b4KpzbpB4Hd99
         GgwE8d3cyS3nXznGVgA6PRmCI67VrWXU/93ZGN9zXotWfvawbyaX/yziyop2TqoIv7cR
         nYoSnYb/T4AdF/oLhkOSGsyS0MC8GZdnblfFOgwODDFf1xe8eVd1wPr0tJJMzVA4+rdx
         iAyxTSaWeB1XEEveHndekqR3H877aDU1l0HN1m4V9SCdyl1TKFau4Bek37NGQynEddm5
         R0UIvboX1gYlYD9wmpyuVxJIyUhi1C1guMYOyvlA/nSvEfeIN24bBSLJXvpcJlYlsJp5
         H1dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r15si634708qtn.95.2019.05.05.02.20.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 May 2019 02:20:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 50F6C3091749;
	Sun,  5 May 2019 09:20:42 +0000 (UTC)
Received: from [10.72.12.197] (ovpn-12-197.pek2.redhat.com [10.72.12.197])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EC3AF5DA5B;
	Sun,  5 May 2019 09:20:32 +0000 (UTC)
Subject: Re: [RFC PATCH V3 0/6] vhost: accelerate metadata access
To: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Cc: peterx@redhat.com, aarcange@redhat.com,
 James.Bottomley@hansenpartnership.com, hch@infradead.org,
 davem@davemloft.net, jglisse@redhat.com, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org,
 christophe.de.dinechin@gmail.com, jrdr.linux@gmail.com
References: <20190423055420.26408-1-jasowang@redhat.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <831c343f-c547-f68c-19fe-d89e8f259d87@redhat.com>
Date: Sun, 5 May 2019 17:20:31 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190423055420.26408-1-jasowang@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Sun, 05 May 2019 09:20:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/4/23 下午1:54, Jason Wang wrote:
> This series tries to access virtqueue metadata through kernel virtual
> address instead of copy_user() friends since they had too much
> overheads like checks, spec barriers or even hardware feature
> toggling. This is done through setup kernel address through direct
> mapping and co-opreate VM management with MMU notifiers.
>
> Test shows about 23% improvement on TX PPS. TCP_STREAM doesn't see
> obvious improvement.


Ping. Comments are more than welcomed.

Thanks


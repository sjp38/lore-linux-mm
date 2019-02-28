Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0437C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 00:12:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0B7E2171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 00:12:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0B7E2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29DC88E0003; Wed, 27 Feb 2019 19:12:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24BBE8E0001; Wed, 27 Feb 2019 19:12:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F00C8E0003; Wed, 27 Feb 2019 19:12:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E13688E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 19:12:34 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id c9so16871862qte.11
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 16:12:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=oDoxBkzQwFChQRCKafTVJkBN33mMgG51p/1TDqwrqm8=;
        b=NVRmm0dQ1grTtL3U0o35FaCaKN0+ZImZo7ah4zqHafQfmycLTh53KCkBFUubiiS1C5
         GIcfYnHvxU3h9+epae7VHb8PAw/lLQetnytU1mWTk3jws6OgkEny13Laq1vK/IIBUtG2
         0Wcrfdv9RxeHd8P7KZ0ShgKPRtAA77uTocJJ0or2jL7CT2iRqhY+BMmuk9NorsimdRVH
         VgJT1a/3g0d+iNP5x11RBRHURmjIUORRlRK9jhhNRTRzr3EEJlras+buN6Zyujm+tKkD
         9ucdaeG9PfQPpGMx/GarFjlbmsesdMPupry2MSk9MV0EH/FbTausJcrDsBTG5+gnj9Vv
         ax4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubG0TFxGGhQNnhoCUNAJHxrTmHxA8ZuF5IkexGBqZIiYI72CMjY
	ZqPWCodX/5jYADBkohOpVaKUHFSdpu7BSjvvOzODffeBgDrKD4xApri9yB4kh2TGclDzIsY9f1W
	Kh0eFmzU/2bNudhgU+ldEn4C+gHWWGbCb/nLQFTpcA9v4Y55JHnoA0viAcgAznYEC7rTZC480KD
	H9rPvE6z+7si3fDVhuHqfSrFQqgUERx5d9f2rfmJb4wqdPcN6VlPXWKVzCRp4Cq5nVmT5mK9eew
	wNoV0ZJRUSQT7+Jv41W8IPXggVIJIyYLT9CmkUFJ8zhKtqfFpq5oNvY6mdlsUn6CtiWTd2OSx7r
	CBboHIVFnG2ofCXZjovc0MPqg2ClXVs7o/OUXsba25MVCwSiCMXWtTw4xxjxot/Ii/mhH5YHfEH
	t
X-Received: by 2002:ac8:2e68:: with SMTP id s37mr4111336qta.382.1551312754687;
        Wed, 27 Feb 2019 16:12:34 -0800 (PST)
X-Received: by 2002:ac8:2e68:: with SMTP id s37mr4111306qta.382.1551312753813;
        Wed, 27 Feb 2019 16:12:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551312753; cv=none;
        d=google.com; s=arc-20160816;
        b=TQ7+ZlWNNDCYwGxE+VrPH6udtdHYlxNry3xS/dvRuOGjvh4EmsTFYpXfCjCIIyEmQg
         pl2Fi93CKXU2YrZsEpZablaURUtMrWLLCDa9kqvAAG8VYTTEvtYPUwZ7RxeT0gw2Bj5P
         kAGQcDmfQ2oD9rGigJYMQARaw7fczGMsscwla78zHhMfDUOvmNaEEeJtc8aoLzU5MVRP
         /OJPKjbs4qIHZviab1hCU5lL5clsvcxPj8An9N/vDLtVMFI9FmyxbfgqaNx1rWd54bTX
         v/iYnlYpDM7EJBJ7Ur8+jNF9hEVC8IiTlgREOyLnBYcQz2YLvw2ceFTIajCdL1aMGXw0
         4G7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=oDoxBkzQwFChQRCKafTVJkBN33mMgG51p/1TDqwrqm8=;
        b=Z7r2s+UT13sQ3W4jyoiXnoftjCH0px+6pHNXhNSdhqJkHjPErY1TKXG8ED4eWjmoxL
         NkAgweOD7m0KvpzXElAv7CSMOMfxGGNNd+8HBCNdXpQ3UNAhwa5B86J7aFcEVsGjX0qe
         FxTissPjyYf3hALKjU85UsBjMYcnb8CzL3ZAaUKNSfrG1TP5fqYNumJc5wQZBnNf3is2
         +wnR4KTG1dtlQ/z4tkBj4WWGICjsOd4ZnXbCpbsYTUZnT+axpkytvwm06fD+3U+Y0fdd
         NlJfnHiSjSV6L7OparRV7+TxUhL2H9+LWNQ27cjqDR6D0sKcDoZCo8+A3ZpVQmHhJYfP
         gWFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h24sor9667959qkg.54.2019.02.27.16.12.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 16:12:33 -0800 (PST)
Received-SPF: pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: AHgI3IYbK8vEH0uPq5duj7VDwmMSAZEr+ZrmNKH5JCyMqo7ED7RWSUru9l8E5Rg8upOL+u8F3FSrAQ==
X-Received: by 2002:a37:f513:: with SMTP id l19mr4491848qkk.313.1551312753610;
        Wed, 27 Feb 2019 16:12:33 -0800 (PST)
Received: from ?IPv6:2601:602:9800:dae6:8083:e891:a0d6:f666? ([2601:602:9800:dae6:8083:e891:a0d6:f666])
        by smtp.gmail.com with ESMTPSA id s16sm7000416qks.90.2019.02.27.16.12.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 16:12:32 -0800 (PST)
Subject: Re: [PATCH 0/6] Improve handling of GFP flags in the CMA allocator
To: Christoph Hellwig <hch@infradead.org>,
 Gabriel Krisman Bertazi <krisman@collabora.com>
Cc: linux-mm@kvack.org, kernel@collabora.com, gael.portay@collabora.com,
 mike.kravetz@oracle.com, m.szyprowski@samsung.com
References: <20190218210715.1066-1-krisman@collabora.com>
 <20190226142941.GA13684@infradead.org>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <878b80c2-93bc-9ffe-7b2a-6fce97f5bb25@redhat.com>
Date: Wed, 27 Feb 2019 16:12:30 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190226142941.GA13684@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/26/19 6:29 AM, Christoph Hellwig wrote:
> I don't think this is a good idea.  The whole concept of just passing
> random GFP_ flags to dma_alloc_attrs / dma_alloc_coherent can't work,
> given that on many architectures we need to set up new page tables
> to remap the allocated memory, and we can't use arbitrary gfp flags
> for pte allocations.
> 
> So instead of trying to pass them further down again we need to instead
> work to fix all callers of dma_alloc_attrs / dma_alloc_coherent
> that don't just pass GFP_KERNEL.
> 

What's the expected approach to fix callers? It's not clear how
you would fix the callers for the case that prompted this series
(context correctly used GFP_NOIO but it was not passed to
dma_alloc_coherent)

Thanks,
Laura


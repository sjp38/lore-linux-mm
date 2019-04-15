Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48FFDC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 07:47:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBBEF20825
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 07:47:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBBEF20825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47CFC6B0003; Mon, 15 Apr 2019 03:47:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42F966B0006; Mon, 15 Apr 2019 03:47:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31CD06B0007; Mon, 15 Apr 2019 03:47:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 117D76B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 03:47:15 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q12so15441303qtr.3
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 00:47:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1sqwRDPqv8TM7xLyzVhPqsTZ9uL3Z2stWknu4TNhD7g=;
        b=T3qVAv33IT4o+8/69Z/uuipySE0b600X/VcjkhVIPuViDScmGJqc5WWd2Z4wvIrwgK
         53zzmS8uJwpeL20XivFnu0w06h7Jaf/gAm6UMxLLQwNBjXfsbn7BSLj51Q5kz5qBX1rG
         zzX8U7CrMnSMLW9zBnnKLZaU2sEyfwKMBm6ulTNc+Q6cbAY+xvyigyrreqyZ+aaRVyGn
         7ZTpE7exZ3egSS2+lHMPCEtlcYtY/MfqCtVRh6DRj5f38aJlNI0yTIkYN0cWNrlIy2FH
         96vnoaIoNRNCz9pdhseHr4IiRJGFjiGNIevgXChzsdO/qvELyQA7XzNE2Jg662INa9x7
         HcQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zyan@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=zyan@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVFCtzGhJE1UkhwoKnX9kVA3J1zU8pbUwKvae8obQb/vAyAZOBu
	0aI/Dwa2pq/zEcL7Ft4zw9iGz2DCWzmkI965g+2c6ik9yOiqJJfh8tXt6QmPx/WbIqQfQ3PhiAs
	f6E7pDxIyNYKHbtABzJ6DRzJjrHJvSbN3uHCT2fgGqh7wBr+Tx7zR/W/QLCvTadDLPA==
X-Received: by 2002:a0c:9ac8:: with SMTP id k8mr58356415qvf.132.1555314434843;
        Mon, 15 Apr 2019 00:47:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJwlb0AfY7fLqUcs4tbkx2pV119BljR1qYebnp5fT7AablWEMIumtS0gZOs4MD9Ha/b6ZV
X-Received: by 2002:a0c:9ac8:: with SMTP id k8mr58356395qvf.132.1555314434252;
        Mon, 15 Apr 2019 00:47:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555314434; cv=none;
        d=google.com; s=arc-20160816;
        b=kH0elLgEkcCTb1z5enBE9rIRP4+9mA2oQEerewG5YN4NhhnneDI84/FrSZLCvfFRpw
         huJzvonuIsdaJQXXblOke3YYbGgJWzHVxeOJ9JDeU2V6F8ZDH9CyhUTTz2D6Jc1E2+nV
         0ieWLJ95PMODmDoXyC8/sUbi2/ybBTwTUNluVx6lpnyiZY7q422BD9sfZ0giEvISCdDN
         LtuU1CeATXyPI44tZX9dFJZEEHplWHS54Z7ks+VSAqpS+s2dAPCAd3p5ZKTYiP+7NsLB
         88WO5rSyW2VF46i9jfMwseCvZRDGuZcP6/E3NrJTZzYLboizjqBe4BtR+MIXE8QMPUlF
         KYuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1sqwRDPqv8TM7xLyzVhPqsTZ9uL3Z2stWknu4TNhD7g=;
        b=Jd3uzGpNvqfa7NfPQ0htJM9O68UrpAq6WcUrs6KM94pvy1RU8msdAfKbGAeREHMPgY
         w6pFdvOZwtO2A7TRSVtz2hJUHB3OKyJoAg19QYnqL7rKn9zG3tE3KZg1CsWNTnKZzaMq
         QU6G9kQbRt1UfG3uFm2ISGpMaC596RbOheczOrJAby9N5oKSBmkoDBJjBxxMOXT1h+oO
         QPCp9VCHKNYLwG22CHm4fLLmY9JcHbtDMeVum0EowQsuW4eK+3SBFl4uNmCLZcJwuO0n
         oc/ogkOfbh8KJ9QaHPrzjVfcipx4d/JUppHK8yTOS2vFNE8TBVqmXMuwd7xBK4rGisN3
         FAlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zyan@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=zyan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i5si2068609qvg.95.2019.04.15.00.47.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 00:47:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of zyan@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zyan@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=zyan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CB9F6821C3;
	Mon, 15 Apr 2019 07:47:12 +0000 (UTC)
Received: from [10.72.12.206] (ovpn-12-206.pek2.redhat.com [10.72.12.206])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 19B3E5D9CA;
	Mon, 15 Apr 2019 07:47:00 +0000 (UTC)
Subject: Re: [PATCH v1 15/15] ceph: use put_user_pages() instead of
 ceph_put_page_vector()
To: jglisse@redhat.com, linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
 linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>,
 Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Johannes Thumshirn <jthumshirn@suse.de>, Christoph Hellwig <hch@lst.de>,
 Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>,
 Dave Chinner <david@fromorbit.com>, Jason Gunthorpe <jgg@ziepe.ca>,
 Matthew Wilcox <willy@infradead.org>, Sage Weil <sage@redhat.com>,
 Ilya Dryomov <idryomov@gmail.com>, ceph-devel@vger.kernel.org
References: <20190411210834.4105-1-jglisse@redhat.com>
 <20190411210834.4105-16-jglisse@redhat.com>
From: "Yan, Zheng" <zyan@redhat.com>
Message-ID: <df4da184-fe8b-c189-43e5-fac58adb3ed9@redhat.com>
Date: Mon, 15 Apr 2019 15:46:59 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190411210834.4105-16-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 15 Apr 2019 07:47:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/12/19 5:08 AM, jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> When page reference were taken through GUP (get_user_page*()) we need
> to drop them with put_user_pages().
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: linux-block@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Johannes Thumshirn <jthumshirn@suse.de>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Ming Lei <ming.lei@redhat.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Yan Zheng <zyan@redhat.com>
> Cc: Sage Weil <sage@redhat.com>
> Cc: Ilya Dryomov <idryomov@gmail.com>
> Cc: ceph-devel@vger.kernel.org
> ---
>   fs/ceph/file.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/ceph/file.c b/fs/ceph/file.c
> index 6c5b85f01721..5842ad3a4218 100644
> --- a/fs/ceph/file.c
> +++ b/fs/ceph/file.c
> @@ -667,7 +667,8 @@ static ssize_t ceph_sync_read(struct kiocb *iocb, struct iov_iter *to,
>   			} else {
>   				iov_iter_advance(to, 0);
>   			}
> -			ceph_put_page_vector(pages, num_pages, false);
> +			/* iov_iter_get_pages_alloc() did call GUP */
> +			put_user_pages(pages, num_pages);

pages in pipe were not from get_user_pages(). Am I missing anything?

Regards
Yan, Zheng

>   		} else {
>   			int idx = 0;
>   			size_t left = ret > 0 ? ret : 0;
> 


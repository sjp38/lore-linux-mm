Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BBEEC004C9
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 18:38:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CA8A20652
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 18:38:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CA8A20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9C5F6B0005; Wed,  1 May 2019 14:38:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4CB46B0006; Wed,  1 May 2019 14:38:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93AD46B0007; Wed,  1 May 2019 14:38:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC6D6B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 14:38:58 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id z34so17786583qtz.14
        for <linux-mm@kvack.org>; Wed, 01 May 2019 11:38:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=AZoVE/JD+p4pvxMUbqDDVl6DA0HD9mSHeUYKfscpr1E=;
        b=HKzswU3MIwlLt/QGyPC8Zk+unazYNKks5SxSangT7ID/UOEHq1vmHsvmKVfYeG72/+
         DC+q+oIRVCSam9u3Eub/9kv1mZkWkGpBgreYwe7zthAC3tUPOzJzy8ABJCh9ioRZFkDM
         gztdLBht5dI2WDy9UhV2du/arEwqRrNkjsLl8A3g32OKw22BL6JjLOY6ldJ617N84L7L
         5vchFX7rZXOb65ocpX2Cu2TEGvbWUgeSSCqqW9Irea+oV9puu5QUgAArd2ZNQMjN7v7p
         liKr4FhehyKkcwxPaROD5fJ1wMD2BnugDnhUJg5zh7ljpNM3wnCo3JTDKwFRTojjjn2I
         8TJA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXJZ3UH2waqzOeZfKUsxsldEWxVqeT7N4l8A3jzWkCu4K6e/pxP
	fmyCWrb7uFaB4ipEa6BVSYIE04hX4531OcGDpcJbF5DWw9KoBG0TiVlx8ihPXOGA8J0iIcAT04F
	sbJuqQ1s8lcrUXbXkvnN2H3WE81TPbnW2wnOktt6nCSwiTLStP7vhc7g3bjoTQ6E8xw==
X-Received: by 2002:a37:4b03:: with SMTP id y3mr58437919qka.260.1556735938237;
        Wed, 01 May 2019 11:38:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrP4yOqkx7OyaOt3BdsC/73956CV1KBnMjDcj2PjnCKQsfuEYKJ5VaoFJBO5GwkoHV4eOK
X-Received: by 2002:a37:4b03:: with SMTP id y3mr58437875qka.260.1556735937490;
        Wed, 01 May 2019 11:38:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556735937; cv=none;
        d=google.com; s=arc-20160816;
        b=mBJQVdi7duTXCfP+gUU8ALUWFqtgQ5JzlzWM2Rbik47m5Fqo5Rrslc63x7a06aHv6G
         daji1/3X82nwbMqhrN8jaZlGrLafQ2Agy56EKbwdOAXxX5XBgkWvASb/cXUHT8zU2+I2
         ox5JCmR6DS32WNSsMt6sn27fgZQ33AsuEQBwKwtp5kL/pT4o8lFu9jBNMufajHL2fhNC
         qFNV8auogMgUCtcV+0LpeOj8yTZi3MouLQZE53RNO4qrYM3pkuPqwlG34zkykN//Fw/t
         XKR9VgbOq2fOrUyKopqN/AgEzdOiamVMDLKLEAHMoNFPw3cMzrIqAOQUqm4fWXucSOQ0
         EvCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=AZoVE/JD+p4pvxMUbqDDVl6DA0HD9mSHeUYKfscpr1E=;
        b=lgcYcvV1QJdR59Ji1u2ajirZnOV/VhZM7apfOAcLHmiKblY7Q5dvSade2r6Pa7BRWG
         /h5xZT7l4DyartWLsIw8o5iN8pxFfl24Duw0hkKu/8m4kRoVwrrtxfHQ+45smmQ8x6wV
         mrLmp/q1ihuKMAALKzArv4zhGViJx+pgXOkloLQNz2D0ABgB0kz+Mj3DKc5rwdZynHcB
         VfNHw+1IeqRIKy3WSvoQALCRsYgqIodTfG5EbQZa1Ni99tANhGbfnki3HoucQQAxU5Ya
         m4gZWvsn5MEtvAjT32vXF0dsZCs8r2JCjcFQ5Pqs1sm2ERhq+Sk5YWkDlpowy5gtjzzL
         T1NQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z37si7931377qvc.90.2019.05.01.11.38.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 11:38:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 935233082E6A;
	Wed,  1 May 2019 18:38:56 +0000 (UTC)
Received: from redhat.com (ovpn-126-26.rdu2.redhat.com [10.10.126.26])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C3D031001DE1;
	Wed,  1 May 2019 18:38:54 +0000 (UTC)
Date: Wed, 1 May 2019 14:38:51 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>,
	Leon Romanovsky <leonro@mellanox.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH] mm/hmm: add ARCH_HAS_HMM_MIRROR ARCH_HAS_HMM_DEVICE
 Kconfig
Message-ID: <20190501183850.GA4018@redhat.com>
References: <20190417211141.17580-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190417211141.17580-1-jglisse@redhat.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 01 May 2019 18:38:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew just the patch that would be nice to get in 5.2 so i can fix
device driver Kconfig before doing the real update to mm HMM Kconfig

On Wed, Apr 17, 2019 at 05:11:41PM -0400, jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> This patch just add 2 new Kconfig that are _not use_ by anyone. I check
> that various make ARCH=somearch allmodconfig do work and do not complain.
> This new Kconfig need to be added first so that device driver that do
> depend on HMM can be updated.
> 
> Once drivers are updated then i can update the HMM Kconfig to depends
> on this new Kconfig in a followup patch.
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Cc: Guenter Roeck <linux@roeck-us.net>
> Cc: Leon Romanovsky <leonro@mellanox.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  mm/Kconfig | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 25c71eb8a7db..daadc9131087 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -676,6 +676,22 @@ config ZONE_DEVICE
>  
>  	  If FS_DAX is enabled, then say Y.
>  
> +config ARCH_HAS_HMM_MIRROR
> +	bool
> +	default y
> +	depends on (X86_64 || PPC64)
> +	depends on MMU && 64BIT
> +
> +config ARCH_HAS_HMM_DEVICE
> +	bool
> +	default y
> +	depends on (X86_64 || PPC64)
> +	depends on MEMORY_HOTPLUG
> +	depends on MEMORY_HOTREMOVE
> +	depends on SPARSEMEM_VMEMMAP
> +	depends on ARCH_HAS_ZONE_DEVICE
> +	select XARRAY_MULTI
> +
>  config ARCH_HAS_HMM
>  	bool
>  	default y
> -- 
> 2.20.1
> 


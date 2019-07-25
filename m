Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AACF9C76191
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 12:56:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C399218EA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 12:56:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C399218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1A2F8E0071; Thu, 25 Jul 2019 08:56:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA4578E0059; Thu, 25 Jul 2019 08:56:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6BC78E0071; Thu, 25 Jul 2019 08:56:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 862FE8E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 08:56:38 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e9so20965939edv.18
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:56:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WzbRpiXeNAPRf1WNpmRGk/SjiXKIj5CDvJcpUk0ckME=;
        b=I3FA34c8g5cWYvaVA5tVeJ/UG20a2gET9C030v5L+rDuuM6nvUS0kYt5P8YeP8486N
         qrC1cgIXkcuEdcTp2wO58XVzDSiRqKYkn6nvUvYYxso+FCd2xAbrAzF/WcLBsddFOeIr
         5KYvY6jcjdguG6nSOZHnPHwciqt/7xrpD6IlJNLdPAGtX1Wdj9M9Y/sxvC5AUWzHNosL
         fQVUk28gowpBcJ7lN5TLR/RVBG9nEFFLz0UGciY+9ir+5xIe2sw5LnVpoax4gNBt+Mt9
         FoxRnHPXsVVjdDD5vT/3eHTxkITdx3QAOgy3XRxSupPhUJjJ98e8w0vjq8QSYsMpn3Wr
         Wddg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU2uMGKrB8xpeUyKikfW32K4xFaPPmViYPfXDANTHE7yL65cIHk
	2cXAypZNp5amaowdcN0MBTEGOdJ/GpG0YQVG2lSNK2Nwo7wIapzL1XBifeOjF2kOiSEsuQOw0D0
	wJxxgDbeWILbNIDSnBsFlypl0/DFEq7FqofdU/UPq21b4abQaZmF51mMNYEsC18I=
X-Received: by 2002:a50:e718:: with SMTP id a24mr75776053edn.91.1564059398102;
        Thu, 25 Jul 2019 05:56:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysfu80qhwNwIwRDOLFzXGeMkk9lvkgXOik/9my0VMKzqRfQEz+d6a9p22ozhnocnfxuESR
X-Received: by 2002:a50:e718:: with SMTP id a24mr75776009edn.91.1564059397402;
        Thu, 25 Jul 2019 05:56:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564059397; cv=none;
        d=google.com; s=arc-20160816;
        b=1JJwAtKlQwHIXYp5EzLtp9VfftOkoHB54EYV9Tj48QmN3C5Gx2lGZffkG77WOBLLWG
         A7DCPS0cYOIxb8ZrfmXPART67bdH89YZzzxrseBcdUV0zfFhiUQQaCcicHoFTfrqoI11
         URA++VPubd7OiEWYQWn1bGaXgq7yYjHe0i3+Uo+G4NJ3aDn+Nxv4SM6F0WNkNTmAVqpO
         vs4hF6SkpM6zKUsjLXWEHjUufwM14Ngno0Ja3W+WlmaycV63BVdwIsBhhUrbzF+sysSe
         mj8PBVohBTHTyWbxKHPW5jIgaCYwXv7K8P1L6cPN2fO0Yiq4/VrKYXYjGjmy+p8m0ExI
         GDRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WzbRpiXeNAPRf1WNpmRGk/SjiXKIj5CDvJcpUk0ckME=;
        b=082inDi7FMZS3NQqSZz6SaYW+lF6ts5p/NOUvCP+B27IMS8+vr1c8cxt6ZT7xRr6Qx
         M4/6r5Hrc/2a40D2C4TCZ4ET1Wet/pVmxMennD+KeeGCVZFUY60us8/AaIRAmfms1519
         8yiYHvZs+GjJB4aHQ/3GbtyX5DlQck1n6ZbTxpbrLr3OOakAd3eSzjsKplRCmjdsZAGm
         wH2ryBW54x3nFSQDq5Zhj+cWcxMm/c3dAqu4XtdpqmTV/s+9fllcsGaR5yBPcL5IIP5i
         KeUULk5VoPnhNSACPohvaeFdNPhWqEvfFHcBJ0mtCdfRl6gRllVr7x99HUO4ymP4+Eba
         vVRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5si9177409ejq.397.2019.07.25.05.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 05:56:37 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D02BCAF05;
	Thu, 25 Jul 2019 12:56:36 +0000 (UTC)
Date: Thu, 25 Jul 2019 14:56:36 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in
 acpi_scan_init()
Message-ID: <20190725125636.GA3582@dhcp22.suse.cz>
References: <20190724143017.12841-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724143017.12841-1-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 24-07-19 16:30:17, David Hildenbrand wrote:
> We end up calling __add_memory() without the device hotplug lock held.
> (I used a local patch to assert in __add_memory() that the
>  device_hotplug_lock is held - I might upstream that as well soon)
> 
> [   26.771684]        create_memory_block_devices+0xa4/0x140
> [   26.772952]        add_memory_resource+0xde/0x200
> [   26.773987]        __add_memory+0x6e/0xa0
> [   26.775161]        acpi_memory_device_add+0x149/0x2b0
> [   26.776263]        acpi_bus_attach+0xf1/0x1f0
> [   26.777247]        acpi_bus_attach+0x66/0x1f0
> [   26.778268]        acpi_bus_attach+0x66/0x1f0
> [   26.779073]        acpi_bus_attach+0x66/0x1f0
> [   26.780143]        acpi_bus_scan+0x3e/0x90
> [   26.780844]        acpi_scan_init+0x109/0x257
> [   26.781638]        acpi_init+0x2ab/0x30d
> [   26.782248]        do_one_initcall+0x58/0x2cf
> [   26.783181]        kernel_init_freeable+0x1bd/0x247
> [   26.784345]        kernel_init+0x5/0xf1
> [   26.785314]        ret_from_fork+0x3a/0x50
> 
> So perform the locking just like in acpi_device_hotplug().

While playing with the device_hotplug_lock, can we actually document
what it is protecting please? I have a bad feeling that we are adding
this lock just because some other code path does rather than with a good
idea why it is needed. This patch just confirms that. What exactly does
the lock protect from here in an early boot stage.

> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Len Brown <lenb@kernel.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/acpi/scan.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
> index 0e28270b0fd8..cbc9d64b48dd 100644
> --- a/drivers/acpi/scan.c
> +++ b/drivers/acpi/scan.c
> @@ -2204,7 +2204,9 @@ int __init acpi_scan_init(void)
>  	acpi_gpe_apply_masked_gpes();
>  	acpi_update_all_gpes();
>  
> +	lock_device_hotplug();
>  	mutex_lock(&acpi_scan_lock);
> +
>  	/*
>  	 * Enumerate devices in the ACPI namespace.
>  	 */
> @@ -2232,6 +2234,7 @@ int __init acpi_scan_init(void)
>  
>   out:
>  	mutex_unlock(&acpi_scan_lock);
> +	unlock_device_hotplug();
>  	return result;
>  }
>  
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs


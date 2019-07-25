Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8229DC76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:11:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C59422BEF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:11:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C59422BEF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rjwysocki.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB7308E0056; Thu, 25 Jul 2019 05:11:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C67618E0031; Thu, 25 Jul 2019 05:11:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2F448E0056; Thu, 25 Jul 2019 05:11:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E70A8E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:11:08 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id o20so5005141lfb.13
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:11:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gMBsBtmQofewQRFe8G+fHzPSGjRcz59YHLDw9u+ClmQ=;
        b=EYZ4HC69YJPPCYYBsUGiS+ljjUnQGF66/zzl5Og/5TwTiCiK4slAxNI1MWmOb+64mK
         xtMRFV/FYmmwWzVTZHWOEaLDIYmWTbJDEuvSY79P0SiVbdbPVNkxsUlclZ54Gsk4pd4Y
         YU0VH9FYSuybxct2TjbnqQpgerNa6+ejyPLPzCs36jy24ubpkwOJwqHSYzo+VL8C8Q/m
         A5aZB3OpztSEAkRL2YNVwH8urE4LHU/1ePzsHMkv0sfa6dhtqucIx+JgjimCAdV+3SxH
         4Ujx6g6z76DpWHCGLCT4qVA2D1SalXIhIzAGdf4LUZogHoKzpuQKBop5UiO6p6HGfpLv
         j6hQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
X-Gm-Message-State: APjAAAUwqnlEs4AoEem2+jh3aiA6oMHsKbvHlOqRvOQLQ3BcOf5+dkwc
	nGxTl7t85WmoSssDkNmqy2BeUcCslkLwimkhqRUONZ8gPJ4pKgQnokOwaKl/SNe1yDvdgDCpSeZ
	hISvCk/O6X5WA1uW31KHZltjC+G8BwphM36Dp5yWvFhxPpi2sKPJVPHVQh8B8rOnL7A==
X-Received: by 2002:ac2:5382:: with SMTP id g2mr39387094lfh.92.1564045867793;
        Thu, 25 Jul 2019 02:11:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwd4ahy5QKTQ7b/RN2/myjL2ohmDB4s3xeTf9/U97pdjezgeh02cl7OLe28EV6zTyF3jXjY
X-Received: by 2002:ac2:5382:: with SMTP id g2mr39387070lfh.92.1564045867068;
        Thu, 25 Jul 2019 02:11:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564045867; cv=none;
        d=google.com; s=arc-20160816;
        b=P7MGtwpQHHYcZFBvCOHqx/R+jmv8DUogc2843tQKXLc5Vd7HCnvldFlf43ybHfM2Bm
         IhoyPHo8QSsUrKoJnEx8Islj62UTz6Oa1HVcvu4KOylLGi6kSTPHDgy3C6d1j5HxAwrO
         Bo2+u1urImfeV33B1+SrDIOqoe82+9Nfsdp703Lw03pU+kkD52cOQhixkSBPV3iclbfF
         LPDhmpcWt6W5I73jCFO87muSWzw05JDSjfa3aoALgAQ0OfOny5UD9PlODaF5OfisVg3m
         SfzGgJSoIWTsn6GIBsBAB0Ut6oV2AbPXvZaegqDhPiwoCUYpx9I3e+xUfWPcRw11dbjn
         IGmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=gMBsBtmQofewQRFe8G+fHzPSGjRcz59YHLDw9u+ClmQ=;
        b=s7UfkjddQC8XIb8HRqiXPhpTcytTuXLD/yhPof95PLdgq+vyS+merJhyh9SQB0figb
         0u3nvH8skc8GrMoBYsUZfr1LMIoozUzn9etE1+omEZtWG5Bbm6WUZnxZIufYosJuVn5h
         Dc43g476aGcTWXRGW288P4lyI/zpF6UzU18UC0GN2d43Kw0bfP5crW5c1RvfUoUcDo35
         zV3xndzJf9fCzRX7nidldQi6ngCX3NS5eXLoyemuenLNZMSepbMfcrz7M1RqRu2NFrMw
         Poig02rKCBQbmtK/IyVnfDImJcAvWJ2qBMZIBg4imc1DlzAQ68rWI/SzZoRx8h+ceemw
         yoRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
Received: from cloudserver094114.home.pl (cloudserver094114.home.pl. [79.96.170.134])
        by mx.google.com with ESMTPS id v1si43766285ljc.13.2019.07.25.02.11.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Jul 2019 02:11:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) client-ip=79.96.170.134;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
Received: from 79.184.253.188.ipv4.supernova.orange.pl (79.184.253.188) (HELO kreacher.localnet)
 by serwer1319399.home.pl (79.96.170.134) with SMTP (IdeaSmtpServer 0.83.267)
 id 487a086af6bce042; Thu, 25 Jul 2019 11:11:05 +0200
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in acpi_scan_init()
Date: Thu, 25 Jul 2019 11:11:05 +0200
Message-ID: <2247325.5bJu2Pzk7V@kreacher>
In-Reply-To: <20190724143017.12841-1-david@redhat.com>
References: <20190724143017.12841-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday, July 24, 2019 4:30:17 PM CEST David Hildenbrand wrote:
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
> 
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Len Brown <lenb@kernel.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

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
> 





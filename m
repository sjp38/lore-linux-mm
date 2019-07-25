Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19DDAC76191
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:19:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB5EA22C7B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:18:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB5EA22C7B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 362888E0058; Thu, 25 Jul 2019 05:18:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EDAE8E0031; Thu, 25 Jul 2019 05:18:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 196528E0058; Thu, 25 Jul 2019 05:18:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C0AB48E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:18:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so31792021ede.0
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:18:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DNrabhREctcUB3AGU3bTK51aEQgQ7EVQBd+9wLyIrE0=;
        b=NAXTCJZIDya62SpuIGehNeyFwgQO1pohoveicBVCicr9ok07+fCjjvgQlN2FakJp/M
         W4l4YlLPhZxrxfYy+i1j9XcH2L1PJYfvdN7FnY5II5lnITD6hCvE3A1Z8ga8TXlK6Sfy
         H0dHKJCScEPoO6MJccL2z3bfpp/w5rX0p6ta9l5n2IEggZJw9FCVXbr43mymv7UPbzVp
         RMDZ/z7zQQWK+sjD9lDcx12zfwKpHEBucbEK0H8YR4YKXG9DR0KrsWadHowPeADdOqsR
         lezF1/OWCD8psCFIdNpm/J+ZRFI5PN3tLmucDAfqBMn/MhqqE012JmQ5sYeXyLzO941y
         Dxfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVZp4wKpuTxG3qO1/Y+uQPEozFYtSLscAvw8KCHaG8nug6RmT5J
	t/OUqawNCXAhSKvN1YwXDc8OiNo9SQzu9JNpNPdMPs/XZfieQabMdj41Bf8iKj25EJPL2FhqxMW
	GMYc+H9bmhNB4o/PjnfqzDIfPoZC4M6MEOemOM5QlPzf/tQkDAch3uMhveMoSEw9giA==
X-Received: by 2002:a05:6402:683:: with SMTP id f3mr73909215edy.200.1564046338339;
        Thu, 25 Jul 2019 02:18:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2HZ84RGP1TUjSHY7mhD604/VtPcNSWv6p1yii1fZfHxhI0xt9EIS9lcyj8IqV/5vUTMXH
X-Received: by 2002:a05:6402:683:: with SMTP id f3mr73909188edy.200.1564046337720;
        Thu, 25 Jul 2019 02:18:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564046337; cv=none;
        d=google.com; s=arc-20160816;
        b=vCbWEhX2DO+Kn1UkZU4YG+h3s5rUjbAMHsEHFVfq0CUh2uhpI8RgpdUmA/cPdegbRR
         QeiZY+haxcjjBOWAmLaqTKUeHW36XEvaRC1gJDlqAOH+p76FIr4L/68EUtHJjcNoZkeU
         pJKMHizwRT/xgYNU9VZ2U7aF3xZTTpx/HJuh0xnLjrh6PJoRIy+D7TIwPNeE3fzrcHTB
         Y9pnNsuKOwGGvYMwoZ/LafknRTIm7TYcVdzstTe+zeoMpq1aTXZvKmvbLxkYVD8GZsvS
         totN4aKmIAQt13o5DMByveZTeZvEmOKYAnPElLNhvVz66GuLe2YzSQow6JnnODhC17kd
         ICtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DNrabhREctcUB3AGU3bTK51aEQgQ7EVQBd+9wLyIrE0=;
        b=fRBH8yF8ApAA2n1BG98eE3aBPG+Cv9f5VOrGtW2HkpcUtpoxJTXlxLMiyQNAGBMJ9l
         fifuRkvbkVNlwf/Rq0HeIrdXlcRKMPO4SmvYOpbpHT+geC3WDIBHec5m+8xlJv8Y3NaO
         i+gpukLOhVrVdOKAmVdY6Km/r5hbpj4rUUYat8Vj4ijHwSf/ANEoyUtycPfXvNj+szSq
         xep0hytOF5EiUs9D3tThfWrjoPziXyh3LbW3lHsXuDpN/P9guZ290DLw4EXZDZcBm0By
         HsTs1OY9y6vYODzGs/abNHzx39tDHFdAm1ttN8JVOZ9S5ycUWYRCr6qWUyFS1ncEFglv
         UKZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u8si10586868edm.69.2019.07.25.02.18.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 02:18:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D7FBBADC4;
	Thu, 25 Jul 2019 09:18:56 +0000 (UTC)
Date: Thu, 25 Jul 2019 11:18:54 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in
 acpi_scan_init()
Message-ID: <20190725091625.GA15848@linux>
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

On Wed, Jul 24, 2019 at 04:30:17PM +0200, David Hildenbrand wrote:
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

Given that that call comes from a __init function, so while booting, I wonder
how bad it is.
Anyway, let us be consistent:

Reviewed-by: Oscar Salvador <osalvador@suse.de>


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
> 

-- 
Oscar Salvador
SUSE L3


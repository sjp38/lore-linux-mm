Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E44CC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:42:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D99D820838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:42:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D99D820838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88ED98E0037; Thu,  1 Aug 2019 12:42:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 818DE8E0001; Thu,  1 Aug 2019 12:42:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 707E08E0037; Thu,  1 Aug 2019 12:42:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 326808E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:42:41 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id q10so22361543pgi.9
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 09:42:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=/CVcMIx6OFg0PNVjp68xBSYBil444rGpajeQ5aMLBTk=;
        b=XbutG1PpZuK59VUA660FvsmGbhTQb+T1QDOWLYl1qScuQm5Gk/MAktbi/S+fVOw6Kj
         KXskl+a1y0Om3fjBB+Dzcw9CZSzrTlsvg4KsCURzUCeyP4i1s/6omLRGNvOP7vzBd99X
         9m6EowvQj95Vs1z4pT2azAZEMbF84ytdAY8JugN3KCvrip2U2x3ASwSkodk5jDM2WVWo
         5nZm5QI+HnHYdsqxsW6Rg0PVTgeHi3v8b3rCM8jjmzAKh9qCBqWON/oDItTozm7L5UgW
         D9/6f6xBxuK5yBzS/2L/NKIGyiL4eo3/TSSgkMD2labDHDe0I5E/R34mHLe2o8c9DxFu
         YQaw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rafael.j.wysocki@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rafael.j.wysocki@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWuNqWREkfDK41IvhTJkOsGqkXgb2kG2K0nY0ggK2edXmf/PobO
	9AkqYLqZgjvpbvkFmQkV0oKlpkITZDjrstwLizkZLIYngPC7DFTvqj5NdxiqLIW2xxnDEl2pj+E
	th2tDwiCBqC2EAvHSRzj/8k3/MnSxE4KNWzBOVX53Sck9ljiLoaE1RGUAkC1SS60oEg==
X-Received: by 2002:a17:90a:384d:: with SMTP id l13mr9889631pjf.86.1564677760826;
        Thu, 01 Aug 2019 09:42:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgrl/nseqbb/iBNvfJ7AoiGkEzIwWrg0VybfVWsVT45CFZeaMBViIXNREmvDz2cEpVAJIq
X-Received: by 2002:a17:90a:384d:: with SMTP id l13mr9889575pjf.86.1564677759924;
        Thu, 01 Aug 2019 09:42:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564677759; cv=none;
        d=google.com; s=arc-20160816;
        b=jvv4Vek2Si50xMNXcdl8+tMaNoLGLkj1ZdUkbJFkavcHX2VKq5d9DDlDKnqf0azzBU
         iusv8OH4Nli66nm/OUgePOQIZIjT8xBnLyp/umv8TQi5ZNcVWNIeH82UhTAPuIVWkn5z
         jTKPWBk6MfQUJKcB5T8UI38qZY6x67qk8EYuVIFm1fWLeMAUwCw31u1fokuxthMALsYE
         nwhW0bi14MYmuwGhPxwk+Heza1YJ8PCsR6yj0Bq7zMKukoYmARIuVPT+03ByeTIrqcro
         mnTlxeKy44o2OTBRJ4ZYbHknKogVcPwxrjM1NnSZd5SsCcFy3jjSy3wZyhckwkrUBYmn
         mltg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=/CVcMIx6OFg0PNVjp68xBSYBil444rGpajeQ5aMLBTk=;
        b=OKoZTF23BRuiHZ18ajnU80F1As5FQvGqy4clVYSQdVC9LZJ+ssS+HwRn/iYs+fmJVo
         cSN1ZERPu2JiVknDFq1ZvgUeybnijpvSGbFhianB4RDmaPQ9abq97tZ0pehpfqjXwqhd
         +Xs6EExK5y/9/SoyNBTRjvWklaXEw8nIG1JV6EO9qL+HjYqf0QHTGqJ7yD0lScfYb8tg
         6GNNvHUTzT9X6+pLoHmUn2g3q5Szf9Iey/V6TvSHRh61QSvOe5gqapla5YmM09kluc+m
         jKu/Kr9yfWEQlg4WCBuM5NJOzCCS8rghott9+DBmsGnaM9LF6BK9a6tHIoDKqidyrPBC
         JlNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rafael.j.wysocki@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rafael.j.wysocki@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q15si35374067pfh.284.2019.08.01.09.42.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 09:42:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of rafael.j.wysocki@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rafael.j.wysocki@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rafael.j.wysocki@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 Aug 2019 09:42:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,334,1559545200"; 
   d="scan'208";a="324299006"
Received: from rjwysock-mobl1.ger.corp.intel.com (HELO [10.249.145.65]) ([10.249.145.65])
  by orsmga004.jf.intel.com with ESMTP; 01 Aug 2019 09:42:37 -0700
Subject: Re: [PATCH v1] drivers/acpi/scan.c: Document why we don't need the
 device_hotplug_lock
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-acpi@vger.kernel.org,
 Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190731135306.31524-1-david@redhat.com>
From: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Organization: Intel Technology Poland Sp. z o. o., KRS 101882, ul. Slowackiego
 173, 80-298 Gdansk
Message-ID: <cf1b5664-af9f-2c0e-3c84-473dd18cb285@intel.com>
Date: Thu, 1 Aug 2019 18:42:36 +0200
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190731135306.31524-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/31/2019 3:53 PM, David Hildenbrand wrote:
> Let's document why the lock is not needed in acpi_scan_init(), right now
> this is not really obvious.
>
> Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


> ---
>
> @Andrew, can you drop "drivers/acpi/scan.c: acquire device_hotplug_lock in
> acpi_scan_init()" and add this patch instead? Thanks
>
> ---
>   drivers/acpi/scan.c | 6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
> index 0e28270b0fd8..8444af6cd514 100644
> --- a/drivers/acpi/scan.c
> +++ b/drivers/acpi/scan.c
> @@ -2204,6 +2204,12 @@ int __init acpi_scan_init(void)
>   	acpi_gpe_apply_masked_gpes();
>   	acpi_update_all_gpes();
>   
> +	/*
> +	 * Although we call__add_memory() that is documented to require the
> +	 * device_hotplug_lock, it is not necessary here because this is an
> +	 * early code when userspace or any other code path cannot trigger
> +	 * hotplug/hotunplug operations.
> +	 */
>   	mutex_lock(&acpi_scan_lock);
>   	/*
>   	 * Enumerate devices in the ACPI namespace.



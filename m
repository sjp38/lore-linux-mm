Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55238C41517
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:53:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23646206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:53:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23646206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92D8C8E0007; Wed, 31 Jul 2019 08:53:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DD558E0001; Wed, 31 Jul 2019 08:53:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A60B8E0007; Wed, 31 Jul 2019 08:53:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3081A8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:53:37 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l14so42358952edw.20
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:53:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3njEql/Ucb9XnYA1rXmZitq3pTN7wgVyH5N1bno1CIU=;
        b=QMvQ4afzxOOyRrFrooc/09ZpcCuUC9xJS+Cthmy6NQbnhyIWmIW831TGBYYK/TfuRL
         /Gfg0bWdSfvyd8G9/PpWK7Uys5pTOanBDemdV1gAwoI5wEk9IM/fy6d7VYVZBVi5sdGi
         A4JT4TNM2zUVq9LM+z8tyrojZIKPRlOpyCRYhPhbbZPtE3uhd7JA0XPg/8ewWQd9Ln58
         nWvW6oeCtjHsr5ke1LsL8iCMK8YwURICHLn1Ife+Nc0tRDU23TQJt/mbOWANguYw07Xa
         9l5p2izd7LF7IESDnvt743O9kt0d4YHmk+xC8VlRpm0A3EVB4Nq/nQTVrIqq2cV0TnSr
         s1iA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVTj3pm/96kZBxXxN/uZ3rux5GSGicKlNi+FKKRfDyYFh/1Aujg
	7wjveMSava2lk8CvdTXLJHvScC5IL/qCbVi/1zFYUghdL2AFU5/OUvW2ldFenOGv1QXbAd1UI7m
	hxEwi0zCsi5Mc9/nXUpSZMcQozLf8TD2VU4yx4k5cDsKWhvAodp6JR2SJ+SeA5No=
X-Received: by 2002:aa7:d0cc:: with SMTP id u12mr107693122edo.212.1564577616779;
        Wed, 31 Jul 2019 05:53:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLbUYwQQtEtpia89S/9pSPVxr+kW2Pe8bSmHDr9dIORX4iXHm2awNROUVMN4UvGCW/h9vV
X-Received: by 2002:aa7:d0cc:: with SMTP id u12mr107693076edo.212.1564577616153;
        Wed, 31 Jul 2019 05:53:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564577616; cv=none;
        d=google.com; s=arc-20160816;
        b=z06vM3lFRZ9ZWX/lLS6rqX1jCuhXSDqxN11eOQ9ODsdQLpeZzi42g255ZTmTrzPIo9
         qPieppNQLRfAWBXhT/VgwGaEyozSGo8WnRzBQ3LD5jBO6vZoEXkiXI4J+4e+9EfS8DYn
         EHWxtABs8fTlFtPMOjMSWUyVWb20s3EahfETEhlIhgXzfvBqm3yQxWmpDpjOqQpBZ1Ur
         clyXQwe26tL0P0pxC/1CVupaaDMjSgiyLuOBHXpjA1ZJ+gD2fI/6WOJ8lULzGp9w9Ay3
         h/iS+cLKqX/RCDPkcfgSWrkDIKJQxtuUXfqfuI0Qh2gQaob0/EgRyuT+HUhKyhprFtPk
         BLHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3njEql/Ucb9XnYA1rXmZitq3pTN7wgVyH5N1bno1CIU=;
        b=yriNGRgKViLZ/8vmO0wt1mJg14y5IPzmFobwyWrY++u9F5yDYIt1uL5RWiIFifcq7J
         eOJrAFeWHsBKpQ/sQJlSp0DTd2RdJErwevsmTRulR2Ou4xt7juDuokgaO9d1C0rsMae2
         gVHIAEij3wuN71lk/2Z2bWohR4ITF/bv1V9FH2UB1GWXyqkmENsgZZ3uWEeHwFRf7jBU
         9CrDKvecLOrXBf9HLIaICkSO1b31DcebEypTcjHMc0+URZS8NuD88fRH4RBdT+sWCcHi
         kGIIH4yypXwj4D8Ql6zuXFC5fukY4ID112sCIf34uUPACMZQRMuF7k+2/JytXaD//cQA
         GIjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5si18694547ejb.103.2019.07.31.05.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 05:53:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 512F7AFEC;
	Wed, 31 Jul 2019 12:53:35 +0000 (UTC)
Date: Wed, 31 Jul 2019 14:53:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-acpi@vger.kernel.org,
	"Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1] drivers/acpi/scan.c: Fixup "acquire
 device_hotplug_lock in acpi_scan_init()"
Message-ID: <20190731125334.GM9330@dhcp22.suse.cz>
References: <20190731123201.13893-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731123201.13893-1-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 14:32:01, David Hildenbrand wrote:
> Let's document why we take the lock here. If we're going to overhaul
> memory hotplug locking, we'll have to touch many places - this comment
> will help to clairfy why it was added here.

And how exactly is "lock for consistency" comment going to help the poor
soul touching that code? How do people know that it is safe to remove it?
I am not going to repeat my arguments how/why I hate "locking for
consistency" (or fun or whatever but a real synchronization reasons)
but if you want to help then just explicitly state what should done to
remove this lock.

> Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/acpi/scan.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
> index cbc9d64b48dd..9193f1d46148 100644
> --- a/drivers/acpi/scan.c
> +++ b/drivers/acpi/scan.c
> @@ -2204,6 +2204,11 @@ int __init acpi_scan_init(void)
>  	acpi_gpe_apply_masked_gpes();
>  	acpi_update_all_gpes();
>  
> +	/*
> +	 * We end up calling __add_memory(), which expects the
> +	 * device_hotplug_lock to be held. Races with userspace and other
> +	 * hotplug activities are not really possible - lock for consistency.
> +	 */
>  	lock_device_hotplug();
>  	mutex_lock(&acpi_scan_lock);
>  
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs


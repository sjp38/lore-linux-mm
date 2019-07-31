Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7A6DC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:17:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E334206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:17:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E334206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2117C8E0005; Wed, 31 Jul 2019 10:17:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C1E38E0001; Wed, 31 Jul 2019 10:17:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D8BF8E0005; Wed, 31 Jul 2019 10:17:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B2BB58E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:17:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so42514174edv.16
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:17:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lv2C26mM+/YHifXZ7gjVeOUQap9HrlBtkrYBA8q5Ggk=;
        b=UPkQSFcbqBl3435x0znpYM+Uk3wUFG5Igd8uhE9Cf4m6/OChlH6ih4NCMz6dvwZv2O
         lKp7F2O/sK8vFlZAzspXwpHhpoZyrTXjNwNEc8XhHfvbwOlaS0RiinW3HmoZCy9TrvHG
         9KX2llIHN+NJx7sWMabcTFo/1xvZOMVwanWTHqoeiQ0xqo/zeASEqiyXByF/U94kwwE7
         2ojwcBjcDmuEtu1x2JowUWdp2w6Q176Vb6jkFVFcE/ilK/A7XRMnsCOJ/aCVLgrPX813
         BUAjLdyaftyBMmLb3oaAJHgDr3VPhHjdvqtUyVfWVd+nb8u+Yv2w5nAz5vrcBQ0nigdZ
         phCg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVUglVXwW07HFfPGIWNlWZssK3J9sXTw5+PajmB7UnDaO2OmHKN
	/I2fijkniUlQkWmT4OTXiBtofTnRqlYPZuYxEIro3opvi220+Pzu92bzwxKAu7oeLU4TV7cbqxK
	b0/Ev+1Cx8sxNxloU0sHXWUnWUKToWwvCOCVHKMdbva7gvyDa3GDGFF+UQRNp5Wc=
X-Received: by 2002:aa7:c3d8:: with SMTP id l24mr110004743edr.58.1564582626299;
        Wed, 31 Jul 2019 07:17:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEhaZiZOeDIfr84v4K7PhNNlCBbcQTONWjOvuhpfJPNE/y76PZVlR2DMQlGr4f4G8HK5Ag
X-Received: by 2002:aa7:c3d8:: with SMTP id l24mr110004681edr.58.1564582625670;
        Wed, 31 Jul 2019 07:17:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564582625; cv=none;
        d=google.com; s=arc-20160816;
        b=SgSba00ClaV5/rk/uHnhAE0okNMOEERonwrCTqwXD7s8sB9fjKikn8SJtmxPn1jvGM
         NaNAzgVA4MmyFJ36q5HdqbNYZTuFJjkaQFxwbC349hnYPQMiUesb45lFzKeOJyJeA0/Q
         0cd87AipLdVn/FwyE5BKypDBUXJp5TQ26Q/BJYynrjsS8xsKjx311N4xFr2mPRX+XVyO
         5uY0nO0WjzVQmRksfIYIqLhzKh1D+4oVYwAdXBppjZtywD6uLIqRNPvSNgPqyxsIlJ5V
         Rrg9VNoiPTjcm5rip0JZJxXY+nZ163ByBx7QHhHTNrj7glh+RL6UxCJW549CwTueS25w
         2zGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lv2C26mM+/YHifXZ7gjVeOUQap9HrlBtkrYBA8q5Ggk=;
        b=Dr9hy9F8i1l0GuWhpnuFcPPGbJ64VtTXdwxEN8dQD+q1wh/YsINdEPio3GcML3HKDI
         rMQiNC46Yx52Wd+Wno1GIwjfBZQdxvnJsgOk6MrRpFGLxTUePMzRrXJe1Am8lRHQAY1c
         VKDd/S3T16D8QPf+1DM3bzwESR2Kdeu9ku2sxkH4FM7p3tyf+5b2+re+UEgBMJa+z+/0
         Qm9L1y/37RUJz5fKprg+XA8I28biQ9N1UvcqB6lcYsMZur7M7rOui3RJ6mx86F4mygTC
         8hYAERBj9VO5WhV/YKJmc412vBgtdLlzaGcBnyqA4Ynsy4I+KG8EJZ5TQGr1l6uEw/zL
         CDrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j9si18874405ejv.235.2019.07.31.07.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 07:17:05 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 23B6BAE5C;
	Wed, 31 Jul 2019 14:17:05 +0000 (UTC)
Date: Wed, 31 Jul 2019 16:17:04 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-acpi@vger.kernel.org,
	"Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1] drivers/acpi/scan.c: Document why we don't need the
 device_hotplug_lock
Message-ID: <20190731141704.GW9330@dhcp22.suse.cz>
References: <20190731135306.31524-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731135306.31524-1-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 15:53:06, David Hildenbrand wrote:
> Let's document why the lock is not needed in acpi_scan_init(), right now
> this is not really obvious.
> 
> Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
> 
> @Andrew, can you drop "drivers/acpi/scan.c: acquire device_hotplug_lock in
> acpi_scan_init()" and add this patch instead? Thanks
> 
> ---
>  drivers/acpi/scan.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
> index 0e28270b0fd8..8444af6cd514 100644
> --- a/drivers/acpi/scan.c
> +++ b/drivers/acpi/scan.c
> @@ -2204,6 +2204,12 @@ int __init acpi_scan_init(void)
>  	acpi_gpe_apply_masked_gpes();
>  	acpi_update_all_gpes();
>  
> +	/*
> +	 * Although we call__add_memory() that is documented to require the
> +	 * device_hotplug_lock, it is not necessary here because this is an
> +	 * early code when userspace or any other code path cannot trigger
> +	 * hotplug/hotunplug operations.
> +	 */
>  	mutex_lock(&acpi_scan_lock);
>  	/*
>  	 * Enumerate devices in the ACPI namespace.
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs


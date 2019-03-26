Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F0C4C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:25:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5269C2075C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:25:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5269C2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E34776B000A; Tue, 26 Mar 2019 08:25:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE4486B000C; Tue, 26 Mar 2019 08:25:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFB106B000D; Tue, 26 Mar 2019 08:25:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 813D26B000A
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 08:25:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w27so5189534edb.13
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:25:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0kExSGrmWcIB0sl93VIYmUJ8N4mLvribsH2qMqDLzJo=;
        b=PvBbZjsBcpzHlObBXLYEGY5ALqzExVT4zIZnJUYVe7HglstYMEbhmpkMmQ2gMvpPJ2
         WekPj4pvRBMYBhCQOZ2puPqYYEiox7orCrMGKx8stVZUjHKwwAKHoLa3hDysmqRgTC+2
         UZjFQphEx8u1rgt1J3zM4nro4/X3irhsYoIg8Ccwaj/SbbBF+IAldcWr3eFKysVCLL/5
         KjOJOxUm24aMIlaXWvVOzMdhPjFNYzdy4AR/Ivb7eY6AkP4fXkqtAz8/TIoAN/Mt+zMf
         7tHMeCP1c4zYwHtoafSoWPGR30B+p4mlm7rdt/mvNEmEiKzo1+73/Y+jEZF4TVA96Wu2
         /Liw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXp6JmY3I9tdkrqI884FY1NwO1fDFD3EcnpWXojaNMnD9zLS66y
	msxHdHORz2tnZjHvZ+6xvVcXK1qMlCDZvqhfSMJeap1nzQu1vzi4fjfs8bTg6bq53jGYkDeN9DF
	H8pqmt8YtK/MQ4d97QOINmn8Y3oJG3Hdu5iKc90+7hSh5oIA89b5I3KDQK9i7vUI=
X-Received: by 2002:a50:b149:: with SMTP id l9mr19869570edd.254.1553603125087;
        Tue, 26 Mar 2019 05:25:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwA+sCI6cGKyqj3s32pRIiimdcoNN1KLDIiuwh4gBdy6p5RiRKDoNPibut2cMFKj4TRGMUg
X-Received: by 2002:a50:b149:: with SMTP id l9mr19869527edd.254.1553603124342;
        Tue, 26 Mar 2019 05:25:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553603124; cv=none;
        d=google.com; s=arc-20160816;
        b=h9qDuIX+m0rbyGQH5rfUCcqxbiOisx9jucf2rZyIK1GQH4joxPruEB033Dz6CFGCiY
         tMu7jBjjZGeIBNwnc4xD0UufSN6ROzBSs7+Y8UPla7eshmCTuiVijn7DZZWouKGp5xA0
         xkhLIAl82sLSkf05DFcvF0CLVbE69Hqrd9R8crNVVRzX/3PjPdO67B4NvM+fPoeg8owL
         sAlGmtXpbqvWgo+OdJvgFPsoKabqBkEUva6Kac6XrZt0VyY+SH+FHBHIa/ISrDuGfJ4x
         37PHCcVQMC5d5VANXt5arLy6MgO7AaFjPoOKEMH/gfWVlDjN1r9fEYssGCkxh50jDhPw
         qOrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0kExSGrmWcIB0sl93VIYmUJ8N4mLvribsH2qMqDLzJo=;
        b=sHDdvyv+k3mrJYfU4qBqg2TD9722vH7Q9X+wBszfFEYqHzM4BK7y8Oh3jmtsIoFC2B
         8w+2M4bB+EZXlwnHsH+BJnPwE3rHrGHDI/Lp/sZIHaL7TP3YKoFG7x9wpJSM/+3uLW1V
         LPl3LtC/F5Iw5NcaZJkYo9VgqEu+3kQGeYhI3BSXRDqHt0Dyd7rhOmUKL206BXJG+d3l
         uDt6to+ieqc8764ZJFM3q84jcKhokeHCLFIaJvFPvreYtngEqEYkAvPx0uYmHuO2tLmu
         gmTiOl54lTWtVobKTkCbO4qWxAULZpV3wP7etNWJ8jzqg7HENoKWEfUYhGVAzTUzSXTe
         4PNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n17si1203894edr.198.2019.03.26.05.25.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 05:25:24 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C215BAF19;
	Tue, 26 Mar 2019 12:25:23 +0000 (UTC)
Date: Tue, 26 Mar 2019 13:25:22 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, logang@deltatee.com,
	osalvador@suse.de, hannes@cmpxchg.org, akpm@linux-foundation.org,
	richard.weiyang@gmail.com, rientjes@google.com,
	zi.yan@cs.rutgers.edu
Subject: Re: [RFC] mm/hotplug: Make get_nid_for_pfn() work with
 HAVE_ARCH_PFN_VALID
Message-ID: <20190326122522.GO28406@dhcp22.suse.cz>
References: <1553155700-3414-1-git-send-email-anshuman.khandual@arm.com>
 <20190321083639.GJ8696@dhcp22.suse.cz>
 <621cc94c-210d-6fd4-a2e1-b7cfce733cf3@arm.com>
 <20190322120219.GI32418@dhcp22.suse.cz>
 <65a4b160-a654-8bd3-8022-491094cf6b8f@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <65a4b160-a654-8bd3-8022-491094cf6b8f@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 17:33:19, Anshuman Khandual wrote:
[...]
> I could get it working with the following re-order of memblock_[free|remove] and
> arch_remove_memory(). I did not observe any other adverse side affect because of
> this change. Does it look okay ?

Memblock should only work with physical memory ranges without touching
struct pages so this should be safe. But you should double check of
course.

> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1863,11 +1863,11 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
>  
>         /* remove memmap entry */
>         firmware_map_remove(start, start + size, "System RAM");
> +       arch_remove_memory(nid, start, size, NULL);
> +
>         memblock_free(start, size);
>         memblock_remove(start, size);
>  
> -       arch_remove_memory(nid, start, size, NULL);
> -
>         try_offline_node(nid);
>  
>         mem_hotplug_done();

-- 
Michal Hocko
SUSE Labs


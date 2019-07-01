Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDE60C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 07:56:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97F9620652
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 07:56:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97F9620652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 318EF6B0003; Mon,  1 Jul 2019 03:56:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A3CF8E0003; Mon,  1 Jul 2019 03:56:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16B2A8E0002; Mon,  1 Jul 2019 03:56:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f78.google.com (mail-ed1-f78.google.com [209.85.208.78])
	by kanga.kvack.org (Postfix) with ESMTP id B8CCA6B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 03:56:17 -0400 (EDT)
Received: by mail-ed1-f78.google.com with SMTP id b21so16285252edt.18
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 00:56:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=COUa2mpX659Jaq7DpTF8hgwf7cleVmC4D7dRZmILxtQ=;
        b=Ac1tILzAYgUjay9aYL12JWGRnBavtLgRtNRaMtYpbvEj10RUdJiE36yOJ6dj5HPYJt
         JNnQCCcK4vWkZXRnECP1+UCgScZa3yoXJ0XGjnGfXlvysJMb6nkSJmHz9gXV6hdZcdNa
         UGE7FET72nw+HhWaWbm2B1GUOdaw8Cpty1AAd2W6eCKAjPDy88EfV8RzMYnvODXp0Sww
         Mkzvu0sPtEURtB2DHEIHdULLVct09FTX9gNhiuz1vfenquv3S7jeXOnVIw7sIPSl4oE1
         Oyfy1OW3Wy8ebez7q4CFMvC1wZp4sRCc3JltGdxdq1mImtbYVSBXSFpGj1ejtvJYDuy4
         GSHw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX+2CUN/srco1aiVQnA8sBDXypEkawKqgTzr6mGZao881q+9gCw
	DF13YA8TRXHOUO3M5LxLTX8bfy7OjCxPwY0XyheDUtQX7okJ+r8PwjJAnJUmI3vcnOrk6nxwf0o
	tqRME1HYOHlfPTE31OfsHetG85pyHrhT3VOQzCYm7aZZsJEmfEEimV+qeZjy9IBk=
X-Received: by 2002:a50:d0d6:: with SMTP id g22mr27590538edf.250.1561967777338;
        Mon, 01 Jul 2019 00:56:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/4RAulDetsIQoBf7zWqS8hgvs7oFksZxIxqPAekkhOgyV4OCsYOi+iQvpraxR6u0WE9TS
X-Received: by 2002:a50:d0d6:: with SMTP id g22mr27590483edf.250.1561967776536;
        Mon, 01 Jul 2019 00:56:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561967776; cv=none;
        d=google.com; s=arc-20160816;
        b=XEhGiWP2b/QpZeBNraVQtKT6/HeLpD6CZYK6b4hckoEcXE8n6si5JX1uf9lbZl0y+X
         JrSZs93gGHZ8+sq+B10qtpR8yQOG6rupJb0xAkzyDNhEiRy6xHAdi3OfZnEeUpjKx0ac
         Rz72ZDM0+gZK9Q+feS63PXff4LohrtKUi6LR3MEjKcUFXiSshVOgb0xHrKo1afggYF21
         3AeScfsSS+C3evl1pLAOFm88Vaf+LW4eJptoeRuNgKPNcO+GZGlz14Yp3n/4AobjfOoQ
         c7tIriPGOXcyP0RkfH8ZZF21xofqr3/8gufJJ2JDb5Qf43atIj4GrkPSfp7RrnwVNhSM
         VJRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=COUa2mpX659Jaq7DpTF8hgwf7cleVmC4D7dRZmILxtQ=;
        b=HgHd2UkAhycKRvRp/0/1mD3AV/WRTPO/llmJQ3l6Pu7zg3ELzGWILBameMKMkNKHQm
         S8SqhXpdR+jOWtDJBabv3Werh1tm3++QtVz2CW4JtgOEZfH9wXwBUi8YOCm0Irn7iPBR
         QJ9zNHCyNts8w9EvAXvB3gqViFQEnhTEd1ImcAXY/aIn9fYaAr2yvqdKPoLaODzHlwAE
         hlwS3VvDMcCDjxIMof9x2WzVZzveBZZhw4/8a+N046hRh77+Tfz7ohVnYuEYZl0lb2jR
         eJSHMHpCU27rgDPYXZ4f4aMqL6Vsb/q7VINKBH2rpiGzRXnvd6ZdZdQBFrPFAoNtlp5K
         xtOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gg1si3693669ejb.12.2019.07.01.00.56.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 00:56:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9AD85AEBD;
	Mon,  1 Jul 2019 07:56:15 +0000 (UTC)
Date: Mon, 1 Jul 2019 09:56:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>
Subject: Re: [PATCH v3 05/11] drivers/base/memory: Pass a block_id to
 init_memory_block()
Message-ID: <20190701075615.GE6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-6-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-6-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 13:11:46, David Hildenbrand wrote:
> We'll rework hotplug_memory_register() shortly, so it no longer consumes
> pass a section.
> 
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  drivers/base/memory.c | 15 +++++++--------
>  1 file changed, 7 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index f180427e48f4..f914fa6fe350 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -651,21 +651,18 @@ int register_memory(struct memory_block *memory)
>  	return ret;
>  }
>  
> -static int init_memory_block(struct memory_block **memory,
> -			     struct mem_section *section, unsigned long state)
> +static int init_memory_block(struct memory_block **memory, int block_id,
> +			     unsigned long state)
>  {
>  	struct memory_block *mem;
>  	unsigned long start_pfn;
> -	int scn_nr;
>  	int ret = 0;
>  
>  	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
>  	if (!mem)
>  		return -ENOMEM;
>  
> -	scn_nr = __section_nr(section);
> -	mem->start_section_nr =
> -			base_memory_block_id(scn_nr) * sections_per_block;
> +	mem->start_section_nr = block_id * sections_per_block;
>  	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
>  	mem->state = state;
>  	start_pfn = section_nr_to_pfn(mem->start_section_nr);
> @@ -694,7 +691,8 @@ static int add_memory_block(int base_section_nr)
>  
>  	if (section_count == 0)
>  		return 0;
> -	ret = init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE);
> +	ret = init_memory_block(&mem, base_memory_block_id(base_section_nr),
> +				MEM_ONLINE);
>  	if (ret)
>  		return ret;
>  	mem->section_count = section_count;
> @@ -707,6 +705,7 @@ static int add_memory_block(int base_section_nr)
>   */
>  int hotplug_memory_register(int nid, struct mem_section *section)
>  {
> +	int block_id = base_memory_block_id(__section_nr(section));
>  	int ret = 0;
>  	struct memory_block *mem;
>  
> @@ -717,7 +716,7 @@ int hotplug_memory_register(int nid, struct mem_section *section)
>  		mem->section_count++;
>  		put_device(&mem->dev);
>  	} else {
> -		ret = init_memory_block(&mem, section, MEM_OFFLINE);
> +		ret = init_memory_block(&mem, block_id, MEM_OFFLINE);
>  		if (ret)
>  			goto out;
>  		mem->section_count++;
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs


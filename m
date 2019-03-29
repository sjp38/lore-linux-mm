Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 714A8C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:13:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37E492173C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:13:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37E492173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD0B16B026A; Fri, 29 Mar 2019 05:13:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C80586B026B; Fri, 29 Mar 2019 05:13:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBC926B026C; Fri, 29 Mar 2019 05:13:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6FFC16B026A
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 05:13:28 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m31so771081edm.4
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 02:13:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7dbCtRuPK+fGf8kjczUnXrEmzmPaf6kaofCaXTocWlg=;
        b=btFzpKKtEUXuyP+LRNocVHm8LgNBmepV3d1/8bj3thY5nX8/avGyezg8Rk4B6auoLc
         YiADOPsUL9V1ZNES3QkOxIF5I5789iZnrWNf2LI7mrqEEgDmbXEcnePc7zbmO43qPIEb
         TAw5CueghT96rwKsZE/HpSklhWaDhIok4vnyZ+ZWoNoWCEbrlZYJHoWfRjCD3vu+gc/n
         Lg3LAfQXapSEkIA451QG0uOMpcY/dZumMs7bVEUlwWndfHJwH2Gt3+UZephdbCmaK/PF
         SAfaE3yGsZoKBnurKqQj8XJ9gQvi7rtO9dVWQI5XpanbEF0/vNKWvsO0Lu3dmlAWm+yD
         nHpg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWJkrwfteiBJnHyZ2UxLTJSO6U94U07GDDIM0QeHIhGltW8VC25
	4apJcouvqCFmxOwxpYMonCuAtRK5TQ52kX/d4O4FUsjx1INPEodPd+pQZ6QDPwPSE5HoRJn3ULG
	O+bZmPkgIc2BVxhbHikpLN9+K3IhSF5mMVzDc4bWT+1utJIgfOzkxBnLh02Ro73c=
X-Received: by 2002:a50:c982:: with SMTP id w2mr12190602edh.47.1553850807945;
        Fri, 29 Mar 2019 02:13:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwe32GioAJ8Be5Kgd6wyKXJ5VC/e/TiTfN6uVtUn3Mbd7N5lY+NZS/LAiFJiJql1qmI7Cf
X-Received: by 2002:a50:c982:: with SMTP id w2mr12190570edh.47.1553850807079;
        Fri, 29 Mar 2019 02:13:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553850807; cv=none;
        d=google.com; s=arc-20160816;
        b=exf9V5kd1Sx7QjyXZAeeCKJcKnQ4YubZeIPVdzI3LxdoA3zmt7PhtZ0QBlFben2xBK
         CaUivtswLbcEN5ENZtxRbH5bJsBc3cMtXh4JQwRHuoHWHPzXwe3aVO2jJs4TRw5bAqW/
         JAaJwySyl7F8mbgO+Vd4gE+J/1fP1JKH9Bcm/osoDkZzYYETOtCpWe6LERpp/FZbLxHf
         miHCHcaS15El4B5ygTWMWmyITjrgIl+2655DarpDffpUlbaZ2ZdB4e4M2bIVpNPT4UGo
         QyVPPgl204o3QDD9C0TYKdKqQwavXVbSiWuFD4wb/N72m179MUtLVcftwxIAw0Ny8slV
         i2Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7dbCtRuPK+fGf8kjczUnXrEmzmPaf6kaofCaXTocWlg=;
        b=aFtW56o9hodejyrSLtnazhb0Q9PemZdPrblPfCXQzu0yNwUWqVgJvRLZtEUfxhSb9j
         S4oJOtDeppQ7x/tP0uZk/VWOXLBmf1JhKNXzeyCehXLOVKrmAGMopPnGs/zuvwOs9ML6
         9qHEFxBwK8Cy1+lS2XKv3A6PK1l7usaK7MLjcdLvp7gDzfIHTZHRKGncmhLLyYEeppCc
         sEq3/oANMQ8d5gOasUoHaDaK+7w6nUgjavKSL4alhAcjrH3Tc2/vO6/7jvSAsLxHgVQv
         7IRhqQFhF8f9u4fIgZ9TY/bAxD9bBQ+afNQRCgCqSPgBpkd/DQqE3z0IVvgYCfLPkVNd
         PAYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g23si694100edh.174.2019.03.29.02.13.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 02:13:27 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 89C11AE52;
	Fri, 29 Mar 2019 09:13:26 +0000 (UTC)
Date: Fri, 29 Mar 2019 10:13:25 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rafael@kernel.org,
	akpm@linux-foundation.org, osalvador@suse.de, rppt@linux.ibm.com,
	willy@infradead.org, fanc.fnst@cn.fujitsu.com
Subject: Re: [PATCH v3 2/2] drivers/base/memory.c: Rename the misleading
 parameter
Message-ID: <20190329091325.GD28616@dhcp22.suse.cz>
References: <20190329082915.19763-1-bhe@redhat.com>
 <20190329082915.19763-2-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329082915.19763-2-bhe@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 29-03-19 16:29:15, Baoquan He wrote:
> The input parameter 'phys_index' of memory_block_action() is actually
> the section number, but not the phys_index of memory_block. Fix it.

I have tried to explain that the naming is mostly a relict from the past
than really a misleading name http://lkml.kernel.org/r/20190326093315.GL28406@dhcp22.suse.cz
Maybe it would be good to reflect that in the changelog
 
> Signed-off-by: Baoquan He <bhe@redhat.com>

btw. I've acked the previous version as well.

> ---
> v2->v3:
>   Rename the parameter to 'start_section_nr' from 'sec'.
> 
>  drivers/base/memory.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index cb8347500ce2..9ea972b2ae79 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -231,13 +231,14 @@ static bool pages_correctly_probed(unsigned long start_pfn)
>   * OK to have direct references to sparsemem variables in here.
>   */
>  static int
> -memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
> +memory_block_action(unsigned long start_section_nr, unsigned long action,
> +		    int online_type)
>  {
>  	unsigned long start_pfn;
>  	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
>  	int ret;
>  
> -	start_pfn = section_nr_to_pfn(phys_index);
> +	start_pfn = section_nr_to_pfn(start_section_nr);
>  
>  	switch (action) {
>  	case MEM_ONLINE:
> @@ -251,7 +252,7 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
>  		break;
>  	default:
>  		WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
> -		     "%ld\n", __func__, phys_index, action, action);
> +		     "%ld\n", __func__, start_section_nr, action, action);
>  		ret = -EINVAL;
>  	}
>  
> -- 
> 2.17.2
> 

-- 
Michal Hocko
SUSE Labs


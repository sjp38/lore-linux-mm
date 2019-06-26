Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFC21C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:21:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E10F2085A
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:21:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E10F2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE2498E0005; Wed, 26 Jun 2019 02:21:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6A818E0002; Wed, 26 Jun 2019 02:21:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B31F48E0005; Wed, 26 Jun 2019 02:21:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 623138E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:21:17 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y24so1615106edb.1
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:21:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UbQ0LWxOThJiValZiSjck/pdiQHYcIEH4UGPXHP3Ogc=;
        b=gY0A+YuvuDGg/UtECDR6LCzCks2p7Ixri+XsNNk/JSAXAdD7FuBHQPgqETIt3hpj2N
         7IhaNd0PeeTdM8WYnItDN6gtHRus68FutaXo0BADiX00yiFca2oa+eLR/zCxEv6B6yPV
         /lA/kPLmW56qPCJ/wmzX8qlz9x8buYoclnBKwS8iMg7nE7jB6kx+OPniAO1C+RXvXva6
         aXGkMqfaGAFqaPScNBHKxLhX0AkNeSIbqjnVKqzzMYONipF/xwrw1nbMHNwm6xDDkOO9
         uTss25zrx2LDuz98u6qowLZW7EUiNKHWgqt4oVsX/S1O3P2npeti1dpFg9F2nHeTlvI+
         7gYw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXOEqABxM15MzLL6vCmp8qB8pLBGXgHzR7aKuF1hTxAqcS8TOmG
	5S7LSh72O8FMBIZ7PrKg31yh0fZQ7SuK/v8klfLSmPzpJFMuDSkW5TLdDBAbKUzXpt/cdGC6tBd
	BGj4tdUHfSZsNypaQ6nmbe16IeXF/A20D03YD3LknBl4nnzoQ3om5jqjp33K+9ho=
X-Received: by 2002:a17:906:7541:: with SMTP id a1mr2386350ejn.50.1561530076955;
        Tue, 25 Jun 2019 23:21:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQMe8DAMRPkQlwvoAm0U+EYejpvvH9QMxqu8LuGAnr9T8OWunT8bR7OhqEi8G+KVJRnKxV
X-Received: by 2002:a17:906:7541:: with SMTP id a1mr2386305ejn.50.1561530076193;
        Tue, 25 Jun 2019 23:21:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561530076; cv=none;
        d=google.com; s=arc-20160816;
        b=HQJwUDAiDSG67EKgniXR9viVsrfLNNVsrG4Uy38HMoPEz8jG3+GwMTrkecWBbF1V30
         tM7Q/deTpqCMzfFweARP3KydvPwgJXrSM16ePqGrTPn+G8eLcxMkA1tzSq4paSDoOeQ/
         SVUp85o0NwDmxX/49tywwUKT4+TBrVynDve16xQG+a5kI62iUdsFsg0hnPETU2tbYnyW
         TN7lCjUyo7kqFTu0/9zXksSrAjyiJ+7JBnX5+hmBXb03vucJStqPX8AM8ZDUs1QKkDxs
         uogho2wkpuuCnkD7jyg0hMTmnv7oPF1tD3HsI9X7In6poT8NLew4Q5G1RvMiztldrAbm
         c59g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UbQ0LWxOThJiValZiSjck/pdiQHYcIEH4UGPXHP3Ogc=;
        b=ZDsgnJ8Xz7/DIvVc0d+FKrvSRr6ni4tDPeGL4rVMXvCEXdKCH2yBStNKhBnDt/+pQ3
         kon5TwpM05yX+8XHa5m9dixkD/IiaNqePq5mhGT2ZTXgxBRatFNd2wX7SiDnmrxNXUaL
         40KLkkuY+RSNHdSijPkkm5oEQvq4YIz+yar0eiOMrUT6CWnwJNSrAq0O70ylYBEa01TB
         Rhph9bEtg0oCgjNyOZYh9ZgnB6OROW0psX+vrPQitxwG0a26q6bpIeprxtvRJgeZfAHt
         WP+6psiTXCBxlEQVVA08lOokXxYPZd0kmbe6nyMzurSxPWQk2iwC7EIq2uxHyEFiM5j5
         Aygw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f20si2259004edy.431.2019.06.25.23.21.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:21:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3619AAD47;
	Wed, 26 Jun 2019 06:21:15 +0000 (UTC)
Date: Wed, 26 Jun 2019 08:21:13 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>,
	Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 1/3] mm: Trigger bug on if a section is not found in
 __section_nr
Message-ID: <20190626062113.GF17798@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
 <20190626061124.16013-2-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626061124.16013-2-alastair@au1.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 26-06-19 16:11:21, Alastair D'Silva wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> If a memory section comes in where the physical address is greater than
> that which is managed by the kernel, this function would not trigger the
> bug and instead return a bogus section number.
> 
> This patch tracks whether the section was actually found, and triggers the
> bug if not.

Why do we want/need that? In other words the changelog should contina
WHY and WHAT. This one contains only the later one.
 
> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> ---
>  drivers/base/memory.c | 18 +++++++++++++++---
>  mm/sparse.c           |  7 ++++++-
>  2 files changed, 21 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index f180427e48f4..9244c122abf1 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -585,13 +585,21 @@ int __weak arch_get_memory_phys_device(unsigned long start_pfn)
>  struct memory_block *find_memory_block_hinted(struct mem_section *section,
>  					      struct memory_block *hint)
>  {
> -	int block_id = base_memory_block_id(__section_nr(section));
> +	int block_id, section_nr;
>  	struct device *hintdev = hint ? &hint->dev : NULL;
>  	struct device *dev;
>  
> +	section_nr = __section_nr(section);
> +	if (section_nr < 0) {
> +		if (hintdev)
> +			put_device(hintdev);
> +		return NULL;
> +	}
> +
> +	block_id = base_memory_block_id(section_nr);
>  	dev = subsys_find_device_by_id(&memory_subsys, block_id, hintdev);
> -	if (hint)
> -		put_device(&hint->dev);
> +	if (hintdev)
> +		put_device(hintdev);
>  	if (!dev)
>  		return NULL;
>  	return to_memory_block(dev);
> @@ -664,6 +672,10 @@ static int init_memory_block(struct memory_block **memory,
>  		return -ENOMEM;
>  
>  	scn_nr = __section_nr(section);
> +
> +	if (scn_nr < 0)
> +		return scn_nr;
> +
>  	mem->start_section_nr =
>  			base_memory_block_id(scn_nr) * sections_per_block;
>  	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
> diff --git a/mm/sparse.c b/mm/sparse.c
> index fd13166949b5..57a1a3d9c1cf 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -113,10 +113,15 @@ int __section_nr(struct mem_section* ms)
>  			continue;
>  
>  		if ((ms >= root) && (ms < (root + SECTIONS_PER_ROOT)))
> -		     break;
> +			break;
>  	}
>  
>  	VM_BUG_ON(!root);
> +	if (root_nr == NR_SECTION_ROOTS) {
> +		VM_BUG_ON(true);
> +
> +		return -EINVAL;
> +	}
>  
>  	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
>  }
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs


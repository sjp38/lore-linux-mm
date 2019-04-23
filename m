Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82B86C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 21:21:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EE37218B0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 21:21:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EE37218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F4DB6B0003; Tue, 23 Apr 2019 17:21:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A5076B0005; Tue, 23 Apr 2019 17:21:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56C156B0007; Tue, 23 Apr 2019 17:21:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 353DA6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 17:21:25 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id p3so14208096qkj.18
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 14:21:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Kd6ItcCsoMCfNADJOM1r5WTWkxzSnmXVdltfLMmYUyg=;
        b=bhBMMNBZCdBQwczyOPeLgS5UFT4R8GwDJ8X7/m3sdxl0L4qichaVfIrW77NIQijrTE
         B6DKcBHCALteuXhEmnQ+tJMSwflLyQ2L/y/RyBCvdV1NiY/I0BAR/x6hUQNeLHWqwT3J
         Pc5P3Q4aWPBcmM17jLp+w7pkTVy3uoo6RLURmGP/b5IMrv/MSqJ7afkD8dX0gfnB4M6w
         oCdZ4Wo0ctw/eZbiN+CzKH+x7bl6S7GLiAL2p3f1/lDySZPc75qW4d0tO9w59gmEmOmG
         ZrZVks2jJ8S1e1Z2gZukTJFSJNSgMqB10u6OlwwetbakULC9f4yq8L88BWVIARMGnwOj
         EcFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVBiieVSvrbYAHmLr7P9cQBzeWFujA8BG6AhuLnoEnLRBUeAXLp
	eQh+rA+BRVAosWdlevcwjRBzOkNcCsbt5nSzRr+3HUaUGyll6WY4FFY7RPf6T3nMU5Mm3MpZBgm
	N+VIxgAGgaiZRcUg2AgATDDuxhswyTCE5BjQQVo6s8TrZ/iJxmMvtN+9uwfH7pDlbBg==
X-Received: by 2002:ae9:f70e:: with SMTP id s14mr4340724qkg.81.1556054484980;
        Tue, 23 Apr 2019 14:21:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOaunyCOo34HGzuutwCFuEz8x4PhQZVTrTEGmNjfVo+p+ju/OyFtmXynxUl3pu9DnsB37b
X-Received: by 2002:ae9:f70e:: with SMTP id s14mr4340668qkg.81.1556054484322;
        Tue, 23 Apr 2019 14:21:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556054484; cv=none;
        d=google.com; s=arc-20160816;
        b=MByD7qNHo2FiH6gA4tNaGwAFBO/JGAc8M6pp4PnPa8O8tAmfx0yU8KCYRpUwpT6C9I
         8+CbWlDDEWXDd412Qqi0QwBDI4OUNOlU4xwyw+tk4dYwJtDCrHlsSJxtJzjDszY2YqXk
         B/VnBxMrQ8So/1Pc/qJHvohgbaJs913fqvinONlKraVIFqWkngKU8P2IuP5CSTzZzOg5
         48k8ljpFWW8FD5BlkWym2440VfYXe2H5qPff4UKz7NG9C9ZGW5MFSHrmW4RCk7Q7DtGo
         xOh0k3q9hvuy443WaHcqT0bXlYYVSvfnLGmckOTd63zwE8mlH8rw4+UJtn+YbGhz0W1w
         IfkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Kd6ItcCsoMCfNADJOM1r5WTWkxzSnmXVdltfLMmYUyg=;
        b=aAw+E8z3Pf4wDjMLydb6fZ2XHClmtHo8ZRUey0AVxAE7MW7yuwzqquowwv0JFH1ipb
         PJL7E+aIPhEMIyJYuJoAwzERMLe+n1sjqsNOMjZFl7oMnmJfEphN/Ejk/EXieQiKgq6E
         GueYe/PlNmlA4jkgxDlZU66Cc+7pw0L40AKbMOimRSYw1ebOqcyedyk9mbxv9uGh9p0M
         W8MFzw3W6auG8ayxJYAaCgig3lzpIb6vuFVGva1wuafOK8+kZfBA1KjNqTRE+k6FoCHY
         Ay6IdQ9K7MB1VMtUADmz7q578v0MyrV7Jr5YVwrgobMq2UuKPnssWYvf8VkgHb0gNApy
         ZDdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h10si463431qta.253.2019.04.23.14.21.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 14:21:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4B2C6319936D;
	Tue, 23 Apr 2019 21:21:23 +0000 (UTC)
Received: from [10.36.116.61] (ovpn-116-61.ams2.redhat.com [10.36.116.61])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9557E600C2;
	Tue, 23 Apr 2019 21:21:21 +0000 (UTC)
Subject: Re: [PATCH v6 06/12] mm/hotplug: Add mem-hotplug restrictions for
 remove_memory()
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Logan Gunthorpe <logang@deltatee.com>,
 linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552636696.2015392.12612320706815016081.stgit@dwillia2-desk3.amr.corp.intel.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <3dda9d08-a572-65b9-2f2f-da978a008deb@redhat.com>
Date: Tue, 23 Apr 2019 23:21:20 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <155552636696.2015392.12612320706815016081.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 23 Apr 2019 21:21:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17.04.19 20:39, Dan Williams wrote:
> Teach the arch_remove_memory() path to consult the same 'struct
> mhp_restrictions' context as was specified at arch_add_memory() time.
> 
> No functional change, this is a preparation step for teaching
> __remove_pages() about how and when to allow sub-section hot-remove, and
> a cleanup for an unnecessary "is_dev_zone()" special case.

I am not yet sure if this is the right thing to do. When adding memory,
we obviously have to specify the "how". When removing memory, we usually
should be able to look such stuff up.


>  void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> -		    unsigned long nr_pages, struct vmem_altmap *altmap)
> +		unsigned long nr_pages, struct mhp_restrictions *restrictions)
>  {
>  	unsigned long i;
> -	unsigned long map_offset = 0;
>  	int sections_to_remove;
> +	unsigned long map_offset = 0;
> +	struct vmem_altmap *altmap = restrictions->altmap;
>  
> -	/* In the ZONE_DEVICE case device driver owns the memory region */
> -	if (is_dev_zone(zone)) {
> -		if (altmap)
> -			map_offset = vmem_altmap_offset(altmap);
> -	}
> +	if (altmap)
> +		map_offset = vmem_altmap_offset(altmap);
>  

Why weren't we able to use this exact same hunk before? (after my
resource deletion cleanup of course)

IOW, do we really need struct mhp_restrictions here?

After I factor out memory device handling into the caller of
arch_remove_memory(), also the next patch ("mm/sparsemem: Prepare for
sub-section ranges") should no longer need it. Or am I missing something?

-- 

Thanks,

David / dhildenb


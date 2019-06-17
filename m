Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 321C3C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:43:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00BD32084A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:43:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00BD32084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 910FB8E0005; Mon, 17 Jun 2019 11:43:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C1C88E0001; Mon, 17 Jun 2019 11:43:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D8048E0005; Mon, 17 Jun 2019 11:43:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 44CC08E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:43:30 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so16997654ede.0
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:43:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Gou/n6LTZNYDYqO8t/e3YDcbKrxrhcuGeGFVz4mdg2Q=;
        b=FfH8WjVLs38DmhmVrBl2toCDEwpfXZSQRuP+lSLvHwucLpQuT2MVU5vCStGsHxwusH
         ABGqQ9ae8d1nKseCOPUqQrGeajTs69K7Lv6T5KMLxqM8UdUWbEVqf8bfjEdgHWGg5KqJ
         AD1deugp423Bt86EZW8yPU3tVytfSiCoBuFQqzir1vWpKTcFfLyqthwqGaJEvm+6NUCS
         FdeTGxWWxxIU+8tp1NvA7GpFbS/9AGtE5giFYolRtu/TyzGxqRxhy3M8TU3ASuhBdwa+
         PvXs8wzxztQCIwhIx+zMpi5AkDQMHCLtvN3/y1QEZH+wPgWTcsMiirlhJtiUj+vRLAda
         tN0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXpOOshnsPbVsKIjxI/Yb+d3BzupMUFAEBoX+VOA31gzbjwv6p/
	Buz+chpy4k7M5dnz/4CONqroe9fi7jM3iEzC8egbNLzigaBZyar3JGZq2fIlsTNkZj1I9raJj7K
	5KweLJQIksUNVMQTt/XDbEktaYaDaCeOLUkDC81FqCFW4n1ZeaBCqBq6z5RbQApXknQ==
X-Received: by 2002:a50:b1e7:: with SMTP id n36mr71154561edd.227.1560786209767;
        Mon, 17 Jun 2019 08:43:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz64TYpvTjNN/Sufh9cDltdR2Wt4gAUZ7mgDPAEgOy8XvJNSc0J8UueFf6pL6PQW08W3kEh
X-Received: by 2002:a50:b1e7:: with SMTP id n36mr71154513edd.227.1560786209109;
        Mon, 17 Jun 2019 08:43:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560786209; cv=none;
        d=google.com; s=arc-20160816;
        b=YhC4N7vIh+p1nlDbFJ/GNH6I4FCg37g82MOBDZ07ZSQyQd/EPZxXx9zy2ktmBNvm+6
         2avo+vqzAHriguVNTR/yOYVl5zw7n9VspvBm55ZhoD5EoAa3BOMhkV8wAXcYmuNUkYJQ
         gil4Dkk4y2rzH7Ul008Iap6IcEjG/kN58UQVUk8fFX5vajAD/yY8TYCYXJKqQP0ire9p
         dMLnsOvToymYbI2nq73BZQeitPYJrDGle6eDkfzbHT9XRUCU1MqfjewTD9hXuALgMwxi
         OyhvwP8z8uZHB3/pNDSwmOqm28ztP9bdUBMTXtG1eX2GDbR0v1Mb9wkTnRGObpSYyDAd
         yczQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Gou/n6LTZNYDYqO8t/e3YDcbKrxrhcuGeGFVz4mdg2Q=;
        b=sTUtu0APjgCFo5to7SuLh+A4CyTe4wjVx8WoZtd9wqJhUwY/fdFTtbfh32yktBKW3b
         4qjZEtrET/iJ/4ejkwIUS3Nnoxj+QTpu64ogdRG+yf8VvfhW7bGPPl7yqbLYlyuvPCuC
         gAeftAvekuN4g9jUCssIEj1iQheATAw0rmgMhlEUw9Mh4u0K9MkVi9x192aDE4wIUb0Q
         oM03vbN8Ve2KyotK6C1UQgRq+ANos6fwjBZIeuHPqv24fz17GR2NEMDOnEbwLHAP7AZE
         wLmOmnqDLJv3ksCkg8JjZ4BmpEUevZLaOarqtOPEFTePdzUWmpRkfMax36K5ADKAOoBC
         BKMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k27si8973998edb.284.2019.06.17.08.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 08:43:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 735A9AC4E;
	Mon, 17 Jun 2019 15:43:28 +0000 (UTC)
Date: Mon, 17 Jun 2019 17:43:25 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Wei Yang <richardw.yang@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org,
	pasha.tatashin@oracle.com
Subject: Re: [PATCH] mm/sparse: set section nid for hot-add memory
Message-ID: <20190617154314.GA2407@linux>
References: <20190616023554.19316-1-richardw.yang@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190616023554.19316-1-richardw.yang@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 16, 2019 at 10:35:54AM +0800, Wei Yang wrote:
> section_to_node_table[] is used to record section's node id, which is
> used in page_to_nid(). While for hot-add memory, this is missed.
> 
> BTW, current online_pages works because it leverages nid in memory_block.
> But the granularity of node id should be mem_section wide.
> 
> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>

While the patch is valid, I think that the changelog could be improved a bit.
For example, I would point out the possible problems we can face if it is not set
properly (e.g: page_to_nid() operations failing to give the right node) and when
section_to_node_table[] is used (NODE_NOT_IN_PAGE_FLAGS scenario).

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  mm/sparse.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index fd13166949b5..3ba8f843cb7a 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -735,6 +735,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  	 */
>  	page_init_poison(memmap, sizeof(struct page) * PAGES_PER_SECTION);
>  
> +	set_section_nid(section_nr, nid);
>  	section_mark_present(ms);
>  	sparse_init_one_section(ms, section_nr, memmap, usemap);
>  
> -- 
> 2.19.1
> 

-- 
Oscar Salvador
SUSE L3


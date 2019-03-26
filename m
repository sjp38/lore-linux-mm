Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 225D7C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:23:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDE2A2084B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:23:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDE2A2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 634106B0006; Tue, 26 Mar 2019 05:23:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E2096B0007; Tue, 26 Mar 2019 05:23:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D3716B0008; Tue, 26 Mar 2019 05:23:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0235D6B0006
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:23:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n24so4954861edd.21
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:23:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=C7MjwKqQAagBZDbh0m1tsLlMKHeylm2uEeYYB5lLtAY=;
        b=LDw/G7Bz7Vg3WVXdXfsKGZba+/th2AqAYexpJCzuepK5TGOWPtCPPoBawKvjS2xcob
         HxsupQT/NbWKlo1l7Sj+dyGMt0TNvpqYFGPCdnGX0glZ6heEjDhD1sErS7ASZYAHICGk
         GmJto71cOONExtmEX8RTSIh5e4CMgkgfCxBiUREpFsIYufwkRdxHCw9kdoPAfn8PAem0
         xTfOAsRoqrm14E4j+gtupaQF+ZqS+4w7zr8gsvzJV2A+vZh67DrIG1jL7gkc49cRww1V
         peUEwfvoMiPFLrBT9CHcVE6IP/WG2wFzcEq47tHdtTogu+usxUfUuz0xOBfKrvzKWqb8
         tnBA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWCMLevtaPpaU/oGEebCsqho39e00vKp6vr6Kzglsai3kJymSnf
	npJmtLB+NLstlNLPLPPBauF0WphicnJ3nkXIs12zyY8B6Y+S0VCljbYsX9COgyC3PfKn8pAKtvy
	7IHtsIxiZbbLyqD7bXUG6NCyFtgCB1HDT4xrytUXOmDUAMWTbG/d5QGOc1wWodh4=
X-Received: by 2002:a50:94aa:: with SMTP id s39mr20224011eda.191.1553592206574;
        Tue, 26 Mar 2019 02:23:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4DQAZhmU14k1z8swBjix16HkbAcS0RlJvKiMdoZDNr0AvLWx9oH8CqoB3S4i8IbabrZuz
X-Received: by 2002:a50:94aa:: with SMTP id s39mr20223974eda.191.1553592205924;
        Tue, 26 Mar 2019 02:23:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553592205; cv=none;
        d=google.com; s=arc-20160816;
        b=wNcrZPM4A4HANOLSoo++Nb4JZoTf9qk7fb+jXf871z2/Esk6cHw+5lkF2321o4gCbG
         UhuNUysShYVGoE4FiuA60wNmV5guHISk5Nb62GrUSkxgej1TPQvwAS8IhESi5rl6VilQ
         qIXEvcOkXtPJzMWWsBFJOFUlHSwr0b75vZBAc7GIyca9v+KX0KlgGkFF2ihVXh0mw2mp
         ldp1/DiXi5+fmTvj3u+J2yjUpJNdy6CD+n5MM51Px6u3i51y/v92gPxlN8pxBKoQ/R8z
         8cUy2vabGwCe3zjuAoA2xoP1cX5NwV5s2itUF3cBx3rx82WSAuNSwRZlXvWUcUgvbWAS
         CMVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=C7MjwKqQAagBZDbh0m1tsLlMKHeylm2uEeYYB5lLtAY=;
        b=Y7m3/UyKXoY3qpZYcAetp63RW5I3oL4fPRwZC2lfLULy5Xv7oucGMlcgaBRHxZa6VC
         4xP9mb86UiTA7aOH8F9uBRc8RqoaKOWNc7hIegxemJ3Bnkw/L1M1TjSkntbKT7HYuW+U
         JqQ60K7bmqbrdJnjsDuTMY1TPJjJIAEyVXqkN84q9YjbKNSWO3deYqHTO7WS5QRu72bw
         DDtgozY2jL6vAg4aZtRMJVm4ISzabMiONdNv7eYmc2w4dJ3yHBBo4JXz51bQ+rWNySzU
         g0L/8sppcnipc6XDUpJZdZLh676/MhEDsTYqC+LxH9Ue694MdlfPMTqtZcyZ6PaZZhOR
         6A1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q1si5674142ejs.275.2019.03.26.02.23.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:23:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 294C4ACEB;
	Tue, 26 Mar 2019 09:23:25 +0000 (UTC)
Date: Tue, 26 Mar 2019 10:23:24 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, rppt@linux.ibm.com, osalvador@suse.de,
	willy@infradead.org, william.kucharski@oracle.com
Subject: Re: [PATCH v2 1/4] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190326092324.GJ28406@dhcp22.suse.cz>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-2-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326090227.3059-2-bhe@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 17:02:24, Baoquan He wrote:
> The code comment above sparse_add_one_section() is obsolete and
> incorrect, clean it up and write new one.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>

Please note that you need /** to start a kernel doc. Other than that.

Acked-by: Michal Hocko <mhocko@suse.com>
> ---
> v1-v2:
>   Add comments to explain what the returned value means for
>   each error code.
> 
>  mm/sparse.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 69904aa6165b..b2111f996aa6 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -685,9 +685,18 @@ static void free_map_bootmem(struct page *memmap)
>  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
>  
>  /*
> - * returns the number of sections whose mem_maps were properly
> - * set.  If this is <=0, then that means that the passed-in
> - * map was not consumed and must be freed.
> + * sparse_add_one_section - add a memory section
> + * @nid: The node to add section on
> + * @start_pfn: start pfn of the memory range
> + * @altmap: device page map
> + *
> + * This is only intended for hotplug.
> + *
> + * Returns:
> + *   0 on success.
> + *   Other error code on failure:
> + *     - -EEXIST - section has been present.
> + *     - -ENOMEM - out of memory.
>   */
>  int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  				     struct vmem_altmap *altmap)
> -- 
> 2.17.2
> 

-- 
Michal Hocko
SUSE Labs


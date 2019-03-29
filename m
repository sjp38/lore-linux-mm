Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E51A3C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 10:36:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA6EE20811
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 10:36:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA6EE20811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58D2A6B000E; Fri, 29 Mar 2019 06:36:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53C366B0269; Fri, 29 Mar 2019 06:36:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42C476B026A; Fri, 29 Mar 2019 06:36:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E62B96B000E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 06:36:45 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c41so868525edb.7
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 03:36:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=06Bw7sljTt98RMDQihAitFTmxwheg4ckH//AVEmvhtA=;
        b=shf+DR4glSYFm02iKDldIaVwN+FqpaZWLiaF0qnxh2dtrW/v98pY3ybeb5Fi4BKeqn
         qmBWEc9fBCmrgLMTsi6qn4582ddb8jpG1N9/aMVBqCCWwdyH9hA89w27G3ZJc0QiL5eC
         kYbgeCbVFCK1jw3IblI72Jd1HclTU/I4S2eyFez0fZ1Q536/KZUH1PlyZPR6qFNErZAn
         Bl2vMN/k685pjUF/Sd7zdWONIAhCczUkK4wp7xYe3/IoEDxxTJ1ZfJzDuE48NXohL46P
         CEt00mp0G1YvbKKrSz4jGc0LPRz9C/ofNXpX+ldnGN9KgJ1rKKKDlhiXgYCnJMzTnxd3
         o/XA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWpTLBcmmJ4hFMsCKK8uI2Wm7Omm27R5cwhKeSKGp8lpOEqUbVo
	VbGIJuyC+9RHqaIvfeLHtw5BnA0MN3jpssMX25rBu7a0bwTnVx00sS4pfexkwRCrB1nkNozRi84
	etRzgPNQhASIhjpRSEsFwPwDqhqEYXF3x+h9cwJLCH+zhUHicty219/ohUHr8Xqd02Q==
X-Received: by 2002:a50:ad8e:: with SMTP id a14mr32598756edd.221.1553855805450;
        Fri, 29 Mar 2019 03:36:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMd2eOiZpYvLeMYfZDHOZBKLTpvHcIAMdpPafUAR1WJDNlpnFw2miuLeTTrbbBmU+4Xklu
X-Received: by 2002:a50:ad8e:: with SMTP id a14mr32598721edd.221.1553855804815;
        Fri, 29 Mar 2019 03:36:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553855804; cv=none;
        d=google.com; s=arc-20160816;
        b=owo619YsagM3qsWh+O5PBomkErri7eSCVtbOxZ/z4NVYehaaQLttKASrmJeBXUIveE
         eMb3UBcy/x+OYVrhjQ3iRyYtIEQue6E2efKBbwBbakwnL7cBv8j1cIfz9Fr7e9PTWh9Y
         sHIUFM4gbJH0Bl2HbLmm5LwsLwB2iQ/vf/W0r0f1bbF7that45rehY5rHZ6YjK2kJKa7
         NSKNksxL9CVIPXqjiJd5JdBUVz7koZXO4x2voTxARI/etV8w/EthcEV1UrIIT5kVyA4E
         JP8TrB36PuA/OvzXwqYvkJNyo020ahEaYVRI82OZejcTFK94S5fe7ZRoUBMWKKhSjh/Z
         K8ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=06Bw7sljTt98RMDQihAitFTmxwheg4ckH//AVEmvhtA=;
        b=hGyIOB1ePc55wg361OWJ+moVrWIRCv5cYmeKM/6OJNX47tTtYvlIovZ6W136G0J6+l
         k/nmPSqcJ/Q6Xcw6nLbEGP9mkRrki2WoMrbtoxNWEi8tmqH3UtzubPjvK2KGsJOGZEGp
         9UE819aQ5O8+K3q8qG4LF3p1vzpc9B6w++cDnsW36F/6zKs0JkdPn1Zmbew3q/4BBPsX
         PTiinMki9mSpm89wL7k/BJP4xz/w5m7td2osaiihkD2bNzaKuocnupg218k9WwUxiXMO
         yQyz7KJpCFE62pMb0u3gU06ciMNGt47qRVCby8JTgOtEmOQOvC/uS47AyUQCnValT4OC
         66UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id 4si835116edu.178.2019.03.29.03.36.44
        for <linux-mm@kvack.org>;
        Fri, 29 Mar 2019 03:36:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 781B44748; Fri, 29 Mar 2019 11:36:44 +0100 (CET)
Date: Fri, 29 Mar 2019 11:36:44 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rafael@kernel.org,
	akpm@linux-foundation.org, mhocko@suse.com, rppt@linux.ibm.com,
	willy@infradead.org, fanc.fnst@cn.fujitsu.com
Subject: Re: [PATCH v3 1/2] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190329103644.ljswr5usslrx7twr@d104.suse.de>
References: <20190329082915.19763-1-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329082915.19763-1-bhe@redhat.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 04:29:14PM +0800, Baoquan He wrote:
> The code comment above sparse_add_one_section() is obsolete and
> incorrect, clean it up and write new one.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
> v2->v3:
>   Normalize the code comment to use '/**' at 1st line of doc
>   above function.
> v1-v2:
>   Add comments to explain what the returned value means for
>   each error code.
>  mm/sparse.c | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 69904aa6165b..363f9d31b511 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -684,10 +684,19 @@ static void free_map_bootmem(struct page *memmap)
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
>  
> -/*
> - * returns the number of sections whose mem_maps were properly
> - * set.  If this is <=0, then that means that the passed-in
> - * map was not consumed and must be freed.
> +/**
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

I am not really into kernel-doc format, but I thought it was something like:

<--
Return:
  0: success
  -EEXIST: Section is already present
  -ENOMEM: Out of memory
-->

But as I said, I might very well be wrong.

-- 
Oscar Salvador
SUSE L3


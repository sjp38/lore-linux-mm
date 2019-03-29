Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AE67C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 10:32:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C52A021773
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 10:32:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C52A021773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 569776B000E; Fri, 29 Mar 2019 06:32:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51ACD6B0269; Fri, 29 Mar 2019 06:32:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 407B06B026A; Fri, 29 Mar 2019 06:32:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E93E86B000E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 06:32:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y17so850828edd.20
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 03:32:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aMZyUbLChIj4Ql0w5OtARwkvmrkquMq4/rsNvqg8a38=;
        b=cIs5dOQxFch3w9P5bquxMf83DnXBStgk8ZIIT1D+9ikzAB+U1uaySmnxUsywOLMZAW
         nTljkGhMJet9dpn+YIyja8mdwSG819SIIerqot+feK3WODh4ilCBQwScGzk66untLl3f
         4N4+O0Nrdzhn6W9TYpX2Obg9lSN/FNvDTzhmI43qWi/X3CDig3dJeJfen7od6v62lGTG
         7Gqfw1q5dMQXrf6p6mV1TvbYWGbl60fD1nJumTGVKB+kUEMYXUS0lwU1SwSdP3dP9iJ9
         e1d1QdkW6NJr52IoyzGYFlU/xNRGSB2RRGDkf3AZAaYnbG1MIXOTI/7gisCBOPaIIl6V
         3UVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAW7xgrld2R1tAMcDDkl8TA8IzYv3ZGpjLnsPZS6RBRFt7HtqjNg
	ySx6+31vhOdtyyPDoVOQoRGRQnp1k5jSHAtyBU0Z6P+TMuCa9pu/vUYyvKcBPPmvHwizFGxenLO
	Oaa9M7vxcsFDErPXShSwLtc0W6PH57bqBOVGa6w2eLCGGg9G7uu4Mov8mkZVoQm1z8w==
X-Received: by 2002:a50:9e8d:: with SMTP id a13mr30695116edf.55.1553855523523;
        Fri, 29 Mar 2019 03:32:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYR0CVVOhB3D/lk7XWERH8YHHyERu6KE8HTxqS/0CXsyPRJOTG/KlAuT/8zssGPJHsyb7e
X-Received: by 2002:a50:9e8d:: with SMTP id a13mr30695075edf.55.1553855522787;
        Fri, 29 Mar 2019 03:32:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553855522; cv=none;
        d=google.com; s=arc-20160816;
        b=RygKUJYqMrWtiK6dKlDHofOFbhQUI0BjQVm6wtYAjhaReVH0gAXShcaf/3nB44PQZa
         /MBheiADP9Ag6TdhmNJ06mfWyrmIKxX7SfOm8+zKpMXkhIYZmiR450RPAAzpcrjqC5+4
         BP3NwIN2AjewATb6sda3I6Wsy+g2+/jWZR9+Rm53I0gOHGZc6p548S8VHs0JIbflG8ih
         ZW/UmZ9oyBP+lk1JEo1eWrTmskWFKEq7lQRXga9IwgcWh7WP7PwHXgbitI7SPPVg03CI
         k93TZkBajA9MThNq2hzsCD+BlLkvH2Cpxu9KQj3IOfIblq6cjcE6iISNw2HBAno8uIed
         GTdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aMZyUbLChIj4Ql0w5OtARwkvmrkquMq4/rsNvqg8a38=;
        b=Hg3dodYz0nAbydC3OSugc861JouOkOILaJpxe1UkHSBDxd6fn8tY4qNAC8nlfGTLZz
         HvlGIjgvENBgPVAOnVqjKiKhgCL6D88nMy6vEX+H8WvULG9sesuO2d2McC4RacM6+JMu
         zjbzyi7Ss1XHwgzZ5GiGvX6WHyTZmW7EfLBc5lj9wyuw4tXFvL8H2siOYFd55KkzbGVi
         8XhlUq7vrf1hmbi0Zb0/2n7T7c86Kj+KutEmqvLAp3gvaz5GRrAmuYe6mSnJLWhHvGp2
         orSQrrfgIm/JP8PN1nE/u3J/MycolaNs2kFSLNU/xnRDr5vYRyvuDSHEm4X5TV324z4L
         9SFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id a20si788500edd.353.2019.03.29.03.32.02
        for <linux-mm@kvack.org>;
        Fri, 29 Mar 2019 03:32:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id C04684746; Fri, 29 Mar 2019 11:32:01 +0100 (CET)
Date: Fri, 29 Mar 2019 11:32:01 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rafael@kernel.org,
	akpm@linux-foundation.org, mhocko@suse.com, rppt@linux.ibm.com,
	willy@infradead.org, fanc.fnst@cn.fujitsu.com
Subject: Re: [PATCH v4 2/2] drivers/base/memory.c: Rename the misleading
 parameter
Message-ID: <20190329103201.v4r74pdej4y7mecr@d104.suse.de>
References: <20190329082915.19763-1-bhe@redhat.com>
 <20190329082915.19763-2-bhe@redhat.com>
 <20190329093659.GG7627@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329093659.GG7627@MiWiFi-R3L-srv>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 05:36:59PM +0800, Baoquan He wrote:
> The input parameter 'phys_index' of memory_block_action() is actually
> the section number, but not the phys_index of memory_block. This is
> a relict from the past when one memory block could only contain one
> section.
> 
> Rename it to start_section_nr.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>


> ---
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
Oscar Salvador
SUSE L3


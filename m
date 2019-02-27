Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18014C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:21:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5FBC2183F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:21:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5FBC2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CB348E0008; Wed, 27 Feb 2019 12:21:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 554868E0001; Wed, 27 Feb 2019 12:21:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41E878E0008; Wed, 27 Feb 2019 12:21:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F40EB8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:21:19 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f2so7118393edm.18
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:21:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1CWnOG19A4B5Bu4LlrPoldpdkCG2dFxTAn6xHi0gJEU=;
        b=hnqmf5dciMwh43XpXkk8iEI92IW9INXRud4mKl0WFL0NpgifOpA4pQTNBOMyYuucYX
         nbfov3I+9xWf8DGC8WLhCaCV/xX6fh6enDvBB5MPVQNoIKHG4BAJ8lkPpEE5fb1j6wIt
         Za3zj2f6Cc8FTiKZ38YMZ4j5tA8Kxnsl5iJWpVaHeppcUBcdwp6XK+ZE7eK4xtYWYVmx
         xkG9Mpl/iKyPm49iwOvnrwbUjxlpyxLoqNwwa/zysWCvYujnTKZtJHsawDVV17KGWW89
         OcngNUURjH9EQyFVKK/Q4UMeCnw5q1qeA4K4ehbNasc6DBb9aN0FQKbfkpwkN9xz4S5Q
         4cEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAubrRm0teRNBDuaf30S8XzZ+SeqPO1iIkTbzbOzDNDK4Hr9oVtCH
	4AZUDN5HJNmwQlT/XcsOkJREqW6DTa5L9XrQaZXoa/TDjNIXHPqzxCp/zX2XogkrJRLGoeP9rUZ
	Y0PmR2cG0cQx5dk9rTqb0Rrm6CRm+h8eeS36joHHQ4vnhqJYbwgr2tCj4g+s338A0XA==
X-Received: by 2002:a50:c352:: with SMTP id q18mr3225109edb.175.1551288079591;
        Wed, 27 Feb 2019 09:21:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib+awDZmhuUNYMRTaa3yGSiHFw3faOit5IA5xsBYspDnQnLTdqy8sxJD4YJZdnYH0zV+gsR
X-Received: by 2002:a50:c352:: with SMTP id q18mr3225037edb.175.1551288078502;
        Wed, 27 Feb 2019 09:21:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551288078; cv=none;
        d=google.com; s=arc-20160816;
        b=D6SH6vqWCs5mOOtwZ+KOlfjz1rQ6dMJmwWGO3+UIZcsaAof4uZ/GCuczUk2zrY/N7U
         Ct5BeiypiQjuF39a4RZ16QDTH+sFluCyShm3ojPY2Dj8wD7NRTWTdWDSMgm5N3gLKqOX
         OorABmB4nbPb+TUrhhmufMDZNKnA8rXgXdV3zgjZrleQkuy5r7raXVDON5U4g5aZXCWl
         Cb6gAaUUBiTA96lAumFO8d/GikZoXiVhg5sgQwYpGH2Z/71WCZe8ziO6CXCoL4CE1ZPu
         XfaxYl8LngMiOJ2RheLq9ebZbqX/oVGuxRvv+fgmolQOZ+V4idZ3MoHjh7dbgj4TvDTX
         KKlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1CWnOG19A4B5Bu4LlrPoldpdkCG2dFxTAn6xHi0gJEU=;
        b=sDsovv+oF/sY79s1mpPlw/ycP1ukOE4Ynhz1GWWO6rdHo2v+knX1ME07ggtL2wf6tp
         bdbGRAO5h7n1BV6osliuihc2HO4UlAD+oxr8NYSx1GGrNEfrYd4km2GUcIWri5dObZGA
         9lP2PLWc6WcSdaaScy0pK1e7RIMdNY2+NqzYaOcAJz7MSgc3YnraAJ0sOUa4drnC9x75
         3xjgmduOFY/ekjCXSMAkm//9MNdJgZkhmNKJy2bW2L1iFGG6dAZbdPMrAVruuH+C4s4+
         30lCdV0Glz55dAEywl3SCKPOa4FEHcWqesBBx5TCWjn0OkTvLZYoPKsnVRQWAdrVZIKu
         Tfvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y2si180967ejw.302.2019.02.27.09.21.18
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:21:18 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5A1D31688;
	Wed, 27 Feb 2019 09:21:17 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4B0543F703;
	Wed, 27 Feb 2019 09:21:16 -0800 (PST)
Date: Wed, 27 Feb 2019 17:21:13 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/page_ext: fix an imbalance with kmemleak
Message-ID: <20190227172113.GE125513@arrakis.emea.arm.com>
References: <20190227171556.75444-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190227171556.75444-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 12:15:56PM -0500, Qian Cai wrote:
> After offlined a memory block, kmemleak scan will trigger a crash, as it
> encounters a page ext address that has already been freed during memory
> offlining. At the beginning in alloc_page_ext(), it calls
> kmemleak_alloc(), but it does not call kmemleak_free() in
> __free_page_ext().
[...]
> diff --git a/mm/page_ext.c b/mm/page_ext.c
> index 8c78b8d45117..b68f2a58ea3b 100644
> --- a/mm/page_ext.c
> +++ b/mm/page_ext.c
> @@ -288,6 +288,7 @@ static void __free_page_ext(unsigned long pfn)
>  	base = get_entry(ms->page_ext, pfn);
>  	free_page_ext(base);
>  	ms->page_ext = NULL;
> +	kmemleak_free(base);
>  }

The kmemleak_free() call should be placed before free_page_ext() to
avoid a small window where the address has been freed but kmemleak not
informed.

-- 
Catalin


Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D4DBC28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 10:42:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BEE12578C
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 10:42:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BEE12578C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D903A6B026C; Thu, 30 May 2019 06:42:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D40716B026D; Thu, 30 May 2019 06:42:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C06FC6B026E; Thu, 30 May 2019 06:42:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD596B026C
	for <linux-mm@kvack.org>; Thu, 30 May 2019 06:42:11 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t58so7991007edb.22
        for <linux-mm@kvack.org>; Thu, 30 May 2019 03:42:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LjeoK8/bEmVDjgpoMcP13fTESGZzaPayAiMsHdJl7us=;
        b=Xib2Q1iFspC5A2mqoJMPwZanMXTqOcif4EekxYiCB+iSDLj7DjZUkVl0b8b0Cqbpud
         8Utq4MNtviPpZiSYeHlf33Pp0aLIM7M8XnQugoNwK63u4CruCq7cxYcehwDcEI4HEFPm
         mOvPfD9KjvVwAosuqnAXCHDjQ1SHnq/PoIh8Ns/K49WSLJVcMkGmoDIAm+81EkC/HkgC
         MNdtinOR5FiOqpLwuTu/n4eAoEAtr8zs+1p0H3GziPS0U7USuttkEP2VIzcdhPjKjHmj
         EQMV6RedxTSLbnFdY2euuXTImG48hunwshiRdlJM6B/9UPlwFzJq5Lx0tLG1lzMfTEvl
         Ck8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAX6gw8abwMXBI5gEiySAhkTnxfZmXaREbfWsNs7JeG/GelqJell
	A2esCrqe1UmSh21q/+JYEPI56yVyf/kdhO4+X6NEavxSusG7VJ81EFFISzM5J0Yw/mMnqdLpsQr
	8KBfUU+35ncKl6SBFM0sLs6N/FLGwJJnPFTcr1O/JPDK8q9w73nKAV4RKnDiexschkA==
X-Received: by 2002:a17:906:ca5b:: with SMTP id jx27mr2769326ejb.233.1559212931014;
        Thu, 30 May 2019 03:42:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxO+ybfTNFH4XnLGeWVY4NVZVDpyTDyf4ehnOlfDUox3UljoTbu9aMcxgs1XpCpdEDlCXW/
X-Received: by 2002:a17:906:ca5b:: with SMTP id jx27mr2769259ejb.233.1559212930089;
        Thu, 30 May 2019 03:42:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559212930; cv=none;
        d=google.com; s=arc-20160816;
        b=ZIDjh83nzw4PP8Tgor+K0RCnWx0fehIg9eSXRgqUr2HrDHI2NpTPEd025vysFc5Awy
         MhRuG/GCfXx3e32dD+yQ5lBohZefRmdkyILGwFhMfKmeoTXdcrtnLrgCtXdJM6/qiaBE
         A/Zv8rkXK/nlW8HUlTAT96c42NKbpb/c+1BJDUzicONsjPGywa4Z1wm8b9rCs18LkfOk
         YNjPL8JiIJoNVKA/LByG24uJaWXeThtCQ2ta+IvNJYBUhxpHD4i8bGXtt1nzYcpZjlny
         Q9VUiwxt8R9FG0wO1CMMpiqejLccVaQed9+2e/9yjTT91EMaVADn2OW95EIgS09nMDqA
         Z3Dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LjeoK8/bEmVDjgpoMcP13fTESGZzaPayAiMsHdJl7us=;
        b=WSetorMXJki2CUOcZLcc3oPDJ7K/6/fbtVJ5tYgNiVwXddgf1dMD+29kuV9mhO/Ulq
         9p8aEJpglri43f1LZangASMjCYaxCQyQblidgt+ZnUYtYmhREhlAu6GjsTwyQw1cxXaw
         Ka9N46ncVwoZFptvDcmXrW0SMDSpWj2P0wX9qqQ6BcElN1ln3M46UGRBEukbXYK5dJqN
         vCDkJrug4fikggjcutDKpv0Yu0WpcjUjUlZAHxiqtfXEZxvtgC93zdqIQMDwlTCBkVR8
         hDykAQVj3XfOEu/oJra22mUu6n1I8BMIN60rAgtUpljbROlTtO3OyHun6Pg+FV3c3DSR
         xqfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l25si1506920ejs.293.2019.05.30.03.42.09
        for <linux-mm@kvack.org>;
        Thu, 30 May 2019 03:42:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 10609374;
	Thu, 30 May 2019 03:42:09 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E85343F5AF;
	Thu, 30 May 2019 03:42:05 -0700 (PDT)
Date: Thu, 30 May 2019 11:42:03 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	catalin.marinas@arm.com, will.deacon@arm.com, mhocko@suse.com,
	ira.weiny@intel.com, david@redhat.com, cai@lca.pw,
	logang@deltatee.com, james.morse@arm.com, cpandya@codeaurora.org,
	arunks@codeaurora.org, dan.j.williams@intel.com,
	mgorman@techsingularity.net, osalvador@suse.de,
	ard.biesheuvel@arm.com
Subject: Re: [PATCH V5 2/3] arm64/mm: Hold memory hotplug lock while walking
 for kernel page table dump
Message-ID: <20190530104203.GC56046@lakrids.cambridge.arm.com>
References: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
 <1559121387-674-3-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559121387-674-3-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 02:46:26PM +0530, Anshuman Khandual wrote:
> The arm64 page table dump code can race with concurrent modification of the
> kernel page tables. When a leaf entries are modified concurrently, the dump
> code may log stale or inconsistent information for a VA range, but this is
> otherwise not harmful.
> 
> When intermediate levels of table are freed, the dump code will continue to
> use memory which has been freed and potentially reallocated for another
> purpose. In such cases, the dump code may dereference bogus addresses,
> leading to a number of potential problems.
> 
> Intermediate levels of table may by freed during memory hot-remove,
> which will be enabled by a subsequent patch. To avoid racing with
> this, take the memory hotplug lock when walking the kernel page table.
> 
> Acked-by: David Hildenbrand <david@redhat.com>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  arch/arm64/mm/ptdump_debugfs.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/arch/arm64/mm/ptdump_debugfs.c b/arch/arm64/mm/ptdump_debugfs.c
> index 064163f..80171d1 100644
> --- a/arch/arm64/mm/ptdump_debugfs.c
> +++ b/arch/arm64/mm/ptdump_debugfs.c
> @@ -7,7 +7,10 @@
>  static int ptdump_show(struct seq_file *m, void *v)
>  {
>  	struct ptdump_info *info = m->private;
> +
> +	get_online_mems();
>  	ptdump_walk_pgd(m, info);
> +	put_online_mems();

We need to explicitly include <linux/memory_hotplug.h> to get the
prototypes of {get,put}_online_mems().

With that fixed up:

Acked-by: Mark Rutland <mark.rutland@arm.com>

I understand from [1] that Michal is ok with using these here, and we're
open to reworking this if/when the hotplug locking is changed.

Mark.

[1] https://lkml.kernel.org/r/20190527072001.GB1658@dhcp22.suse.cz

>  	return 0;
>  }
>  DEFINE_SHOW_ATTRIBUTE(ptdump);
> -- 
> 2.7.4
> 


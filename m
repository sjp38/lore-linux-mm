Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48151C3A59F
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 18:33:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDB1B2173B
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 18:33:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=armlinux.org.uk header.i=@armlinux.org.uk header.b="AQ/LCNFN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDB1B2173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=armlinux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D3BA6B0005; Sat, 17 Aug 2019 14:33:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45CB86B0006; Sat, 17 Aug 2019 14:33:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FDBC6B0008; Sat, 17 Aug 2019 14:33:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0110.hostedemail.com [216.40.44.110])
	by kanga.kvack.org (Postfix) with ESMTP id 060866B0005
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 14:33:04 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A44D88248AAF
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 18:33:04 +0000 (UTC)
X-FDA: 75832766688.19.uncle09_720934a56000d
X-HE-Tag: uncle09_720934a56000d
X-Filterd-Recvd-Size: 3723
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk [78.32.30.218])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 18:33:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=armlinux.org.uk; s=pandora-2019; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=4iPPPv5NfbDLMj5Tm8yspzzGhoi5IcI9jj/IAVT+4MA=; b=AQ/LCNFNQyY7mNXi2fXmMIepZ
	8mWSHMytyWXp+G7vT/og7aO2VJeyNczHjZo6KaMJ5N7moT0aREUG1TTqzZruDg5AUYo3K5q3euZsJ
	sUAGhYOsNFYvpSrJ7EN8UuKFd6VYzUu4Y/9l+LdJnb51koETPA00qazTHbUwHBJPgCm83FcGEu/uM
	3YShy02DPOGx9g11xcRXFjC5mZ9qWKSUduns1/D86uqYDUoPctiSAYoumJ4R/t4nt6qgIfw0L8b4q
	X6VvxwauAI7ri5zYvXAccP8CXp/BA+gBzMgYZc4uB1VlT7hDZ4ajwApiec10mvI/L0KMvEW0apSoG
	pNF787Myg==;
Received: from shell.armlinux.org.uk ([2002:4e20:1eda:1:5054:ff:fe00:4ec]:53652)
	by pandora.armlinux.org.uk with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <linux@armlinux.org.uk>)
	id 1hz3VP-0001Es-Ad; Sat, 17 Aug 2019 19:32:50 +0100
Received: from linux by shell.armlinux.org.uk with local (Exim 4.92)
	(envelope-from <linux@shell.armlinux.org.uk>)
	id 1hz3VI-00035d-Dn; Sat, 17 Aug 2019 19:32:40 +0100
Date: Sat, 17 Aug 2019 19:32:40 +0100
From: Russell King - ARM Linux admin <linux@armlinux.org.uk>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Mike Rapoport <rppt@linux.ibm.com>, Rob Herring <robh@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Doug Berger <opendmb@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] arch : arm : add a criteria for pfn_valid
Message-ID: <20190817183240.GM13294@shell.armlinux.org.uk>
References: <1566010813-27219-1-git-send-email-huangzhaoyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1566010813-27219-1-git-send-email-huangzhaoyang@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 17, 2019 at 11:00:13AM +0800, Zhaoyang Huang wrote:
> From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> 
> pfn_valid can be wrong while the MSB of physical address be trimed as pfn
> larger than the max_pfn.

What scenario are you addressing here?  At a guess, you're addressing
the non-LPAE case with PFNs that correspond with >= 4GiB of memory?

> 
> Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
> ---
>  arch/arm/mm/init.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index c2daabb..9c4d938 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -177,7 +177,8 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max_low,
>  #ifdef CONFIG_HAVE_ARCH_PFN_VALID
>  int pfn_valid(unsigned long pfn)
>  {
> -	return memblock_is_map_memory(__pfn_to_phys(pfn));
> +	return (pfn > max_pfn) ?
> +		false : memblock_is_map_memory(__pfn_to_phys(pfn));
>  }
>  EXPORT_SYMBOL(pfn_valid);
>  #endif
> -- 
> 1.9.1
> 
> 

-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up


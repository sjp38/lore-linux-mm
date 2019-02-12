Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B6D3C282D7
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:21:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F08C32083E
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:20:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F08C32083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F10D8E0115; Mon, 11 Feb 2019 22:20:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A0BC8E0103; Mon, 11 Feb 2019 22:20:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 290828E0115; Mon, 11 Feb 2019 22:20:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C4DF98E0103
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:20:58 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m19so1108984edc.6
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:20:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=/Vc4P27dJlWpCcdI/Lz9flR0jTwLlsRQ/rr8NJe5TaE=;
        b=fnt26ZYTYMikJBxAIZy8tVvJ4ZvyIAV/HLz+OM3mPAXzVIjd4n76KY36+rA+Tk3WpE
         5QpS5tTXQ5igBZeSQPPXW43iGzYlLMd0wCTB/fObfIB1rTDjLLVTJExiOO+JiiRsWJ3y
         5x77SH8WHefD7BJoSGD1R8RNyGx9T9t4dNOEXTeer1MalW8UUpj3zzIOgKYdo/beez9v
         9j6JkwGO8XU6v6+PCM1vLzidXOXlp2Y+ItGF+Jle6wI3LNW6YgLHP2TkE33k5mp05b6G
         4FmJ5QfA72hYW54z/ocMlUGAUMFR1hOnRj4nkXD3UWE/Baczefu4C/q7MUBow0HJ9huR
         L/2g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAubEASgWCYUJ+Mu4uNL2T8Ymqkxe4yQpXvLPEpf1ne6c+zKJB4uh
	HSaNfqUV3zWLrT3mmZhI1quGWK4e543jUcBH2GG4kdb4gCbTO+BSzOz3o+9970drP1FSU2ZeZtI
	Lu3oqLZUxIQqJ08DeCVGDDYvOsGu/i6pDJy1vH0ZKISuBcO6Ouz7VCt1MSRGWngCVUQ==
X-Received: by 2002:a50:f5b0:: with SMTP id u45mr1139285edm.45.1549941658351;
        Mon, 11 Feb 2019 19:20:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZpgAEprbyFHIz0OCkmdKnFD1AyK1XQm6xGJ2yhan8cqyIwjQQhAaEfsuAUZfJEr4Eg4Tk0
X-Received: by 2002:a50:f5b0:: with SMTP id u45mr1139254edm.45.1549941657566;
        Mon, 11 Feb 2019 19:20:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549941657; cv=none;
        d=google.com; s=arc-20160816;
        b=DK2hmSU4A694cjuTRyJPrgzGwDblCZpJTQpGhvpWrHUk3IwQ5+npXplqC4rza/yw1l
         5/vp8ZGoeB4f3hxSHwPDCFKdvIt+jkmdA/S6yVqOpbsrrRBBv5ry/i8el99gbFIH/3cw
         M3N1+8Z8lDqKP0k6HFCDQ+5nTFBXO4qsl/R1KvI1xxTNofqhQ6PH8Cg9cuWLNVnJEKtj
         zG9rW6x/bIMhZRLJc3nDkx2xsR+EqFFgb3askm1K7UcoS8nlEWUH1SaBbwapiVF3DRHQ
         29vLu50xtBRFuk2mN/Gaeqg9F5xzklPCMFwrodoaw/DWMPi7d1/u3Go2uQLediLPHejK
         p7Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=/Vc4P27dJlWpCcdI/Lz9flR0jTwLlsRQ/rr8NJe5TaE=;
        b=nQjx9UwPWSuUKfgexXExR9IOmOKDg9pBUb6mYmL7700Gl+a5onWuq6QVqKxXQz85TI
         OwPvrHvXvEC+Rv+wAei8BM6GwdkJo6Gk+U58YngSjS63aWG1D7+vj+y2ZPJZQ9fKBtjZ
         4AGRvqe4sj4NGDIt7+gwf/ILizQ9xNqnDMXOm9Mm6tZuWLisuxlfsVs8wRTk+RL2C8uf
         jLLOQtx0zSaLD3DvsDuDsZGdhr0XL4Th5zEoV4rfTc8LsjQkFLqIWYirZgFNGk8gD2ll
         fPxxO7brVVSMVqb8KE79i0p7cteNFpp6MVCrNsGq6ctLCN8lImTkjOvq8+1NTJCeBLJl
         T/Fg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b2si536530edf.233.2019.02.11.19.20.57
        for <linux-mm@kvack.org>;
        Mon, 11 Feb 2019 19:20:57 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 63BDBEBD;
	Mon, 11 Feb 2019 19:20:56 -0800 (PST)
Received: from [10.162.43.137] (p8cg001049571a15.blr.arm.com [10.162.43.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A8DBC3F557;
	Mon, 11 Feb 2019 19:20:53 -0800 (PST)
Subject: Re: [PATCH v2] mm/memory-hotplug: Add sysfs hot-remove trigger
To: Robin Murphy <robin.murphy@arm.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org,
 rafael@kernel.org, mhocko@kernel.org, akpm@linux-foundation.org,
 osalvador@suse.de
References: <49ef5e6c12f5ede189419d4dcced5dc04957c34d.1549906631.git.robin.murphy@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <4d92d783-736b-b94c-dbfd-1560c0936fb3@arm.com>
Date: Tue, 12 Feb 2019 08:50:52 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <49ef5e6c12f5ede189419d4dcced5dc04957c34d.1549906631.git.robin.murphy@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/11/2019 11:20 PM, Robin Murphy wrote:
> ARCH_MEMORY_PROBE is a useful thing for testing and debugging hotplug,
> but being able to exercise the (arguably trickier) hot-remove path would
> be even more useful. Extend the feature to allow removal of offline
> sections to be triggered manually to aid development.
> 
> Since process dictates the new sysfs entry be documented, let's also
> document the existing probe entry to match - better 13-and-a-half years
> late than never, as they say...
> 
> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
> ---
> 
> v2: Use is_memblock_offlined() helper, write up documentation
> 
>  .../ABI/testing/sysfs-devices-memory          | 25 +++++++++++
>  drivers/base/memory.c                         | 42 ++++++++++++++++++-
>  2 files changed, 66 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/ABI/testing/sysfs-devices-memory b/Documentation/ABI/testing/sysfs-devices-memory
> index deef3b5723cf..02a4250964e0 100644
> --- a/Documentation/ABI/testing/sysfs-devices-memory
> +++ b/Documentation/ABI/testing/sysfs-devices-memory
> @@ -91,3 +91,28 @@ Description:
>  		memory section directory.  For example, the following symbolic
>  		link is created for memory section 9 on node0.
>  		/sys/devices/system/node/node0/memory9 -> ../../memory/memory9
> +
> +What:		/sys/devices/system/memory/probe
> +Date:		October 2005
> +Contact:	Linux Memory Management list <linux-mm@kvack.org>
> +Description:
> +		The file /sys/devices/system/memory/probe is write-only, and
> +		when written will simulate a physical hot-add of a memory

Small nit. It does not 'simulate' but really does add the memory block into
the memblock, buddy allocator and so on.

> +		section at the given address. For example, assuming a section
> +		of unused memory exists at physical address 0x80000000, it can
> +		be introduced to the kernel with the following command:
> +		# echo 0x80000000 > /sys/devices/system/memory/probe
> +Users:		Memory hotplug testing and development
> +
> +What:		/sys/devices/system/memory/memoryX/remove
> +Date:		February 2019
> +Contact:	Linux Memory Management list <linux-mm@kvack.org>
> +Description:
> +		The file /sys/devices/system/memory/memoryX/remove is
> +		write-only, and when written with a boolean 'true' value will
> +		simulate a physical hot-remove of that memory section. For

Same here.
> +		example, assuming a 1GB section size, the section added by the
> +		above "probe" example could be removed again with the following

There is no need to mention specific memory block sizes like 1G in documentation
for this generic interface which would work for all possible sizes.


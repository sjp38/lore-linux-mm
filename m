Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 003DAC76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 03:55:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB8DE20818
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 03:55:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VgFnL306"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB8DE20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A7AA6B0006; Tue, 16 Jul 2019 23:55:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 658B56B0008; Tue, 16 Jul 2019 23:55:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51EA58E0001; Tue, 16 Jul 2019 23:55:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C04A6B0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 23:55:02 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h5so13888739pgq.23
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 20:55:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=vyR2W0buEBQBwHqzpo3Kuz2YKIBskwD7RiIVEkP3yqY=;
        b=Sn/wD1joGUL7z7oK3EelygYZFkLFw0bkjH0u+atnuHeG/GtkvAYLNmZitpg1saXmRF
         +IQsv239dd2on6CPx+YmCy6iDhkF5zGhSzESm6g8UqlSzjdYJXxwaOFSPIMX1pSJFjv+
         llFISETUuACdOvchzMOmQl4iJqOSh1YtAw9/z11lGQNFdg9Z0fmKmM+kX5kBejUeVJ1g
         TwbpK2CTVrZIWUq5F2GpUsWIpi29hIG+dBCKtQpvDtTL0KkmX6jOSdo3IxyI23R7mgFV
         zxzqxtL1T8xKYda/qSy0B3ZhUxhwWvuKqYZWlOjNEhdpdqTZ50Zi9oWZBoRqTepDw0Ig
         Z9Sw==
X-Gm-Message-State: APjAAAWhrgCzy8AdylNOXFHjjCqO7kZcmPuCd84eaoCndAP0XBSEc8CH
	lugJw3WyCqhxg+sArZiFeQoml+dCNeYaDZwB3Jyk7CkZF/7DxJFiN/5FJ8B/OB3pcFVOjr9XLzS
	dMW2hvdPBF4ZAkt/vdBMDvWxznrUhM4cjzVzLZyI2ekH7bzZqvBYejYTNZgziE/J0Uw==
X-Received: by 2002:a63:1723:: with SMTP id x35mr37762277pgl.233.1563335701456;
        Tue, 16 Jul 2019 20:55:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycBR307hkAtbeP+AYOOx8Eq6as6idw9ZIE8FEOUZEu9AexLlq8Jm+JUIt9zl34A4kFnE7M
X-Received: by 2002:a63:1723:: with SMTP id x35mr37762196pgl.233.1563335700705;
        Tue, 16 Jul 2019 20:55:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563335700; cv=none;
        d=google.com; s=arc-20160816;
        b=CXZKvTOowOFqzcsk+twVkqSF/5YXM42P4qmQop9gtc/bD1unyKPAhV255BqWUVlFgd
         d95XPUxa30Giv+G+HMVnqb8Z90gI3THCGOx5aEk6TMkiSwI4a86FX7E1ADEjcyMzOWjE
         4OWGgEU0TMdUI701WCLjUH/cOS9Y1d96MJonh1toH8fiRs8KxLt6l/51z50xxQ3FMfzQ
         QElxkDY9PjNmPCfsSCr9aTeNGjgagUZ1Y6QDJ7c4gfhXTf07VQb3z7G6rasKstGkXp8N
         9vQSAJ820YUZPanZRItdSQekGOsY1ul2cYN8r/gxn5iL6kSjiKjSugivEZuK+JeukGfL
         zfCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=vyR2W0buEBQBwHqzpo3Kuz2YKIBskwD7RiIVEkP3yqY=;
        b=TNpNUygRfnHfHe2ipp6rZNXdqTf94XeCJERaac259yCKzHJF6tafO7/GevkzMzhxMN
         Okr5VqbXhphTSboPYjeiZ+E1rcKWZ+tNBKS8ypsjarqlPt9lh2z+QhB75WQ4pNnn1XYl
         Ei0dEuqsuIA3IHtHXS35xItOcjnzN04Ic2+9BKDzUvGsGyKW27QlH0CLaW2bXBf0SHMv
         KxK9ETo98Xor2FWDscKNoXbUL3YxXHSlsCWM4q2RCBuMElkrtiiDEBr/Q8IMqZ/1RZ61
         RZBR9K78exQGfMUPVMDEvQ4Wk+Ni3CWc0hYSIpg1hr4eD/2dqFUx76CVgGuZX4VxfIss
         OFZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VgFnL306;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p1si24136965pff.250.2019.07.16.20.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 20:55:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VgFnL306;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:
	Subject:Sender:Reply-To:Cc:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=vyR2W0buEBQBwHqzpo3Kuz2YKIBskwD7RiIVEkP3yqY=; b=VgFnL306MBZB234zHxrAop3yh
	J60H45jix4Wp/MlViHpGWFIhp5Jf83Obs/3zEV9kF3cS/eGCH677S46DrgYTo2i5lD1eW+HRToZVq
	4yioavcYl//gv15+4hlnR5t7JXIBS3B0eoiHp+hwD9D8FZV0kGRrhl5wZmQYm84xs8uLjsLIWIKwB
	ik9Qt8RW1ywSFw+L2KmAQxw2MNn112vNiDAd04ZVKIAKdEulquWRhtNQ1kcbRzTQUh4BPyA+KV4xa
	UrNj0oqYk0/juwr7JuzNzYSW2CANtWm/W4j/k+CTcwi10FAZx78aG9AOg7Y4nFJk30b0lGstv1TBA
	6GiVaCVcQ==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=[192.168.1.17])
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hnb1v-0004sI-Vk; Wed, 17 Jul 2019 03:55:00 +0000
Subject: Re: mmotm 2019-07-16-17-14 uploaded
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 sfr@canb.auug.org.au, linux-next@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org
References: <20190717001534.83sL1%akpm@linux-foundation.org>
 <8165e113-6da1-c4c0-69eb-37b2d63ceed9@infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <d2b7b174-36b2-e0f5-a98f-2b538eab6b6c@infradead.org>
Date: Tue, 16 Jul 2019 20:54:59 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <8165e113-6da1-c4c0-69eb-37b2d63ceed9@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/16/19 8:50 PM, Randy Dunlap wrote:
> On 7/16/19 5:15 PM, akpm@linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2019-07-16-17-14 has been uploaded to
>>
>>    http://www.ozlabs.org/~akpm/mmotm/
>>
>> mmotm-readme.txt says
>>
>> README for mm-of-the-moment:
>>
>> http://www.ozlabs.org/~akpm/mmotm/
>>
>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
>> more than once a week.
> 
> drivers/gpu/drm/amd/amdgpu/Kconfig contains this (from linux-next.patch):
> 
> --- a/drivers/gpu/drm/amd/amdgpu/Kconfig~linux-next
> +++ a/drivers/gpu/drm/amd/amdgpu/Kconfig
> @@ -27,7 +27,12 @@ config DRM_AMDGPU_CIK
>  config DRM_AMDGPU_USERPTR
>  	bool "Always enable userptr write support"
>  	depends on DRM_AMDGPU
> +<<<<<<< HEAD
>  	depends on HMM_MIRROR
> +=======
> +	depends on ARCH_HAS_HMM
> +	select HMM_MIRROR
> +>>>>>>> linux-next/akpm-base
>  	help
>  	  This option selects CONFIG_HMM and CONFIG_HMM_MIRROR if it
>  	  isn't already selected to enabled full userptr support.
> 
> which causes a lot of problems.
> 
> 

include/uapi/linux/magic.h:
<<<<<<< HEAD
=======
#define Z3FOLD_MAGIC		0x33
>>>>>>> linux-next/akpm-base


-- 
~Randy


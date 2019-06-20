Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 797EAC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 19:26:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31F5B2082C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 19:26:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31F5B2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 908038E0002; Thu, 20 Jun 2019 15:26:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B8928E0001; Thu, 20 Jun 2019 15:26:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CEB88E0002; Thu, 20 Jun 2019 15:26:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3435B8E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 15:26:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m23so5600334edr.7
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:26:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=t+TRyBpNFBBXyzHfTAAsNX0ZDoBsKN57d1Zf5stJV70=;
        b=cxCbSGcay07fAjvV8n/hrvGiPrDvF70e4bVquuMPuYOojIOpOXxwLFrkWO3yY5NcW3
         lnF0AAKVJoPJyJjRsOnb6ttmp+W3hdcEsDzUoblI6QLl/bnJfZnQObtLpsL50EYDXqoB
         cSPC6LP7GfCOabGkPM/Coitdb2N0rwV7BjuBNHAaoHUDkIP60IpollMarZmBxGd2UMIQ
         pOpSgze78pJLPovFvTyfRKEdbQLgDJPY6xIobqwyCqaRBKWzhTCfaO2Y6JF+a5Yp+PQX
         +oX71kUxfysB4ANzxUdbEUSTHhDA5Ri5ZdW/7WJV1ce8oo49KnBgnyZkv0cavQTBxYH7
         w9NA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUMvd6A2TEszvDJNeW4/F+rezqFkIeAejmVA/lJgKcFTXmzvTAh
	hT9EORK1W0IjvynnrM1rhI2+2QNbWrFDgmY5bGA863PCv/dnQ+qoGjVH8MimLlRH03+cagFkrbI
	c4PgNcj4Fd4AFt0Sq6jYfI2ZVZnuCgEVdrDcNqLdkSIvZDqCCKmJe3MQAaknE+1M=
X-Received: by 2002:a17:906:ece7:: with SMTP id qt7mr17309229ejb.155.1561058812652;
        Thu, 20 Jun 2019 12:26:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKd7qxNg/MwtqrteAhWOnCJIFrkOqtUpg0EeJbmSSK5g2FwPp3TksQT3A5/A3Z56gqEoY4
X-Received: by 2002:a17:906:ece7:: with SMTP id qt7mr17309173ejb.155.1561058811799;
        Thu, 20 Jun 2019 12:26:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561058811; cv=none;
        d=google.com; s=arc-20160816;
        b=y34LNyObOunfDMYlBub3Fdpt/p9nmat6O7iEdttW5tVIzoSSVtIU/+srN5Yeyc8NYL
         6jTFD5AaCsUU/0RV34WLmjmvn8Mw8YjTat28Ff6r9v/fY/ChWvH0Fh75Kiwr2VAOlgri
         bt/lmOXyCxOXGEr6PxsjhZZAgSM/wlPheTAIvzDnvlTVnvScBRI5qjzRuRU+6MvC6x1l
         X2JH6kI/i2fsq/fvt71nILzVAl6tGivyXQ5cVBqq1+4I8TI2QvpZH8MC0QiKBV9HgmjA
         qhjZrev2ZKfzrz6nFr5pBkTsacN8/bEpzeD5ReyMYPzo7hFSn/iTqveTUy3+SnGMlSuO
         zcTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=t+TRyBpNFBBXyzHfTAAsNX0ZDoBsKN57d1Zf5stJV70=;
        b=ZiSQL0zGntND8gSJIMhJ0mfXTWdoioL+HUV1/23KRESHSsz4hZpsjdPL6693xnzR/z
         Mc1DpXq9QY4RfXuK2RhPfnhBWFFpVD1zLoSUunz2+nKjeY85yTuCxHR0teQn9fwn1c0p
         hjaKhFK6pzQAYeMJ7VsQm0oNflul/pxbwBDhbeKMmKo6zl2EP4xLbtv+tVCyvOGVWjym
         l3jFfz4d4QGeDfG2yB5hCkMRwQFRxh17IbhFLUguFJCWJPonMYjLcykvqJMCyp1VGke1
         vFNvcgOhqeL+6Cp1GHl/e705yqvOLZ+Qz0uY1T3ATpEq5hLDn8kTRNQWkIfg9j/B3hKs
         mivw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y48si642824edc.355.2019.06.20.12.26.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 12:26:51 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E42C3AC9A;
	Thu, 20 Jun 2019 19:26:50 +0000 (UTC)
Date: Thu, 20 Jun 2019 21:26:48 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Message-ID: <20190620192648.GI12083@dhcp22.suse.cz>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-19-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613094326.24093-19-hch@lst.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 13-06-19 11:43:21, Christoph Hellwig wrote:
> The code hasn't been used since it was added to the tree, and doesn't
> appear to actually be usable.  Mark it as BROKEN until either a user
> comes along or we finally give up on it.

I would go even further and simply remove all the DEVICE_PUBLIC code.

> Signed-off-by: Christoph Hellwig <hch@lst.de>

Anyway
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 0d2ba7e1f43e..406fa45e9ecc 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -721,6 +721,7 @@ config DEVICE_PRIVATE
>  config DEVICE_PUBLIC
>  	bool "Addressable device memory (like GPU memory)"
>  	depends on ARCH_HAS_HMM
> +	depends on BROKEN
>  	select HMM
>  	select DEV_PAGEMAP_OPS
>  
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs


Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FD48C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 02:58:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BAF52184A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 02:58:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="WUybDOPT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BAF52184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0C1E8E0003; Thu, 31 Jan 2019 21:58:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBAA58E0001; Thu, 31 Jan 2019 21:58:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAAA48E0003; Thu, 31 Jan 2019 21:58:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 90B738E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 21:58:45 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id c84so5559886qkb.13
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 18:58:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=eKzGGb5J7xnw7YW9klEzISreEEiI8ajXRNdS4HRdGss=;
        b=Md8hjrr0VDaYeUMo3UCt7vuN4X1eumSv7zYPT+NbPgkQzOrw6yWVO67niCT9PcT8AC
         ZCRgKbL1EnUBZFHCUW+nFYg3/XJDdIewL6X2KyK4qAH4n4CTIsfG8q6/DGdEoSXmFwFk
         u6M8poQSOusE4ew8dSCeJAGWBC103Yyjs4o7z+/62EDq6sdGmrafsd5o8/72N4H85Zqi
         Kc55aZd3yFpuTlVOBMZQrOiEDt9jUqClmSnMEAVBM5DVmrYlGBvhnZDdo9bIQXG/FcR/
         MHTZIOSOZygtrCJEPbg9cXgP3mjMe2n8x33TahNGBC3brjRwcQMuhgnlV6L/TU28/CpF
         qtRw==
X-Gm-Message-State: AJcUukcTE70AfpNSYou8CnYUyZo2zMwQL8HZAbqJtcrK8SSeHQaZawER
	GxE4yLZOUMoK1pwx+c3YIbnhsNjgwpxyUTx190W/wU4O2/C6Flm2j8K/1GIJTMiEy+4uPmt2/+K
	gusPTy5PaFgwBA+uV8jLFZhayYBBZM6OB633Bt3bspGzd9Yfuhojt2GRFpdOd1rvNrzogcNmI/Y
	oUf/IIeYaqDX+aalPPqGn2gyY6ZTtt3KnstuHSGd8rxRufN29j9jCjKhn7WvDNVDmcu2+xKR5Ps
	eIE+q9H8zM7Vpxj0rXMtCGYwRcQwg6uAtJHu2pdqhBcF08rMgW4Bdb2O3R1fuD8U8oapbdHyGGy
	BcWzl0zyEk388VnmBt/fXYF+GLfNNdMjW0vx0WGXE1kv58skuZSIpNEFwU8/1DeibpqCmohWzgo
	6
X-Received: by 2002:ac8:760f:: with SMTP id t15mr35703174qtq.188.1548989925381;
        Thu, 31 Jan 2019 18:58:45 -0800 (PST)
X-Received: by 2002:ac8:760f:: with SMTP id t15mr35703160qtq.188.1548989924972;
        Thu, 31 Jan 2019 18:58:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548989924; cv=none;
        d=google.com; s=arc-20160816;
        b=IoNrpDOaTPCW0juCUUl4Zul59gWPXCmzGhALYYjT+HVNMxG+Sn+ArmIuzUTzhX7nNk
         gIYj+biQTPpChs/eDNyO+F6/IwM4zwcsiLR6Si/osV+EsUrBXFFBL/hQe0xhEUiBfhjq
         tcIpo43LTzFGwJLmsMbhY0TdxIUwN/OWnix8p5Vb78LdLLHwlFNAFUEE+4ANJJNM+Xbw
         j/tzF7ulh/uJdHhcRxkx0o+KJk8MYSLcDuztSK27bJ5y4Ck8aG+BaVYsMVDVK9iZdsHm
         feW1rWRyOUf2tDi/3XOjfLd+5SjNkRQGYAXhV/2eQ0UwUYm5umBBN29wQbC2oMvE2NHz
         4wlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=eKzGGb5J7xnw7YW9klEzISreEEiI8ajXRNdS4HRdGss=;
        b=s9zUDtZ4z8ys84C2kB5l1GL2BQXlb+PPC5+id7onkfcDdafhge5wVWzLIPhknrQRWd
         0e0tbBvuDUbTmjX+Zk1Jmbe3hASe4ltAYTittD8ryTRoupUYmKgRxCp1Slx6205jjbBE
         s4lxV0JTYgoMJb2X6jeGoHk43XGtyhxwwtjL9ef5Bi3iwsScnrqJjnffJzSrkKtzjXbm
         EoEm4imGqQa54MUDCr2m2Di9jBnINMJg4yJGWlR1B9pXVwcgM5KxtRLPXCH8aKduwuuZ
         9zeb3vM6KoxY7Vhr8flGA+s3ExELq0bMsta8sFWMXr1M8oeVt1cK3/rZBWv1GHMm3/aD
         VW+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=WUybDOPT;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f64sor8177873qtb.41.2019.01.31.18.58.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 18:58:44 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=WUybDOPT;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=eKzGGb5J7xnw7YW9klEzISreEEiI8ajXRNdS4HRdGss=;
        b=WUybDOPT0Ir6GsF67zeiTl4e+obVjnbqnKajN9ynkx2TUorRE78G8h797zfEC4US+o
         CyZXCuPyzEgTAheG4maLrlxAuTZCu1z2E3z220ChhxSM1dtGqkTfBTZYynVXZqRV42h6
         nSvYYRKIdNgkukoPBcM9JvKPZ+5PuUv7qM/vM=
X-Google-Smtp-Source: ALg8bN6eJMVhvueQhK5gMoovSnrfMbkM0Rsbw0mcoPdCGI+oVpbNIPAeYc7bMCyRD5MSLYvKDVDfUw==
X-Received: by 2002:ac8:32b2:: with SMTP id z47mr36186503qta.209.1548989924561;
        Thu, 31 Jan 2019 18:58:44 -0800 (PST)
Received: from localhost (rrcs-108-176-24-99.nyc.biz.rr.com. [108.176.24.99])
        by smtp.gmail.com with ESMTPSA id u7sm11111412qkg.79.2019.01.31.18.58.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 18:58:44 -0800 (PST)
Date: Thu, 31 Jan 2019 21:58:43 -0500
From: Chris Down <chris@chrisdown.name>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH] mm: memcontrol: Expose THP events on a per-memcg basis
Message-ID: <20190201025843.GA19018@chrisdown.name>
References: <20190129205852.GA7310@chrisdown.name>
 <201902011021.dwu1fKhG%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <201902011021.dwu1fKhG%fengguang.wu@intel.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001182, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kbuild test robot writes:
>Thank you for the patch! Yet something to improve:
>
>[auto build test ERROR on linus/master]
>[also build test ERROR on v5.0-rc4]

This was already fixed and is now in linux-next.


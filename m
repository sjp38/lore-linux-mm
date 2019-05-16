Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E334C04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 10:44:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 036302087B
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 10:44:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 036302087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 666616B0005; Thu, 16 May 2019 06:44:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63BCC6B0006; Thu, 16 May 2019 06:44:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52B136B0007; Thu, 16 May 2019 06:44:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 196A66B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 06:44:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b22so4797985edw.0
        for <linux-mm@kvack.org>; Thu, 16 May 2019 03:44:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9JBRz2mJ5XkmlHAQncxlb2p7V0BQvJ1Gs0ld5Bx6Ktk=;
        b=gPo+2BAetu3qcIG0e7g0+TBN9LZDO8xCbVZYo/DAvdnYbhZ29Qa5P+byxjYAvRdJLe
         5TjBpETRa8VwAj1q/pHcGCfqr4IBSsRmw2J7Va2pVdf5vUgOBtwhUAEDpkj5k7NzJOUs
         zp4UINOWrfQJE2QzBvhR29CKvzrkw23Zyw5vElIjAYl3lGSdoFoJRGa8K8ABVPUrQ/OJ
         +5BkgfizVkLfGxOop30IEhfWy55UFxhHlSZl+YU8rzee6LjIhAZpxyh8WwSU3GJHjZZu
         lRPd83PnOPRynLqQhcJQm2ywCLQ2ucfj+rlLIUualVVmtTq9fHWkb1CXTV8s4QHHHGNs
         qlWw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXYb7GgyC9xJznwW8GMLtWPs/7T+LJ95c3CpygiqEKj9t43+Jen
	zbDWDx7A8qi32OR4raImerQniYqLz7/SCD21/fEIQSK84pOc/Ip3Sf0QFijHSFxJIRy2AoKPqH5
	efJPBN1SxPrFZav4n4UchuTVX7+RNFdI/+N3iV/sWOn1wN29j+atZgDmZLXsD2co=
X-Received: by 2002:a50:b69c:: with SMTP id d28mr49630685ede.129.1558003456630;
        Thu, 16 May 2019 03:44:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9BlsMpEvaJl6sT+OueHAlV/cqpat3n+VTWKKHSpXcWhJHTuqZrH0fJGYiUTmZWOO6SpZg
X-Received: by 2002:a50:b69c:: with SMTP id d28mr49630624ede.129.1558003455818;
        Thu, 16 May 2019 03:44:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558003455; cv=none;
        d=google.com; s=arc-20160816;
        b=zlh2ImX70ghWN6VgkCH2xJpIlurQuLlMbA+vdsHcFm3z0DBO/50QEfw5rAV2z/pfve
         YQ0OMFSD+v6OCnXI8xLZlZaNQ7/XwnrdHftTaonwd4ClfTYeZ+aDm05pFWVIv0C/pq5F
         thPa5uFdvK3n/AuUYG419hY0J4/xaDSiKVmzDBnxerCXwbgBSMSOY2Oqmah0ICJ/xoHc
         gvxRVezxyNVVO+qNZ00RGd+Utrudq5WfEwV3Q4ZOcJehbeOWKLrQdLWG94wGxP8rFakI
         Jo7UDoawZnmC/xq8MIrwJMplkqfnalB98nuPE0pVMJt7hcA8GykY/5y/+XLBb9yMSBJt
         rIXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9JBRz2mJ5XkmlHAQncxlb2p7V0BQvJ1Gs0ld5Bx6Ktk=;
        b=SYTNtxyxhXJ09ymU9/DyFgNQKk95RuHhR59kcxcgJOp/TROy4MUSZ5ry8hZNm38hHl
         x0x/0LGh/G12tVXnJah1mmJYz2TeRUkaLFXb81+G1GJ2NmboQc13TbaBWl/EoTt2adnv
         JomSvE2xkSCWA8efCymWcJwq3okpKT+vFbeujImGUcv9hA9Rlpok/wwuD9DFMPXlRkOp
         b/yNy1KrX7YxE6+G1DbQp8sTevs6ohht6Vz/9pJVgilGf0dGCDofiCk+BpUFlpWSAOTh
         /Vgv6+RsQzarvXnNgAZ50spM2ZCXRr9ljUob2gE48uU9eW9ZjBQD++4d5rkoDJP2qKXY
         5bSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b38si1391810edc.267.2019.05.16.03.44.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 03:44:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 98DF2ACC1;
	Thu, 16 May 2019 10:44:14 +0000 (UTC)
Date: Thu, 16 May 2019 12:44:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Hugh Dickins <hughd@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Greg KH <greg@kroah.com>, Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: Re: [PATCH RFC 0/5] mm/ksm, proc: introduce remote madvise
Message-ID: <20190516104412.GN16651@dhcp22.suse.cz>
References: <20190516094234.9116-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190516094234.9116-1-oleksandr@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 16-05-19 11:42:29, Oleksandr Natalenko wrote:
[...]
> * to mark all the eligible VMAs as mergeable, use:
> 
>    # echo merge > /proc/<pid>/madvise
> 
> * to unmerge all the VMAs, use:
> 
>    # echo unmerge > /proc/<pid>/madvise

Please do not open a new thread until a previous one reaches some
conclusion. I have outlined some ways to go forward in
http://lkml.kernel.org/r/20190515145151.GG16651@dhcp22.suse.cz.
I haven't heard any feedback on that, yet you open a 3rd way in a
different thread. This will not help to move on with the discussion.

Please follow up on that thread.
-- 
Michal Hocko
SUSE Labs


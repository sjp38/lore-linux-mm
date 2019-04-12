Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADECCC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:17:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A38C2171F
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:17:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="yNuKOmHf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A38C2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B71F6B0271; Fri, 12 Apr 2019 11:17:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06BE26B0272; Fri, 12 Apr 2019 11:17:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC1816B0273; Fri, 12 Apr 2019 11:17:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC6916B0271
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:17:01 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id l26so8992338qtk.18
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:17:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DBVwMeaUDBJkycGKDayUqBJF7IF5Fkb1UBmd6vl/3EA=;
        b=eoUu2U1zdB39ODGELUVJpOHMWKerumJMb4U9Q/IgOP8+CCpE0r/sef0hdUMjpRdZyg
         mh6ZBkqP+DvU/tTXIkVwlfWnIlTrCXhh8xdlSX8tE2fc/9vkzwX0GkLhBWNNrOeK43Xi
         Did8BptWz3KUoozu68L8HSWiKkHCtFHlFifyOoB2LPXdoL2qv1EUvVkVoT2xpgJkm51z
         hRLv30H4qv2KVlgjHtudoymvX3KNPV+AUqBYVbhJt3MwkBPTLBLo/FNbFcQ5hF8BluF5
         7RzRsBUKGQk5N9b6v9mPSO+acAq+yUqTAg86I4UBy5VTuN4uN0qN+vifPBHNu9hKbwZt
         cMMg==
X-Gm-Message-State: APjAAAUE8ZqODAFN9oFNINjCXY2+HZLmSv+l23wwJZiJ1zUcnJtrpBpR
	fzL+zUPoB3kWqnLn7TX8yixm3FpAHaC6fyv1tf9tDQMYTc/IXaTIXyZE6sXPNuqYIpL4lK+7PBV
	h82T9kHkI7yuWpllW801oE9MxPOAfX8/gra5H5FS0fDY8WBc++IL7nJuiGQRtMN1n0Q==
X-Received: by 2002:a37:aa8c:: with SMTP id t134mr45323330qke.93.1555082221631;
        Fri, 12 Apr 2019 08:17:01 -0700 (PDT)
X-Received: by 2002:a37:aa8c:: with SMTP id t134mr45323286qke.93.1555082221223;
        Fri, 12 Apr 2019 08:17:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555082221; cv=none;
        d=google.com; s=arc-20160816;
        b=IK6pa+oQQbBABDcQOmQaYFf0HJGXQhozdbq2Q8RdK4cl+hvIaNm4zZDeUJRdMNRvzb
         4nhu/BDdOKgVv3bIcN+FfQpGhd3q4+Mu0dd78tWWqiLnicSFeHAQTNe1k88wacKZyqgU
         I52Nk587T3QIlrmR+uo6uvux+VN75XwcECQ2HZJRb9+Cyw/hSXWxVfPYt5ACDOTIqjk4
         jf4k21iO0rZA4oEqZW7geLj075qhralrIfFCneeWd+kv6PrR9mXYgZSso8ObjBIxF4iv
         o+gyl+Mvyd5yWAK19D7N2Lj9mbWZwU3Z2fo2gDLWEQzrObymgz/6M3rHUGPh9V3zx2Sz
         vkTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DBVwMeaUDBJkycGKDayUqBJF7IF5Fkb1UBmd6vl/3EA=;
        b=Ue62o0GHhStle3O8gOyq8SN3aDPoNhG4A5/GfNqYfD0s51m5oPzX7DFowkffXENH3S
         XAZIbeCqmrWZ+PEKpctc7gAWnltOE8fiUU08el5Cwstyw0VoXXv7EaKJ3p3u9RxYtjCO
         S8zKSUhPXoJveHXdhcLQetbZJa7NHip4P9l6qKQF9lJ7a62S3/NL9hquMH+n/bQnn5Mw
         ptFWCdX4vNNjSkLpzs4OAxe1ltzjXOUU8ln+GN7SqMHp46zuMaUArlbgILP/i03gsLMJ
         ZGLdBo3sMLRohoTCOai4BeuQ1enEJHMNAF7Fd8rXnuHOHJXUN0WuQISNse/VVVz+Carh
         wi7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=yNuKOmHf;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m27sor57453437qtk.2.2019.04.12.08.17.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 08:17:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=yNuKOmHf;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DBVwMeaUDBJkycGKDayUqBJF7IF5Fkb1UBmd6vl/3EA=;
        b=yNuKOmHfWBMAN0fxLIFo2SqWFxv7D1j/yAq/MomXxFQXcbYKWH4DLyTDrnuxoMFFlL
         KZVm2GYrY8/IbFxHTJjMXM76xYThjsKZmnNzdYvftfSXlOtGO5h4r1j8LkL5fCIeU2j+
         CeCnCzTPLQvAFGOcExI8ewWI1Zv7k3KBZBLvrnYfSUAYhtLotbz5yGzJnUQXvxUE87cc
         6yvfK7PWARPnal4GdxD97M/YQ/5VZh38O9sPDEeygDG3ld+kdlhaN4MgYpNpI9Qsk9Lw
         pIsHc41MYkvZ0kEq7INzEYInABbVczSb38wtsFzD4mD9ULnnLFHmGLZpI6h3J8Jqf341
         cBcQ==
X-Google-Smtp-Source: APXvYqzF3HpyxGuUjVItHMAG8rnGhhMbkkLtnGlmeZc7OEbn9JgFb/hgLHiC590ZbvDMkcFsk/ioEw==
X-Received: by 2002:ac8:7653:: with SMTP id i19mr47366814qtr.177.1555082221000;
        Fri, 12 Apr 2019 08:17:01 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id j25sm28952761qtc.24.2019.04.12.08.16.59
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Apr 2019 08:16:59 -0700 (PDT)
Date: Fri, 12 Apr 2019 11:16:58 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Michal Hocko <mhocko@suse.com>, Baoquan He <bhe@redhat.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	akpm@linux-foundation.org, dave@stgolabs.net, linux-mm@kvack.org
Subject: Re: [PATCH v3] mm: Simplify shrink_inactive_list()
Message-ID: <20190412151658.GA3173@cmpxchg.org>
References: <155490878845.17489.11907324308110282086.stgit@localhost.localdomain>
 <20190411221310.sz5jtsb563wlaj3v@ca-dmjordan1.us.oracle.com>
 <20190412000547.GB3856@localhost.localdomain>
 <26e570cd-dbee-575c-3a23-ff8798de77dc@virtuozzo.com>
 <20190412113131.GB5223@dhcp22.suse.cz>
 <4ac7242c-54d3-cd44-2cd9-5d5c746e2690@virtuozzo.com>
 <20190412120504.GD5223@dhcp22.suse.cz>
 <2ece1df4-2989-bc9b-6172-61e9fdde5bfd@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2ece1df4-2989-bc9b-6172-61e9fdde5bfd@virtuozzo.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 03:10:01PM +0300, Kirill Tkhai wrote:
> This merges together duplicating patterns of code.
> Also, replace count_memcg_events() with its
> irq-careless namesake, because they are already
> called in interrupts disabled context.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> v3: Advance changelog.
> v2: Introduce local variable.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>


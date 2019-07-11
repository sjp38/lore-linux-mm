Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C23C9C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 15:26:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CA2E20872
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 15:26:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="d2lENQ3w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CA2E20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C6678E00E6; Thu, 11 Jul 2019 11:26:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 279178E00DB; Thu, 11 Jul 2019 11:26:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1664C8E00E6; Thu, 11 Jul 2019 11:26:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D30248E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 11:25:59 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x10so3622951pfa.23
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 08:25:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3ahhQ+9CCV1RUDKRM5TFZcgtNPOj1dansSCnwk/nmOg=;
        b=jVtngOYOFdOIvDUYfLsSOhzPzgICsxDrb3OYIGAZrv2YC+Ae2P0Vt4fviEooY+IaTd
         XDPzFmahZVvIr/iRhsSO6s422kiQAmuhBH//AdfGaErsdm/6qRK54g20LXUBCTolhlkX
         JPQSQNrYLnqBr9qUVa1PkQ3ihsOQ3rMOXqppYS87Lgdrmg+5xdH24zkpeSH+rq+jCLo9
         4/RVgxpfgm9c2XbbHOGD6TpyTN9HG6t42rvFiRL1cbwLEp6N9O3i/o8akyi6jCCn5ro7
         PG0G+Ii/LJUANAvtV+MiEoQfV+MDDuc3JVof1NK2gqteBNjyAI8Dax4HmKqDXl1KfaD9
         m6kQ==
X-Gm-Message-State: APjAAAUK9aJ4TjWPD14/3oWXxFRATD90QICpx66iQ2ppcM5rJEbGafdm
	sbAt85xWql8MesA1xgnks8Wxw7uS73Ei27eUduNTZ4WrQ5Ghbsj7jbFawN34+1cpVuRvrY28eM3
	05zjeW/aX431h8l1SxezAfW9STKefQ6DxXclU+U5hvJ7LXqguQyUOqRE4s1gBeQZM7Q==
X-Received: by 2002:a17:902:d70a:: with SMTP id w10mr4989130ply.251.1562858759464;
        Thu, 11 Jul 2019 08:25:59 -0700 (PDT)
X-Received: by 2002:a17:902:d70a:: with SMTP id w10mr4989074ply.251.1562858758715;
        Thu, 11 Jul 2019 08:25:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562858758; cv=none;
        d=google.com; s=arc-20160816;
        b=yZYvmjdn3XGzragLBAsPOF8zQQfb8f62n35+mCoM4IkmQEQBTiWt0O1uPE2bMG8Sh8
         WKOVknblhsiMwKIWnHIvSJfaWHaK2FJN7wbtrpUkBb6YSlg2IMSA0la3RCeaQa2LwICc
         y7MTkcaTz8l22BqOOcjQI/csBBMcffzR+FkqDeZE/F07ZcVoQBCP6eDF/eIcThU1rpCn
         jzSrVC06q/2p6cV+lDMnC4qDChO1InO2hEVLn1knpBQlvYfpe/1zJctilkw8GwfIy3Qb
         nOoOQAFoifcKyVaG0scpypu3oRwCmt0KPqqeMGNhWT6gkYXWqhqX5zgxfIVvCbSlvp75
         e5Og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3ahhQ+9CCV1RUDKRM5TFZcgtNPOj1dansSCnwk/nmOg=;
        b=l18KYudO+JGiDz1J9hXRPIWG+5vVHUAz0o6SJaaTl9HUhQsTvm3We2wPvI9duwnpyF
         q8PruGNhaxG/LTU0ihR3dZZel4pgA3foT2Pisv2J8x+ZkfK2+xWHhwwG9TyZMAUDfwtl
         bvgd2Eul2uJG7HuvYdazc2gXqwjJp+MlcEDmADXyHe6mMK4R43Vl5X7ZD5wEC7UuRNXl
         aLdCKi71V8B4PXeVbgX34cSwlkQjNKDzQHEtlm+nkjqHoscKWIlfOF+ieAe+ZdorxC1K
         EvaY17Gq2+nSdiOCme2afNUNe0lry6BV6a+Ebl4psQKX6XTQEffp/sMh6GqHtgYB+xk9
         lJYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=d2lENQ3w;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m39sor7136518plg.49.2019.07.11.08.25.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 08:25:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=d2lENQ3w;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3ahhQ+9CCV1RUDKRM5TFZcgtNPOj1dansSCnwk/nmOg=;
        b=d2lENQ3wKspL1afPpwiMIMJTEtBu+3KRlviHBIV4/B5UC37H51zReuZ416QRoXpIe2
         o2wmkTIr2ailmX4MJoktDc/x2fNGBESK7lpnPf7caIWBEthnI9JViE9zFBOEMjvhf43m
         itDC80oThCy9XFYKTuVKPJxhfVAl1WIfVRYNc/DGVIIlIyfcbvY8GHGrD4lY885E/trN
         mb5C9EWN/v+uf6P74qonMeev0oC/D5Ql51Bi7zMZrRAMf3hOVm2RTc65AQrbrM2+uR3G
         FVzAh9j0UcKXid1HRp7x21ZT/XBEHmZbifIcBunTXtfAdXxqZgU0OdEi7CbGXIa3/UQr
         YdsQ==
X-Google-Smtp-Source: APXvYqzrq8ZKmOBHrm3NMUilV5X7y9HrlK8XVGKpg1nNByoohX3AvOSOI4JtUKlplVLiWjaFRr+p9Q==
X-Received: by 2002:a17:90a:d3d4:: with SMTP id d20mr5665939pjw.28.1562858757966;
        Thu, 11 Jul 2019 08:25:57 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:6fa9])
        by smtp.gmail.com with ESMTPSA id h129sm5716609pfb.110.2019.07.11.08.25.56
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 08:25:57 -0700 (PDT)
Date: Thu, 11 Jul 2019 11:25:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v4 1/4] mm: introduce MADV_COLD
Message-ID: <20190711152555.GB20341@cmpxchg.org>
References: <20190711012528.176050-1-minchan@kernel.org>
 <20190711012528.176050-2-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190711012528.176050-2-minchan@kernel.org>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 10:25:25AM +0900, Minchan Kim wrote:
> When a process expects no accesses to a certain memory range, it could
> give a hint to kernel that the pages can be reclaimed when memory pressure
> happens but data should be preserved for future use.  This could reduce
> workingset eviction so it ends up increasing performance.
> 
> This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> MADV_COLD can be used by a process to mark a memory range as not expected
> to be used in the near future. The hint can help kernel in deciding which
> pages to evict early during memory pressure.
> 
> It works for every LRU pages like MADV_[DONTNEED|FREE]. IOW, It moves
> 
> 	active file page -> inactive file LRU
> 	active anon page -> inacdtive anon LRU
> 
> Unlike MADV_FREE, it doesn't move active anonymous pages to inactive
> file LRU's head because MADV_COLD is a little bit different symantic.
> MADV_FREE means it's okay to discard when the memory pressure because
> the content of the page is *garbage* so freeing such pages is almost zero
> overhead since we don't need to swap out and access afterward causes just
> minor fault. Thus, it would make sense to put those freeable pages in
> inactive file LRU to compete other used-once pages. It makes sense for
> implmentaion point of view, too because it's not swapbacked memory any
> longer until it would be re-dirtied. Even, it could give a bonus to make
> them be reclaimed on swapless system. However, MADV_COLD doesn't mean
> garbage so reclaiming them requires swap-out/in in the end so it's bigger
> cost. Since we have designed VM LRU aging based on cost-model, anonymous
> cold pages would be better to position inactive anon's LRU list, not file
> LRU. Furthermore, it would help to avoid unnecessary scanning if system
> doesn't have a swap device. Let's start simpler way without adding
> complexity at this moment. However, keep in mind, too that it's a caveat
> that workloads with a lot of pages cache are likely to ignore MADV_COLD
> on anonymous memory because we rarely age anonymous LRU lists.
> 
> * man-page material
> 
> MADV_COLD (since Linux x.x)
> 
> Pages in the specified regions will be treated as less-recently-accessed
> compared to pages in the system with similar access frequencies.
> In contrast to MADV_FREE, the contents of the region are preserved
> regardless of subsequent writes to pages.
> 
> MADV_COLD cannot be applied to locked pages, Huge TLB pages, or VM_PFNMAP
> pages.
> 
> * v2
>  * add up the warn with lots of page cache workload - mhocko
>  * add man page stuff - dave
> 
> * v1
>  * remove page_mapcount filter - hannes, mhocko
>  * remove idle page handling - joelaf
> 
> * RFCv2
>  * add more description - mhocko
> 
> * RFCv1
>  * renaming from MADV_COOL to MADV_COLD - hannes
> 
> * internal review
>  * use clear_page_youn in deactivate_page - joelaf
>  * Revise the description - surenb
>  * Renaming from MADV_WARM to MADV_COOL - surenb
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>


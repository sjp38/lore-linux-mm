Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90467C742BD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 15:01:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AFE92084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 15:01:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AFE92084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1B9E8E0157; Fri, 12 Jul 2019 11:01:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA4F88E00DB; Fri, 12 Jul 2019 11:01:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D47138E0157; Fri, 12 Jul 2019 11:01:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 824728E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 11:01:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m23so8067604edr.7
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:01:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=D1mDCghNHFZf9mSlYR0mupbNP94KV/aTZJZt10WBa9U=;
        b=j6JZXgE/VQCmph7KQgsShShUIfJ4WdnS//NRClcjH1er/IqtxeZCpR1G1Ix3+BE9aT
         8ahzoyGjb9er/J64GdU2ykDiBCP4WZXfxi1z/LlkVxKFbe5mveEr1v3oUdxz38JoyP2I
         PPmFUr1Y4I7FI7Gn5OzvC/9Mibg+SlToG8PZE3dNkZTo+4HGsJKFOlU7zYOpVI8PVbFK
         kl4hDJsvbJHbyFZPbFDUu6iqXhGPy8aMFomGnXFc2fUZrEEK9SVDWI0E6aN0bnWcf1nr
         U2xrHj5S3pXIqA4dLuU7Du5AHUXE+CKnDcIIdWN29rYKoJgxgqEZXfHMd6VHfSroUHBt
         8Osw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVEqB1zepmWFwJQw9MT06HlB4m7EU4x038ZM5vkasjCZRgKjo9q
	gNX77igD7k3xBFpchZocSm/dueYjMd1vFGx8iZfVpH1JaCPtmF4s+pmlLPUclXHWzfWlyrh7fex
	ILZTkFBKO7zhz7Lq5fWFTP2mNuIR9qUoUuXzD5kZMSMLjfT5+5bfxEyMFaDk7EkI=
X-Received: by 2002:a17:906:12d7:: with SMTP id l23mr8570486ejb.282.1562943690111;
        Fri, 12 Jul 2019 08:01:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcLSgneeqv8PSyy6Lno4qhYE6gsggVAiY1S5CgiPVcXakrPzpbqIEBFpMS84t+XMaZCvC2
X-Received: by 2002:a17:906:12d7:: with SMTP id l23mr8570402ejb.282.1562943689339;
        Fri, 12 Jul 2019 08:01:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562943689; cv=none;
        d=google.com; s=arc-20160816;
        b=bMnCrkoePWaFwSgw4tENUPM0DvcG0ACzDafI2O0idmm0rL5lpG1jfsHKE85O1ceGqY
         k4PUDwxdkvFw3r/lASFdEN0WurSM3o+qpeVQt6nQmsRv+qCehFgJoZOkXY+oDCL7V5pU
         dQ5Myn3m1AZaOFPZpcFBlhw3yI6B61meAJoXQ7tM0V4svPnY9Z0UBGVc/gGbde5HqT8C
         tDn9DaF77AtTvNQ2jwxdno/DrxaJ/JL70BFvkGD7ADp5vLF9xPBnKkpaBppKvky0bGyW
         cBiqKrsYle3oA/nCsRos5hUcLMQQDk7l9aQnwVAuuq2ZwTUwNTlArFnpEhd93Tlq4g4+
         vdlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=D1mDCghNHFZf9mSlYR0mupbNP94KV/aTZJZt10WBa9U=;
        b=fB+O+GQREkBDCDbKfEEq4QR7kJx9Otx2R/0FnI4wWoK5Mj+RthRJeI5HkKRg+bbiww
         z1njY52P6lWZwU9rHHw2xr+zduK/mOssXQlXRa4zaCL/9sRJ74bLleG0aDQHy3pUdR0o
         Gt5WdQpZnoxn4yKpwo3X/Ibfn4jdt9NhyFS5eEjbYCPrJHvkIt7HjwNMQ4NZH5zAlnNt
         f0EkvlZN0nTuE/8KVozHP5CPdxFIM8pecP9Cg1K2XmITy/woWTRpNfj1ydxT8KYAxQNk
         WnWZ8JIcg58ieHycKMcqLYoLq4WVcShN1qdBSh6VsigaJEU6FfYgHYqNymg3qWz1x/lj
         lJTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gf12si4858805ejb.392.2019.07.12.08.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 08:01:29 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CC43AAE84;
	Fri, 12 Jul 2019 15:01:28 +0000 (UTC)
Date: Fri, 12 Jul 2019 17:01:27 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v4 4/4] mm: introduce MADV_PAGEOUT
Message-ID: <20190712150127.GV29483@dhcp22.suse.cz>
References: <20190711012528.176050-1-minchan@kernel.org>
 <20190711012528.176050-5-minchan@kernel.org>
 <20190711184223.GD20341@cmpxchg.org>
 <20190712051828.GA128252@google.com>
 <20190712135809.GB31107@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190712135809.GB31107@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-07-19 09:58:09, Johannes Weiner wrote:
[...]
> > @@ -423,6 +445,12 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
> >  
> >  		VM_BUG_ON_PAGE(PageTransCompound(page), page);
> >  
> > +		if (pageout) {
> > +			if (isolate_lru_page(page))
> > +				continue;
> > +			list_add(&page->lru, &page_list);
> > +		}
> > +
> >  		if (pte_young(ptent)) {
> >  			ptent = ptep_get_and_clear_full(mm, addr, pte,
> >  							tlb->fullmm);
> 
> One thought on the ordering here.
> 
> When LRU isolation fails, it would still make sense to clear the young
> bit: we cannot reclaim the page as we wanted to, but the user still
> provided a clear hint that the page is cold and she won't be touching
> it for a while. MADV_PAGEOUT is basically MADV_COLD + try_to_reclaim.
> So IMO isolation should go to the end next to deactivate_page().

Make sense to me

-- 
Michal Hocko
SUSE Labs


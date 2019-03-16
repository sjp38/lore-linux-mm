Return-Path: <SRS0=HgWV=RT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1224EC10F03
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 08:34:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD11F218FC
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 08:34:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD11F218FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54D936B02D1; Sat, 16 Mar 2019 04:34:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D5CD6B02D2; Sat, 16 Mar 2019 04:34:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39EAC6B02D3; Sat, 16 Mar 2019 04:34:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D2D3B6B02D1
	for <linux-mm@kvack.org>; Sat, 16 Mar 2019 04:34:37 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d5so4812723edl.22
        for <linux-mm@kvack.org>; Sat, 16 Mar 2019 01:34:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ITA6CL5hCZRyW7s8fFzIfwI8ElWa95Hy9WtyMFBGPMo=;
        b=IJ2fLWf6mg8po5LkF3hJIxJtW5bwzht8K8zlXmb6AwV1lo+V5wQnzdjmnGsBQDtDWO
         MqiHFWdqvjhK3xULx4yGwtqj/P/Sa/Vuuhg2ED02Ni6ABnX6Ia/a3izum9YODIGV+XI9
         epube3GuG8t2l81qaz5g5Jvn4Yl3F0OGLqIdhUd+T4qP7iWIVBBUvTyb/wiIIf9msLAG
         RyRr9gAF6Ua9r8PifnwWaEx6inKYfwRdJVZEHe57V5J7Zg/RaKQ576LJS5PxGTraBPFo
         kMhr0ijkpuDfpLEMyL5dLfselAVbdbr+Zg/e1hDI/a7wqavjisRRHWHIARWIZlt2sAFs
         J52Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXQBXeECeL4QYDKg6/OrNri07Kk+E/c1SRdh0ovaK+wDfnCeRsx
	4OCf62GIqaaHgE/KFX+AqMrBxkjbdaT9XfpUbFEvr1uIzMPS++JhPcqB3xOeCbGhDUXkLbmDdEA
	YOfoNY5THIco0uD1yOsD6DK9Lv0HLbu+vCvlqKO7god68YV8+4Ln0bKh2aQ80hW0=
X-Received: by 2002:a17:906:54d:: with SMTP id k13mr4678227eja.207.1552725277396;
        Sat, 16 Mar 2019 01:34:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxV58h1umkF2FDUoveZo5qDiW4Zbat5JhBqycGeh2oI8I1pEWuDUAE0RsMY5tJBkBhVJPGV
X-Received: by 2002:a17:906:54d:: with SMTP id k13mr4678190eja.207.1552725276451;
        Sat, 16 Mar 2019 01:34:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552725276; cv=none;
        d=google.com; s=arc-20160816;
        b=vEF740xFNCHAu7LmcpU7m9It9DDoW0qkN7huu0AuICgCp7nECaWVSWCDX/6cV/cITe
         jyumpD31h8yrXXHKZGuRF8MuSc8T0KhjSdZFyrz+y+Bexwe3oUelp8yUuItG5poMxTiX
         ZRYECCdZVc11yctGRwPEgyLMc/EeURrtZioS2E+K24QsNB4BfqQFwj4vkvdW1631hhz/
         D1q0W5FbyvzgRhAseCkZqyDIBlJD+8FCw3MIPj42EpRzgslE4Od7jfNN/niKHJLwwc5D
         eBwVHt1t3k/OyADVXHz5zwq++UmmKFwn30aTxxrV72dZM2t9PdZjNl3fUhanRup2YCDv
         PsYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ITA6CL5hCZRyW7s8fFzIfwI8ElWa95Hy9WtyMFBGPMo=;
        b=M4uLkUFZKlnhCHrBaO2TSLDOC2vQ5hiXVC+6AtbPhChRJbkcX49L95M5z2KGjjw4rL
         0tHe48nunSKa4P9Pmdyr4DPBgYdDw986Z85vhNt0Xj9K+FJAms/vdtWCDNsqQx1vaUCc
         jSlI7yMWURNQqi5030ySMcoOQ+hEz3D88P8qEgQvyZ6srPWoSkmOpsv3FiFXJ+8sSjzd
         g0Vv2jfvQcQM9FhdxUYKRWCsq6HLV9RZsn0YskVEZdQKOvcTYe2tn6wqTRFePvUqO4Ur
         Tx1XzIKZKwPzjB0JTkHadoO7GW6tVm+BAxCaZJD2ghLvl9n++uWepSrkWqhdTtqVcJ3q
         v5+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j27si1775455eda.283.2019.03.16.01.34.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Mar 2019 01:34:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B8205ACD7;
	Sat, 16 Mar 2019 08:34:35 +0000 (UTC)
Date: Sat, 16 Mar 2019 09:34:34 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Hugh Dickins <hughd@google.com>
Cc: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org,
	anshuman.khandual@arm.com, william.kucharski@oracle.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Fix __dump_page when mapping->host is not set
Message-ID: <20190316083434.GI15672@dhcp22.suse.cz>
References: <20190315121826.23609-1-osalvador@suse.de>
 <20190315124733.GE15672@dhcp22.suse.cz>
 <20190315143304.pkuvj4qwtlzgm7iq@d104.suse.de>
 <alpine.LSU.2.11.1903150952270.2934@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1903150952270.2934@eggly.anvils>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[my mbox didn't get synced completely so our emails "crossed"]

On Fri 15-03-19 10:21:18, Hugh Dickins wrote:
> On Fri, 15 Mar 2019, Oscar Salvador wrote:
> > On Fri, Mar 15, 2019 at 01:47:33PM +0100, Michal Hocko wrote:
> > > diff --git a/mm/debug.c b/mm/debug.c
> > > index 1611cf00a137..499c26d5ebe5 100644
> > > --- a/mm/debug.c
> > > +++ b/mm/debug.c
> > > @@ -78,6 +78,9 @@ void __dump_page(struct page *page, const char *reason)
> > >  	else if (PageKsm(page))
> > >  		pr_warn("ksm ");
> > >  	else if (mapping) {
> > > +		if (PageSwapCache(page))
> > > +			mapping = page_swap_info(page)->swap_file->f_mapping;
> > > +
> > >  		pr_warn("%ps ", mapping->a_ops);
> > >  		if (mapping->host->i_dentry.first) {
> > >  			struct dentry *dentry;
> > 
> > This looks like a much nicer fix, indeed.
> > I gave it a spin and it works.
> > 
> > Since the mapping is set during the swapon, I would assume that this should
> > always work for swap.
> > Although I am not sure if once you start playing with e.g zswap the picture can
> > change.
> > 
> > Let us wait for Hugh and Jan.
> > 
> > Thanks Michal
> 
> Sorry, I don't agree that Michal's more sophisticated patch is nicer:
> the appropriate patch was your original, just checking for NULL.
> 
> Though, would I be too snarky to suggest that your patch description
> would be better at 2 lines than 90?  Swap mapping->host is NULL,
> so of course __dump_page() needs to be careful about that.
> 
> I was a little disturbed to see __dump_page() now getting into dentries,
> but admit that it can sometimes be very helpful to see the name of the
> file involved; so if that is not in danger of breaking anything, okay.
> 
> It is very often useful to see if a page is PageSwapCache (typically
> because that should account for 1 of its refcount); I cannot think of
> a time when it's been useful to know the name of the underlying swap
> device (if that's indeed what f_mapping leads to: it's new to me).
> And if you need swp_type and swp_offset, they're in the raw output.
> 
> The cleverer __dump_page() tries to get, the more likely that it will
> itself crash just when you need it most. Please just keep it simple.

OK, fair enough. If we ever have anybody suggesting to follow the swap
lead then we can add it. I do not have a good use case for that right
now. Let's go with Oscar's original patch. Thanks!

Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs


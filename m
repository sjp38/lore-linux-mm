Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78ACAC74A42
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 07:12:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 430BD208E4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 07:12:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 430BD208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEBCC8E00A9; Thu, 11 Jul 2019 03:12:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC39F8E0032; Thu, 11 Jul 2019 03:12:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB39D8E00A9; Thu, 11 Jul 2019 03:12:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6BCDB8E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 03:12:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l14so3737114edw.20
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 00:12:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VQV2R1yVIYkMnMB0sO1Yqc1eECwOX3+9/eQi5iOzhC8=;
        b=uWzKwCUtSVvUSvSqXqXWAryqAt38XiYyLpItA/1sDbpWoVo3pnCJuqovG9ncNqi1kA
         qhrzs0mtHvqvTksxVPrnfkRNuoByamyfmS55Ja9LS/Abha8hMdlkfhaMvx3FqH00gsjA
         tLjOBPxedBvI5TBePRbk/S7fRT3kkvflVz2hL8ciEe+40Kz5HeGSzjEn5AYpBkpGLgsE
         Zy1zN18ccTo0DepwxK1sKKiFqulspmRPx9oK0FfdJTI267N6fr/53i71Qpq7G8ckrzir
         aiBcKvNgMAA11zV3SyxgaerztqeUtAHQAKdkntpI1CsIkvguAfNFf8UHUunjlLaq3qyk
         d1/Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXwHDSH4hiEC9dLpy5fnZfW3NvDfNVTx00DWijCZVt2Dm/AqN85
	Y+v2tZio8WN1pnqvfwFD8vwiFULSjmiRp/9KooKFBREHCtISlVh1O701LFm7/D2X7XxC3w+wnAH
	M154mn7+CTWMoNe4gLXSiVuGLKvZOkHxZBgQyCnfSsvRT62CVcO3+GZ3r6FyHpSg=
X-Received: by 2002:a17:906:114d:: with SMTP id i13mr1830612eja.252.1562829168007;
        Thu, 11 Jul 2019 00:12:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8xGphdxjWF1bk83Zp0MXkvpRF30VYuBmYdESqs6xaFIrkfyTkEMdezORDxSQ6O9O4MJQw
X-Received: by 2002:a17:906:114d:: with SMTP id i13mr1830577eja.252.1562829167203;
        Thu, 11 Jul 2019 00:12:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562829167; cv=none;
        d=google.com; s=arc-20160816;
        b=gGlxkxb6A0hLxcD85eCU2pFhvNPaHkd7BEbjWtaupNbGeAYF8lDqO12hG8vP4gJ/Sp
         ewIMP63ORnxsmGKqTD8PwHoIAP1vozM30PZ9ynItWJZ8DprIeuPVhU+xvji56PMVhUAA
         +6gGDHLKk7VptC1OeBgUOiES1OzAPuQfzPisS+JWQWKW/Tqzshndq4AtcI7kDKykx8bx
         hMOiamSRNKN17TqB4E/nK8hWhc52nL3paCGj+UjZpgqPAUQZ+ivqxd98DjzDJeTaFof5
         sWVY86S/hc5xGXQ4RfwMke16s510FfEFsBnNksYknBhPqoknjr0f1oIbosZpCRXTouAH
         TzxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VQV2R1yVIYkMnMB0sO1Yqc1eECwOX3+9/eQi5iOzhC8=;
        b=AkhdW3UiyyNNe/jrk3jAq6MCBGhiCKEdU5K08fTu8HDI+NlA94FZYS2EOIxJyr8pXY
         S17iO/sGh0lvC/0UllNvbpHAtr9n8IEy5TCEdZJdAVq89FBLFs8ubAD2r8cV/jhIda+y
         Woy1/y2tICsRX3kiEhf/ldsvVpxKFkrjQ/l4RQm8lb/qaRuZE3B6Ivrw910pH52nL6zn
         TmU/cVVCkGWdm+XUdeuVvZe097Ne1fVTndzEyS7ZxfBAx1fPkj0hfCU1HUSaiP8c+NGH
         teJLOCQlfQ8YrbuIZ3msGh10LuN6/n1IxPLQCsVYo+UUWaZr2jxnb8QzvnLBJ5evfV7k
         EGzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sa28si2637289ejb.308.2019.07.11.00.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 00:12:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B1E01AD12;
	Thu, 11 Jul 2019 07:12:46 +0000 (UTC)
Date: Thu, 11 Jul 2019 09:12:45 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hillf Danton <hdanton@sina.com>, Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@suse.de>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Question] Should direct reclaim time be bounded?
Message-ID: <20190711071245.GB29483@dhcp22.suse.cz>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
 <80036eed-993d-1d24-7ab6-e495f01b1caa@oracle.com>
 <885afb7b-f5be-590a-00c8-a24d2bc65f37@oracle.com>
 <20190710194403.GR29695@dhcp22.suse.cz>
 <9d6c8b74-3cf6-4b9e-d3cb-a7ef49f838c7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9d6c8b74-3cf6-4b9e-d3cb-a7ef49f838c7@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 10-07-19 16:36:58, Mike Kravetz wrote:
> On 7/10/19 12:44 PM, Michal Hocko wrote:
> > On Wed 10-07-19 11:42:40, Mike Kravetz wrote:
> > [...]
> >> As Michal suggested, I'm going to do some testing to see what impact
> >> dropping the __GFP_RETRY_MAYFAIL flag for these huge page allocations
> >> will have on the number of pages allocated.
> > 
> > Just to clarify. I didn't mean to drop __GFP_RETRY_MAYFAIL from the
> > allocation request. I meant to drop the special casing of the flag in
> > should_continue_reclaim. I really have hard time to argue for this
> > special casing TBH. The flag is meant to retry harder but that shouldn't
> > be reduced to a single reclaim attempt because that alone doesn't really
> > help much with the high order allocation. It is more about compaction to
> > be retried harder.
> 
> Thanks Michal.  That is indeed what you suggested earlier.  I remembered
> incorrectly.  Sorry.
> 
> Removing the special casing for __GFP_RETRY_MAYFAIL in should_continue_reclaim
> implies that it will return false if nothing was reclaimed (nr_reclaimed == 0)
> in the previous pass.
> 
> When I make such a modification and test, I see long stalls as a result
> of should_compact_retry returning true too often.  On a system I am currently
> testing, should_compact_retry has returned true 36000000 times.  My guess
> is that this may stall forever.  Vlastmil previously asked about this behavior,
> so I am capturing the reason.  Like before [1], should_compact_retry is
> returning true mostly because compaction_withdrawn() returns COMPACT_DEFERRED.

This smells like a problem to me. But somebody more familiar with
compaction should comment.

> 
> Total 36000000
>       35437500	COMPACT_DEFERRED
>         562500  COMPACT_PARTIAL_SKIPPED
> 
> 
> [1] https://lkml.org/lkml/2019/6/5/643
> -- 
> Mike Kravetz

-- 
Michal Hocko
SUSE Labs


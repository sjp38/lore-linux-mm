Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26905C74A3F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 00:25:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1AE320844
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 00:25:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dqi0EsXh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1AE320844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F0E18E009F; Wed, 10 Jul 2019 20:25:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A0C88E0032; Wed, 10 Jul 2019 20:25:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B84F8E009F; Wed, 10 Jul 2019 20:25:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2684C8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 20:25:32 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i33so2171330pld.15
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 17:25:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PSrRRdlZuwCbhrC4BGiP6VbqlB+slyYAJraAbbeTAVc=;
        b=iz6qV4Pu7WU6rRtlv6cdHImm9/fPrUbNd1NSbUwWkTK6OsXzylSVHn8E4a/0ixcvz5
         FNxaetkgGu7KL0fBm2exb5jjRr/4CmSo8UE6M/8J/8iR3F1IBkuVsF0r7O7JvPSclIwS
         hCnZqZNHqPvL9yzTbPYxA1fbcD787Ewv1wWUhuMyK+i1G6eZCBmzGUCMyuynhfVwKlq7
         bL2KH2jEl7P43eWFFAXETIFY8z4NYyr+kQ7p6MREr6BmNxH2h5iJyTiWJp8raEbXfDRW
         SyRyjJipTnAwk717MpY9bctPxaZ5ZSqXRISyDfyqsdERT2XT+2Vp2hznhWCjsRKdUrVl
         i+7A==
X-Gm-Message-State: APjAAAX+Zl/9TnLDqqhoLwK/pYI+U8e6S0ox4tKTSKuejAqmV+KQRkDR
	Ml71X+psbGTLBHYy2veEIkZNo3VPUUoIdL6+0G2weOMzZCi2Xbd2g9SL0FrbabVgzsG4lbDAzm9
	W4Q+DaydIIDzxfiSxEuZItNKnC44IEZ6bRQjC7JLj5TIIqG/zPbeL97X+/4HJbMk=
X-Received: by 2002:a63:24c1:: with SMTP id k184mr1192024pgk.120.1562804731547;
        Wed, 10 Jul 2019 17:25:31 -0700 (PDT)
X-Received: by 2002:a63:24c1:: with SMTP id k184mr1191952pgk.120.1562804730341;
        Wed, 10 Jul 2019 17:25:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562804730; cv=none;
        d=google.com; s=arc-20160816;
        b=jzTc9V8SekNDvRDWILCysGM3j9Di2L3NOTJcP6vC8lOHo1Mk/w4VwWmlISgLWe1qnY
         o7S38sMm6bLP6sXpO9Gku1Ql5ttMG026mzLSoiRRhR9nr7l58qTYaU2u3DEm6nXXw2KA
         mxuDWGvMCY9LQe/p6r9EI5rslgcXIVD+TFnMhTRtZN7VTq4h/2QfJyGdZsSJ768eTgfR
         Lm/RcmiHRXCitg2vtXFCw7UkhawmJLj7ebfI31NkJ4LjZIYjLF+S62fDKlmtbPvuNqZl
         foCsuEd1mbHhiIa+lqYkxwlyhSp8KbcD7Zm8OMjF2+ErYKVujuvK5ogOcapt4fKmMBKh
         o0aw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=PSrRRdlZuwCbhrC4BGiP6VbqlB+slyYAJraAbbeTAVc=;
        b=pE1W1HZLFZ1Wkdu5OpjYOh8Je7LeAd1sR5uym9TwX6NhGBmcPXSA6MU+Iis+5r78Ea
         +oO3gX7iTgBH15DbqJhqmf/S8yLOakDLKZ+T8QSZ+PUqNMs1xDgeCk6bWhJiT0CK8ZYZ
         OEXZbbHSg+51AUvB7dGz2/XBkJhr26xgqzmp1iZCG5Ay/v6OPRIR/3gDQ1DUq2kY3ehr
         U2dudDrg06388gloWOZgwX6x+1fBOhz8YKLqVNbrDLrpLsvOylPoQ5myxYomogNynCrX
         6zPlvm1RibafEqzGxcmE5tiqE4Szqs0NfKP51ouhH/heJaA81FSWykxQLiakgx8Vgy+f
         03JQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dqi0EsXh;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p32sor2071304pgm.1.2019.07.10.17.25.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 17:25:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dqi0EsXh;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PSrRRdlZuwCbhrC4BGiP6VbqlB+slyYAJraAbbeTAVc=;
        b=dqi0EsXhqHhP5K98X2PHRzhIJqAh7Uf6mdAJ2kB12s1CPYVMytMsw0oLnDkGpCSZAK
         XXR8EVrqMiIQG3kKg9YQBlWsotzErD0+O4eIRniG+KLOt+3eRrE0KLAErkWvo6QE2zRZ
         mREN/Mah+yTttDd29Fn7vi06Hm3IytJrK9MMBukNqZEEqfw9FzaLjWpo3r3OrPopS7YT
         sM02a86i/AryiKGUXK1wxsZoBHIsuBqBqzFDeoQNFovViyWduLDOZ9zN9IVfyuXVBrxN
         gUORW28ayC6zatUrswHpC1e1EeESLDyc3yBdmuE3K+GJ87O7nypgGE7gOBI0Dx7yBOzS
         E2ow==
X-Google-Smtp-Source: APXvYqyh0rIS43MPSspgemppfQv0nfmEjAFry/GPnBi51JgdU/Rn2St6WkcieBqjyJtXAPkz9zxifw==
X-Received: by 2002:a65:60cc:: with SMTP id r12mr1166350pgv.333.1562804729591;
        Wed, 10 Jul 2019 17:25:29 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id v138sm3886270pfc.15.2019.07.10.17.25.24
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 17:25:28 -0700 (PDT)
Date: Thu, 11 Jul 2019 09:25:21 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 4/5] mm: introduce MADV_PAGEOUT
Message-ID: <20190711002521.GA71901@google.com>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-5-minchan@kernel.org>
 <20190709095518.GF26380@dhcp22.suse.cz>
 <20190710104809.GA186559@google.com>
 <20190710111622.GI29695@dhcp22.suse.cz>
 <20190710115356.GC186559@google.com>
 <20190710194719.GS29695@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190710194719.GS29695@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 10, 2019 at 09:47:19PM +0200, Michal Hocko wrote:
> On Wed 10-07-19 20:53:56, Minchan Kim wrote:
> > On Wed, Jul 10, 2019 at 01:16:22PM +0200, Michal Hocko wrote:
> > > On Wed 10-07-19 19:48:09, Minchan Kim wrote:
> > > > On Tue, Jul 09, 2019 at 11:55:19AM +0200, Michal Hocko wrote:
> > > [...]
> > > > > I am still not convinced about the SWAP_CLUSTER_MAX batching and the
> > > > > udnerlying OOM argument. Is one pmd worth of pages really an OOM risk?
> > > > > Sure you can have many invocations in parallel and that would add on
> > > > > but the same might happen with SWAP_CLUSTER_MAX. So I would just remove
> > > > > the batching for now and think of it only if we really see this being a
> > > > > problem for real. Unless you feel really strong about this, of course.
> > > > 
> > > > I don't have the number to support SWAP_CLUSTER_MAX batching for hinting
> > > > operations. However, I wanted to be consistent with other LRU batching
> > > > logic so that it could affect altogether if someone try to increase
> > > > SWAP_CLUSTER_MAX which is more efficienty for batching operation, later.
> > > > (AFAIK, someone tried it a few years ago but rollback soon, I couldn't
> > > > rebemeber what was the reason at that time, anyway).
> > > 
> > > Then please drop this part. It makes the code more complex while any
> > > benefit is not demonstrated.
> > 
> > The history says the benefit.
> > https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/patch/?id=d37dd5dcb955dd8c2cdd4eaef1f15d1b7ecbc379
> 
> Limiting the number of isolated pages is fine. All I am saying is that
> SWAP_CLUSTER_MAX is an arbitrary number same as 512 pages for one PMD as
> a unit of work. Both can lead to the same effect if there are too many
> parallel tasks doing the same thing.
> 
> I do not want you to change that in the reclaim path. All I am asking
> for is to add a bathing without any actual data to back that because
> that makes the code more complex without any gains.

I understand what you meant and I'm really one to make code simple.
However, my concern was that we have isolated by SWAP_CLUSTER_MAX(32 pages)
for other path(reclaim/compaction) so I want to be consistent with others.
If you think that the consistency(IOW, others are 32 limit but here 256
limit) is no helpful this case, I don't have any strong opinion.
Let's drop the part. I will add it into description, then.

Thanks.

> -- 
> Michal Hocko
> SUSE Labs


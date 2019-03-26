Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4534DC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:03:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB3182075C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:03:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB3182075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CAC26B0006; Tue, 26 Mar 2019 08:03:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82B266B0007; Tue, 26 Mar 2019 08:03:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CCBF6B0008; Tue, 26 Mar 2019 08:03:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7CE6B0006
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 08:03:32 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c41so5171745edb.7
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:03:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DMGdOS3TCFi7gu3SuWza/u540MkytIhZHI5mq5Gi97c=;
        b=FAxgH7Fj8LeAXyLJsBoeF5F/M8666+AQT/kZLLgwiVgnQTKzWNQfnq+8bjjr2iuWO2
         qnc4//KLL/APEW0xvSi3EiOQhlkt98bYV2aeR78f7Gdx+tt5z04/IFgRNaH74RsFAVg2
         TBc51dh+6kr0dIdn2Rd664bNr0unvn5qjfAMzQw/irUZokIUFUnGIPRcbvCTqlZn9K1N
         pmX9TJqCHl+/6IuZtm41xHK02P7EtPjYLTLO7UqFmwJqkBa1lMy6frnRm5x/XHE0vClq
         3TVj3f4F6H4CWl7vBH5qflK0vB8c+XDJqLOnpmhw5UnUdAh88VC4wUCZGKlry0n2dmTC
         53Rw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAX2B1S/s5wRk+fDW7X5zqA0rQ2vB6/D4YDp5BL9+shooeBMBwgC
	xyMapknWeMES9hh4+mg4APiDfQhDqXTmcVpe8zD1IdJvQmSmX3c0unMkFyrWKVEVypYE8U/KsQF
	hdI6MO7QijBeMFbKLp0lm5FlcOyU6r2KccROEArwBcwnrjm5lAv3UqsE+yUOnk7Oz0w==
X-Received: by 2002:a50:a725:: with SMTP id h34mr10424104edc.201.1553601811690;
        Tue, 26 Mar 2019 05:03:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9ZVEJ4DtY62f+5I3leYzb2CFrhBsaFrbQYjnLYchkAetoo10HpCYKThbyhZ19e1lRe+13
X-Received: by 2002:a50:a725:: with SMTP id h34mr10424048edc.201.1553601810726;
        Tue, 26 Mar 2019 05:03:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553601810; cv=none;
        d=google.com; s=arc-20160816;
        b=U5SOPkVY2t6HXOnkpWCXDZYRekpYcI14IFMzHAwNRjAObmB4/Eiy7MeIp47qivF/Ce
         cUARFgk1i2hRnnIWewDeGRaj6VIpujI0nY/sTM4tTyZIa/RMWGHqno4wYYozOYrkgEzc
         XlXMeQhrvjYQWMPytWy6/g01N3bYajg++TraCZpy1Z/ECo+o17gYehBvHpZ3yFpl9E0q
         WmJGVLFOE0mfU4MqC8T9LaLIK5k22lETtP5H548U6TVQqopS1v5466bJStyRFYpfIfGp
         PN6cr2BHw16fJ5kCZXWoa6H/EuFnNkXUrOayx/vGZCKiACK3CpdiiU2Y4IgfR5A6FzVd
         204g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DMGdOS3TCFi7gu3SuWza/u540MkytIhZHI5mq5Gi97c=;
        b=fm0oIvWVUVnEuj4ya8m1hbc4r9HwB6NR04yVlDqe8/tTCNcKZFoxvmFBXxNvt9OA2E
         WxyM9WQdkhTj4NrDVafqpkSiQwoK4MGHbeq/WW+tSpH5z1dYI2aAel8xatzvQSsvTOD2
         DT8NH641k5aQjhwc+6NSaosuX26MNEddOKMs1ne5ELAOlrq1/jncisZ2XICZyvTNrBQm
         l3wMfhs456l2Vk576gzPlQbArgPfCOxR1m7nYJJwul7RJyGfc72+K5pJClQHsR68QaAT
         FEBx6PS2w3YqQq8wb3BRMNXxdo8rWir7AR8mTR7rnwI2TO3aFsy92h4+10MInricC5ja
         M2dw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id v2si3018152eja.217.2019.03.26.05.03.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 05:03:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) client-ip=46.22.139.17;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id C72C11C2453
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:03:28 +0000 (GMT)
Received: (qmail 6302 invoked from network); 26 Mar 2019 12:03:28 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 26 Mar 2019 12:03:28 -0000
Date: Tue, 26 Mar 2019 12:03:27 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Qian Cai <cai@lca.pw>,
	linux-mm@kvack.org, vbabka@suse.cz
Subject: Re: kernel BUG at include/linux/mm.h:1020!
Message-ID: <20190326120327.GK3189@techsingularity.net>
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
 <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
 <20190322111527.GG3189@techsingularity.net>
 <CABXGCsMG+oCTxiEv1vmiK0P+fvr7ZiuOsbX-GCE13gapcRi5-Q@mail.gmail.com>
 <20190325105856.GI3189@techsingularity.net>
 <CABXGCsMjY4uQ_xpOXZ93idyzTS5yR2k-ZQ2R2neOgm_hDxd7Og@mail.gmail.com>
 <20190325203142.GJ3189@techsingularity.net>
 <CABXGCsNFNHee3Up78m7qH0NjEp_KCiNwQorJU=DGWUC4meGx1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CABXGCsNFNHee3Up78m7qH0NjEp_KCiNwQorJU=DGWUC4meGx1w@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 09:03:07AM +0500, Mikhail Gavrilov wrote:
> > Ok, thanks.
> >
> > Trying one last time before putting together a debugging patch to see
> > exactly what PFNs are triggering as I still have not reproduced this on a
> > local machine. This is another replacement that is based on the assumption
> > that it's the free_pfn at the end of the zone that is triggering the
> > warning and it happens to be the case the end of a zone is aligned. Sorry
> > for the frustration with this and for persisting.
> >
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index f171a83707ce..b4930bf93c8a 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
>
> <SNIP>
> 
> I do not want to hurry, but it looks like this patch has fixed the problem.
> I will watch for a day.
> But the system has already experienced a night without a hang (kernel panic).
> 

Good news (for now at least). I've written an appropriate changelog and
it's ready to send. I'll wait to hear confirmation on whether your
machine survives for a day or not. Thanks.

-- 
Mel Gorman
SUSE Labs


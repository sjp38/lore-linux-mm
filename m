Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B276DC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:18:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7227320656
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:18:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="fLiZ2GSX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7227320656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24B4E6B026B; Thu, 15 Aug 2019 15:18:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D5976B027A; Thu, 15 Aug 2019 15:18:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09CD16B0281; Thu, 15 Aug 2019 15:18:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0102.hostedemail.com [216.40.44.102])
	by kanga.kvack.org (Postfix) with ESMTP id D5CFD6B026B
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:18:12 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7190B8248AB2
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:18:12 +0000 (UTC)
X-FDA: 75825622824.16.scent01_64b474b993e21
X-HE-Tag: scent01_64b474b993e21
X-Filterd-Recvd-Size: 5319
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:18:11 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id t12so3493391qtp.9
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:18:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=nHlPwI6h/V625xmzih5wA+jOZNnzWd66O1xd1ERtpeE=;
        b=fLiZ2GSX7TMO8JVXsK92o5Wv5m0RqWLHrj8ldc6pcgdf/mVcwYJ/SmzfhxHCh6qvro
         Tp/LRTHwR+hPxVCTqHVxXAXjxi6fc4tAfyhR1RyRsyzQVXJLf6Ntpn7unqRmmg7nz9kW
         jQg4Vn7bKCmHHHTEYyQhuMt4hE1kl1GgLUHrAvSjmpQHMZkPhSAdpeG8D7MLw6d1eTu0
         iLXW2FSDnaipUWKPP6u/s2XT76Elan60y6/5YKCGhyTK5HlwouiKXxIOM8dmXH2nI8EK
         tPw4BeR8rwPZ4Eg/haH846mqKyfLdmRwJce0t+H6beAhcQLieFDthvRXszoHBgroe6sR
         UFZg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=nHlPwI6h/V625xmzih5wA+jOZNnzWd66O1xd1ERtpeE=;
        b=qF7asKHI+N2J/297Uqi0t5A+opnTSL1aO1B7aqfmdoF78m6zI/2zNTabqouQ1hMAA8
         ZR3HALlILN25YKo4tYLoyGQ4k3Dj2ywa6ygtaqISAZjm0QzDh51/VDtUXvLUYW0pLGm4
         JhqExSl0J+0Oky9DAk5cEiF442Ci5yfwp/pyPXEBoCZXvn3LB93Lrcg55/BlKtkekFtf
         vSN1/Vw3wqXjK9w43Di+wA/9r2rSHOgZhDDOonH57NPPUAYHDmSQ67WdzcZsQB9mSIvZ
         hZcqx+7BkMnD/G3121KMDXnPnOkyePk7iSzBnwcu6CekEH1anaUDuv4+BlLpqGpAv9i8
         RR+A==
X-Gm-Message-State: APjAAAWosra0BoGxMO1DIlrJo5n1r2ozLEeTttv9D3oneKTJghpxPfCX
	goJARos5Tja3o3v14qmXDFrmxw==
X-Google-Smtp-Source: APXvYqxzyb+MEcFc9EqQdTjnul75yj1R+1XL1BUPttOduKO447Q7xMOa3vPB1CyV2bgIob1IxYc3iQ==
X-Received: by 2002:ad4:45d3:: with SMTP id v19mr4341304qvt.90.1565896691409;
        Thu, 15 Aug 2019 12:18:11 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id h13sm1876510qkk.12.2019.08.15.12.18.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 12:18:10 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyLGE-0007y8-Dp; Thu, 15 Aug 2019 16:18:10 -0300
Date: Thu, 15 Aug 2019 16:18:10 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190815191810.GR21596@ziepe.ca>
References: <20190814235805.GB11200@ziepe.ca>
 <20190815065829.GA7444@phenom.ffwll.local>
 <20190815122344.GA21596@ziepe.ca>
 <20190815132127.GI9477@dhcp22.suse.cz>
 <20190815141219.GF21596@ziepe.ca>
 <20190815155950.GN9477@dhcp22.suse.cz>
 <20190815165631.GK21596@ziepe.ca>
 <20190815174207.GR9477@dhcp22.suse.cz>
 <20190815182448.GP21596@ziepe.ca>
 <20190815190525.GS9477@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815190525.GS9477@dhcp22.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 09:05:25PM +0200, Michal Hocko wrote:

> This is what you claim and I am saying that fs_reclaim is about a
> restricted reclaim context and it is an ugly hack. It has proven to
> report false positives. Maybe it can be extended to a generic reclaim.
> I haven't tried that. Do not aim to try it.

Okay, great, I think this has been very helpful, at least for me,
thanks. I did not know fs_reclaim was so problematic, or the special
cases about OOM 'reclaim'. 

On this patch, I have no general objection to enforcing drivers to be
non-blocking, I'd just like to see it done with the existing lockdep
can't sleep detection rather than inventing some new debugging for it.

I understand this means the debugging requires lockdep enabled and
will not run in production, but I'm of the view that is OK and in line
with general kernel practice.

The last detail is I'm still unclear what a GFP flags a blockable
invalidate_range_start() should use. Is GFP_KERNEL OK? Lockdep has
complained on that in past due to fs_reclaim - how do you know if it
is a false positive?

Thanks again,
Jason


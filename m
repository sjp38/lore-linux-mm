Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 512C3C10F0B
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 01:06:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0147A2177E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 01:06:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="XVhxodS/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0147A2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 821648E0003; Tue, 12 Mar 2019 21:06:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CEFA8E0002; Tue, 12 Mar 2019 21:06:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BF998E0003; Tue, 12 Mar 2019 21:06:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38EA78E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 21:06:37 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id s12so30966oth.14
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:06:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LZK3UMA0+jcYLH9GlOc1de7OArJB5HWUsfhSIV+qw/o=;
        b=KEyyH1TJkwT+rBi/cy4duH6JvL4A+8x17CjnErzKCLoGnsndDWMV+eN+iOEhH2mAIJ
         w+2WYw3CkKwd1CriGJKAjeb1URz+cFox0lGyTkLzQdqvHPfKs/sxjwCfeWngRH3W12k6
         Wh5l3Ai6Zww58JjIX97ZRsqjnCb2Y1pjfyG4093Af5k8bUMVXlMMlF50M7GF/gArarDR
         fqvRwdPWIYAWPpnxOjQAn4gc3qkmlKesFjbHJLiMgGD7LNmxrfGzw8NCIZfDWi3KLeNF
         MVBR7bHl/MF99SIbLMFWZlNIVyyGt47RTnYri7YZpK7S8QKr89MUO7fYT+hNUzZf3GVC
         yRcA==
X-Gm-Message-State: APjAAAVVRY5/OppmvXFEK1Y5PncMi32lbUacV8O8o+9xdCw2aAnJ15ul
	oBn97QXrKJmC+OFu1LEhlD744LXo+TfX0VrlAVVoLoqH0H/saHJhdVzi4PSHrPGqInjnqZR2ktM
	UeWUitJ54mEGXCgugNyMQohVWL+D1IRHk22/Q6QTqqeADhH+Ay6VMukynZ/t2HRikmoRYlK8PS+
	xWifbBu0vEpLWT5bs5PZiPbT6m/gFpi70dJXLqkDXPG3r3DODIGVjD3hVVgqljdlNHSREAHOCPp
	3GayXmH5mChkZU275ssoTpFa5u8DdRQCN8z81I9jm/ETvRxQYHWbNEmLLKHHjHHWDjua4ExDOrw
	+M0nL8fBtF8J0uUQNQZOjzQGu0Nk2zLnHgmH1mwjw8FyTl4HmR4pzxLpr+jTza9N7A5URY2j7BD
	l
X-Received: by 2002:a9d:6515:: with SMTP id i21mr27117927otl.325.1552439196748;
        Tue, 12 Mar 2019 18:06:36 -0700 (PDT)
X-Received: by 2002:a9d:6515:: with SMTP id i21mr27117889otl.325.1552439195751;
        Tue, 12 Mar 2019 18:06:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552439195; cv=none;
        d=google.com; s=arc-20160816;
        b=hh3ueNfeY7yn4p929wP7WJV7kb6/P9Cte6MiGzqvyCx3RoSfxzteX8+3WU3diI6beY
         5CjkN0qsbyIfCGCUmfw0XoVKOmmqyGWV2UqkcWbbSbEMJRzPMAKcmcjOM9ycuhOdPx1O
         GZuk1W5hGVA0urq9SB0ZRVGQQS1zFCRePJoVaiSdLs1AduRAHt12JvpbJhGhq7Sue7RE
         0MIUBUgSIUiWsFjutL7OmbWHSVaNp5eV4k9Q6rJ9z6YMP6nrVQAv86NTpNmujVuntNtT
         8kKca5H+WHGFqm9m4hNcN+qGSmzbip7gUUd2aeZo9++xPvboBwD9pZX8XMZs4Vjs/3bx
         MrDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LZK3UMA0+jcYLH9GlOc1de7OArJB5HWUsfhSIV+qw/o=;
        b=weueKtH49Svb9MxHjUU+CnT9VHMWTYbBtJjkdmU+QQEo2oP9K+bZDalge1rE8UXx6w
         3hCGsFx9385baCN8GoPxnCTSHbKSBvHSwju3w3s6rngtz8dQsxcXlaE/G0HhexvpI/o1
         cbMUg/j8n7yMRVdTrQyZiK8qYuwypP2U6T0ScQKKPwRSvgMEUjh9I/buGSz4tHIojOwG
         pKLkHnIFGSTiyMesk4FZNDapfLP3AY9QsWvBn+02RHHW9+wdH1G/bClXLDocBf7gxF2P
         j2A0GCzOhAO8M75Jg9vJL1+OHeDvZc3RnDjq5YTedyctc3A0PaEluiV4o++pth8Dj2Ij
         4aOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="XVhxodS/";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k7sor5459512otj.158.2019.03.12.18.06.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 18:06:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="XVhxodS/";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LZK3UMA0+jcYLH9GlOc1de7OArJB5HWUsfhSIV+qw/o=;
        b=XVhxodS/cWi1+Kj0zcuMgBSdNtgToQjq+8zyn9JVumzlZtbH0+u3oMW5gy/suWMBp7
         cJ/u6/9rAbYc03wFDmk2ca7iID5lAsbN5R+aWhjKEKe5Wpxfayck71YUPVAqqqigj58O
         WAvR7oAPg7Nmo0R8A0sgLCcDrruerUv+Ib4vukplAt7U4DfYdh+NpbYxLtTY4KftS4Pv
         4Cevpn9yEX0quULptFuWBkXtcIa+Bu0J6JWXggDCI79WzhwglU0r5DO8RfAnGdzdvXCk
         JhhzmvjVws2VsBBbqDzbxyoF8nU1mYSD/my4iNqwGoExV/cBrWu83WZza99ubsFkNqhd
         rqRg==
X-Google-Smtp-Source: APXvYqxsMNMGK6e/Fpi42NFWPK3QTmiBgY/COyLYD70QTD/njfoKOA8X+IxFRFTr7yYcjC2F5nme4fECbkh7IFz9I0M=
X-Received: by 2002:a9d:7a87:: with SMTP id l7mr25469024otn.98.1552439195041;
 Tue, 12 Mar 2019 18:06:35 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
 <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
 <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
 <20190307094654.35391e0066396b204d133927@linux-foundation.org>
 <20190307185623.GD3835@redhat.com> <CAPcyv4gkxmmkB0nofVOvkmV7HcuBDb+1VLR9CSsp+m-QLX_mxA@mail.gmail.com>
 <20190312152551.GA3233@redhat.com> <CAPcyv4iYzTVpP+4iezH1BekawwPwJYiMvk2GZDzfzFLUnO+RgA@mail.gmail.com>
 <20190312190606.GA15675@redhat.com> <CAPcyv4g-z8nkM1B65oR-3PT_RFQbmQMsM-J-P0-nzyvvJ8gVog@mail.gmail.com>
 <20190312203436.GE23020@dastard>
In-Reply-To: <20190312203436.GE23020@dastard>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 12 Mar 2019 18:06:23 -0700
Message-ID: <CAPcyv4htpVHm9GSYdKS=i4Ry011XZQUkOdMz9CXMrxJccRW9tw@mail.gmail.com>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
To: Dave Chinner <david@fromorbit.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 1:34 PM Dave Chinner <david@fromorbit.com> wrote:
>
> On Tue, Mar 12, 2019 at 12:30:52PM -0700, Dan Williams wrote:
> > On Tue, Mar 12, 2019 at 12:06 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > > On Tue, Mar 12, 2019 at 09:06:12AM -0700, Dan Williams wrote:
> > > > On Tue, Mar 12, 2019 at 8:26 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > [..]
> > > > > Spirit of the rule is better than blind application of rule.
> > > >
> > > > Again, I fail to see why HMM is suddenly unable to make forward
> > > > progress when the infrastructure that came before it was merged with
> > > > consumers in the same development cycle.
> > > >
> > > > A gate to upstream merge is about the only lever a reviewer has to
> > > > push for change, and these requests to uncouple the consumer only
> > > > serve to weaken that review tool in my mind.
> > >
> > > Well let just agree to disagree and leave it at that and stop
> > > wasting each other time
> >
> > I'm fine to continue this discussion if you are. Please be specific
> > about where we disagree and what aspect of the proposed rules about
> > merge staging are either acceptable, painful-but-doable, or
> > show-stoppers. Do you agree that HMM is doing something novel with
> > merge staging, am I off base there? I expect I can find folks that
> > would balk with even a one cycle deferment of consumers, but can we
> > start with that concession and see how it goes? I'm missing where I've
> > proposed something that is untenable for the future of HMM which is
> > addressing some real needs in gaps in the kernel's support for new
> > hardware.
>
> /me quietly wonders why the hmm infrastructure can't be staged in a
> maintainer tree development branch on a kernel.org and then
> all merged in one go when that branch has both infrastructure and
> drivers merged into it...
>
> i.e. everyone doing hmm driver work gets the infrastructure from the
> dev tree, not mainline. That's a pretty standard procedure for
> developing complex features, and it avoids all the issues being
> argued over right now...

True, but I wasn't considering that because the mm tree does not do
stable topic branches. This kind of staging seems not amenable to a
quilt workflow and it needs to keep pace with the rest of mm.


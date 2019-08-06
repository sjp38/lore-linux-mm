Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9473DC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:11:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B00020C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:11:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B00020C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB4256B000D; Tue,  6 Aug 2019 07:11:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3D8A6B000E; Tue,  6 Aug 2019 07:11:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B066F6B0010; Tue,  6 Aug 2019 07:11:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD106B000D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:11:13 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so53663278ede.0
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:11:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qtv/snZ1P6q9N2i4DZ0PccndAbkpjqByTN0OL6qFyZ0=;
        b=Y0R7y7qMgWu/dXnhBOvT5XDvVe/1vbvRuqo1rMj8cpe1NYL7VNx1Wy4DyCO7aMqBk4
         E8qi0KSkvjNf9CsNW0XREnS/WjpSf1YI3MY0gS4CKlk1DFAWVqBr+6au+W9WLsS+eh/L
         snM+VdW/ydf7GQTHBD34FAFvNrUebRq/oBf7oDkWkvwjH9OMDbeKJLOY9nZBuQQHdFws
         NXDGHisnb4Bx2WIE3J7cz85Ma/T0R2Gx9FJcNbW+1lUEsvq0JXIF0bi8/7XBK8CDqIqk
         tKNZa/ZpfD0+gQhn0a7qK9EfWDENV1XKBarENBjh0YtFI511Po2QT9k92pBR0/SUWSgK
         LuUA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVu6kzA+8Z1DsW4lYS5XLTbb365x747KQsRbBISLc7zQ+jUVO3U
	QYgXA4/iXV818zsA8QgDsxtsxT4Nq8BlKKHuCQadAMIFL1X9UeBIJ/DjBoKnTxyXQvG408f3O1a
	DPMUSn4I5qCk8n+gItR2fT4lSqADz2d52pyi8X0No8amrYMLW3GeGmE/B1nQW/fU=
X-Received: by 2002:a50:eb96:: with SMTP id y22mr3146270edr.211.1565089872980;
        Tue, 06 Aug 2019 04:11:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwy0k/jgoUQBOLDgalCzFBiRDMbUuun+63JJMHbZDPn3uSbogMCgpxlsN1yvBS8P5ZSXl2l
X-Received: by 2002:a50:eb96:: with SMTP id y22mr3146215edr.211.1565089872314;
        Tue, 06 Aug 2019 04:11:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565089872; cv=none;
        d=google.com; s=arc-20160816;
        b=vpwBXwFBDj7G8mT04kF1vln1JvbHK5dlMQCXONPZL6uOu7pSaeZbStT4c9xzlvtjcd
         jU2+5tJiXVGMHa/rpTuK6yjTWHuPGlCyiVJj8J1+Zmo0QamWBmuVfs1kPnS+/wvqtK4R
         HXFyQNKtPIFfE7XyemQbkJLhxNrSqsd/Eszr9L7qaxWx7FFvjbSIaXfE496W9DWBlWvc
         6ql2Zyt5AwCg9SWI3KYs4KB8hBOJrRAPxz8luvuGG8VqlzLXIvirVN2QZnq6stu9JBbV
         mKnVYWqZFKzZfq835e966eNEsJRzY0onnQXOXdDqLrf/KJCShtZNwLgKvAc0Hk/4MBZJ
         LfRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qtv/snZ1P6q9N2i4DZ0PccndAbkpjqByTN0OL6qFyZ0=;
        b=DanHJGAWVTAP7+cK6NfB8gEHdI43xGsVpLs6ZaPLz8t70yRg0FKPLw6bkUD7AOeWlF
         8DmwMcEIhKGgUAyIFaJ/Eadr8lUW7YJHfbIHd7FgBBYLFCQdxuTrvAqr3I6o+xlYIEcl
         mWSGmi9C5r9YnA/ug0saLAwJRMzRydAcbA8ZdkFYFQUQ7NhRwVuoLC684/vgwbHAgjO2
         jh12RNlsxz/F+DaEe0mPUr3oW4+jdgJg39iAyIUavjjgg3QYItZdEvwBGZ3qdLEBnTSC
         JrNqR77gU+lzH7j0/tQObsgfCL0616M+d0RoEqRyVcixN0csduQOD2I2IGuH0/+6NofP
         dScA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qt9si28103557ejb.283.2019.08.06.04.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 04:11:12 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DB69CB629;
	Tue,  6 Aug 2019 11:11:11 +0000 (UTC)
Date: Tue, 6 Aug 2019 13:11:09 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: kernel test robot <oliver.sang@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>, lkp@01.org
Subject: Re: [mm]  755d6edc1a:  will-it-scale.per_process_ops -4.1% regression
Message-ID: <20190806111109.GV11812@dhcp22.suse.cz>
References: <20190729071037.241581-1-minchan@kernel.org>
 <20190806070547.GA10123@xsang-OptiPlex-9020>
 <20190806080415.GG11812@dhcp22.suse.cz>
 <20190806110024.GA32615@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806110024.GA32615@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 20:00:24, Minchan Kim wrote:
> On Tue, Aug 06, 2019 at 10:04:15AM +0200, Michal Hocko wrote:
> > On Tue 06-08-19 15:05:47, kernel test robot wrote:
> > > Greeting,
> > > 
> > > FYI, we noticed a -4.1% regression of will-it-scale.per_process_ops due to commit:
> > 
> > I have to confess I cannot make much sense from numbers because they
> > seem to be too volatile and the main contributor doesn't stand up for
> > me. Anyway, regressions on microbenchmarks like this are not all that
> > surprising when a locking is slightly changed and the critical section
> > made shorter. I have seen that in the past already.
> 
> I guess if it's multi process workload. The patch will give more chance
> to be scheduled out so TLB miss ratio would be bigger than old.
> I see it's natural trade-off for latency vs. performance so only thing
> I could think is just increase threshold from 32 to 64 or 128?

This still feels like a magic number tunning, doesn't it?

-- 
Michal Hocko
SUSE Labs


Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BB47C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:44:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0910520880
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:44:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0910520880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 791DE6B0005; Tue,  6 Aug 2019 07:44:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 741B66B0006; Tue,  6 Aug 2019 07:44:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60A136B0008; Tue,  6 Aug 2019 07:44:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1428E6B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:44:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l14so53734813edw.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:44:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=M7xwBBk2ijoFEX0YRfTFXOfgVxiJM6mtXulCPGec2C0=;
        b=b+8gGnh/eHW/axYQl41e0QpYfQiiQQdRMH5YWG6HHy0773t3C2zDejGstXG9nrzwWs
         Mdw7LtqjanA/MZx6oT/++1UvH2+xjROZobLuGpEuI7Chk05tYBAZEoP+nOymgP3DGSbH
         8pR+P2+KWuYp1mbKMwox8dG168wgCxf4hPEylqEx0XxvAYYjlgG/2QnBnO2DqevdZ1cd
         J/6pqIOolPArOnWTd9OXtg/WxeQWZLDk+sA0x2Q77L5NpYgFWgUo62uxjCVhDJFd6SzP
         Fw+v9uZ7jO2xAEXCrPoKrgf4aBWRky8/ZJ9CgwZpGRfXQf0n7d3d0vZklY2xb1vumgxT
         WBog==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXC8HMAwaRKxbYB0f84pzOwGw9/FHETq5za9I03Q/Pv1u5+K08H
	GVe8BWA45Sh8MuwdnmjqEEdOM1cW4VgVRuBdi6AEotzlFsaVPpkq8EQLhq6l0XU/q3tGnzEK+Cm
	R2oP1SBM8/J8jsNq+HYF/FqAVNB7m205lXicBnBn5ZCWwG8onDh3qFPcAL1/NyRM=
X-Received: by 2002:a05:6402:1707:: with SMTP id y7mr3232848edu.223.1565091845632;
        Tue, 06 Aug 2019 04:44:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybxebJxrLsmIdQmbcUig8iHeOnsvJkzFc4fxK/2vSuYKljmZMxxAOY5HtEWhYOMQdubGFD
X-Received: by 2002:a05:6402:1707:: with SMTP id y7mr3232803edu.223.1565091844939;
        Tue, 06 Aug 2019 04:44:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565091844; cv=none;
        d=google.com; s=arc-20160816;
        b=Z9Zk2WsGxNKvxkQLmmHEZY61AtVUR5S0Pj+ZgI7Ka7gJdlDWx0yPAnO/sJtGGL5k8D
         4pnfdzoTvuDpU7iHmAPoopuV8/b5alZU6ukYprm80kVREJmIP+IhOnScVhFjebXhSVWb
         PiMqjQO2YXHLStXeF3HUo8d2zqaBOvpXKIy8V0taFwQTPOinaCJ93/M1m07NYBBl/b44
         Ax1ywNTBY+oodMZy8IKBz3jvBEM51yS363SAQeLG7boeFfa1B3lPDEazPrU5ZQR2/XJH
         oYUUOJdtZOtX/NK272M85/+jol1JWzUxzLjrM5qh72eXnKCyQFj7cKhQnna5qrEKKckm
         Ug5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=M7xwBBk2ijoFEX0YRfTFXOfgVxiJM6mtXulCPGec2C0=;
        b=GG4Jw0wZTcivlcll89OQo3PiRaYnvDe5cUfHvv7og1BypN7iRcviS4vhipynM0BMbl
         +VEz/hxSP1lj6Pl3c8jtzRq6sckvGQ6Z/9LcDWGHN/gK4qsYgJDsoQcWhfCdQLQbcOnc
         VN55X25cPIulDmVeOxDxJPSiO5A8kGDY0OAJRf9zXJ1T4GHNGPe/6KxqkvqojQzAbnx7
         PQMjWhUKhkeWM0LyMVUj/8y2+rOMAHWmnYHgUAZ/N5oSp4ad/bKW9k3GeQeMjPiEwoYU
         DbzX9r8zD8DVT1YmKRweWL4qYWdm3Ju0cXygKYqjufe0kabgXDgN2ztRuQ/jR1CwPr2x
         uFhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x48si32613297edm.225.2019.08.06.04.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 04:44:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0656EAF59;
	Tue,  6 Aug 2019 11:44:04 +0000 (UTC)
Date: Tue, 6 Aug 2019 13:44:02 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, minchan@kernel.org,
	namhyung@google.com, paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 4/5] page_idle: Drain all LRU pagevec before idle
 tracking
Message-ID: <20190806114402.GX11812@dhcp22.suse.cz>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-4-joel@joelfernandes.org>
 <20190806084357.GK11812@dhcp22.suse.cz>
 <20190806104554.GB218260@google.com>
 <20190806105149.GT11812@dhcp22.suse.cz>
 <20190806111921.GB117316@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806111921.GB117316@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 07:19:21, Joel Fernandes wrote:
> On Tue, Aug 06, 2019 at 12:51:49PM +0200, Michal Hocko wrote:
> > On Tue 06-08-19 06:45:54, Joel Fernandes wrote:
> > > On Tue, Aug 06, 2019 at 10:43:57AM +0200, Michal Hocko wrote:
> > > > On Mon 05-08-19 13:04:50, Joel Fernandes (Google) wrote:
> > > > > During idle tracking, we see that sometimes faulted anon pages are in
> > > > > pagevec but are not drained to LRU. Idle tracking considers pages only
> > > > > on LRU. Drain all CPU's LRU before starting idle tracking.
> > > > 
> > > > Please expand on why does this matter enough to introduce a potentially
> > > > expensinve draining which has to schedule a work on each CPU and wait
> > > > for them to finish.
> > > 
> > > Sure, I can expand. I am able to find multiple issues involving this. One
> > > issue looks like idle tracking is completely broken. It shows up in my
> > > testing as if a page that is marked as idle is always "accessed" -- because
> > > it was never marked as idle (due to not draining of pagevec).
> > > 
> > > The other issue shows up as a failure in my "swap test", with the following
> > > sequence:
> > > 1. Allocate some pages
> > > 2. Write to them
> > > 3. Mark them as idle                                    <--- fails
> > > 4. Introduce some memory pressure to induce swapping.
> > > 5. Check the swap bit I introduced in this series.      <--- fails to set idle
> > >                                                              bit in swap PTE.
> > > 
> > > Draining the pagevec in advance fixes both of these issues.
> > 
> > This belongs to the changelog.
> 
> Sure, will add.
> 
> 
> > > This operation even if expensive is only done once during the access of the
> > > page_idle file. Did you have a better fix in mind?
> > 
> > Can we set the idle bit also for non-lru pages as long as they are
> > reachable via pte?
> 
> Not at the moment with the current page idle tracking code. PageLRU(page)
> flag is checked in page_idle_get_page().

yes, I am aware of the current code. I strongly suspect that the PageLRU
check was there to not mark arbitrary page looked up by pfn with the
idle bit because that would be unexpected. But I might be easily wrong
here.

> Even if we could set it for non-LRU, the idle bit (page flag) would not be
> cleared if page is not on LRU because page-reclaim code (page_referenced() I
> believe) would not clear it.

Yes, it is either reclaim when checking references as you say but also
mark_page_accessed. I believe the later might still have the page on the
pcp LRU add cache. Maybe I am missing something something but it seems
that there is nothing fundamentally requiring the user mapped page to be
on the LRU list when seting the idle bit.

That being said, your big hammer approach will work more reliable but if
you do not feel like changing the underlying PageLRU assumption then
document that draining should be removed longterm.
-- 
Michal Hocko
SUSE Labs


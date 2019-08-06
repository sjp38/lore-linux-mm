Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81756C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:10:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A3DA20818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:10:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A3DA20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C05CC6B0003; Tue,  6 Aug 2019 10:10:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB6CF6B0006; Tue,  6 Aug 2019 10:10:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A57F56B0007; Tue,  6 Aug 2019 10:10:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 56E766B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 10:10:04 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c31so54045991ede.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 07:10:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Gx41ZMg0//phFLDjHBZyZ1xbTAuE05DSPUqWAaNSjbw=;
        b=GNwCzO/DgYahSQAFZNh2UlZfNtCM2IRaudToqk+wwT6Gchgc75rXBHQiwFMVbIengk
         uL5HHvNuMZ89lCJLxCx1Deb5UqIAl1TF4MJ2AD1xfrq/5NaZ1EWpNJZAgT8XpLeG45A/
         H/NX63xZvN+OhiTz87TjlFLFAdyG7ylHR3f5RnQDdpfpYrJU8hgAmhPTxQ5hN3KqQ7bp
         YAwhw84RUYs+Xw/x6S+44Fk8Qqo0K1LxRwphPIYvbkbrvJsceZzhvDXcqaN3nARDup47
         q498k6T6pJkWjShXQI9UjVvWxLZR/v31Zsyl1eNxmvY8u8zZAnk66mqHLlzBX9phxuyx
         jihQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXo6VLvJuf5Z8kcsfsE5mxq0JdlF5atMN/00dMK8nq8E5rWJri/
	25a7YPATt00SzjZ75AJDN2A3TDShARxHysomUxQE2ctttt6ug43F6aaRx5k7qkFza7phgLhnPxj
	kirxZTcUPvvITqwaHhk8JEEs08b89KPwgE61uvDA1O9aDGLMKvK8mhoXxIFwon9I=
X-Received: by 2002:aa7:c49a:: with SMTP id m26mr4148396edq.0.1565100603921;
        Tue, 06 Aug 2019 07:10:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGA5BMNa7krZGtKyRGjNI/bfAZjX6AjufhXOnW/w0HQab0gmEoLT5vjc1b2n9aLtQzXtHP
X-Received: by 2002:aa7:c49a:: with SMTP id m26mr4148322edq.0.1565100603167;
        Tue, 06 Aug 2019 07:10:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565100603; cv=none;
        d=google.com; s=arc-20160816;
        b=0IKtE+srTv78QupP45R1NwdU9+qZhtRr2a3t+e1VwqpqJW+SjmaXLDZw2j5m2X0n5O
         Ku1pTie8oCAR+2GZMRKC+fQpKxNCSkgs+DEBXmPTZVF5yB6RTZlDVzkhIiSlU58aAJJL
         CJhxxTKWBv2ScuUqJ6Dm9/gEF7tQ1j32hMWdiFD2Qgjzn8u2GIuVQbbcq9YrqxRzFQ7p
         CTHOk1uO8wqlHSB8GVShP2s5hE02UKg09fMkjqa2dFmY+Iq5jFA7O206vT0iyWh6BYhw
         GuKCBV1T5Ys7MARhNSRol0OkawCaGqqSwg1TAc6IKuDwGfMpBQ9qtAdEk2kU9g7OcRbF
         ACBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Gx41ZMg0//phFLDjHBZyZ1xbTAuE05DSPUqWAaNSjbw=;
        b=pUcpNNTajGbHcj94jvo7S7uWg06Xnohs6O8SYkA3hjDl+wb1d8ZalOBHH8yVjkDS1p
         xe5ObdmbtTex9w42z24MnTcIxPoTJE9uraMcwmzODw5Ruxf1X6YZR0Zc1zfRierftk9T
         LBTbimiC9GxUv3p99DZ7ILbLASJ+Rl71uxSierr7OXIXxkv5Gm39/CQDWWRq+tUVDGCx
         pmm+PiU7nr4kDhRzaR6QSgve0bKxMWcjKvGGOIFZodFT8cXdmYwyJh7+TZNxwMvO9vWk
         p4kNr/BMQldIqrK9ZzelupLbSGH+A+dsMtRP7c+nIX76cqfoeDsVCJpuCymVyjWvBRhH
         44rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w1si30401785edc.440.2019.08.06.07.10.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 07:10:03 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 01A6BAD43;
	Tue,  6 Aug 2019 14:10:01 +0000 (UTC)
Date: Tue, 6 Aug 2019 16:09:59 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, Robin Murphy <robin.murphy@arm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
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
	Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 3/5] [RFC] arm64: Add support for idle bit in swap PTE
Message-ID: <20190806140959.GD11812@dhcp22.suse.cz>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-3-joel@joelfernandes.org>
 <20190806084203.GJ11812@dhcp22.suse.cz>
 <20190806103627.GA218260@google.com>
 <20190806104755.GR11812@dhcp22.suse.cz>
 <20190806111446.GA117316@google.com>
 <20190806115703.GY11812@dhcp22.suse.cz>
 <20190806134321.GA15167@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806134321.GA15167@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 09:43:21, Joel Fernandes wrote:
> On Tue, Aug 06, 2019 at 01:57:03PM +0200, Michal Hocko wrote:
> > On Tue 06-08-19 07:14:46, Joel Fernandes wrote:
> > > On Tue, Aug 06, 2019 at 12:47:55PM +0200, Michal Hocko wrote:
> > > > On Tue 06-08-19 06:36:27, Joel Fernandes wrote:
> > > > > On Tue, Aug 06, 2019 at 10:42:03AM +0200, Michal Hocko wrote:
> > > > > > On Mon 05-08-19 13:04:49, Joel Fernandes (Google) wrote:
> > > > > > > This bit will be used by idle page tracking code to correctly identify
> > > > > > > if a page that was swapped out was idle before it got swapped out.
> > > > > > > Without this PTE bit, we lose information about if a page is idle or not
> > > > > > > since the page frame gets unmapped.
> > > > > > 
> > > > > > And why do we need that? Why cannot we simply assume all swapped out
> > > > > > pages to be idle? They were certainly idle enough to be reclaimed,
> > > > > > right? Or what does idle actualy mean here?
> > > > > 
> > > > > Yes, but other than swapping, in Android a page can be forced to be swapped
> > > > > out as well using the new hints that Minchan is adding?
> > > > 
> > > > Yes and that is effectivelly making them idle, no?
> > > 
> > > That depends on how you think of it.
> > 
> > I would much prefer to have it documented so that I do not have to guess ;)
> 
> Sure :)
> 
> > > If you are thinking of a monitoring
> > > process like a heap profiler, then from the heap profiler's (that only cares
> > > about the process it is monitoring) perspective it will look extremely odd if
> > > pages that are recently accessed by the process appear to be idle which would
> > > falsely look like those processes are leaking memory. The reality being,
> > > Android forced those pages into swap because of other reasons. I would like
> > > for the swapping mechanism, whether forced swapping or memory reclaim, not to
> > > interfere with the idle detection.
> > 
> > Hmm, but how are you going to handle situation when the page is unmapped
> > and refaulted again (e.g. a normal reclaim of a pagecache)? You are
> > losing that information same was as in the swapout case, no? Or am I
> > missing something?
> 
> Yes you are right, it would have the same issue, thanks for bringing it up.
> Should we rename this bit to PTE_IDLE and do the same thing that we are doing
> for swap?

What if we decide to tear the page table down as well? E.g. because we
can reclaim file backed mappings and free some memory used for page
tables. We do not do that right now but I can see that really large
mappings might push us that direction. Sure this is mostly a theoretical
concern but I am wondering whether promissing to keep the idle bit over
unmapping is not too much.

I am not sure how to deal with this myself, TBH. In any case the current
semantic - via pfn - will lose the idle bit already so can we mimic it
as well? We only have 1 bit for each address which makes it challenging.
The easiest way would be to declare that the idle bit might disappear on
activating or reclaiming the page. How well that suits different
usecases is a different question. I would be interested in hearing from
other people about this of course.
-- 
Michal Hocko
SUSE Labs


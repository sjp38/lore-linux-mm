Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8708C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:20:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85A7821872
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:20:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="WLX9eAV+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85A7821872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14A9B6B0007; Tue,  6 Aug 2019 11:20:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FC6E6B0008; Tue,  6 Aug 2019 11:20:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2BEC6B000A; Tue,  6 Aug 2019 11:20:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC7656B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 11:20:05 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r142so56033163pfc.2
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 08:20:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DLr/S8jU71563TTjt3V9DdQkFNfZZ9GpEDLqJqyThL8=;
        b=ddfobbOHnU5cfniZjtJF9Ozzl2UfVu5dS3DP97fZZ0tjxV8CbvoE2GFMGEyvwBMqLX
         2QQyA96ah+P1LfsdKHiObH5aL4QLrWK9tjUlArczZyPv81yfH76kAch61sDLrUkLfLtw
         RUEXVbMX5l5A2x12GzKKjZ0xxa6r4bCI2/wkLfLzs/P9r9ba9m+UQMeiGf0UkuaPCSoJ
         iLlWEVS3Icrpk6JOt0W9xGFDd+pXyfGPJrDMrzDgC0n3AH3qYG80JEiKQEJMWaH8d5oZ
         /e95hA56zJ2WfBNqrFlaKn1WRFKLPQGtIe3AbVhqJr+m/2Wt6zddRo0tW1LwKFH8iuL9
         hgVw==
X-Gm-Message-State: APjAAAUe6Kcl2gAjEAZiJlDmiW+bwRWBF3wuC7aM84m4MtltZdQRGkJ/
	EyOpB+kcwJJWYcf5ecaY6o6WKHQvzLfTKnld1POcrTSr9XEy6t+btmnflLU+Y9QyL9yS5ml9etB
	k3WUfBDfzpNx33Mk55UX9GyDx8I0W5Inv3+yVwqFoYiKWQEx3nZGMIADFt36Ukhvf9w==
X-Received: by 2002:a17:902:467:: with SMTP id 94mr3675951ple.131.1565104805363;
        Tue, 06 Aug 2019 08:20:05 -0700 (PDT)
X-Received: by 2002:a17:902:467:: with SMTP id 94mr3675855ple.131.1565104804472;
        Tue, 06 Aug 2019 08:20:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565104804; cv=none;
        d=google.com; s=arc-20160816;
        b=gXOb/ACU2iwX2YzZY33vmjskKPiX6s9YINE1GwIzr0sr1Y7e8JxVbi4hQqf2ILEGE6
         IsvNkfxkXVtX8rSqXWam4hcgHJy1WUCOOjh9ZLvmqqdim4OyykZS5NVjer2NohzXIwB5
         bBOMK0NL7yFUn+swRnhnfQ472Rkqg5nNeU+P7Ygkd+fQ44W75JfNPdeJkqTJBpTtTvyL
         xFSQcB09RukNzbFisf9MBHZ1ufDMEVFMrWpUCyh+qKDdW4dzqUgFMds4y2j2bhOAhGBl
         i1mAQRrmchBwRKSRlLk3Q+Wllf6AUNjoDLhzqWmOzXXsFpMN2PAiqJarUDXGk+LwooA0
         2Ggw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DLr/S8jU71563TTjt3V9DdQkFNfZZ9GpEDLqJqyThL8=;
        b=ZsSGo3exCyrycj70ZYOTcmKQzAFd8iWc/tyClWRYG7ZUoyl3jZjT1EMGkesAbon+4b
         p2YUJkgdSr2NTkOvR89JA6LtRecvP9vf7U8ubI4grZDdUeJaueH6ZjbI+Hxaq1ybX8hc
         FJn0qxYyMnetszm5V3Yu7O38j2wTBXliGE2Ui6xBgnSbtMKlZflmFRDEniRI4eiwiCx4
         3i4PFVqZzd6xmK0laRmM3uzXFuAtoIlWtVZr9QKR4AphJFFNhWYzB6zvs8LUNhO1Pj50
         TIqwgmQiNrXjTkkvmPuo1MVDc837zn/nx2IuKsY0lJYgVezgVn8em2h+Ktgxhb+fxOmI
         bITg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=WLX9eAV+;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q62sor24642697pjb.10.2019.08.06.08.20.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 08:20:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=WLX9eAV+;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DLr/S8jU71563TTjt3V9DdQkFNfZZ9GpEDLqJqyThL8=;
        b=WLX9eAV+Do9txkuh9FQp3qtI2mkb3uS6AWtl5v+D2s68dxeCFgLT8Mu0dlFrU308LQ
         sC+N27xnuwSrtm+Fkx/n/0WT6ocS2hECqVMaOg2jUc5fvRrC59LIGmFPN9Vp9gF1OGo6
         EbYSi32+OEJ6Oq5K3W2+BSQeACoJmAG4Q1XEU=
X-Google-Smtp-Source: APXvYqxVQuc55AKHRFXAeMJAi3UPCUUUsl8H3gf0xO9Gg7+Z0EfVEsgvhGQKwjSNvREljAcS14pVrA==
X-Received: by 2002:a17:90a:8d09:: with SMTP id c9mr3784595pjo.131.1565104803991;
        Tue, 06 Aug 2019 08:20:03 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id s5sm71081936pfm.97.2019.08.06.08.20.02
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 08:20:02 -0700 (PDT)
Date: Tue, 6 Aug 2019 11:20:01 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org,
	Robin Murphy <robin.murphy@arm.com>,
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
	Mike Rapoport <rppt@linux.ibm.com>, namhyung@google.com,
	paulmck@linux.ibm.com, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 3/5] [RFC] arm64: Add support for idle bit in swap PTE
Message-ID: <20190806152001.GA39951@google.com>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-3-joel@joelfernandes.org>
 <20190806084203.GJ11812@dhcp22.suse.cz>
 <20190806103627.GA218260@google.com>
 <20190806104755.GR11812@dhcp22.suse.cz>
 <20190806111446.GA117316@google.com>
 <20190806115703.GY11812@dhcp22.suse.cz>
 <20190806144747.GA72938@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806144747.GA72938@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 11:47:47PM +0900, Minchan Kim wrote:
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
> > 
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
> If page is unmapped, it's not a idle memory any longer because it's
> free memory. We could detect the pte is not present.

I think Michal is not talking of explictly being unmapped, but about the case
where a file-backed mapped page is unmapped due to memory pressure ? This is
similar to the swap situation.

Basically... file page is marked idle, then it is accessed by userspace. Then
memory pressure drops it off the page cache so the idle information is lost.
Next time we check the page_idle, we miss that it was accessed indeed.

It is not an issue for the heap profiler or anonymous memory per-se. But is
similar to the swap situation.

> If page is refaulted, it's not a idle memory any longer because it's
> accessed again. We could detect it because the newly allocated page
> doesn't have a PG_idle page flag.

In the refault case, yes it should not be a problem.

thanks,

 - Joel


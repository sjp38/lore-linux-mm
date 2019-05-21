Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F53EC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:26:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9D21217D7
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:26:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9D21217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 658D36B0005; Tue, 21 May 2019 02:26:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 607DE6B0006; Tue, 21 May 2019 02:26:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F6E66B0007; Tue, 21 May 2019 02:26:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 046606B0005
	for <linux-mm@kvack.org>; Tue, 21 May 2019 02:26:31 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r20so29009341edp.17
        for <linux-mm@kvack.org>; Mon, 20 May 2019 23:26:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CzppJZV98yTh7mhgyQj10DGJb6ANdtEoPKV4ajF34Zc=;
        b=n8MytUse/7WmvES3jIExSVYwDxTiNvkiJOVHBGYfrtN+AP9C2dU3EkHoEA/bFzSkvh
         4KY3QcZKcdkXPVRYhxHnGvvjJxFCQbILgcDjBOEDqVDkOQuUpEszA3UgAkm4Ot0Y3Lp6
         mSHjOg9yPC7YgOT5AO3v64vGoqIm//qoN7E38WnEfZN5Uv3l+ng8l4KrMRRaxWVno+4g
         ub8dpqmsaJxg9RpCCwu3uX7RwUCbgtxfOe8uB9DWyuxgbnlrPzRTDcbB5Nq5s3rH//09
         iu1pcB7rcUAOjjGOBmMCAw/6ALMaxn1vUVxOJChM8tEbvfsiDL2gUMs8jgaTFhj8s/kx
         6uZg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXDzs89nbeD8YkMi8H5U+QtqA2RXXE/En3PxCvfHQPennVZHiZY
	oYYw6jLua/ezXy85bwUgLvlnKam17eU9QCxQObVS5jAfPr+c+rYibE3gYNvR57QHrsrXkgNOINA
	cpKDhNYpYaH641F/Wb3kaKCk72pMVpsa+9KbgL1LogYxfbF54mXHRKOF43XuNqFA=
X-Received: by 2002:a50:e705:: with SMTP id a5mr80289031edn.270.1558419990601;
        Mon, 20 May 2019 23:26:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfxFxwDDFoj1wm/9mmW7onRAk7j7cQjtyt4guAnx9RtI1ER7NoXM1ewMSASysCletLBnYH
X-Received: by 2002:a50:e705:: with SMTP id a5mr80288984edn.270.1558419989915;
        Mon, 20 May 2019 23:26:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558419989; cv=none;
        d=google.com; s=arc-20160816;
        b=RPy4/dCA7CgdnmmIVcONfDspdawypFzXv+NUa3QQr9OxMlzxgZnWL8bLerrLfSM5zj
         FzpiE7xebiu2eBSK1Az2HSYF2ol7e705tyT+qjGfyCnV968E2XS7NMFDVubVCHNbb1fl
         gtYd2hJ3BkAtN0NNRQBHKHx8UzCsMw7yp+hVkbf9iwdiFU8jtVq2guDXZzLcERjBtL6U
         uJeyZ2HV9QjcUwAWDV184cxDDCaFsgPrtk398G5wFvtMgTJX7fX5zY9SS6B3LQcxmKNx
         k/sdFCSCy9REMiKLQb5k6FA6u1d69T/ln0MRotaw+u77eN463NcvDcAmy0LR0xiQ9Xwh
         efdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CzppJZV98yTh7mhgyQj10DGJb6ANdtEoPKV4ajF34Zc=;
        b=SJ2aWTv8LqILX5fZyEMOYaLHjzkWYYnTgkn0KlnbX6YY0TaKPodwdhpL6WTQkxpSya
         dA5NaOHunVfJpGVncZL3I8x/xHDCLvl1jmUXaEMi0Z3f3QlNeKOQu4P7hdhZSgGVfMmf
         l9DDbrVIeNBK0Qg4lSsE80x5u32DjeJk6+KJ/rhA5KFTHVDeYRO18PJ/U8vHS+zMf11W
         fXHQGFGpTB6sv1H40b6ec176ngFWO6RgaJMg8gY1rOeUFVC3xUwI5eg6nlmEO1KvPIyC
         soJ6ofVXgDOOBKSqQ0DQhkLuXPTcB/4lnavQLa7TQI1Zzv2+CDb6cIkHzi7LilIYYLLt
         p8Fw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cw5si6291762ejb.382.2019.05.20.23.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 23:26:29 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7FB96AE08;
	Tue, 21 May 2019 06:26:29 +0000 (UTC)
Date: Tue, 21 May 2019 08:26:28 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190521062628.GE32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-8-minchan@kernel.org>
 <20190520092801.GA6836@dhcp22.suse.cz>
 <20190521025533.GH10039@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521025533.GH10039@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 11:55:33, Minchan Kim wrote:
> On Mon, May 20, 2019 at 11:28:01AM +0200, Michal Hocko wrote:
> > [cc linux-api]
> > 
> > On Mon 20-05-19 12:52:54, Minchan Kim wrote:
> > > System could have much faster swap device like zRAM. In that case, swapping
> > > is extremely cheaper than file-IO on the low-end storage.
> > > In this configuration, userspace could handle different strategy for each
> > > kinds of vma. IOW, they want to reclaim anonymous pages by MADV_COLD
> > > while it keeps file-backed pages in inactive LRU by MADV_COOL because
> > > file IO is more expensive in this case so want to keep them in memory
> > > until memory pressure happens.
> > > 
> > > To support such strategy easier, this patch introduces
> > > MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER options in madvise(2) like
> > > that /proc/<pid>/clear_refs already has supported same filters.
> > > They are filters could be Ored with other existing hints using top two bits
> > > of (int behavior).
> > 
> > madvise operates on top of ranges and it is quite trivial to do the
> > filtering from the userspace so why do we need any additional filtering?
> > 
> > > Once either of them is set, the hint could affect only the interested vma
> > > either anonymous or file-backed.
> > > 
> > > With that, user could call a process_madvise syscall simply with a entire
> > > range(0x0 - 0xFFFFFFFFFFFFFFFF) but either of MADV_ANONYMOUS_FILTER and
> > > MADV_FILE_FILTER so there is no need to call the syscall range by range.
> > 
> > OK, so here is the reason you want that. The immediate question is why
> > cannot the monitor do the filtering from the userspace. Slightly more
> > work, all right, but less of an API to expose and that itself is a
> > strong argument against.
> 
> What I should do if we don't have such filter option is to enumerate all of
> vma via /proc/<pid>/maps and then parse every ranges and inode from string,
> which would be painful for 2000+ vmas.

Painful is not an argument to add a new user API. If the existing API
suits the purpose then it should be used. If it is not usable, we can
think of a different way.
-- 
Michal Hocko
SUSE Labs


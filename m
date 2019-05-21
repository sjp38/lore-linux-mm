Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFB8FC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:37:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9270217D9
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:37:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9270217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DA9D6B0003; Tue, 21 May 2019 06:37:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48AD16B0005; Tue, 21 May 2019 06:37:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 353446B0006; Tue, 21 May 2019 06:37:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC99A6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 06:37:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i3so30030648edr.12
        for <linux-mm@kvack.org>; Tue, 21 May 2019 03:37:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1q/dVdP7HxJsS6UFE2LHPoykJOiSsP8777Pj4xifRDk=;
        b=crx34VOwSJ5Jw+GP1rLJ44rkJPwynn0bQrgx/uTfHycPoNge3NXJXWJAx5QFdJMh9d
         3tCVT3sID0mMa7HT8HsBxyKfeZjVqkGTpE9cFfYUFbFmhQAsprxXgUprtp5i/Jxx3VZP
         SzwUJrJ6FyEFn8sTcx2owvKCBjSJE0qarZdlvLF8MLrS0nRSPsIVG+Ab2sKc3dicIQY8
         Xr9gCjbVs1s0+qtdgUWDH4WUtrZUFY0qpYkgJY14421cSCs8l1jHuqquvrrNjGnLVAK6
         ao7tYm+NmTlcZ+uzF+gZ0YkoU7W8QFZDo42YeeuROPi7fDk9PhBgiaYL6Cy7SRmDe3/+
         KeMw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVFXATSWGSUC8J7IzgjXva4LK7gVIiKzDlaYFh4bfmvcVb2C63o
	zA+WbMd1/Awnt0hmbZdEl4ZTS7+mM1DH36BcbCYiRTK+6VACaFtez+2MMsRofoGg+a4e+x1iANm
	kmkJCOvvzP2cd0FMWd7XZHnl2KJQ8oYq7M8Rgfla5NxfEYi7cDLzTYl8iQ+Vhn7U=
X-Received: by 2002:a50:a522:: with SMTP id y31mr80612640edb.69.1558435048478;
        Tue, 21 May 2019 03:37:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWo3FvVzsZaHFbOOC8yWHTH9Ohi52dLltSHHZ+IGkVWZbzt9tnVse+Kgro1xde8BcTen1d
X-Received: by 2002:a50:a522:: with SMTP id y31mr80612567edb.69.1558435047726;
        Tue, 21 May 2019 03:37:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558435047; cv=none;
        d=google.com; s=arc-20160816;
        b=n0a99cX6xMVsZ+J0wjrakwoZjjJsuGaIwYN0T0IA5f6vn9pNkyvq7rYIyWZgOcTugm
         BzZTYoS5unPYpsjfAWVxwQjOg6PyMvIgCsnWeL/YZEbHtCrT1lgnkZ4JKKOL4MST0/28
         xfPgQMI018OoR0JOoLMAgO+D8r93elfejLylxIvj2iXzXmq5cKxZoBD68It65yU02ThX
         nVziuIiX8cI0lvFKLGTaNMnfX5rxIdF5Bo2B0MVxtbBaiDe0zJQ1AX98Aof43RwF8QoE
         A4zrlK69PY7PzkbirBFaW9AaGk25NU2bNl2jhORuyBjZw7b3zs/l7Rxu9f33gG4+r3Nz
         TpRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1q/dVdP7HxJsS6UFE2LHPoykJOiSsP8777Pj4xifRDk=;
        b=FBdZDdVeiJ0aSviBDXxLX4e7Hj5V4kJ6q5Z1PJdQWdRUJKWvrXLrQ5pcN8knzGW/ic
         v7vwvCyLUMwVgbbc4aNmg8OrkmUnKbRbtZg+EMNMagAx97ZvIRUgjhLpYPzN8nqiig8+
         k2BlNVA6iLgcPLiDjYsBiCrjP9+aKZC5+2PN/vn0vPMyjh6SbLai4vW0wSLUMK1mmqrn
         alJo4qDa4g2silxX7w9VwLgukTd6Ro80ajMhGfaoChEhj29QgvXChWMlyhgi9dFk0f8W
         raIW8WefBmWcsO1xGqcKF9kn91NccSgd07GNKznU8XDDEIxXdJ5YbDjlCOeUF0kdWaG5
         9rLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 32si3199230eds.25.2019.05.21.03.37.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 03:37:27 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 452F8AF1C;
	Tue, 21 May 2019 10:37:27 +0000 (UTC)
Date: Tue, 21 May 2019 12:37:26 +0200
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
Subject: Re: [RFC 6/7] mm: extend process_madvise syscall to support vector
 arrary
Message-ID: <20190521103726.GM32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-7-minchan@kernel.org>
 <20190520092258.GZ6836@dhcp22.suse.cz>
 <20190521024820.GG10039@google.com>
 <20190521062421.GD32329@dhcp22.suse.cz>
 <20190521102613.GC219653@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521102613.GC219653@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 19:26:13, Minchan Kim wrote:
> On Tue, May 21, 2019 at 08:24:21AM +0200, Michal Hocko wrote:
> > On Tue 21-05-19 11:48:20, Minchan Kim wrote:
> > > On Mon, May 20, 2019 at 11:22:58AM +0200, Michal Hocko wrote:
> > > > [Cc linux-api]
> > > > 
> > > > On Mon 20-05-19 12:52:53, Minchan Kim wrote:
> > > > > Currently, process_madvise syscall works for only one address range
> > > > > so user should call the syscall several times to give hints to
> > > > > multiple address range.
> > > > 
> > > > Is that a problem? How big of a problem? Any numbers?
> > > 
> > > We easily have 2000+ vma so it's not trivial overhead. I will come up
> > > with number in the description at respin.
> > 
> > Does this really have to be a fast operation? I would expect the monitor
> > is by no means a fast path. The system call overhead is not what it used
> > to be, sigh, but still for something that is not a hot path it should be
> > tolerable, especially when the whole operation is quite expensive on its
> > own (wrt. the syscall entry/exit).
> 
> What's different with process_vm_[readv|writev] and vmsplice?
> If the range needed to be covered is a lot, vector operation makes senese
> to me.

I am not saying that the vector API is wrong. All I am trying to say is
that the benefit is not really clear so far. If you want to push it
through then you should better get some supporting data.
-- 
Michal Hocko
SUSE Labs


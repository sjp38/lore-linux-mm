Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB706C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:57:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C64B2086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:57:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C64B2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 292296B0006; Fri,  9 Aug 2019 04:57:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2423B6B0008; Fri,  9 Aug 2019 04:57:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10BC36B000E; Fri,  9 Aug 2019 04:57:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BAB656B0006
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:57:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so59890417eda.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:57:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eAIRqplkFxHUyV5zoefBK/RQ907Tglp8KwB4YIGUa0I=;
        b=K3oCFRoNZp+fLzMaHbVhAy77w/8sHh7EK3+4HFAT2vi2jOHskYJ5wN4ggR0B+8Atxh
         NmuA6bzF7wqUqg3Bjzct5feb0qdsVuM6rCPE2vO6WzlV/c4qJnTCCh0KgLKtoTOirgcr
         QCnDqExYVjdmCpJAApzRx/gebWXKSMy8agVF/v+Sgl/5aO8q472GXjb23xrWHwnLn4Kx
         LWFIpIA9zdgzKbDn9R0fgaVfEnN9i0PqOtem2dE65Dnf1l+pOG6uFEV1RetiSNVepHI5
         Z0sHP1h+QSdfY5GpIV5pF2btRBZ63m0wBtNcDfe03DhqNe7QhGwDDq4Z2rLy27akZ8o0
         +jUA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXgrlCm64kADrsqeb01C5ZyZw4/q/yQf3BTaDqBJirS/7s3ncMK
	JfouuPPTL728aO5m9wy8KKwxhv3P11xB4KpLWrPnoRb/pJCY3nVe9kbawZXQTPuQOx8kq0lngIN
	afqIOiU55Kbwfv7XmU7G3UX4z6XpRT7rBfbgxIClyyUgk2uy90dbbkLKQzMWiuhA=
X-Received: by 2002:a17:906:1dcb:: with SMTP id v11mr17447829ejh.218.1565341071288;
        Fri, 09 Aug 2019 01:57:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXBmsCMPdfv4AcH1KWpXhg8KJ1dx8qPU9cumkrzr91ercEBpiENE4/wBHjHa3/zxqXQpsC
X-Received: by 2002:a17:906:1dcb:: with SMTP id v11mr17447795ejh.218.1565341070459;
        Fri, 09 Aug 2019 01:57:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565341070; cv=none;
        d=google.com; s=arc-20160816;
        b=tUBInyD/tRoam8Ttly7OqJVtol+d4mObqA4jNougkrqwWqiP1jd8LSZhdu0Kzhji26
         yFsGa8cd8UBxMCCWIaC7vQn7IG6JYjSeU+je7gGI/9tmhXQwSHhmdrVasSpzdKbv+0lZ
         unkslNxQhv9F/9GXB5W0UhuJ1jfys2L4Q4t1cYPl1BhGdnIJ3fHCSE/LWYm1GN/+3DwB
         82DG0UBHf+5hUFR1aMrHzNA7/86XyjsNo9IENp2z6aJhkYMVB5zM2i9pna2tQkiA8EPr
         tkRxaxHYD9ECFlplAmPwjwPKFn0ePFluJJgIU8aVdj/Gge0sPqPTV+GObKOqElpChvNd
         zlKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eAIRqplkFxHUyV5zoefBK/RQ907Tglp8KwB4YIGUa0I=;
        b=aCuTUsB4aRKvci3i1s/g3eqz4oWDG4TpH5QUD+c19Q2Bdc99WZmdpuiZT5pd9iYVrf
         EU/jOzN9Y1JkB8cmsO1zjVAGnVGncMfEx1vh/YUKyj6EzjkYxWAK/KX/xNmjLnjdz5pq
         alwX4TCcXwzznhGjEVxFtMmvqjDcoLIA0htD99nrGsE82qcKfyqLAfl1yfQRx2UaJf7e
         KwK0wH5xX6uX9jTSkPXBuccyLuTNCwLNz3AAbmDKqGuvX3hMUM3FLM3NegFPR0cLocMi
         SNULdZOXNtBGBoQmSlWTs9mz6NLs5PjcBTHbFVo19KL41fsjI4wHoGKhnd9kULJ3FoWb
         29nQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v26si31995882eju.206.2019.08.09.01.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:57:50 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EA141AFDB;
	Fri,  9 Aug 2019 08:57:49 +0000 (UTC)
Date: Fri, 9 Aug 2019 10:57:48 +0200
From: Michal Hocko <mhocko@kernel.org>
To: ndrw <ndrw.xf@redhazel.co.uk>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Artem S. Tashkinov" <aros@gmx.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190809085748.GN18351@dhcp22.suse.cz>
References: <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
 <20190806220150.GA22516@cmpxchg.org>
 <20190807075927.GO11812@dhcp22.suse.cz>
 <20190807205138.GA24222@cmpxchg.org>
 <20190808114826.GC18351@dhcp22.suse.cz>
 <806F5696-A8D6-481D-A82F-49DEC1F2B035@redhazel.co.uk>
 <20190808163228.GE18351@dhcp22.suse.cz>
 <5FBB0A26-0CFE-4B88-A4F2-6A42E3377EDB@redhazel.co.uk>
 <20190808185925.GH18351@dhcp22.suse.cz>
 <08e5d007-a41a-e322-5631-b89978b9cc20@redhazel.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <08e5d007-a41a-e322-5631-b89978b9cc20@redhazel.co.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 08-08-19 22:59:32, ndrw wrote:
> On 08/08/2019 19:59, Michal Hocko wrote:
> > Well, I am afraid that implementing anything like that in the kernel
> > will lead to many regressions and bug reports. People tend to have very
> > different opinions on when it is suitable to kill a potentially
> > important part of a workload just because memory gets low.
> 
> Are you proposing having a zero memory reserve or not having such option at
> all? I'm fine with the current default (zero reserve/margin).

We already do have a reserve (min_free_kbytes). That gives kswapd some
room to perform reclaim in the background without obvious latencies to
allocating tasks (well CPU still be used so there is still some effect).

Kswapd tries to keep a balance and free memory low but still with some
room to satisfy an immediate memory demand. Once kswapd doesn't catch up
with the memory demand we dive into the direct reclaim and that is where
people usually see latencies coming from.

The main problem here is that it is hard to tell from a single
allocation latency that we have a bigger problem. As already said, the
usual trashing scenario doesn't show problem during the reclaim because
pages can be freed up very efficiently. The problem is that they are
refaulted very quickly so we are effectively rotating working set like
crazy. Compare that to a normal used-once streaming IO workload which is
generating a lot of page cache that can be recycled in a similar pace
but a working set doesn't get freed. Free memory figures will look very
similar in both cases.

> I strongly prefer forcing OOM killer when the system is still running
> normally. Not just for preventing stalls: in my limited testing I found the
> OOM killer on a stalled system rather inaccurate, occasionally killing
> system services etc. I had much better experience with earlyoom.

Good that earlyoom works for you. All I am saying is that this is not
generally applicable heuristic because we do care about a larger variety
of workloads. I should probably emphasise that the OOM killer is there
as a _last resort_ hand break when something goes terribly wrong. It
operates at times when any user intervention would be really hard
because there is a lack of resources to be actionable.

[...]
> > > > PSI is giving you a matric that tells you how much time you
> > > > spend on the memory reclaim. So you can start watching the system from
> > > > lower utilization already.
> 
> I've tested it on a system with 45GB of RAM, SSD, swap disabled (my
> intention was to approximate a worst-case scenario) and it didn't really
> detect stall before it happened. I can see some activity after reaching
> ~42GB, the system remains fully responsive until it suddenly freezes and
> requires sysrq-f.

This is a useful feedback! What was your workload? Which kernel version?

-- 
Michal Hocko
SUSE Labs


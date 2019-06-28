Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60FC4C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 02:13:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A5FA2086D
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 02:13:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bNoMT+Yu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A5FA2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9229B8E0003; Thu, 27 Jun 2019 22:13:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D1678E0002; Thu, 27 Jun 2019 22:13:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C16F8E0003; Thu, 27 Jun 2019 22:13:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D94B8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 22:13:00 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id l138so7198387ybf.6
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 19:13:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ESdzyALH+b44/HL+ukDoP4QdSzem8V/icNADS0o9wFw=;
        b=tlZJHQCF++DHzPrGN0y8H5KZ/372LTJYeMsuP1NRkHEaGJ9GkmdXE5xq4hupRA3hW0
         uQ3xRIPwMruNhT8G/NR1UzfU1gzmXa7z+BzzfCYXBsqrXqgv3eZOWIfePQXkMqxmIxpd
         YZ5Ye7wLrrJb3DMLlFF1kDF4XZqj2+Sif2UI7xmZnRyZAc5ZTrIg5HsJxfAaD5851+dn
         HE45JeXGuWR4gusMoi9NDviRk3BDSvn73ruu4w7Rz+mBXVLl8KMlZPqEIE7f8vpLEBoP
         FMpazz641UWdbVOBQstiZdRZSp17SZt6u8/sqts4nVh/F9WQXuXlac80XCQBYHK7I1Ay
         be4A==
X-Gm-Message-State: APjAAAUTNepDoNYgNWoD8HeueLKHSnlVEnZC+o/VbpK+RoxgXC/LvXZ4
	oTGAj7QcWKDwmrAlF8EEvKVd5AqiXd/cfy48itqrPH9smJiQfS8tU+R2u22Oj7jJ1ngpiiYaODI
	IQrAlwjnjBH9BkrFu450ChSe6tRnwdzvRKT16lkEIaTFjOSduJDz2XW39yNQeLtuh8g==
X-Received: by 2002:a81:5fd4:: with SMTP id t203mr4299712ywb.300.1561687980142;
        Thu, 27 Jun 2019 19:13:00 -0700 (PDT)
X-Received: by 2002:a81:5fd4:: with SMTP id t203mr4299691ywb.300.1561687979639;
        Thu, 27 Jun 2019 19:12:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561687979; cv=none;
        d=google.com; s=arc-20160816;
        b=WnISqv2UO7DpH89shVtq2BXd4aatrh4NIolgLHlrkuOujaxI6Coh8ej3oMrHNcjXQO
         6LJP9oDnDYCv25v+F5NHm19kGStuTEjgBxKo5+uiitc1P3n27zdZFBFUiKD491iSSbto
         o0exsY+6FxZZUzImnYxO0Y0pWiMLuxH+okq1hjEbPV0KSZlPyvx6jgjThSIg6FlVDDD5
         jCLdva2p/sRejpmhiGL/YRwcrYHVYYkESbVClOx3p6FXLnMHXQcdvX78MFYTst5HP/rN
         8U7ZC3y+ywBUIiqyabIQSGTUqZe61Sa+cB9S2rvYsdS0p916rILbGnV6kkRY7A0xVTae
         Q2uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ESdzyALH+b44/HL+ukDoP4QdSzem8V/icNADS0o9wFw=;
        b=x1wd8VyYqacQIvOiI0Yofo/h9PTPgPEEXaqtKMAfPcXKymDrBb/enwFRl0pgzp3q8C
         vGFKrJ8im0KQbPtKtAqxkTJHOFdS2Tc9fMgbarj+SmxI64DZtNPTHHHh2UyTZqJ0bA0o
         iLvSoSj0V62jp9OcAuMKIH9xcHikGwONHJk0tiymWTsqsro5JVoF1jGr9yragq69QQ0P
         7mVuqOFLdZLMtKhkPs+oxj0ziqhCG5ABCV+eNhbSJUdOKTkUDGJd4+07RdSVxJkQTjRB
         SkIy6NqM5D2JrTTcvet1z/XXPPQN+1l/bz0lyQ6EmkxsKjZFaWYdK40SsHrWC9lj7py5
         fLIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bNoMT+Yu;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p73sor326849ywp.216.2019.06.27.19.12.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 19:12:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bNoMT+Yu;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ESdzyALH+b44/HL+ukDoP4QdSzem8V/icNADS0o9wFw=;
        b=bNoMT+YuH7ItGziVtsdIPXsPVFdbcyoeQtMerqHWvQsnSinptdEeivENVNdUr7TGgH
         xs9S8RJdpFaJ/u8yifB/4AFCuclR6vey0K+VFkrCKxc7CD6VrygNTDddQFT8XoS2xY5k
         B0Azomfo3EFsSKBuzaSHT3/t1S7yKCBAYqaGhu+vKwVWDDYJcPXiRDEvfz3vBgwHqKPu
         UsV5N6XCFxj3SDFFkwHdx0PVbh5PMzCj1A6FXBI+G9ad/eqnis4qroBq2Ejk94ZhomLv
         /FcfOTAjaVHiMdNxlTpO4YuYAz9aatDHVh/RxmZCxsrQJrFPI3InGgc6lXuv/sSzNAfk
         SCtw==
X-Google-Smtp-Source: APXvYqz0Cii6IBq9YH7EmbunOU8BzavnHLsl7DRlxEB5WcJVW9lCfnYlLvilIE/eHTA8PvLerwqJhx3puAdd8M0dbfo=
X-Received: by 2002:a81:a55:: with SMTP id 82mr4680020ywk.205.1561687978995;
 Thu, 27 Jun 2019 19:12:58 -0700 (PDT)
MIME-Version: 1.0
References: <20190624212631.87212-1-shakeelb@google.com> <20190624212631.87212-2-shakeelb@google.com>
 <20190626063755.GI17798@dhcp22.suse.cz>
In-Reply-To: <20190626063755.GI17798@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 27 Jun 2019 19:12:48 -0700
Message-ID: <CALvZod6_EDG=WMvrcrSFK4yJ69Mc-sqWJ3_HycCUdW=FpxzGVQ@mail.gmail.com>
Subject: Re: [PATCH v3 2/3] mm, oom: remove redundant task_in_mem_cgroup() check
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Paul Jackson <pj@sgi.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 11:38 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 24-06-19 14:26:30, Shakeel Butt wrote:
> > oom_unkillable_task() can be called from three different contexts i.e.
> > global OOM, memcg OOM and oom_score procfs interface. At the moment
> > oom_unkillable_task() does a task_in_mem_cgroup() check on the given
> > process. Since there is no reason to perform task_in_mem_cgroup()
> > check for global OOM and oom_score procfs interface, those contexts
> > provide NULL memcg and skips the task_in_mem_cgroup() check. However for
> > memcg OOM context, the oom_unkillable_task() is always called from
> > mem_cgroup_scan_tasks() and thus task_in_mem_cgroup() check becomes
> > redundant. So, just remove the task_in_mem_cgroup() check altogether.
>
> Just a nit. Not only it is redundant but it is effectively a dead code
> after your previous patch.
>

I will update the commit message.

> > Signed-off-by: Shakeel Butt <shakeelb@google.com>
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks


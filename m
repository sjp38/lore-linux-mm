Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A96B8C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:06:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44F972087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:06:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="rlvbtrIt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44F972087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 805888E0005; Tue, 30 Jul 2019 09:06:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B6038E0001; Tue, 30 Jul 2019 09:06:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CB488E0005; Tue, 30 Jul 2019 09:06:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 081FB8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 09:06:50 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id s7so14256720ljm.5
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 06:06:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+w66kByWBg6FjYrxXcGd5uPmMwPtO1bhVxzbFathPzI=;
        b=p+SNt7xtHWjS+EvRh0pZ8ARUQ0hDp6HdS1+4zITfFVZk5ZHWj3A52XPvjfUwljHEjh
         zKVVbskbCsuTmjwRTWnURFuSvCYXjE7c4zyM9c4uzG8m0S7DWPanZykaE0J9x+MDMBQN
         0tUC4WcOXsjOHS0fsWj2o+UHxWn1oIs7n3Zwh+lVgLeN/Ct7BlplWZ4lcw3eiCeKKCb7
         SKT5GI3E9mfpvbbK3ToSdQ3I2vOx9WQuvZW2w31VgCFQZYjeuPC0vfZ2PkMJG4Ifx2y5
         8k/cVzSFPJhQKZ68e87BFxtjFijjPI1ViZz6RYGux+grKa02JAgBmwP4G26ud3RrRYDk
         Xwgg==
X-Gm-Message-State: APjAAAU5u3tisWdXgGj75zLRkLeGj2Ni2qBSGBSWBv4DlZKyS9tXzdIM
	nC2D9DYOWssKrdvG1KKmcpYsvACDNeAswD+f6jFzYngsQyb6EVpXDrfQzGFahSC/MnvkASBCZmB
	OJAlAVNs+rjVSmUOcILD5Is9s/yU8flOY1AqP409qPoqglVajzE5isFnVNQM0/jjtxw==
X-Received: by 2002:a2e:3211:: with SMTP id y17mr23860379ljy.86.1564492009191;
        Tue, 30 Jul 2019 06:06:49 -0700 (PDT)
X-Received: by 2002:a2e:3211:: with SMTP id y17mr23860343ljy.86.1564492008344;
        Tue, 30 Jul 2019 06:06:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564492008; cv=none;
        d=google.com; s=arc-20160816;
        b=if0/MIuRLf+zjETHHcOaiBtEXuGZeJY0fobc/B0lbQ4tpyL7bAuYXZdrD2mVRfZ8Vk
         gbEKFbrQHR2zDI047nzJEjF/VmMWPkC7FqmmRftT/Pbgbkmzs4smdB6UbDQPzo0rOKBD
         YkOIoC948ud7un9iULJpt/yiTc0ARodD4rgrY1hyfa4EIXWq1kNt3Ax4VDB9AOVYprJE
         PO8It1x86jp0eO30ynn5cStCFnHLyraa3Rf8Bph7BhNsEPIvhldtnHUpYoKBZJHBt1b9
         xSlwv2Pn5LNGNlL8+mAANPpcK8I4Y/tW/Fw2PXqDpQEQk7T/Ty/5N5kHDx999bYR3UBx
         VJMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+w66kByWBg6FjYrxXcGd5uPmMwPtO1bhVxzbFathPzI=;
        b=YhAHODWCi0MLTpiTFcXtZYfPa2gNn9QVVjhr8vI2Q1kWs2zMBqSTF3kQFdvFwKkUYA
         eIJ0gQYB4igbkF00N7dOn1+Ze7xO9XZ8SRfYvZROlkbVduXdafDY2EDE70n5igbg7aZ+
         vX5Zewh1iDAJMmQtOoqnvkbIRlHf3CQ6189IdwXkaFJXf0msG6vwxTZwzCZlLLC4Bprz
         pNHVA1F+sEQNmkq3McVwon3Els0M7HR9WiTbwWWvTV3vEWVGXdYAi3z3TaO6EJxwc4CG
         kb0bPeSEch40Ka22ScTQNTKYi7OcL3FVhEv2dRGBkSqDbnI0sSATR3vWGgBno6qEFFdM
         eVxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=rlvbtrIt;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l13sor16429090lfh.64.2019.07.30.06.06.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 06:06:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=rlvbtrIt;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+w66kByWBg6FjYrxXcGd5uPmMwPtO1bhVxzbFathPzI=;
        b=rlvbtrIt21GU4iIJZ5r9dzLKvzu4zMCj4l8RKBDeA0o2mYiR3UKN0mPszMjSSAhX6X
         3OVtDWT+La05tWgdt87ZEAWGPkMfChkvs3/3jpFIqx88JiCdQhRyg5Hp1suRYIE7B9ff
         MncOgoeiv7F+vEZfGTVRnoNhuPuHjjFqr7im4=
X-Google-Smtp-Source: APXvYqxs+4zVTdk9wyREtf+ZtRrQRM3zR7YozzpsYYyXpsDMuwIYF8bDwOGtZvkDbZ5vHhbJCEniuM4mVcKBeMp71V4=
X-Received: by 2002:ac2:53a7:: with SMTP id j7mr23078118lfh.112.1564492007737;
 Tue, 30 Jul 2019 06:06:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190726152319.134152-1-joel@joelfernandes.org>
In-Reply-To: <20190726152319.134152-1-joel@joelfernandes.org>
From: Joel Fernandes <joel@joelfernandes.org>
Date: Tue, 30 Jul 2019 09:06:36 -0400
Message-ID: <CAEXW_YQN+htU-LpYQ_jxepVdRhO0byw1pWFrsbU2XsH=8FDKLA@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm/page_idle: Add per-pid idle page tracking using
 virtual indexing
To: LKML <linux-kernel@vger.kernel.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Brendan Gregg <bgregg@netflix.com>, Christian Hansen <chansen3@cisco.com>, 
	Daniel Colascione <dancol@google.com>, Florian Mayer <fmayer@google.com>, John Dias <joaodias@google.com>, 
	Joel Fernandes <joelaf@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, 
	kernel-team <kernel-team@android.com>, Linux API <linux-api@vger.kernel.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Minchan Kim <minchan@kernel.org>, Namhyung Kim <namhyung@google.com>, Roman Gushchin <guro@fb.com>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Suren Baghdasaryan <surenb@google.com>, Todd Kjos <tkjos@google.com>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Wei Wang <wvw@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 11:23 AM Joel Fernandes (Google)
<joel@joelfernandes.org> wrote:
>
> The page_idle tracking feature currently requires looking up the pagemap
> for a process followed by interacting with /sys/kernel/mm/page_idle.
> Looking up PFN from pagemap in Android devices is not supported by
> unprivileged process and requires SYS_ADMIN and gives 0 for the PFN.
>
> This patch adds support to directly interact with page_idle tracking at
> the PID level by introducing a /proc/<pid>/page_idle file.  It follows
> the exact same semantics as the global /sys/kernel/mm/page_idle, but now
> looking up PFN through pagemap is not needed since the interface uses
> virtual frame numbers, and at the same time also does not require
> SYS_ADMIN.
>
> In Android, we are using this for the heap profiler (heapprofd) which
> profiles and pin points code paths which allocates and leaves memory
> idle for long periods of time. This method solves the security issue
> with userspace learning the PFN, and while at it is also shown to yield
> better results than the pagemap lookup, the theory being that the window
> where the address space can change is reduced by eliminating the
> intermediate pagemap look up stage. In virtual address indexing, the
> process's mmap_sem is held for the duration of the access.
>
> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
>
> ---
> v2->v3:
> Fixed a bug where I was doing a kfree that is not needed due to not
> needing to do GFP_ATOMIC allocations.
>
> v1->v2:
> Mark swap ptes as idle (Minchan)
> Avoid need for GFP_ATOMIC (Andrew)
> Get rid of idle_page_list lock by moving list to stack

I believe all suggestions have been addressed.  Do these look good now?

thanks,

 - Joel



> Internal review -> v1:
> Fixes from Suren.
> Corrections to change log, docs (Florian, Sandeep)
>
>  fs/proc/base.c            |   3 +
>  fs/proc/internal.h        |   1 +
>  fs/proc/task_mmu.c        |  57 +++++++
>  include/linux/page_idle.h |   4 +
>  mm/page_idle.c            | 340 +++++++++++++++++++++++++++++++++-----
>  5 files changed, 360 insertions(+), 45 deletions(-)
>
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 77eb628ecc7f..a58dd74606e9 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -3021,6 +3021,9 @@ static const struct pid_entry tgid_base_stuff[] = {
>         REG("smaps",      S_IRUGO, proc_pid_smaps_operations),
>         REG("smaps_rollup", S_IRUGO, proc_pid_smaps_rollup_operations),


Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 144C8C41517
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:10:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2AFC22ADC
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:10:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="m6YvAC5U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2AFC22ADC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D5906B000D; Wed, 24 Jul 2019 10:10:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AC4C8E0006; Wed, 24 Jul 2019 10:10:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C2218E0002; Wed, 24 Jul 2019 10:10:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 129AA6B000D
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:10:56 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so24191330plp.12
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:10:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WXhaeMPXQ8MNtkF+Sp+2bS4wghsA38PAkoq4RUXLo/c=;
        b=VBn/H30niWJM83KWCrOpMK/PBGwjKkTz5tvKv2ueVQ8LbjtIygrM9d0ucsov7iIVlM
         ryYecaa3kGy7l+rxN07nwMJfqRYN+JJd1cZTCrTorCDyR/7qD6UpThpN9Ksw22X1FYnI
         Bb3E9d4SpqrGXK81385lgEtcX5/jL/PKaV/DV4Y/YeWETfWlFzDe4ooVGBkt1bKXG5em
         DhRHYCIzc7eyONjp4IysAUnb3Z0hNvFZfApUjN6wta2bATEzSrr1kdC5z3tmOuX+CeRQ
         KY8rCu2SlQ6SkEvnhoazqf1CsGfjMysZmWqHzEaKPZsgln6ifUbMkc3dccJ5fpcgtFqJ
         2KYw==
X-Gm-Message-State: APjAAAXX871Jb9kM6Q0BJsrFxQRYK7PLqEh0y0nT5XlcdC5SXwyM5hcY
	OYtCb2r+XJgM+8oWLQRt4f7Oef3nnAKTJKH8f0UkSeoLL7X8MU6C3QdYSFNrZ5GNx/FpU1BrfhC
	SoOu/tEwaAAQNLOyBdFqhaBqaTxqa2yZuF7nuzqHjIo1FLZEhGfe6GyJLcC+0S83psw==
X-Received: by 2002:aa7:81d9:: with SMTP id c25mr11751316pfn.255.1563977455729;
        Wed, 24 Jul 2019 07:10:55 -0700 (PDT)
X-Received: by 2002:aa7:81d9:: with SMTP id c25mr11751242pfn.255.1563977454806;
        Wed, 24 Jul 2019 07:10:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563977454; cv=none;
        d=google.com; s=arc-20160816;
        b=bupgoD0+qjh8/l+/bJ6CuE1XMgNsoKc7CzBOTml+jXvK5iP3cqu6jbolqqlcQaPNQh
         /XEZyehW2aFP8ND/R9K2i44efvlgQ1ZuuYzY2RqqV4OuVjxNqkm4A21I8CVAoNdftXHS
         NzGotmwqYj1uhk44J9ywV20oW7mhOlfs9nVcBZsFaDXdzfXJTJEim20yUrixczlnsOCO
         HmpN9M+mGzAT/rRYh21nH/65Pz1/ALV9sG7X3d+wmRK1VbSy/RC2c0CqkAlQuFnxpHiV
         qe1cgMDzCb9Z5a7knBKI7h1K7EqRTcS4P0R8OUU7ymmvAmda0+JtPEzpG5AmnEXTlkmN
         VJDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WXhaeMPXQ8MNtkF+Sp+2bS4wghsA38PAkoq4RUXLo/c=;
        b=HKShH8itKWSuTFHGAG6uuNjO4ntMvURz4OQkyqxHVE6BJ0yG+BGl6nBpEO3HAg+SCB
         DzR3xyhCKMUWkamBtkIc6jKmaSGBJ1gwrUWpGIRKG3WoNRJKuV+0Z4NtUsxqpuxR1Atj
         fNk5NXhMnVrAlWxJ0t5BxP4rFArdawNjoGctEJ1QMZlXVExdqYC4bH7wvuoB07SQBjmo
         kDa0wnTIfvYg1F5+dBU+WKEnd9AOYyFkjmummfa5O+Etn7/yKuGgL52htUryqBf4EtNQ
         AdBS6rqx/rb8mKP8AmPbS0LbIhblbUhtMptb2/d2DHzrAjZVBLrADZf83OuSlXgay1Mr
         a5mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=m6YvAC5U;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1sor1901278pfc.63.2019.07.24.07.10.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 07:10:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=m6YvAC5U;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=WXhaeMPXQ8MNtkF+Sp+2bS4wghsA38PAkoq4RUXLo/c=;
        b=m6YvAC5UDmYi4TsfqlA07rTcUbfvc9lidZhL3ozBZPd9FuNWIKormAzLfT9QLJeXSF
         2DlJ04Pv53eAX5aDIefwhPa4ynnSAA98nz2zD5VGbt4BI8tgCFX+iFwGmIgLSHIE1zb2
         8tkJvPr+jPd5o5N/vsQKy8hTHoEz1YzrJNWUI=
X-Google-Smtp-Source: APXvYqxhiuMEPHH8pRDkDkxK8JM+xQ0EECYE2I6dsIIwwk5MI/hkEsc+JGVOGaSpqK/SVp9B21n2eQ==
X-Received: by 2002:a63:dd0b:: with SMTP id t11mr41295651pgg.410.1563977454295;
        Wed, 24 Jul 2019 07:10:54 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id q63sm61399100pfb.81.2019.07.24.07.10.53
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 07:10:53 -0700 (PDT)
Date: Wed, 24 Jul 2019 10:10:52 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, vdavydov.dev@gmail.com,
	Brendan Gregg <bgregg@netflix.com>, kernel-team@android.com,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>, carmenjackson@google.com,
	Christian Hansen <chansen3@cisco.com>,
	Colin Ian King <colin.king@canonical.com>, dancol@google.com,
	David Howells <dhowells@redhat.com>, fmayer@google.com,
	joaodias@google.com, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>, namhyung@google.com,
	sspatil@google.com, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, timmurray@google.com,
	tkjos@google.com, Vlastimil Babka <vbabka@suse.cz>, wvw@google.com
Subject: Re: [PATCH v1 1/2] mm/page_idle: Add support for per-pid page_idle
 using virtual indexing
Message-ID: <20190724141052.GB9945@google.com>
References: <20190722213205.140845-1-joel@joelfernandes.org>
 <20190723061358.GD128252@google.com>
 <20190723142049.GC104199@google.com>
 <20190724042842.GA39273@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724042842.GA39273@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 01:28:42PM +0900, Minchan Kim wrote:
> On Tue, Jul 23, 2019 at 10:20:49AM -0400, Joel Fernandes wrote:
> > On Tue, Jul 23, 2019 at 03:13:58PM +0900, Minchan Kim wrote:
> > > Hi Joel,
> > > 
> > > On Mon, Jul 22, 2019 at 05:32:04PM -0400, Joel Fernandes (Google) wrote:
> > > > The page_idle tracking feature currently requires looking up the pagemap
> > > > for a process followed by interacting with /sys/kernel/mm/page_idle.
> > > > This is quite cumbersome and can be error-prone too. If between
> > > 
> > > cumbersome: That's the fair tradeoff between idle page tracking and
> > > clear_refs because idle page tracking could check even though the page
> > > is not mapped.
> > 
> > It is fair tradeoff, but could be made simpler. The userspace code got
> > reduced by a good amount as well.
> > 
> > > error-prone: What's the error?
> > 
> > We see in normal Android usage, that some of the times pages appear not to be
> > idle even when they really are idle. Reproducing this is a bit unpredictable
> > and happens at random occasions. With this new interface, we are seeing this
> > happen much much lesser.
> 
> I don't know how you did test. Maybe that could be contributed by
> swapping out or shared pages touched by other processes or some kernel
> behavior not to keep access bit of their operation.

It could be something along these lines is my thinking as well. So we know
its already has issues due to what you mentioned, I am not sure what else
needs investigation?

> Please investigate more what's the root cause. That would be important
> point to justify for the patch motivation.

The motivation is security. I am dropping the 'accuracy' factor I mentioned
from the patch description since it created a lot of confusion.

> > > > More over looking up PFN from pagemap in Android devices is not
> > > > supported by unprivileged process and requires SYS_ADMIN and gives 0 for
> > > > the PFN.
> > > > 
> > > > This patch adds support to directly interact with page_idle tracking at
> > > > the PID level by introducing a /proc/<pid>/page_idle file. This
> > > > eliminates the need for userspace to calculate the mapping of the page.
> > > > It follows the exact same semantics as the global
> > > > /sys/kernel/mm/page_idle, however it is easier to use for some usecases
> > > > where looking up PFN is not needed and also does not require SYS_ADMIN.
> > > 
> > > Ah, so the primary goal is to provide convinience interface and it would
> > > help accurary, too. IOW, accuracy is not your main goal?
> > 
> > There are a couple of primary goals: Security, conveience and also solving
> > the accuracy/reliability problem we are seeing. Do keep in mind looking up
> > PFN has security implications. The PFN field in pagemap is zeroed if the user
> > does not have CAP_SYS_ADMIN.
> 
> Myaybe you don't need PFN. is it?

With the traditional idle tracking, PFN is needed which has the mentioned
security issues. This patch solves it. And the interface is identical and
familiar to the existing page_idle bitmap interface.

> > > > In Android, we are using this for the heap profiler (heapprofd) which
> > > > profiles and pin points code paths which allocates and leaves memory
> > > > idle for long periods of time.
> > > 
> > > So the goal is to detect idle pages with idle memory tracking?
> > 
> > Isn't that what idle memory tracking does?
> 
> To me, it's rather misleading. Please read motivation section in document.
> The feature would be good to detect workingset pages, not idle pages
> because workingset pages are never freed, swapped out and even we could
> count on newly allocated pages.
> 
> Motivation
> ==========
> 
> The idle page tracking feature allows to track which memory pages are being
> accessed by a workload and which are idle. This information can be useful for
> estimating the workload's working set size, which, in turn, can be taken into
> account when configuring the workload parameters, setting memory cgroup limits,
> or deciding where to place the workload within a compute cluster.

As we discussed by chat, we could collect additional metadata to check if
pages were swapped or freed ever since the time we marked them as idle.
However this can be incremental improvement.

> > > It couldn't work well because such idle pages could finally swap out and
> > > lose every flags of the page descriptor which is working mechanism of
> > > idle page tracking. It should have named "workingset page tracking",
> > > not "idle page tracking".
> > 
> > The heap profiler that uses page-idle tracking is not to measure working set,
> > but to look for pages that are idle for long periods of time.
> 
> It's important part. Please include it in the description so that people
> understands what's the usecase. As I said above, if it aims for finding
> idle pages durting the period, current idle page tracking feature is not
> good ironically.

Ok, I will mention.

> > Thanks for bringing up the swapping corner case..  Perhaps we can improve
> > the heap profiler to detect this by looking at bits 0-4 in pagemap. While it
> 
> Yeb, that could work but it could add overhead again what you want to remove?
> Even, userspace should keep metadata to identify that page was already swapped
> in last period or newly swapped in new period.

Yep.

thanks,

 - Joel


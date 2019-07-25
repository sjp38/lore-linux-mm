Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EAC9C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:16:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 202C222CBA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:16:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="yg2Z6Kv3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 202C222CBA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A97528E0050; Thu, 25 Jul 2019 04:15:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A47648E0031; Thu, 25 Jul 2019 04:15:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 936208E0050; Thu, 25 Jul 2019 04:15:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA618E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:15:59 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id m2so4991915lfj.1
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:15:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=mqwyPL/Kvi4FlMJZMuuGgTLVmBANLSvlAgU95QJvMKg=;
        b=PilpQ5ux9jm/CLbHm5Lgabl9US7vyq78KvkZ5yUR+4CzOcoyw/Kf2PnobABHG2y446
         dReDvQUxB2EDaSebdOrvrAaxVRvGp1JXXpHdgnoLSWKhEzreFzrgEVtbteQa81ulWFSg
         Bb2aI23R0EjNCTPLDcPTXe7CaiP3pf/6Eg3xEzFqhgLCNIFlGqzqEAqP9B1gkchwUVFw
         ie38pG+jQTIzI5UQhv7qCh3A5V6ZYh2c0qA+qAWhvNZT+gtpG0DOoeAV7+MeQ3SEUruZ
         i1zOuxJ9DgMJmiyqJHJjK4tK+TjXQQMzufiOa84+FTOimX/of80c6l6cFpAGx+0ugEYx
         Wbag==
X-Gm-Message-State: APjAAAXqhqEpg9raL0q1XMzZGD6/mHY/Vs4E8DgH7b7vEbLQhrzErF2S
	PUogppZTmnmn2vc1hlE53wrtBpHFJ7XKTDAAaBhoosCwCfXP0sOPnn7tJnmRnX4iToqkib6+EGq
	eXwpP6QoJwW4Y/rbwWb5cx/AUIBaYj19WvSpK7BW2ThTj3G37VJvl3NukSUF8pmBqWQ==
X-Received: by 2002:a19:c503:: with SMTP id w3mr36088731lfe.139.1564042558265;
        Thu, 25 Jul 2019 01:15:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHwvDTgrx+arfSIUbFQ0xHeizxXnCMmcVBRVAWaXcTPeh8Wdvjr90n2ENT2F3Ntc0MZnWG
X-Received: by 2002:a19:c503:: with SMTP id w3mr36088686lfe.139.1564042556906;
        Thu, 25 Jul 2019 01:15:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564042556; cv=none;
        d=google.com; s=arc-20160816;
        b=R/rWBLMUDxHIxfs6UYuAaJYUbd62wBgy++OtugZsLKYQaH1onsoZGDmp4hBkufvLuX
         cweKQl6r6ZyqTFVSVbaXY8LEVDpXpc+N6O/tPCrZMdpTyNqudZwPb/UwBpGD8o7NJBT+
         4eVsG8ri5Bp/Ogt6CitypLR7y4f81zj3aLMRSicQDhAh21NiA50Ab5zbmUAMp4oMMsGK
         dXUaLNcYMYadyT81PuU4LJ3DuksvVIdqWQBig/nPdqFOt0q+y2gAxflWdDkmhck9ojAs
         g7ZmeR5D1fgH87j7R+cHiepWlkjnfWgx1bnhohMojuJAp3eAUUPfK+R4/0QENu6BWi1I
         VKxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=mqwyPL/Kvi4FlMJZMuuGgTLVmBANLSvlAgU95QJvMKg=;
        b=whNZICPWi0EBwhUjM7wMd370spIigmIwvDuINIZdWJKA2voqHVGOFAFpVzMR0LZ/vY
         tvat4omFuo/rUDojFGqKk9OlBcMlJU9kphQmelajbmyiqkTlkATt5hpC3Uzn7sQeoede
         yEjohdnWqqxbtc7QJkVfk7JrrtoqHuR/knlHOU2ewtciTp/6w1mNiGgJi9wBC55691DU
         ByHQcM+Nlrd1HGseH7km6vpEmPZDKsqRDarSxz92yr7cFZ4x9UJYXC9XzG5LwCYTeTnY
         8BW+TZOfxjNJ8xWTqqWp9INrJlTPsvQkx6/2NsMG64mLf6syqpA4INGOjgC8kIHzgO0q
         tB5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=yg2Z6Kv3;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [95.108.205.193])
        by mx.google.com with ESMTPS id d26si45383517ljj.123.2019.07.25.01.15.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 01:15:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) client-ip=95.108.205.193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=yg2Z6Kv3;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id CEA9A2E1546;
	Thu, 25 Jul 2019 11:15:55 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id BHFOVffvkF-FsBKYq39;
	Thu, 25 Jul 2019 11:15:55 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1564042555; bh=mqwyPL/Kvi4FlMJZMuuGgTLVmBANLSvlAgU95QJvMKg=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=yg2Z6Kv3kAo5EaGGy3G9RVrs92O5ikWA9VmdX0QpVDDSlO0VlBwqkO2pAkbukBQnn
	 J5OizK5Zp+57pK6J+mXCnOSs2NZMLzr+oqr3vj3KLBzIx55idigsymckEWqbyt6bei
	 kw1JkUxfveSV9/6Vmj8g1+t1A7++FSfjCZ7y2NpI=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:38b3:1cdf:ad1a:1fe1])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id QkVcPTjsve-FrIap0Me;
	Thu, 25 Jul 2019 11:15:54 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH v1 1/2] mm/page_idle: Add support for per-pid page_idle
 using virtual indexing
To: Joel Fernandes <joel@joelfernandes.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, vdavydov.dev@gmail.com,
 Brendan Gregg <bgregg@netflix.com>, kernel-team@android.com,
 Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>,
 Andrew Morton <akpm@linux-foundation.org>, carmenjackson@google.com,
 Christian Hansen <chansen3@cisco.com>,
 Colin Ian King <colin.king@canonical.com>, dancol@google.com,
 David Howells <dhowells@redhat.com>, fmayer@google.com, joaodias@google.com,
 Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
 Kirill Tkhai <ktkhai@virtuozzo.com>, linux-doc@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
 namhyung@google.com, sspatil@google.c
References: <20190722213205.140845-1-joel@joelfernandes.org>
 <20190723061358.GD128252@google.com> <20190723142049.GC104199@google.com>
 <20190724042842.GA39273@google.com> <20190724141052.GB9945@google.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <c116f836-5a72-c6e6-498f-a904497ef557@yandex-team.ru>
Date: Thu, 25 Jul 2019 11:15:53 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190724141052.GB9945@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 24.07.2019 17:10, Joel Fernandes wrote:> On Wed, Jul 24, 2019 at 01:28:42PM +0900, Minchan Kim wrote:
 >> On Tue, Jul 23, 2019 at 10:20:49AM -0400, Joel Fernandes wrote:
 >>> On Tue, Jul 23, 2019 at 03:13:58PM +0900, Minchan Kim wrote:
 >>>> Hi Joel,
 >>>>
 >>>> On Mon, Jul 22, 2019 at 05:32:04PM -0400, Joel Fernandes (Google) wrote:
 >>>>> The page_idle tracking feature currently requires looking up the pagemap
 >>>>> for a process followed by interacting with /sys/kernel/mm/page_idle.
 >>>>> This is quite cumbersome and can be error-prone too. If between
 >>>>
 >>>> cumbersome: That's the fair tradeoff between idle page tracking and
 >>>> clear_refs because idle page tracking could check even though the page
 >>>> is not mapped.
 >>>
 >>> It is fair tradeoff, but could be made simpler. The userspace code got
 >>> reduced by a good amount as well.
 >>>
 >>>> error-prone: What's the error?
 >>>
 >>> We see in normal Android usage, that some of the times pages appear not to be
 >>> idle even when they really are idle. Reproducing this is a bit unpredictable
 >>> and happens at random occasions. With this new interface, we are seeing this
 >>> happen much much lesser.
 >>
 >> I don't know how you did test. Maybe that could be contributed by
 >> swapping out or shared pages touched by other processes or some kernel
 >> behavior not to keep access bit of their operation.
 >
 > It could be something along these lines is my thinking as well. So we know
 > its already has issues due to what you mentioned, I am not sure what else
 > needs investigation?
 >
 >> Please investigate more what's the root cause. That would be important
 >> point to justify for the patch motivation.
 >
 > The motivation is security. I am dropping the 'accuracy' factor I mentioned
 > from the patch description since it created a lot of confusion.
If you are tracking idle working set for one process you could use degrading
'accuracy' for good - just don't walk page rmap and play only with access
bits in one process. Foreign access could be detected with arbitrary delay,
but this does not important if main goal is heap profiling.

 >
 >>>>> More over looking up PFN from pagemap in Android devices is not
 >>>>> supported by unprivileged process and requires SYS_ADMIN and gives 0 for
 >>>>> the PFN.
 >>>>>
 >>>>> This patch adds support to directly interact with page_idle tracking at
 >>>>> the PID level by introducing a /proc/<pid>/page_idle file. This
 >>>>> eliminates the need for userspace to calculate the mapping of the page.
 >>>>> It follows the exact same semantics as the global
 >>>>> /sys/kernel/mm/page_idle, however it is easier to use for some usecases
 >>>>> where looking up PFN is not needed and also does not require SYS_ADMIN.
 >>>>
 >>>> Ah, so the primary goal is to provide convinience interface and it would
 >>>> help accurary, too. IOW, accuracy is not your main goal?
 >>>
 >>> There are a couple of primary goals: Security, conveience and also solving
 >>> the accuracy/reliability problem we are seeing. Do keep in mind looking up
 >>> PFN has security implications. The PFN field in pagemap is zeroed if the user
 >>> does not have CAP_SYS_ADMIN.
 >>
 >> Myaybe you don't need PFN. is it?
 >
 > With the traditional idle tracking, PFN is needed which has the mentioned
 > security issues. This patch solves it. And the interface is identical and
 > familiar to the existing page_idle bitmap interface.
 >
 >>>>> In Android, we are using this for the heap profiler (heapprofd) which
 >>>>> profiles and pin points code paths which allocates and leaves memory
 >>>>> idle for long periods of time.
 >>>>
 >>>> So the goal is to detect idle pages with idle memory tracking?
 >>>
 >>> Isn't that what idle memory tracking does?
 >>
 >> To me, it's rather misleading. Please read motivation section in document.
 >> The feature would be good to detect workingset pages, not idle pages
 >> because workingset pages are never freed, swapped out and even we could
 >> count on newly allocated pages.
 >>
 >> Motivation
 >> ==========
 >>
 >> The idle page tracking feature allows to track which memory pages are being
 >> accessed by a workload and which are idle. This information can be useful for
 >> estimating the workload's working set size, which, in turn, can be taken into
 >> account when configuring the workload parameters, setting memory cgroup limits,
 >> or deciding where to place the workload within a compute cluster.
 >
 > As we discussed by chat, we could collect additional metadata to check if
 > pages were swapped or freed ever since the time we marked them as idle.
 > However this can be incremental improvement.
 >
 >>>> It couldn't work well because such idle pages could finally swap out and
 >>>> lose every flags of the page descriptor which is working mechanism of
 >>>> idle page tracking. It should have named "workingset page tracking",
 >>>> not "idle page tracking".
 >>>
 >>> The heap profiler that uses page-idle tracking is not to measure working set,
 >>> but to look for pages that are idle for long periods of time.
 >>
 >> It's important part. Please include it in the description so that people
 >> understands what's the usecase. As I said above, if it aims for finding
 >> idle pages durting the period, current idle page tracking feature is not
 >> good ironically.
 >
 > Ok, I will mention.
 >
 >>> Thanks for bringing up the swapping corner case..  Perhaps we can improve
 >>> the heap profiler to detect this by looking at bits 0-4 in pagemap. While it
 >>
 >> Yeb, that could work but it could add overhead again what you want to remove?
 >> Even, userspace should keep metadata to identify that page was already swapped
 >> in last period or newly swapped in new period.
 >
 > Yep.
Between samples page could be read from swap and swapped out back multiple times.
For tracking this swap ptes could be marked with idle bit too.
I believe it's not so hard to find free bit for this.

Refault\swapout will automatically clear this bit in pte even if
page goes nowhere stays if swap-cache.




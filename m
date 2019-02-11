Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35481C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:01:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4D2221B25
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:01:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="fR9XwG2I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4D2221B25
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC29B8E0138; Mon, 11 Feb 2019 14:01:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4A9A8E0136; Mon, 11 Feb 2019 14:01:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 914988E0138; Mon, 11 Feb 2019 14:01:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4DE8E0136
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:01:21 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id l14so8312131ybq.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:01:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=s09oajM8sRG6VR42JLX9NXyJV4gfvXuCrn6cD3FbZqw=;
        b=VjfwkQtYa0SibVqEeGdsCGx/krHMTQLQRK4UlgY3zguu7Cru2gggEngKfCAgCX73lg
         poXyxEoJN0JBi/2Qo0ksMltG/hlw5VwjNScaNbT3KlU1z5xe/1WB14DoiuMM5evnimy/
         kUxj5M4OwRwfWhVj/AKZHZY5dAfLTD4XUBrCOczuHsMX1s4HkGPKJZkPmykMBpFKvSD5
         V4c2WZUXPA8z8BDkUHBQdpN1I3uDTvhEBQVDx0gK2BV1xbN++sUKgyoO+d1MJ1R6hAKV
         IGpPXus6Y4gq7lG2dByKV9I+XNSy4GcN4INwAdZa+cE+Yp1ipwNKsDSHbZIOCDqH4YpW
         6H3g==
X-Gm-Message-State: AHQUAubRfFdWJBJ0P5FPIWjiPBINxjhepgt1E346cNcKcEU8C/AVOAP7
	+NVXQ8hukJBgM4eSl6Ytt/WNXUlM5bo0BBs70A0AilTT0gM1nA5DJ0ZTJNa7mxKd/BwcKvu999x
	IbqBbY3dZiXSy7ovcG1JpzJj14F2HHHU1xOU0p44jgOUROqHLcwtRn+f+DLX9c5ykqO9BntYIqk
	Jpd3OMcbpXoqW6IuPM9dhxo1gZMacZWhzVd4PyqxTM4ZSOjBxJAzmvEiF5UomUOsQpvBgS72SN2
	BavVIvaXTwfstucZiQCEQrnEAaNIdL5EQs0Sl7hXlgC68yX01le0QZwNDuPXggCE8JUVm8JWykh
	eSzEMto4MsQTfW8ERUOlw6KuaEZPrh5jc+LF3qV82LKvyH7CYz+rnROgYZJjKCS+XsF6BX5xiG1
	j
X-Received: by 2002:a25:a0ca:: with SMTP id i10mr30319185ybm.54.1549911681141;
        Mon, 11 Feb 2019 11:01:21 -0800 (PST)
X-Received: by 2002:a25:a0ca:: with SMTP id i10mr30319107ybm.54.1549911680367;
        Mon, 11 Feb 2019 11:01:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549911680; cv=none;
        d=google.com; s=arc-20160816;
        b=UtDYhbnek8IsC7AL4a+MfwJ0pW99Zj9onETQHfrmvm2eV9qPlmGwxO16zo4rgxnTw6
         Sh7Nnqrq+PJ0nYrmHE+0zaWVtGs5n+abEbJEoeSIkn7IIAIuplKiPyn6a4YMwh06s1ko
         NyZtqhM4HPYip+FwiZAk1Q98UbO4KdjInWl462iSGr064w5qn4SNixATC91qlPfkfVQs
         3vvi7+EYCZUuTOdXD9D5/1YoyBEWiISgXIptZaJPEyUV97IDZuiRWg5Dqoqcy1Jnn2yl
         XtrnnTHzIO9f3nXyC9xWw2BRdDI8HUvyUmSxG1z19+KuI3Xwy3EZSINobyCM6SF1mf8I
         wfOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=s09oajM8sRG6VR42JLX9NXyJV4gfvXuCrn6cD3FbZqw=;
        b=bU2XQlawBqSr7iRc/dUQY5ZGMQmSTBWiWiNVMUp1giOvth2W1z85zLgMczf6yl8/bZ
         fyCAnthOPwP+X3tE6/AG3FNIKMS+WZwflUQ7Hdc/NmIDlYhuO/rSnuorg1SmYdhxhUiT
         BR4zvg1Ms5pfN2/OziA/VgbYpOxzgihUCbAeEIs13DIz+Dh7+xhYcg2/U0hXK5ZmXtfV
         z1hedrayVIXt8IUn92AUEnfiggPe0W94bxxwYsGTEPZMww76uCxmzOT0+KOGQnSndaVq
         WNvQYcMwkZmmr5azLH2jKUKKXgnwgyccgBi+dwwSdmom2yt6mTEfGxY67UKUs7ymo+wm
         jmmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=fR9XwG2I;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l144sor1973481ywb.99.2019.02.11.11.01.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 11:01:17 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=fR9XwG2I;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=s09oajM8sRG6VR42JLX9NXyJV4gfvXuCrn6cD3FbZqw=;
        b=fR9XwG2IpAJnHWw0MPBfz0HAX7xH++BkHbFzdYsjyY2FzzSQFnOya2QKZoELQ/IC5O
         8Dk/hBPxZ0V9ikPopvPDe6YxClqHJSPNu1lZ87Q2cVLMHwm3C8kKQ6WVmLFZXPEsz3HR
         nk0JyG9P2MV9qyR1u2B3Xw3gJO/S9XhKwPznBWi+552PjkO8ma2qfoEUpctr7+xltiHq
         U0S6AsRR2MhGChi8V+igCAz55oV0a1ftWgNSfONzCoxSz9AXXndTZ37wJ/dMBqvXEFXY
         +XOiZ81yTVgf8Ej4uzhR7/jhIkE2VBZSgSaFyAlZwRqoU0RCaJewWGnOx0Db/jxAlBs3
         WMrg==
X-Google-Smtp-Source: AHgI3IZLVsFOrLYBm0wpfHBVnBwYPYDxF1jVhbzc5rUhM1jl1nqzmd8gWWaX9ycIHhhicOSxmCRd/w==
X-Received: by 2002:a81:a9ca:: with SMTP id g193mr30060659ywh.52.1549911677658;
        Mon, 11 Feb 2019 11:01:17 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:6e5])
        by smtp.gmail.com with ESMTPSA id h62sm4103600ywe.100.2019.02.11.11.01.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 11:01:16 -0800 (PST)
Date: Mon, 11 Feb 2019 14:01:15 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH v2 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190211190115.GC13953@cmpxchg.org>
References: <20190208224319.GA23801@chrisdown.name>
 <20190208224419.GA24772@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190208224419.GA24772@chrisdown.name>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2019 at 10:44:19PM +0000, Chris Down wrote:
> memory.stat and other files already consider subtrees in their output,
> and we should too in order to not present an inconsistent interface.
> 
> The current situation is fairly confusing, because people interacting
> with cgroups expect hierarchical behaviour in the vein of memory.stat,
> cgroup.events, and other files. For example, this causes confusion when
> debugging reclaim events under low, as currently these always read "0"
> at non-leaf memcg nodes, which frequently causes people to misdiagnose
> breach behaviour. The same confusion applies to other counters in this
> file when debugging issues.
> 
> Aggregation is done at write time instead of at read-time since these
> counters aren't hot (unlike memory.stat which is per-page, so it does it
> at read time), and it makes sense to bundle this with the file
> notifications.
> 
> After this patch, events are propagated up the hierarchy:
> 
>     [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
>     low 0
>     high 0
>     max 0
>     oom 0
>     oom_kill 0
>     [root@ktst ~]# systemd-run -p MemoryMax=1 true
>     Running as unit: run-r251162a189fb4562b9dabfdc9b0422f5.service
>     [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
>     low 0
>     high 0
>     max 7
>     oom 1
>     oom_kill 1
> 
> As this is a change in behaviour, this can be reverted to the old
> behaviour by mounting with the `memory_localevents` flag set. However,
> we use the new behaviour by default as there's a lack of evidence that
> there are any current users of memory.events that would find this change
> undesirable.
> 
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Dennis Zhou <dennis@kernel.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com

Acked-by: Johannes Weiner <hannes@cmpxchg.org>


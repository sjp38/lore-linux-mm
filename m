Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22D1AC48BE0
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 23:42:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C520621721
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 23:42:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sg+QN5Do"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C520621721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63DAB6B0003; Wed, 19 Jun 2019 19:42:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EE878E0002; Wed, 19 Jun 2019 19:42:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B6688E0001; Wed, 19 Jun 2019 19:42:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6156B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:42:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c17so596485pfb.21
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 16:42:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=vsbPrRbTy3n+9aeG6Y9WG7BmsjIf/GUTHi4GwNMBp8A=;
        b=SFxfb7SN6pQ6nNFMXR0IW2NYobGO0K98ZGl6jY7UpvwRGYnlgUl1VvtUm1NK1YER/7
         em22yNgrhqg87sj8eDJSxE1kWunYjf1w+qCkOPg4zzTGVBwEyhgR9luG1l2m/OoCZdWZ
         RkFUj20l3h16KOFbxp9reSXzan2drQ9Y4sbqlFUJ8SURVc5gcEZsiF4CyLG6hEwp3+bS
         bi+azz4NZxgwU+sIXYtplqU9KmwAPa3HU1V1Yqgi095g0NIeOL/+m1Zb7S8M/HpOhYcB
         Sw0X6o68cV/QKPsMIxhgy9v8+j9JcCxiyHKGuastEpNfEaToEFAegY/u/k0SKL0mqOB1
         +ipQ==
X-Gm-Message-State: APjAAAWaE0GpaDqEAjEHC1qzdYsgk75yUqwbm4bO2QFA49T8AgK7Bmw4
	1GTTlMVyH4mwOuLWbsYbLCry73pjU11wGzRP60HHYIDEKND0nIW8OzAA8G38gzuqdGEay8XWS4q
	b+NKpqlFGwF3bM+tOcV6LLY8E0+7UiU5jhTa6f3/jyDrL7CUiA9K4k2n/xBfH7f0=
X-Received: by 2002:a17:902:d695:: with SMTP id v21mr103089115ply.342.1560987766496;
        Wed, 19 Jun 2019 16:42:46 -0700 (PDT)
X-Received: by 2002:a17:902:d695:: with SMTP id v21mr103089044ply.342.1560987765598;
        Wed, 19 Jun 2019 16:42:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560987765; cv=none;
        d=google.com; s=arc-20160816;
        b=JCZEmA1friVP1QS9y+W3qpds+4kqCXHdWnFdMwbzD7NnJehxPwArQMIFh3cP+l74NJ
         7pghHQc0Y3LXOK7TjVe0thnqXW8Ma7RgU9PHs6LiRpg0YeH8SeHJGk1BwMugWFy7jwqF
         FHgtkZ6D3HtRc1xDlrMiRqHpZS8bJGSXFoUkEyDLT8/o+xGaoMSvWUco821MKg4Q/yg6
         j5QZtwhJi4bxPiMjh/5qcZq5gN9RKDjw0WFkIfuqScteHZVahZUTX4dsPyeeqxvpt9c+
         a6IeI6O1UwK7fb5v/Lxuar2NwnqunY/P4CLYUxJ0fPkWH3Ph7qHRZHQuw6P9hx1d8gls
         aLSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=vsbPrRbTy3n+9aeG6Y9WG7BmsjIf/GUTHi4GwNMBp8A=;
        b=o5BTU4epBN+scZw4ry370+B11T1j1kOIik38w0lMxBGnqXUQq7MVzqMajE+IXr6L92
         YhPZHHgHEl5E0FChfcajXGNdJ3YpmI+Lvu1zNfoB2TaeRFHCy/AjPdHS/fI6upFIZxiQ
         /x2lGSxUECidMfeee77NBHCysn1sKnpwN8WJxSGxNOXIdyoP96a8I7BifmJJjUqZB3X1
         nVyptWb2fc683H04YBsrv5s4jnJlD6XCFzbEN63wf9nAa/U+0L4+WV44Q718Kv1yFwuV
         2e3wpx+F9rJqofE2gRGrk/TWtmXEqzQgS/UMovMXkWc/9LOdY54dSfcvVrbkHkqzAYXq
         HLaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sg+QN5Do;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id go5sor23199387plb.37.2019.06.19.16.42.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 16:42:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sg+QN5Do;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=vsbPrRbTy3n+9aeG6Y9WG7BmsjIf/GUTHi4GwNMBp8A=;
        b=sg+QN5DojLMGxQQDCS+jGFwhnp/TLRwrvzhYpTG6Y8H8qxN1UxurIXe/OVcpscALku
         SR2IxIhu/MpK1E3IjWjSfb6Q+Utkc8F1Iwi1LmQnJn1AYZz+AfCDrMwA0ujfRwE+Y4c4
         DDfalXES/sc+uvLmUCV2D9QDn6sJYQEQfb/aSJw7KNMNyS5k9mpd8eX5p+dTK9T9rsaj
         Fz0D3SQxIJsjtrx2EF+EKZodWobX20P5cOeF/oE8xnlZU1E+Dyv0xPVPRqoWTugLsZYd
         EjDQOAGCnfUANmgZBT8o3qvxaYgeL2frTMIUj6me0ApUAM9fwlHOYDQJL/8Lt8h0hEXI
         dO9w==
X-Google-Smtp-Source: APXvYqyBFSgDTUXU7wAhb9dojUkivR3grLasbuyIhBXnxjA2gqQw71aDb1O3j7rkdX9uurouxgzQvg==
X-Received: by 2002:a17:902:d887:: with SMTP id b7mr15509236plz.28.1560987765105;
        Wed, 19 Jun 2019 16:42:45 -0700 (PDT)
Received: from google.com ([122.38.223.241])
        by smtp.gmail.com with ESMTPSA id j1sm21890149pfe.101.2019.06.19.16.42.38
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 16:42:43 -0700 (PDT)
Date: Thu, 20 Jun 2019 08:42:35 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, lizeb@google.com
Subject: Re: [PATCH v2 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Message-ID: <20190619234235.GA52978@google.com>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190619122750.GN2968@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190619122750.GN2968@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 02:27:50PM +0200, Michal Hocko wrote:
> On Mon 10-06-19 20:12:47, Minchan Kim wrote:
> > This patch is part of previous series:
> > https://lore.kernel.org/lkml/20190531064313.193437-1-minchan@kernel.org/T/#u
> > Originally, it was created for external madvise hinting feature.
> > 
> > https://lkml.org/lkml/2019/5/31/463
> > Michal wanted to separte the discussion from external hinting interface
> > so this patchset includes only first part of my entire patchset
> > 
> >   - introduce MADV_COLD and MADV_PAGEOUT hint to madvise.
> > 
> > However, I keep entire description for others for easier understanding
> > why this kinds of hint was born.
> > 
> > Thanks.
> > 
> > This patchset is against on next-20190530.
> > 
> > Below is description of previous entire patchset.
> > ================= &< =====================
> > 
> > - Background
> > 
> > The Android terminology used for forking a new process and starting an app
> > from scratch is a cold start, while resuming an existing app is a hot start.
> > While we continually try to improve the performance of cold starts, hot
> > starts will always be significantly less power hungry as well as faster so
> > we are trying to make hot start more likely than cold start.
> > 
> > To increase hot start, Android userspace manages the order that apps should
> > be killed in a process called ActivityManagerService. ActivityManagerService
> > tracks every Android app or service that the user could be interacting with
> > at any time and translates that into a ranked list for lmkd(low memory
> > killer daemon). They are likely to be killed by lmkd if the system has to
> > reclaim memory. In that sense they are similar to entries in any other cache.
> > Those apps are kept alive for opportunistic performance improvements but
> > those performance improvements will vary based on the memory requirements of
> > individual workloads.
> > 
> > - Problem
> > 
> > Naturally, cached apps were dominant consumers of memory on the system.
> > However, they were not significant consumers of swap even though they are
> > good candidate for swap. Under investigation, swapping out only begins
> > once the low zone watermark is hit and kswapd wakes up, but the overall
> > allocation rate in the system might trip lmkd thresholds and cause a cached
> > process to be killed(we measured performance swapping out vs. zapping the
> > memory by killing a process. Unsurprisingly, zapping is 10x times faster
> > even though we use zram which is much faster than real storage) so kill
> > from lmkd will often satisfy the high zone watermark, resulting in very
> > few pages actually being moved to swap.
> > 
> > - Approach
> > 
> > The approach we chose was to use a new interface to allow userspace to
> > proactively reclaim entire processes by leveraging platform information.
> > This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
> > that are known to be cold from userspace and to avoid races with lmkd
> > by reclaiming apps as soon as they entered the cached state. Additionally,
> > it could provide many chances for platform to use much information to
> > optimize memory efficiency.
> > 
> > To achieve the goal, the patchset introduce two new options for madvise.
> > One is MADV_COLD which will deactivate activated pages and the other is
> > MADV_PAGEOUT which will reclaim private pages instantly. These new options
> > complement MADV_DONTNEED and MADV_FREE by adding non-destructive ways to
> > gain some free memory space. MADV_PAGEOUT is similar to MADV_DONTNEED in a way
> > that it hints the kernel that memory region is not currently needed and
> > should be reclaimed immediately; MADV_COLD is similar to MADV_FREE in a way
> > that it hints the kernel that memory region is not currently needed and
> > should be reclaimed when memory pressure rises.
> 
> This all is a very good background information suitable for the cover
> letter.
> 
> > This approach is similar in spirit to madvise(MADV_WONTNEED), but the
> > information required to make the reclaim decision is not known to the app.
> > Instead, it is known to a centralized userspace daemon, and that daemon
> > must be able to initiate reclaim on its own without any app involvement.
> > To solve the concern, this patch introduces new syscall -
> > 
> >     struct pr_madvise_param {
> >             int size;               /* the size of this structure */
> >             int cookie;             /* reserved to support atomicity */
> >             int nr_elem;            /* count of below arrary fields */
> >             int __user *hints;      /* hints for each range */
> >             /* to store result of each operation */
> >             const struct iovec __user *results;
> >             /* input address ranges */
> >             const struct iovec __user *ranges;
> >     };
> >     
> >     int process_madvise(int pidfd, struct pr_madvise_param *u_param,
> >                             unsigned long flags);
> 
> But this and the following paragraphs are referring to the later step
> when the madvise gains a remote process capabilities and that is out
> of the scope of this patch series so I would simply remove it from
> here. Andrew tends to put the cover letter into the first patch of the
> series and that would be indeed
> confusing here.

Okay, I will remove the part in next revision.


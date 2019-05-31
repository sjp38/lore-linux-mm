Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B4D4C28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 13:44:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52A7C269B9
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 13:44:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZEX8PNbz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52A7C269B9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2A826B0007; Fri, 31 May 2019 09:44:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDA7E6B026A; Fri, 31 May 2019 09:44:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA2526B027A; Fri, 31 May 2019 09:44:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 72EEF6B0007
	for <linux-mm@kvack.org>; Fri, 31 May 2019 09:44:58 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x5so7428073pfi.5
        for <linux-mm@kvack.org>; Fri, 31 May 2019 06:44:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=vPbIIJuyYstqKudbEw2Wc+jcaMTMVd97T1l4e8lD3KA=;
        b=iVd2wiEel8hFzHUcty1h4PmPlJKEys6GMn70OJuUja474ukYskLj+A+ieJNWtDPbOE
         xzvlyIdgH6qQH//EgFJNNeZ2qBEvJX6dlIKEQHcPjha6Npf0dhJ3mY6UujCMu2arQeSQ
         pLBBxp5htxc+8k/PMBxihLR1FhAyV0xLml4rkgb0ESGJPVheVxru1LRO2foYngEfBjnN
         3TmcI+H65SbIFi1IJ5kbV0/wooMp7SDh6+555dnoA76tlrJFnngqCk5yz/Hlqm+bUOxi
         YabL4r16QTvhzB+ICxK0wqVvGtkJ9s82pIraPDRKFou7PlTXkJCR693v8fxjK9VtL5/n
         B/Zg==
X-Gm-Message-State: APjAAAXfSelVGVoTrAGOvvcCHp451maTqqgwsjF2tx7SYPeYJ6BlCRxt
	We5quXM2PLV1XfSix0Fn5TTcIz4zHP5J5uI+8UFfO8oA+QHHxnMkYGF/la10gQmtRmrbFZXOSeC
	fDbMx9H7LUVFZrELYDMA5iu9bu7kf/TvBJ7mwQcJ4/1AwZ6fx8lWLWivuGhWzrGc=
X-Received: by 2002:a17:902:42e2:: with SMTP id h89mr9665206pld.332.1559310298060;
        Fri, 31 May 2019 06:44:58 -0700 (PDT)
X-Received: by 2002:a17:902:42e2:: with SMTP id h89mr9665148pld.332.1559310297310;
        Fri, 31 May 2019 06:44:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559310297; cv=none;
        d=google.com; s=arc-20160816;
        b=juYcH0co1vD/dKbka+C167l2xSeCRboWxCxPa6qd1BbS2fVRK3LnXU+9iRVwJbKMgK
         e1ETionuOeTKero9v0uaGn6oOj8LQBpC7CNwu+WeJCqYBvuRSRuJ47IfVUsbyldQT9yq
         f2Y9WPwR6KmgGozEUphy78D9DLFIOei9ByBBjlV3eM6+51dG28+njr+3bJbhkWksOhBz
         QPC23sWvzZ8VJV2ZM9Q9O8Ds99LmDm9ciKTYhFhlxe5Donwbd6Hj+xw3aW+11YVR8ARG
         ZXK3InUvhKh/DjNDoSwNVtxAFAIYWiJ36bHhhUR8Mf16agqXcRIWZgLxRKjBX+Du0PwW
         KHRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=vPbIIJuyYstqKudbEw2Wc+jcaMTMVd97T1l4e8lD3KA=;
        b=MXm3efd7nBPtiluIZtTiG3amVZPe1GJWqzYqyzKamh+OMDwG/89N/WHVnbGJ5o7X+i
         jLbNu5Urv+I6v6HburB9qmAjLOdW2YwEFzHyPbA57O0CgT5rB04V73YJ3RgK9bjkpfC1
         Q8uM6yyKxTCSduIUoIMVV2l9MiEiIU7U/AcPg7uJkltcgcGIt6muYxd7sJYdtAwKRzGE
         sGojTtDuyJqDuC49876nlUN2TF/VJi7I3xrDxE7kKMc7gr4YnwyZVcCPy2iSnn1/wTh1
         WMTXuA5Iql5EQ7BezKl9UHruGgnOk82tK2ZGHNK7VCOgjLqmT6EqZdus0lChWjDmm5oI
         SAwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZEX8PNbz;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u40sor3135520pjb.2.2019.05.31.06.44.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 06:44:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZEX8PNbz;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=vPbIIJuyYstqKudbEw2Wc+jcaMTMVd97T1l4e8lD3KA=;
        b=ZEX8PNbz0qOV4voBBdbFmKU8Z61+Kq1IWhx5JPVytMYOvYTBT5KAWMYHlQHpuKdgSg
         HSrAx8xuwmobu/aN7G69ZUXBZGFsZAZKV9Jwh7R86aeFbLWpR61w1dIFZRGmCJEQeIJX
         cWE9s+nnWFabfC6BKmM5q+lzvE9zelYV4BIrEjFfbqCw6jo4BlTEpDpeVU9ZNlUskaZE
         QxrQ3Kle9nm1Vhb7WtfmtLmGs/xkMXVJASxfRSvUPhsmiQFlY+5ygS1PjZUquJEC4CoC
         ODl+QIaQ/YQt/Fyrhd0r1FX06SAFd8tvZi3XzPE6c2gDd+30+cy7tWw0Q6OCeGgjV+/u
         6ZGw==
X-Google-Smtp-Source: APXvYqwQVdzt+MDB8OA82hnznf1kjVB0kSuwffl4tojHdIoAaLiUvdyrPZr97mrwWIcFKVij7mYIJw==
X-Received: by 2002:a17:90a:9382:: with SMTP id q2mr9524146pjo.131.1559310296875;
        Fri, 31 May 2019 06:44:56 -0700 (PDT)
Received: from google.com ([122.38.223.241])
        by smtp.gmail.com with ESMTPSA id g83sm6546532pfb.158.2019.05.31.06.44.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 31 May 2019 06:44:55 -0700 (PDT)
Date: Fri, 31 May 2019 22:44:47 +0900
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
	hdanton@sina.com
Subject: Re: [RFCv2 3/6] mm: introduce MADV_PAGEOUT
Message-ID: <20190531134447.GD195463@google.com>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-4-minchan@kernel.org>
 <20190531085044.GJ6896@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531085044.GJ6896@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 10:50:44AM +0200, Michal Hocko wrote:
> On Fri 31-05-19 15:43:10, Minchan Kim wrote:
> > When a process expects no accesses to a certain memory range
> > for a long time, it could hint kernel that the pages can be
> > reclaimed instantly but data should be preserved for future use.
> > This could reduce workingset eviction so it ends up increasing
> > performance.
> > 
> > This patch introduces the new MADV_PAGEOUT hint to madvise(2)
> > syscall. MADV_PAGEOUT can be used by a process to mark a memory
> > range as not expected to be used for a long time so that kernel
> > reclaims the memory instantly. The hint can help kernel in deciding
> > which pages to evict proactively.
> 
> Again, are there any restictions on what kind of memory can be paged out?
> Private/Shared, anonymous/file backed. Any restrictions on mapping type.
> Etc. Please make sure all that is in the changelog.

It's same with MADV_COLD. Yes, I will include all detail in the
description.

> 
> What are the failure modes? E.g. what if the swap is full, does the call
> fails or it silently ignores the error?

In such case, just ignore the swapout. It returns -EINVAL only if the
vma is one of (VM_LOCKED|VM_HUGETLB|VM_PFNMAP) at this moment.

> 
> Thanks!
> -- 
> Michal Hocko
> SUSE Labs


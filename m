Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC420C169C4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 01:01:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D71D20844
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 01:01:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D71D20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0997B8E0007; Tue, 29 Jan 2019 20:01:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 048498E0001; Tue, 29 Jan 2019 20:01:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2CBB8E0007; Tue, 29 Jan 2019 20:01:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9547A8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 20:01:53 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id t26so15097014pgu.18
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 17:01:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yDkuNqMe2lspjjBeEgNb9liwmn5z0jBNU7alD0vWOCs=;
        b=PgKq/pf11pxUUxnsyUoEVABuppkcb3FIBR+Z0bMRvUxOB7zIaAkfW/GztyegQCNfIb
         7OgB20/01dOG8ls8yoOSu8rHKEgT+FuyYrqGpsmc0OirP4hZPC4LH1L7e/i0sJwTgkEh
         8AwvTU+xp9jcB7HkydHzZA0gfPejcPmuVWGGfLnOJcoUhaK/V978/AM1RTnCeIbYUg2t
         mHps+HgGz7NIpTMJihxfJhYNBYYrREd57drXMc0Th3qYuNkEPou0VWcQO+f1mxJPHOpB
         W+pq7LxELw0+I4u7z4/q3ulnlId2t7aW5Ifvvww03arU3UbVwbBed9dF+2IJ9Y0lierK
         LRSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukcLx+8nal6VPvGp6fZE+iNvoWThD/caXJNj7Gbw0f/plXV+nJX+
	doIKcvUNHANszmgM9Sm5pqPmXJH7P9yYHmtjk8hyOEKVEOL8dye+c6ASUheOxISe8lsCYXeYtex
	QzEl5dm56puDrWfiIQEWvoiZDNBigqKJHUHkEkA33M/W+6h/YOLCJFas1O0bsrjP8mQ==
X-Received: by 2002:a17:902:12f:: with SMTP id 44mr28667818plb.74.1548810113222;
        Tue, 29 Jan 2019 17:01:53 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7U0WMswPP+P3icTSVZB2zVi1oXLYr7FDGdAtuZyT1ecS0p/agI+LGLILTrS/de/rXzsS92
X-Received: by 2002:a17:902:12f:: with SMTP id 44mr28667753plb.74.1548810112182;
        Tue, 29 Jan 2019 17:01:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548810112; cv=none;
        d=google.com; s=arc-20160816;
        b=EpsPZvn5D9VDz60lE/ph9Ug8dNiwg9NEFPI9kp2qS39pFCRXVUiv22Sf4oTo6s4Z03
         QHi3pzA+GKFyjfqM1ITV6qyTz/KtqnW5nOjdjUlzewmwE/4cZ1qoV1fY6iZWlp1XjbJI
         ZlaIRyvfinC+/jDJ3YH9IJRcGM08GJ7BPh3dzfMP+3jNpJewkqDudXbBBbJlJa5x+Qxt
         2AbPamFPOqn6sLc93QoIJ4MiMsfzGR4MyH4AxlSB/O4nyye0n5JtKPO076hpUsyqMgjN
         bHLmQCdecB3HoSADv2GOiFSS4J0TLFwyfqixwlKjGqnGnpCDNrlrL5GNr9gyU+47w68g
         ocEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=yDkuNqMe2lspjjBeEgNb9liwmn5z0jBNU7alD0vWOCs=;
        b=0B2WQPedof2a/P0hKxRBa1Ks+MK/hPph+lrKzqSs+tBOJtp0XWNwFnIEQYJX+WJlUW
         fIFGhghyZuXPP9kBzQJrobdc4rDCsgvcQ3xk9m7AfAX/LY9Eu1mjWe04/rjtOiyDF/OW
         jRZA18bpC0t6/p2VcjwT7+DGr2BdKFit7SJ2S4O/1NLQNE8ySWcb7C5S6P66uomUHuxu
         Pcj7Ev3+WbU6lKX5PaKEoQIKKOVXfhmvB4AAr2O4a6c0Cm+qXGEkjxiK+HYOck2b4FKM
         UKXaJW0B25AZqaS20ILOn+xrRKR+SSbkovcbJaxkN0ltbXQazwPI8PU//kZlwnmI7VzO
         uOIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 37si36011576pgw.590.2019.01.29.17.01.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 17:01:52 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 942E73230;
	Wed, 30 Jan 2019 01:01:51 +0000 (UTC)
Date: Tue, 29 Jan 2019 17:01:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Yang Shi <shy828301@gmail.com>, Jiufei Xue
 <jiufei.xue@linux.alibaba.com>, Linux MM <linux-mm@kvack.org>,
 joseph.qi@linux.alibaba.com, Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
Message-Id: <20190129170150.57021080bdfd3a46a479d45d@linux-foundation.org>
In-Reply-To: <201901300042.x0U0g6EH085874@www262.sakura.ne.jp>
References: <b9781d8e-88f7-efc0-3a3c-76d8e7937f10@i-love.sakura.ne.jp>
	<CAHbLzkots=t69A8VmE=gRezSUuyk1-F9RV8uy6Q7Bhcmv6PRJw@mail.gmail.com>
	<201901300042.x0U0g6EH085874@www262.sakura.ne.jp>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2019 09:42:06 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:

> > >
> > > If we want to allow vfree() to sleep, at least we need to test with
> > > kvmalloc() == vmalloc() (i.e. force kvmalloc()/kvfree() users to use
> > > vmalloc()/vfree() path). For now, reverting the
> > > "Context: Either preemptible task context or not-NMI interrupt." change
> > > will be needed for stable kernels.
> > 
> > So, the comment for vfree "May sleep if called *not* from interrupt
> > context." is wrong?
> 
> Commit bf22e37a641327e3 ("mm: add vfree_atomic()") says
> 
>     We are going to use sleeping lock for freeing vmap.  However some
>     vfree() users want to free memory from atomic (but not from interrupt)
>     context.  For this we add vfree_atomic() - deferred variation of vfree()
>     which can be used in any atomic context (except NMIs).
> 
> and commit 52414d3302577bb6 ("kvfree(): fix misleading comment") made
> 
>     - * Context: Any context except NMI.
>     + * Context: Either preemptible task context or not-NMI interrupt.
> 
> change. But I think that we converted kmalloc() to kvmalloc() without checking
> context of kvfree() callers. Therefore, I think that kvfree() needs to use
> vfree_atomic() rather than just saying "vfree() might sleep if called not in
> interrupt context."...

Whereabouts in the vfree() path can the kernel sleep?


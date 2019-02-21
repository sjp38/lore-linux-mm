Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33A3DC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:37:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F17522081B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:37:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F17522081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FE7E8E00AA; Thu, 21 Feb 2019 13:37:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AE5E8E00A9; Thu, 21 Feb 2019 13:37:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69D938E00AA; Thu, 21 Feb 2019 13:37:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D79D8E00A9
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:37:05 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a11so5964252qkk.10
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:37:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=naKN0UERkQ8ykVW7tk3elqaXbshFw+KqLYT2XwVsjxM=;
        b=Bw9Km0DyqJX2dgdTvibLYGYaUjAk73nOl56gd7hbOzaRLgfM7/C5H3E4wZG+3SlhUE
         MaZYyu/iBoQ/LKwSfUrdsb8VkUxD3AJcSDvrmeCTHkb9GIgeE5JBRsz+k6iaDRiMUJCu
         Jw/2aaoWtzhufssWGdOFJtbiO6bRNc5SAYoCWU+u+pqUl6uXg5RUxjdfSoHs8h5upDiu
         h3peQAMpei16rHINTmTirBASiN6K6OkW9+KT04heixMTZ2p6l40SFOinwTcLSu9mI+Ut
         bAxmfUtxH3xmzYNE1TnjeoBRBVK1HbgTdQz3gbjwKF4aKwOw8rofC4O49WsjZ+/jh8Jt
         FFNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaICXErALvhCvHVZvS4++/bkXt8V8McIWB6fF2Lwg3bQxXNlDS3
	VjRZGr4kxCgNGOKJEiKsbaAf+hzBINuNasdmDvSxrlRRdXgzBqFUqX6tj+qICfqyyT2E5Kjl4e/
	WXtYxZq712/gVEL1DJ++wgl5LsMkuhPNZCr9r4JN5oUvWSGxWJ9ncKGFTPG5hZfxmlw==
X-Received: by 2002:aed:3f5d:: with SMTP id q29mr31637327qtf.193.1550774225029;
        Thu, 21 Feb 2019 10:37:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ6WR24TWbrpELXnMNXJ96/y3ZWI95oz+iNFvm1Atg/Vdj4iGl72rq8SkuJ+DecC3Bw2EyZ
X-Received: by 2002:aed:3f5d:: with SMTP id q29mr31637297qtf.193.1550774224514;
        Thu, 21 Feb 2019 10:37:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550774224; cv=none;
        d=google.com; s=arc-20160816;
        b=QKacW5J3f3opJWf83MUnzfsORDsnw9TkHoYTbe0cO/O46NL7FBqk4CBgh8FjBSdhpV
         51LRel2bg/uH1nNxbbRqnO5vqx0U8w7mWfiR4ilT/jw9+eSAVOnxiC0F5kecMxXUG3SF
         +1UPut3KrZO0Nsd20ZR31MtWs7Z7m4gncIYANujCjtpx3QOYsEJl4Ifj76MgEamFxYmQ
         jZ/3mcItZoskCdkMtAt7jrNqZPAF82CstN9l3NYHVypPefvPL5bsGmjimlrqKlavEU31
         Ze6w6EJvhAdxVNrtoG1BsDNjOLGTQmFLInOU4BJ21nSeUDoVkQOBN+8qT33u3T6szdb0
         Udzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=naKN0UERkQ8ykVW7tk3elqaXbshFw+KqLYT2XwVsjxM=;
        b=lAL+A/ADgWPmADDsi4PVqp8yPpZYswVtmmbZmKZOrUYRsSoYG3DKfq0k5PUvB4nkYj
         Jdu8fX74pHC5Ye6s8IPp02BrCTJtLHe1wQH9mG1S1tMXskVElc/YsWe45rjgbG6ZOyZX
         kIhVsvDgGe1LwMIi77x5Q+iO6YckXjsY2Psm6iZ+qV+Afc/fAbYFgbaoOIkYx1tI/kgx
         /qMHdSh/H7zJsjdewTueA7nssooVp4zsu4GkiEXjTZ6kqIN4sTMw8hi7vbvYW9SWb4U3
         AMW++Iap+ORqkqAfOdyvEs9In3VNmWIEvIheiX/VdOlK7qB3BT/Icyzk/aFNNskkoNJx
         juVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b19si2833999qtr.236.2019.02.21.10.37.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 10:37:04 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3E3DF3086275;
	Thu, 21 Feb 2019 18:37:03 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id EA0B460139;
	Thu, 21 Feb 2019 18:36:55 +0000 (UTC)
Date: Thu, 21 Feb 2019 13:36:54 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 23/26] userfaultfd: wp: don't wake up when doing write
 protect
Message-ID: <20190221183653.GV2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-24-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-24-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 21 Feb 2019 18:37:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:29AM +0800, Peter Xu wrote:
> It does not make sense to try to wake up any waiting thread when we're
> write-protecting a memory region.  Only wake up when resolving a write
> protected page fault.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

I am bit confuse here, see below.

> ---
>  fs/userfaultfd.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 81962d62520c..f1f61a0278c2 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1771,6 +1771,7 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
>  	struct uffdio_writeprotect uffdio_wp;
>  	struct uffdio_writeprotect __user *user_uffdio_wp;
>  	struct userfaultfd_wake_range range;
> +	bool mode_wp, mode_dontwake;
>  
>  	if (READ_ONCE(ctx->mmap_changing))
>  		return -EAGAIN;
> @@ -1789,18 +1790,20 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
>  	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
>  			       UFFDIO_WRITEPROTECT_MODE_WP))
>  		return -EINVAL;
> -	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
> -	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
> +
> +	mode_wp = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP;
> +	mode_dontwake = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE;
> +
> +	if (mode_wp && mode_dontwake)
>  		return -EINVAL;

I am confuse by the logic here. DONTWAKE means do not wake any waiting
thread right ? So if the patch header it seems to me the logic should
be:
    if (mode_wp && !mode_dontwake)
        return -EINVAL;

At very least this part does seems to mean the opposite of what the
commit message says.

>  
>  	ret = mwriteprotect_range(ctx->mm, uffdio_wp.range.start,
> -				  uffdio_wp.range.len, uffdio_wp.mode &
> -				  UFFDIO_WRITEPROTECT_MODE_WP,
> +				  uffdio_wp.range.len, mode_wp,
>  				  &ctx->mmap_changing);
>  	if (ret)
>  		return ret;
>  
> -	if (!(uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE)) {
> +	if (!mode_wp && !mode_dontwake) {

This part match the commit message :)

>  		range.start = uffdio_wp.range.start;
>  		range.len = uffdio_wp.range.len;
>  		wake_userfault(ctx, &range);


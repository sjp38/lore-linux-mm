Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88225C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:11:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 138A1217D7
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:11:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 138A1217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 734B86B000A; Thu, 18 Apr 2019 16:11:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E3E36B000C; Thu, 18 Apr 2019 16:11:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F8306B000D; Thu, 18 Apr 2019 16:11:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1566B000A
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 16:11:20 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f15so3013338qtk.16
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 13:11:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=H/aXzFageHdJx7IQHj2g5t2gSFQM8/nuv4ywYipgyRQ=;
        b=aNXcqSNd7s/6/o6mKVYIpvl5V7MK28/oUQgo69uitDagv/nPxnpElFXD/o4CoKno+Z
         iLWlCnGCCkbqW3L6EDIqsX88+735COnxnmF+a0GEX4xmzyq6ia0iK05sqaxTPKVUnsTV
         DhAUMZJ3onK/IJJDZH69zW3BbWxoKOmpKP56T/F+apJGpCT2Uve2veGrxGKKSj3ERT9C
         rCGB8zfGyH+yeMQB9BvcnfXqfQNNbWEOdysUnt45azYYVZgMrWypmT6U7HJbRr328DiW
         hvWiQOsAxzqJsuyxTmF1dLoFc2CSY4OkU9Jpqj/sjrx+RGxnx1e6qSwfBwMF7sHBlP3q
         eEHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU33npCTdwjK6gzp7jJ8WlPQNZOQB9gQdInlSrRCx+NTp4C9chE
	MiMlhAwH8IhXMBelyW8j0gT4iEiNvgeTJE4YR2UZzqbgLG+QCrRY+p3Sd3k3w1qNtaYFZGpURdi
	BJ5cNMFRe0mg4FP1c5VgOGPJ9Wy4xG1yEoAvFfztax0UOdaYL3h6D+X5Gbpc4t0BcfQ==
X-Received: by 2002:aed:35e4:: with SMTP id d33mr76817821qte.58.1555618279944;
        Thu, 18 Apr 2019 13:11:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwx8H6NueZttuLPvoO/nOLI/cJAK5tOzb0Mpgvu9OYr65z8dqL+c9a7OuLZrp/HSm8Gmumh
X-Received: by 2002:aed:35e4:: with SMTP id d33mr76817746qte.58.1555618279034;
        Thu, 18 Apr 2019 13:11:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555618279; cv=none;
        d=google.com; s=arc-20160816;
        b=nvJK3IkBdIgkbI2xMN4pMPvonAk1Vv4AnrQ9bJFZd+O2PCeQQv6OgjlgO3ZRXbcfcA
         HWlrxr24DG/yWYmAjzzat+iA6F46KH7ZWxwnbTmxXLcPLCWxbaHOPjFDIE7Ha+bgCmdc
         MizAVPPhS35czkEtrun3ocuZ+UWPY7+szcrBJIPniaDD/SRjj5fiiacOWA6Cea8kIDma
         RON+dV8fj2IeubzPSX7aCsOo8fi0UGuEWCDLD1KcSV9F4nbSiskSWjMsQrCkChnCZX19
         hl4Ie/3z1ndfVShd4qrLdk06Al/5iVS4b98Y9qqUk42Mm8XWVvrYWp2rqFLMX/WuiNsK
         YGBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=H/aXzFageHdJx7IQHj2g5t2gSFQM8/nuv4ywYipgyRQ=;
        b=z/Ied3f7yb4w2AoAi1UM9QtZYmxtH0uH1py46pCMRCNNYI2XrkIgLcQOmKHYQZXfOM
         v7J2bb0tkwTCwK7WDasR7ZsAchq1fuPbrHgdcpB6QzIXqq57Qe3ak8wQlcf2HKtV+QSm
         0OIp4O8zPgwIY5jqt+9MUXjHn4etxLUPvN1Wn/dgMe23PKi63W7u1uNf8paNn7JF6bB+
         KuGSAOyKQbiN/JUBLscdJ6BZRIHa1gjFFhp89jkQiKOGTCmScAk7DFUBi1VWDXoHb6Ci
         yZzu/VHYJdZqcXbfrLpFSabzhMModQgxiuBsz+rIuo07nuLPXZkXU/Z3xw3w4T+Bl8aW
         FgVA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f17si1825324qkk.12.2019.04.18.13.11.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 13:11:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D3A7D3001A73;
	Thu, 18 Apr 2019 20:11:17 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5476119C7B;
	Thu, 18 Apr 2019 20:11:10 +0000 (UTC)
Date: Thu, 18 Apr 2019 16:11:08 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v3 04/28] mm: allow VM_FAULT_RETRY for multiple times
Message-ID: <20190418201108.GJ3288@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-5-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190320020642.4000-5-peterx@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 18 Apr 2019 20:11:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 10:06:18AM +0800, Peter Xu wrote:
> The idea comes from a discussion between Linus and Andrea [1].
> 
> Before this patch we only allow a page fault to retry once.  We
> achieved this by clearing the FAULT_FLAG_ALLOW_RETRY flag when doing
> handle_mm_fault() the second time.  This was majorly used to avoid
> unexpected starvation of the system by looping over forever to handle
> the page fault on a single page.  However that should hardly happen,
> and after all for each code path to return a VM_FAULT_RETRY we'll
> first wait for a condition (during which time we should possibly yield
> the cpu) to happen before VM_FAULT_RETRY is really returned.
> 
> This patch removes the restriction by keeping the
> FAULT_FLAG_ALLOW_RETRY flag when we receive VM_FAULT_RETRY.  It means
> that the page fault handler now can retry the page fault for multiple
> times if necessary without the need to generate another page fault
> event.  Meanwhile we still keep the FAULT_FLAG_TRIED flag so page
> fault handler can still identify whether a page fault is the first
> attempt or not.
> 
> Then we'll have these combinations of fault flags (only considering
> ALLOW_RETRY flag and TRIED flag):
> 
>   - ALLOW_RETRY and !TRIED:  this means the page fault allows to
>                              retry, and this is the first try
> 
>   - ALLOW_RETRY and TRIED:   this means the page fault allows to
>                              retry, and this is not the first try
> 
>   - !ALLOW_RETRY and !TRIED: this means the page fault does not allow
>                              to retry at all
> 
>   - !ALLOW_RETRY and TRIED:  this is forbidden and should never be used
> 
> In existing code we have multiple places that has taken special care
> of the first condition above by checking against (fault_flags &
> FAULT_FLAG_ALLOW_RETRY).  This patch introduces a simple helper to
> detect the first retry of a page fault by checking against
> both (fault_flags & FAULT_FLAG_ALLOW_RETRY) and !(fault_flag &
> FAULT_FLAG_TRIED) because now even the 2nd try will have the
> ALLOW_RETRY set, then use that helper in all existing special paths.
> One example is in __lock_page_or_retry(), now we'll drop the mmap_sem
> only in the first attempt of page fault and we'll keep it in follow up
> retries, so old locking behavior will be retained.
> 
> This will be a nice enhancement for current code [2] at the same time
> a supporting material for the future userfaultfd-writeprotect work,
> since in that work there will always be an explicit userfault
> writeprotect retry for protected pages, and if that cannot resolve the
> page fault (e.g., when userfaultfd-writeprotect is used in conjunction
> with swapped pages) then we'll possibly need a 3rd retry of the page
> fault.  It might also benefit other potential users who will have
> similar requirement like userfault write-protection.
> 
> GUP code is not touched yet and will be covered in follow up patch.
> 
> Please read the thread below for more information.
> 
> [1] https://lkml.org/lkml/2017/11/2/833
> [2] https://lkml.org/lkml/2018/12/30/64
> 
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

A minor comment suggestion below but it can be fix in a followup patch.

[...]

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 80bb6408fe73..f73dbc4a1957 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -336,16 +336,52 @@ extern unsigned int kobjsize(const void *objp);
>   */
>  extern pgprot_t protection_map[16];
>  
> +/*
> + * About FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_TRIED: we can specify whether we
> + * would allow page faults to retry by specifying these two fault flags
> + * correctly.  Currently there can be three legal combinations:
> + *
> + * (a) ALLOW_RETRY and !TRIED:  this means the page fault allows retry, and
> + *                              this is the first try
> + *
> + * (b) ALLOW_RETRY and TRIED:   this means the page fault allows retry, and
> + *                              we've already tried at least once
> + *
> + * (c) !ALLOW_RETRY and !TRIED: this means the page fault does not allow retry
> + *
> + * The unlisted combination (!ALLOW_RETRY && TRIED) is illegal and should never
> + * be used.  Note that page faults can be allowed to retry for multiple times,
> + * in which case we'll have an initial fault with flags (a) then later on
> + * continuous faults with flags (b).  We should always try to detect pending
> + * signals before a retry to make sure the continuous page faults can still be
> + * interrupted if necessary.
> + */
> +
>  #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
>  #define FAULT_FLAG_MKWRITE	0x02	/* Fault was mkwrite of existing pte */
>  #define FAULT_FLAG_ALLOW_RETRY	0x04	/* Retry fault if blocking */
>  #define FAULT_FLAG_RETRY_NOWAIT	0x08	/* Don't drop mmap_sem and wait when retrying */
>  #define FAULT_FLAG_KILLABLE	0x10	/* The fault task is in SIGKILL killable region */
> -#define FAULT_FLAG_TRIED	0x20	/* Second try */
> +#define FAULT_FLAG_TRIED	0x20	/* We've tried once */
>  #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
>  #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
>  #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
>  
> +/*
> + * Returns true if the page fault allows retry and this is the first
> + * attempt of the fault handling; false otherwise.  This is mostly
> + * used for places where we want to try to avoid taking the mmap_sem
> + * for too long a time when waiting for another condition to change,
> + * in which case we can try to be polite to release the mmap_sem in
> + * the first round to avoid potential starvation of other processes
> + * that would also want the mmap_sem.
> + */

You should be using kernel function documentation style above.

> +static inline bool fault_flag_allow_retry_first(unsigned int flags)
> +{
> +	return (flags & FAULT_FLAG_ALLOW_RETRY) &&
> +	    (!(flags & FAULT_FLAG_TRIED));
> +}
> +


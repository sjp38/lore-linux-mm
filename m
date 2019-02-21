Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 206ADC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 15:34:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7ABB20842
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 15:34:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7ABB20842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74D758E008E; Thu, 21 Feb 2019 10:34:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FE018E0089; Thu, 21 Feb 2019 10:34:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 614588E008E; Thu, 21 Feb 2019 10:34:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 394798E0089
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:34:18 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id v67so5441790qkl.22
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 07:34:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=RFv3nbIFHel4gbXDBsu5mk4OU+dElt2a3XYAra6rlEI=;
        b=cPYVMlnwF5MvvVyJVAX+YtRMnQhF64uAr35Wy2x3MrwFBF0Wn5QWJNd6w8iV87ys3b
         dEWRlcyn5gO67zGUzO1hiYojSB4EeqAtSjOln//HpxUi3rGSg14ecY1jrX/ZzM9MMwK9
         Elaj1QA4ulWkFwNdJMAHadhGQ4dmLtu9pHDbhJRBG9gkCBy8zKL+c9s8I+9TquEJdc4J
         Lma8V+5G9J+E+6eC2beAG5HkR7DHWlkwFUxrImY11jtJXu8flkns9ps/beohsTrS1F8C
         hbDyeu4ETKqBuG8GuHAv/lyugNa4cY4Wut19lwifdc2ukX27suLfdUpxglhlpzRwTjVE
         LZOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZTiK+SlnGr9cMjNHslZt2T9iHkqfJjuDe4cJTT/qomolpPePos
	D87Qc+R6SeCwzvGey+20aq6oT2t8BihN/A//6Spc88fNVsTdDF1i78Nw4TSqKtU1BeKOpLvO9A1
	B688KOUphbHMIgJ8Ew7XZtFUGP459UVtJJ6Vl54VAQnFZhO4IXnzN7mJD7+NxMQkS7A==
X-Received: by 2002:a0c:96b5:: with SMTP id a50mr30309310qvd.33.1550763257981;
        Thu, 21 Feb 2019 07:34:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYOA6Mfh1GY19b1JODwf/PhIBBkMd8Cwt/zudndl5onYQTJY5KAh9efoio7YzZ5+yGCmayc
X-Received: by 2002:a0c:96b5:: with SMTP id a50mr30309277qvd.33.1550763257446;
        Thu, 21 Feb 2019 07:34:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550763257; cv=none;
        d=google.com; s=arc-20160816;
        b=JS4GiUfdQMR7dNnTLQSC+EqcrcIPjtslTQrQCcExAu2CHIdqOVHChSmOOPuhpJrxGE
         hkKviNL6+4lMhgz33jrg/BRsyHDE42SKbQs7tADwiiVRHMcEHDrqaAlDtiXrtujGX+Pd
         92xMNDZqL8cwjQNVJ2P2FqT/KEPJ52fqYgfPwXbvQeVFnzfAdbhWsdG+GYJVfie2P/ED
         RD9QahzOj6MnjkI2wXrmLyN6QjQ7fmVDvkSwQ3+pRyRXAR/7Rbcw0swbIdTKkcU6hilT
         d4HIf8v6ZxXfoaAmuqi49ix8gz2Y6leH6ci6pAKHvd2Hg+ObBD6VEPuVkJIxj/OvSB7T
         FnBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=RFv3nbIFHel4gbXDBsu5mk4OU+dElt2a3XYAra6rlEI=;
        b=MZKYCvd4AOnDDAHUyGfcPwU4HkQQ8x+cF0V/yvGr+RkUA4zwCHGPweYoXoK05DovUz
         7SbQfi/2TPorvtgGfjHTS3KGoGJ1iblWvJFsGXdxjx9IHTFPiAwCF1GIABE95EeatIky
         B56JdRsHycqkNeBzGR+n9CyL3tWSdQbWGg2B6H24YqECMRKOXT3CmbT0QiTUtyCIYckT
         0NKpaV1MZEzhYmvCrIa5LSYeDkTmngaJ26QA/kMS6KIzLmHgGAHyCVO4e2s1zCqiv1hr
         U7m15OLAEw+EX66NK6h5ZlQGk3LBg+1yRfsSC3YD/ZIS9crpZNVydg6+y/EFLN6P58Yj
         lxpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q23si926327qtj.291.2019.02.21.07.34.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 07:34:17 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5EA7680462;
	Thu, 21 Feb 2019 15:34:16 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 569385D706;
	Thu, 21 Feb 2019 15:34:08 +0000 (UTC)
Date: Thu, 21 Feb 2019 10:34:06 -0500
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
Subject: Re: [PATCH v2 03/26] userfaultfd: don't retake mmap_sem to emulate
 NOPAGE
Message-ID: <20190221153406.GC2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-4-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-4-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 21 Feb 2019 15:34:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:09AM +0800, Peter Xu wrote:
> The idea comes from the upstream discussion between Linus and Andrea:
> 
> https://lkml.org/lkml/2017/10/30/560
> 
> A summary to the issue: there was a special path in handle_userfault()
> in the past that we'll return a VM_FAULT_NOPAGE when we detected
> non-fatal signals when waiting for userfault handling.  We did that by
> reacquiring the mmap_sem before returning.  However that brings a risk
> in that the vmas might have changed when we retake the mmap_sem and
> even we could be holding an invalid vma structure.
> 
> This patch removes the risk path in handle_userfault() then we will be
> sure that the callers of handle_mm_fault() will know that the VMAs
> might have changed.  Meanwhile with previous patch we don't lose
> responsiveness as well since the core mm code now can handle the
> nonfatal userspace signals quickly even if we return VM_FAULT_RETRY.
> 
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  fs/userfaultfd.c | 24 ------------------------
>  1 file changed, 24 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 89800fc7dc9d..b397bc3b954d 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -514,30 +514,6 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
>  
>  	__set_current_state(TASK_RUNNING);
>  
> -	if (return_to_userland) {
> -		if (signal_pending(current) &&
> -		    !fatal_signal_pending(current)) {
> -			/*
> -			 * If we got a SIGSTOP or SIGCONT and this is
> -			 * a normal userland page fault, just let
> -			 * userland return so the signal will be
> -			 * handled and gdb debugging works.  The page
> -			 * fault code immediately after we return from
> -			 * this function is going to release the
> -			 * mmap_sem and it's not depending on it
> -			 * (unlike gup would if we were not to return
> -			 * VM_FAULT_RETRY).
> -			 *
> -			 * If a fatal signal is pending we still take
> -			 * the streamlined VM_FAULT_RETRY failure path
> -			 * and there's no need to retake the mmap_sem
> -			 * in such case.
> -			 */
> -			down_read(&mm->mmap_sem);
> -			ret = VM_FAULT_NOPAGE;
> -		}
> -	}
> -
>  	/*
>  	 * Here we race with the list_del; list_add in
>  	 * userfaultfd_ctx_read(), however because we don't ever run
> -- 
> 2.17.1
> 


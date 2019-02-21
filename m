Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36C10C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 15:30:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F30852075A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 15:30:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F30852075A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72D528E008D; Thu, 21 Feb 2019 10:30:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B3F68E0089; Thu, 21 Feb 2019 10:30:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57B898E008D; Thu, 21 Feb 2019 10:30:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3158E0089
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:30:10 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id s8so12405751qth.18
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 07:30:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=gkaaFLV3DHF8mpBMdBF4CVuaCuz9fgSkrVgVvsdybDA=;
        b=I8WYAlko3RhwnAI1jSnZMhUIKBruMDIzEs7Z11dr50QcJbN9KwxTxK1KcssPdBseTc
         9l0mxw+i47t0P2iWb9V+WoRH3w+3htOzJZ4MMrn9aGqKQh1GPdiTnLwO7XApOK+cNqQ3
         WGPEu+utDDyrCPAK7QXVggb2e4Bqgg3udSwRsuJooYPAYSzDN9nCpp7LFimhV09ZTkD3
         wPNOp/pA923Bw+SpzXTaPe3scg0LXYyGyxPFlx03LW2mKbFROZMFMJ9OGI/dXeydqRTk
         e4VvmN6XMQVIm8bZxHQHvx8erW/JyOqoo4EJStE7sCCgXJRpB2JWzm++/hDMCmBbjxYg
         ym/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubeWY1bfqX6qkbuJ/KV2gbWNohcJRpSu2C61lg4vDOGC59fr1yt
	tbDt10/6FybicYlojHJXKzX8yX21+DAuJVjYF6PnMo1ykKaAc9xK4cz1I4TG/gXB7byjzXXiBN8
	2R499bFFNiy0Mha1KX88xTeI2sUcNMer4kDbFwrFLTov6AaYhBfJ9ylQYkA8ZqMNpkw==
X-Received: by 2002:ac8:7553:: with SMTP id b19mr30927427qtr.238.1550763009925;
        Thu, 21 Feb 2019 07:30:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZh+8+Yxw/0IJN8A17DxniEsv6btsM6ylPK/bwpxcqfawjjFwUxUCY0wtLv0fSx/z3iOZlP
X-Received: by 2002:ac8:7553:: with SMTP id b19mr30927387qtr.238.1550763009238;
        Thu, 21 Feb 2019 07:30:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550763009; cv=none;
        d=google.com; s=arc-20160816;
        b=p8Z3KuEnbMWkUA57v2wk8YQtzITWmuCEDUcJYpVB1ZqDv0cGim1DaxkqI+0a0VPk1F
         HAX3N7vcfIsbo4n5y+hgGbU6Hx9nWODcQq6GU2PBaRaPpP5W5M4+c3lrIZym5aWUWS7e
         WKWXQpsDKa82vJfjqt4VB3UybzHgNcoSdDbxHdMjX/BCqmP2qgyxGd05EIOihDGjM80p
         oGiCOLUC7N6cdQsWCuPCtGijfwhrYcSNSaphQrbjMf9Nn7lln2CyCwh8pp/VE20bhNCY
         M1ivIHUxqAgXKAIPxxiyQ7E3QTnCEXQENWP9ToOMJauyM0cOcs7S36QeyeeFrpHYTuVW
         R3dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=gkaaFLV3DHF8mpBMdBF4CVuaCuz9fgSkrVgVvsdybDA=;
        b=xAQ7OJ4iYpeWOsBQjPkR3aQ2u0VOxWmaQZY5M2q2j0g35Mo8pHNIy0L7N/k5S29r6l
         54UE4lPRYdWiF7SS99e4aGaEiRFaMRdKc7qK39tuM4qPaqlARWnzD9KIQvByf95GjvLi
         pieg4smaBJk4TJjyCUKANX+H9ECZH8vqk0kJfVp5Yv/TOn6VBnMzexBKXP/FkF+tlpN9
         PVhM0+OfasHyQiy4S4gIeSGUMQQEE00jID6+AU7C1rL8zSZYEZYehimGzuKyMiK+bO+6
         JQ7aa3R4wqeU1Ce89vi2bHz2dkJ4N4Wv+4555uqxcPGaWWqlNn6mEuktOPSp9PWM9zie
         f3ZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a22si1066099qkk.142.2019.02.21.07.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 07:30:09 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C204D3DD99;
	Thu, 21 Feb 2019 15:30:07 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 63BAE6015C;
	Thu, 21 Feb 2019 15:29:58 +0000 (UTC)
Date: Thu, 21 Feb 2019 10:29:56 -0500
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
Subject: Re: [PATCH v2 02/26] mm: userfault: return VM_FAULT_RETRY on signals
Message-ID: <20190221152956.GB2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-3-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-3-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 21 Feb 2019 15:30:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:08AM +0800, Peter Xu wrote:
> The idea comes from the upstream discussion between Linus and Andrea:
> 
>   https://lkml.org/lkml/2017/10/30/560
> 
> A summary to the issue: there was a special path in handle_userfault()
> in the past that we'll return a VM_FAULT_NOPAGE when we detected
> non-fatal signals when waiting for userfault handling.  We did that by
> reacquiring the mmap_sem before returning.  However that brings a risk
> in that the vmas might have changed when we retake the mmap_sem and
> even we could be holding an invalid vma structure.
> 
> This patch removes the special path and we'll return a VM_FAULT_RETRY
> with the common path even if we have got such signals.  Then for all
> the architectures that is passing in VM_FAULT_ALLOW_RETRY into
> handle_mm_fault(), we check not only for SIGKILL but for all the rest
> of userspace pending signals right after we returned from
> handle_mm_fault().  This can allow the userspace to handle nonfatal
> signals faster than before.
> 
> This patch is a preparation work for the next patch to finally remove
> the special code path mentioned above in handle_userfault().
> 
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

See maybe minor improvement

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

[...]

> diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
> index 58f69fa07df9..c41c021bbe40 100644
> --- a/arch/arm/mm/fault.c
> +++ b/arch/arm/mm/fault.c
> @@ -314,12 +314,12 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
>  
>  	fault = __do_page_fault(mm, addr, fsr, flags, tsk);
>  
> -	/* If we need to retry but a fatal signal is pending, handle the
> +	/* If we need to retry but a signal is pending, handle the
>  	 * signal first. We do not need to release the mmap_sem because
>  	 * it would already be released in __lock_page_or_retry in
>  	 * mm/filemap.c. */
> -	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
> -		if (!user_mode(regs))
> +	if (unlikely(fault & VM_FAULT_RETRY && signal_pending(current))) {

I rather see (fault & VM_FAULT_RETRY) ie with the parenthesis as it
avoids the need to remember operator precedence rules :)

[...]

> diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
> index 68d5f2a27f38..9f6e477b9e30 100644
> --- a/arch/nds32/mm/fault.c
> +++ b/arch/nds32/mm/fault.c
> @@ -206,12 +206,12 @@ void do_page_fault(unsigned long entry, unsigned long addr,
>  	fault = handle_mm_fault(vma, addr, flags);
>  
>  	/*
> -	 * If we need to retry but a fatal signal is pending, handle the
> +	 * If we need to retry but a signal is pending, handle the
>  	 * signal first. We do not need to release the mmap_sem because it
>  	 * would already be released in __lock_page_or_retry in mm/filemap.c.
>  	 */
> -	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
> -		if (!user_mode(regs))
> +	if (fault & VM_FAULT_RETRY && signal_pending(current)) {

Same as above parenthesis maybe.

[...]

> diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
> index 0e8b6158f224..09baf37b65b9 100644
> --- a/arch/um/kernel/trap.c
> +++ b/arch/um/kernel/trap.c
> @@ -76,8 +76,11 @@ int handle_page_fault(unsigned long address, unsigned long ip,
>  
>  		fault = handle_mm_fault(vma, address, flags);
>  
> -		if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
> +		if (fault & VM_FAULT_RETRY && signal_pending(current)) {

Same as above parenthesis maybe.

[...]


Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1BAAC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 20:14:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BBB02182B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 20:14:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BBB02182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1339E6B0005; Fri, 10 May 2019 16:14:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E38C6B0006; Fri, 10 May 2019 16:14:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3B1A6B0007; Fri, 10 May 2019 16:14:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2CB96B0005
	for <linux-mm@kvack.org>; Fri, 10 May 2019 16:14:07 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id n65so5837449qke.12
        for <linux-mm@kvack.org>; Fri, 10 May 2019 13:14:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=otsAOXbLDZPS7xsz/jW/DskpEEHCbU1Df/DuGU1183c=;
        b=WqlrhaBL159x++OClaZKfdwsZbms9xIRMVU57WCfSLJg/rTmIH7VqwmJX5P2zqaQTZ
         DXGSg+eZ0ND6AdUcHAiU5g0o7EwHNcD1dnMU5Oiab00TIyeNmQZSp/6faX4kTh6V4paW
         EPZ0qMoJlIVYwrVtd2vQ/foqR6XFKRO/gEv14jgzdO+/2AEhAN322QIxSN3vEQNcQrKU
         sfHFsyaU7aFnoX5zBBUIEcYlb2iPLyIYMyona2znkcoENe3OqMTam70i4hXmjZ8FL1EZ
         fCeMiKVf/Qes1KXFSp1UHfd4RSOtYaZsuYpgQsHayYbmScbjH+9SfF8YI/gqMregYU/p
         QRcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUi/p5mkH6McrtXIMkFAx6eKmk2p4kEroYLlgXTEd1e18NHd0fz
	JUsEWTSB4qzp3Vj9wp4kgr0j6Ddn6XKqrsM14A+I5+drFfaY+dlYc5H9sB0eciFFvWg02JaEJny
	GEtqmODE+55LOxbzs55wjjGHLtkYHOr74/CV2h5NAstkaJKmDrk56flheH0dld6n2EQ==
X-Received: by 2002:a37:7a84:: with SMTP id v126mr10878476qkc.335.1557519247671;
        Fri, 10 May 2019 13:14:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqlK9z2bfyg1FpRo/08jf73lK7Ak8LvNsYTlbXk6Rii0YfD2Qy0OgKn49VZzvBnGI4zIgh
X-Received: by 2002:a37:7a84:: with SMTP id v126mr10878426qkc.335.1557519246981;
        Fri, 10 May 2019 13:14:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557519246; cv=none;
        d=google.com; s=arc-20160816;
        b=jCi7FUTys0o8n9J7rXEQ5ldUE2ZJicu9Yd9VcRz3tkLRm3sE9Do+cD3gcVwn7PUuL1
         XM64V3RYYQP729dIvx0j6nVWEPdnBuP2oS6sjgzePAJZc6nP7LZULnaB2eixV7e8fRDZ
         rhQgiIvG/i7sjdofSEFzYiHwEXgQTZRHKCR+L3BcWeZMoYWVhRubywO6K0H6IDGr4zOq
         wDSN3R/uGyYwYrezvqIKuzxSeqN8WqTgxZ7depPZVncW43oXq0+DM1A5JzoZ03pPUIlo
         iuMdAD4PTaYjDq6fYjmN/DFwlboYn/VX4g6dPhTmMxjLZuxeRN+ne5o6PMoJvBuUHq+G
         Vrug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=otsAOXbLDZPS7xsz/jW/DskpEEHCbU1Df/DuGU1183c=;
        b=nntX42kbDZG16ZtTJ1ugWtCEB+NBRm6upHNHctukZAkEg3If3wxsx3otCNAkbOVk4S
         un0xXR+1lzAVU/7ahI3WfQpcsrdWKeO5P19Oxj9xYEiR7l+IwkibRSXJ/+Hq/HL1JMMH
         ArsiUPEKbtViH2AvfX+Byw3Emssbr3pUnhVPnIJnVxMo2/TB1jfMjIYQkYO/RJv1hyyt
         gtrJEr4u1KZFD/4g9xsXfuVEdZHs5+61le6InYFZsSIo9YE9g2wq5HBIJVjwFvbj9Wkq
         xTnMrDi5CmpkH4Vygxn+w+Oe3eFZas4iWg/YF1aiU7nYTTKTYXQpVmWsiXmObqGNK977
         t50g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h18si4145175qkl.71.2019.05.10.13.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 13:14:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 411C8308FC4E;
	Fri, 10 May 2019 20:14:06 +0000 (UTC)
Received: from redhat.com (ovpn-124-97.rdu2.redhat.com [10.10.124.97])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 802F722718;
	Fri, 10 May 2019 20:14:05 +0000 (UTC)
Date: Fri, 10 May 2019 16:14:03 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: "alex.deucher@amd.com" <alex.deucher@amd.com>,
	"airlied@gmail.com" <airlied@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Subject: Re: [PATCH 2/2] mm/hmm: Only set FAULT_FLAG_ALLOW_RETRY for
 non-blocking
Message-ID: <20190510201403.GG4507@redhat.com>
References: <20190510195258.9930-1-Felix.Kuehling@amd.com>
 <20190510195258.9930-3-Felix.Kuehling@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190510195258.9930-3-Felix.Kuehling@amd.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 10 May 2019 20:14:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 07:53:24PM +0000, Kuehling, Felix wrote:
> Don't set this flag by default in hmm_vma_do_fault. It is set
> conditionally just a few lines below. Setting it unconditionally
> can lead to handle_mm_fault doing a non-blocking fault, returning
> -EBUSY and unlocking mmap_sem unexpectedly.
> 
> Signed-off-by: Felix Kuehling <Felix.Kuehling@amd.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  mm/hmm.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index b65c27d5c119..3c4f1d62202f 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -339,7 +339,7 @@ struct hmm_vma_walk {
>  static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
>  			    bool write_fault, uint64_t *pfn)
>  {
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REMOTE;
> +	unsigned int flags = FAULT_FLAG_REMOTE;
>  	struct hmm_vma_walk *hmm_vma_walk = walk->private;
>  	struct hmm_range *range = hmm_vma_walk->range;
>  	struct vm_area_struct *vma = walk->vma;
> -- 
> 2.17.1
> 


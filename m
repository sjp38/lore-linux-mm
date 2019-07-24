Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53DAAC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:12:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B8022083B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:12:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B8022083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A44F46B0006; Wed, 24 Jul 2019 16:12:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F3566B0007; Wed, 24 Jul 2019 16:12:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E2AE6B0008; Wed, 24 Jul 2019 16:12:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59B7F6B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:12:11 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so24783195plp.12
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:12:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zVwdxCJUDhyAlG0bHOMkvMY4yTSoQWY63wbXZr2GpuM=;
        b=Hy0hIH76buKhXxDg3kRL8kJS1qcdecd8H2PZUYXYKz8S7oe3qmrxJsXyVCq9+7ZHdJ
         CHVEjgkcK2fNGdjKVxnvYP3PCsnf8Zujiuj2AILVwTT0jYYvtValaJIEOle7gRwhV0pX
         lhAGfJOS07sDba2yxxkW76SEIOTHW0wIeaZjTCRxD1+QWi0gdPtmUUY5W8k/E1gQEaFF
         xy4F36xjIq+tOx79iiuhIat6+xmzHo9xqiC1siO0WnQKB++PodO4LA65hI5p8bIFuPZz
         UaafQFPkX++izJeWQp6S/3Qx862l+75/p7ZC5Gozxfr/uv1fVdS4LR/JU//tGfOwctqK
         lFuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=jct7=vv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=jct7=VV=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAU30o76sXbd02pOu+i/qNf8Y0tDhn/qHB2VKXiAV+RtdCgHZA5P
	Yny+VZeZqhmE+mwEw+Y9Ff4fMHqO1KQQl2T+j2OOoLcEVnRDnNECXr8QAf7v1lUWs34EsFhFdZl
	tybLd7wfqjo3mBBTnAaXQhVoKxF37FV6Crh/uAkvOQig6D3uQ0bQWwYUi/jCzqL8=
X-Received: by 2002:a17:902:16f:: with SMTP id 102mr84317797plb.94.1563999130997;
        Wed, 24 Jul 2019 13:12:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhL7tay6Ez/xb1gvdbMntxsEKtQmjs8Zt3cenn2TnYnKfF1H1xzDz+win3Zpzrr79BQLqV
X-Received: by 2002:a17:902:16f:: with SMTP id 102mr84317746plb.94.1563999130290;
        Wed, 24 Jul 2019 13:12:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563999130; cv=none;
        d=google.com; s=arc-20160816;
        b=07kl7jBH2GmDcJUSwZ7+cVTu7vr++LjXoCv+xFM9bo26N23UjE+VjlA+IcW8+8ZGzy
         MmXK49dpe5uwBYSAbnCRRR0eM+SEVjRzzqb3ijdwKtoTdU3ARd4GjoO+PBjpqeCVt0tP
         l1RNA6cbSBEG4DTeW2mizMPH9+UJmspNi2MdJIozOcWCqUGqvVHYlOIb0Aj/2fj0Adsx
         kfum559s6B6REL/tM6ttWKboNE9sAH27ImCxjOTdCydA1k/T4mPWHaurnzNJ8Lx2cGi7
         bb5A96XqFiCtRIm22xJ/iAdznJlUOUpXWp2L0T+h6vumDkW1y6zQcCcnQMOBa4CZ5boN
         bTtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=zVwdxCJUDhyAlG0bHOMkvMY4yTSoQWY63wbXZr2GpuM=;
        b=XSxeR4kwL2TTuIN/gWM/GOPLwlgX2r6b7OHxIH375lUbeKDP0Waap5AYZIEYd5B9o5
         v3Kmol0byCZ4pI5WLWrfvtXZo56vuS7x+n3aCJ125tclmqwS4RFGz9iGiptjVae/LWac
         Ip+37zt8kpiu7V05w10av+oGmdasBC/Jl5yNIEK8TgMQjkTIXjxaGXS4W6KMqP8B9rNk
         aQJcURPjj6NjZORPOfi40yR7WlNw00mSDtsIGZiHwQA9/hQf8hl9gX+lqx1XQQ84Y+VX
         kL5uY0y+qnHSuUN8c+buARW0yWHnOQeldlIxxTOtsEqEP4YoNFimOwr6bfyE7Q8Qy+c+
         u1Wg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=jct7=vv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=jct7=VV=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g21si4135701pgk.293.2019.07.24.13.12.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 13:12:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=jct7=vv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=jct7=vv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=jct7=VV=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7225E21873;
	Wed, 24 Jul 2019 20:12:09 +0000 (UTC)
Date: Wed, 24 Jul 2019 16:12:07 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: "George G. Davis" <george_davis@mentor.com>
Cc: Ingo Molnar <mingo@redhat.com>, open list
 <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton
 <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] tracing: kmem: convert call_site addresses to user
 friendly symbols
Message-ID: <20190724161207.62f07521@gandalf.local.home>
In-Reply-To: <1563831780-14888-1-git-send-email-george_davis@mentor.com>
References: <1563831780-14888-1-git-send-email-george_davis@mentor.com>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hmm, get_maintainers.pl fails to get the people I think should be
maintaining include/trace/events/kmem.h. 

On Mon, 22 Jul 2019 17:42:59 -0400
"George G. Davis" <george_davis@mentor.com> wrote:

> While attempting to debug slub freelist pointer corruption bugs
> caused by a module, I discovered that the kmem call_site addresses are
> not at all user friendly for modules unless you manage to save a copy
> of kallsyms for the running kernel beforehand.
> 
> So convert kmem call_site addresses to user friendly symbols which is
> especially helpful for module callers when you don't have a copy of
> kallsyms for the running kernel.
> 
> Reported-by: kbuild test robot <lkp@intel.com>
> Signed-off-by: George G. Davis <george_davis@mentor.com>

Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

I can take this if nobody else does.

-- Steve


> ---
> Change history:
> v1:
> - First submission
> v2:
> - Fix kbuild test robot issues as suggested by
>   Steven Rostedt.
> ---
>  include/trace/events/kmem.h | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
> index eb57e3037deb..09e1eeb4e44d 100644
> --- a/include/trace/events/kmem.h
> +++ b/include/trace/events/kmem.h
> @@ -35,8 +35,8 @@ DECLARE_EVENT_CLASS(kmem_alloc,
>  		__entry->gfp_flags	= gfp_flags;
>  	),
>  
> -	TP_printk("call_site=%lx ptr=%p bytes_req=%zu bytes_alloc=%zu gfp_flags=%s",
> -		__entry->call_site,
> +	TP_printk("call_site=%pS ptr=%p bytes_req=%zu bytes_alloc=%zu gfp_flags=%s",
> +		(void *)__entry->call_site,
>  		__entry->ptr,
>  		__entry->bytes_req,
>  		__entry->bytes_alloc,
> @@ -88,8 +88,8 @@ DECLARE_EVENT_CLASS(kmem_alloc_node,
>  		__entry->node		= node;
>  	),
>  
> -	TP_printk("call_site=%lx ptr=%p bytes_req=%zu bytes_alloc=%zu gfp_flags=%s node=%d",
> -		__entry->call_site,
> +	TP_printk("call_site=%pS ptr=%p bytes_req=%zu bytes_alloc=%zu gfp_flags=%s node=%d",
> +		(void *)__entry->call_site,
>  		__entry->ptr,
>  		__entry->bytes_req,
>  		__entry->bytes_alloc,
> @@ -131,7 +131,8 @@ DECLARE_EVENT_CLASS(kmem_free,
>  		__entry->ptr		= ptr;
>  	),
>  
> -	TP_printk("call_site=%lx ptr=%p", __entry->call_site, __entry->ptr)
> +	TP_printk("call_site=%pS ptr=%p",
> +		(void *)__entry->call_site, __entry->ptr)
>  );
>  
>  DEFINE_EVENT(kmem_free, kfree,


Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72C0DC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 02:55:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F3F3217D9
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 02:55:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F3F3217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDA8D6B0005; Wed, 10 Apr 2019 22:55:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B88016B0006; Wed, 10 Apr 2019 22:55:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9D746B0007; Wed, 10 Apr 2019 22:55:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A24E6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 22:55:14 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f89so4302714qtb.4
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 19:55:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xPlQ4aeVgEs/ey25shTPswUOAaW0D4x7SvGqd6go+ps=;
        b=sBvTK8cBM0RkHlfzR09qSMBbhV7PURW/r6OlJx82d5J+suGsXhaGeTE1SPJ3SESV0O
         WHZgTE5jin293i/64TbJdJRSX57Md/rADS/PtbxflumgBKD+niHdnsTcPDQSr4Wv/RxK
         Jxjl0KbzTHWFYwaWvfLCu9DIZ17OdELxDixL4UAEB4ARvUjAC7nL25lUxUSsp2tXZdNJ
         dPaPQA9gdU08yXnDGnEBFhImbLLkuxEPH8is0GqJ8+pnE6y4vB54nIyp67j5wU8PNCm4
         +mwYXFNXejb2FKWQd7R+1arM6fFZMGiMFEPQZfOSkjQa2a5A8AxhD1BVYcWgPjiIFbwC
         7wKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVdLlwGZIoQ2rhw0qHJxFGqS+IMPRi4V8OiI5sTx0MXGECnmBqw
	vS5zz80VkA6EfYLLQLsknYQ+EY+AVJR5LEhpo+0hv+6LITPd+lkXx6ESKMrqe/zKDavCNXu1zm+
	SKElk4XkFtwmri0ylUFWCrPO3T0lzuKER2Yq7ML+qWRcZkPqsew783pXWLUi3HH3pYA==
X-Received: by 2002:a37:9acd:: with SMTP id c196mr34907828qke.273.1554951314330;
        Wed, 10 Apr 2019 19:55:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0Ey5Ux5JQ6HATcLHjDZDJBx7oIYCqUUlWNhgzGTNH6H6crFeZAMiOYfFNKuZ1n5gXtMDI
X-Received: by 2002:a37:9acd:: with SMTP id c196mr34907804qke.273.1554951313822;
        Wed, 10 Apr 2019 19:55:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554951313; cv=none;
        d=google.com; s=arc-20160816;
        b=rd+9sfAF60takFUnQRvcqSWDeQ7gakVFNqiO6aS+8bvRIj32+YV2i2z3GYzc1I4tOX
         Mh9XK/A4pygbuFom6v55tFXs7PcJFFa+rpVtvsOyER9vtr7Df1E5Ps5f0nQYPgf+x57Y
         6TB7i/803NZoaoXHDnK+Gh3BxCgVlQKWiy1zrQ4w1F2TT97ZBBppnbntimyD3GmWiAtS
         vmRPNN64RCkrweOkX8t7orlN7S3ddrzHFC9DsTesW+2rkqEqyNThrYdB0UEwBp6td1Oy
         zDj+WAgB+FGnDKvoDuCvF5YoXYIRPtoeFzCxQdmC9LLvs4fsmMn+JYWkpR8vvixFj/kI
         tjVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xPlQ4aeVgEs/ey25shTPswUOAaW0D4x7SvGqd6go+ps=;
        b=oqs+gYKpoHoicBChQV+88B0WC+NTLKjRJag4MDnDiOLKHc4BL1NwVFtSAzlC3yqx8+
         8N2vWYNdaLrid8lpSp/NjLBvhsPc+hxwBMQU5VTN/jLR83ahhlctMahofGsPeBEYAiIg
         FkCQeLN3SJUuNqxXI6cAXuU0/S3YUPmBzMYrRQmVUzAoRCLpC7aZersKucy0mhTrR739
         EnD88xWR8yRCNyxzUMnyhyV01zEIHhYfCtmY/gF1WMNkPRvua5XKmUi4Z23hmDT7nha9
         mLkLbIJ6vaNZdB6KI7vbMBnyQu4S7GbFW5kXVJJ+vOzk4iG0ugAoMyXiwe//+QRwWvWF
         14vg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o70si31626qka.91.2019.04.10.19.55.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 19:55:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 042E831676AD;
	Thu, 11 Apr 2019 02:55:13 +0000 (UTC)
Received: from treble (ovpn-120-231.rdu2.redhat.com [10.10.120.231])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 067C85D704;
	Thu, 11 Apr 2019 02:55:10 +0000 (UTC)
Date: Wed, 10 Apr 2019 21:55:09 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com,
	linux-mm@kvack.org
Subject: Re: [RFC patch 25/41] mm/kasan: Simplify stacktrace handling
Message-ID: <20190411025509.cslu3nq27g7ww6qu@treble>
References: <20190410102754.387743324@linutronix.de>
 <20190410103645.862294081@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190410103645.862294081@linutronix.de>
User-Agent: NeoMutt/20180716
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 11 Apr 2019 02:55:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 12:28:19PM +0200, Thomas Gleixner wrote:
> Replace the indirection through struct stack_trace by using the storage
> array based interfaces.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: kasan-dev@googlegroups.com
> Cc: linux-mm@kvack.org
> ---
>  mm/kasan/common.c |   30 ++++++++++++------------------
>  mm/kasan/report.c |    7 ++++---
>  2 files changed, 16 insertions(+), 21 deletions(-)
> 
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -48,34 +48,28 @@ static inline int in_irqentry_text(unsig
>  		 ptr < (unsigned long)&__softirqentry_text_end);
>  }
>  
> -static inline void filter_irq_stacks(struct stack_trace *trace)
> +static inline unsigned int filter_irq_stacks(unsigned long *entries,
> +					     unsigned int nr_entries)
>  {
> -	int i;
> +	unsigned int i;
>  
> -	if (!trace->nr_entries)
> -		return;
> -	for (i = 0; i < trace->nr_entries; i++)
> -		if (in_irqentry_text(trace->entries[i])) {
> +	for (i = 0; i < nr_entries; i++) {
> +		if (in_irqentry_text(entries[i])) {
>  			/* Include the irqentry function into the stack. */
> -			trace->nr_entries = i + 1;
> -			break;
> +			return i + 1;

Isn't this an off-by-one error if "i" points to the last entry of the
array?

-- 
Josh


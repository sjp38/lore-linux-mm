Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C260C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 22:00:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7292218D4
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 22:00:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pSWHajQs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7292218D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D86C6B0003; Thu, 21 Mar 2019 18:00:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 587B56B0006; Thu, 21 Mar 2019 18:00:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4771D6B0007; Thu, 21 Mar 2019 18:00:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03F3B6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 18:00:47 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n10so147341pgp.21
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 15:00:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=JVdztBDJcSey0QI9UZ8uSOMuJf9GvmkjJ47WwH+ajqs=;
        b=ALsdsH1oTD/JXECaQA4yDX9u0eGd53n93VeHXmq95jnVquRssaTaU3FbXUpGX58S8R
         w/8eAVihH0MTX/3sqW8BeTW15jyiymfVR4ki0HKGsOlp7lNbK9HRW81QmH/VvFiaFJm1
         DObm2UD7AJHy6Phjlj2cAlPC4rN8STI9YvXV5IH+xiE+WvFxoXMnMu+WM2TK344BPJc1
         t7Bf6O1etTRRIL2O38pdspvX0pD41pM4B7nGTkDnkesO22hNpeqOT9smfC37QO8bUzPK
         08Z/xULNdHqBy4nu0R6IFS3sDfz3iWM+d6C1fl58aSu/wIxqWU/+LxRTsPLBF/Lbtl1n
         jWoQ==
X-Gm-Message-State: APjAAAVQxOW1EmNdRw4WxncTnOwwHY6TuB6bP5wvR67xa2sSAL+MvjcH
	CpBlrKEBvF+cKGTQdKI6M0B04TempW6SAsWYdIhF+MlWA8cVOXEWH7nh23/U+wt5LqP2OYdvmwD
	Hhn0fZL3mMexlkGNHtuXoSkDUPzWwQj4/u6NDJ/PmK+ahvsdpm48enDxrh+45yygwTQ==
X-Received: by 2002:a62:41cc:: with SMTP id g73mr5518183pfd.145.1553205646582;
        Thu, 21 Mar 2019 15:00:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwa60zyD+APgPgddL9C4j4snCXw7E3sZjYpH9PWExLO8I58wagoOGX3hRexpSu88v3D0WM/
X-Received: by 2002:a62:41cc:: with SMTP id g73mr5518117pfd.145.1553205645855;
        Thu, 21 Mar 2019 15:00:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553205645; cv=none;
        d=google.com; s=arc-20160816;
        b=HrO/7/nKjl6DNo4/N01ZYN72YErfFSWj5xh2FRtEKEbYjXuh9+8LAEGjqKWhhMgnGu
         r9J7cQCvhFiwbzIsW6qi+73vdCPB4Ag/xPI4mpeanc3LIQqnPS9T40HFRXOtsLqgjn4L
         vGQF6gdOy9/nlv6qvRCNBga8+O1w51KRcOc+wTI+sHb/LaSdswgIWV20hmHCUFf4tBd4
         4y0crL3zI64bEoXcJnQ3ciXX20iGfPJPI2GpqUxTi9bAQW+ye2iRYyTidTokYZ5+amvI
         ZNHum7Y69rN1GWCEZ8EJkMD3L0pHDEBngXLJfNm7PHzO9LPOi2JionPyiwvqAFC2DiWz
         jUAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=JVdztBDJcSey0QI9UZ8uSOMuJf9GvmkjJ47WwH+ajqs=;
        b=GLGmpnOexnLsp0PFbxaJnGCQcpvyu7v0b475QEhtugaKl5/PEJh6n5fXIySTHV7ptm
         QpdTXUvMk+Dau5c+MqvkiFvssCom6PXRA1Y6/d3h/hOwKCEqo1LW5EHMIpa8AnUnI6rg
         x5F+BWm4cqyQFbPAIQ7iCgf7tV97v/W5UEuWXDIG2sMY4q0NRFOjheLSfW5+fHdOVNqX
         gUYRLSn18KRqhZ50lr8Bh5ghQmYg1TGxmT/iF1Kv70US07oPF/K964TSoFmcVG3dJHx6
         ng+ZOIVA/Gw8nOkUeQXjdWyy80Uyj7EFdLG/LbA+djdTO/NT4l15pfpub1YY/sfkHdUf
         wbLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pSWHajQs;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p6si5353319pgi.531.2019.03.21.15.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Mar 2019 15:00:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pSWHajQs;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=JVdztBDJcSey0QI9UZ8uSOMuJf9GvmkjJ47WwH+ajqs=; b=pSWHajQsPC7Dnpe2r+iQ7C2or
	UFxfv/su+iL/pKAP1gL41nDsBFsAb+DZM7b3AC8jaWN1Nbr6zTLE4rlY7vXWA6ShCSc+lKp24ZqUG
	qhRw/NfaVJZq1G/CZ36bCkP/M+xVdDArAkWcgTFPjD32YIh0KrgZKLFiUJQHkaz2C83VSRMMOm2GV
	D2jvftVr170zAbhGkv4lfpzXvHNnGDd0q40AKVeo7vgk2svIcocNRSlzTKx1GjXiti2EhTXA7ASG4
	6fLbS8rQB6J+iUyMkw9PqSK7xGSs6ue2cucX/lcfS8l9qu+ffGrvUpFoYiWLToHMAzHZhgA5KgGNU
	6C1Eh4s7w==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=worktop.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h75jr-0001Fe-Im; Thu, 21 Mar 2019 22:00:40 +0000
Received: by worktop.programming.kicks-ass.net (Postfix, from userid 1000)
	id 737E7984EEA; Thu, 21 Mar 2019 23:00:35 +0100 (CET)
Date: Thu, 21 Mar 2019 23:00:35 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Waiman Long <longman@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, selinux@vger.kernel.org,
	Paul Moore <paul@paul-moore.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>, Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 4/4] mm: Do periodic rescheduling when freeing objects in
 kmem_free_up_q()
Message-ID: <20190321220035.GF7905@worktop.programming.kicks-ass.net>
References: <20190321214512.11524-1-longman@redhat.com>
 <20190321214512.11524-5-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190321214512.11524-5-longman@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 05:45:12PM -0400, Waiman Long wrote:
> If the freeing queue has many objects, freeing all of them consecutively
> may cause soft lockup especially on a debug kernel. So kmem_free_up_q()
> is modified to call cond_resched() if running in the process context.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  mm/slab_common.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index dba20b4208f1..633a1d0f6d20 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1622,11 +1622,14 @@ EXPORT_SYMBOL_GPL(kmem_free_q_add);
>   * kmem_free_up_q - free all the objects in the freeing queue
>   * @head: freeing queue head
>   *
> - * Free all the objects in the freeing queue.
> + * Free all the objects in the freeing queue. The caller cannot hold any
> + * non-sleeping locks.
>   */
>  void kmem_free_up_q(struct kmem_free_q_head *head)
>  {
>  	struct kmem_free_q_node *node, *next;
> +	bool do_resched = !in_irq();
> +	int cnt = 0;
>  
>  	for (node = head->first; node; node = next) {
>  		next = node->next;
> @@ -1634,6 +1637,12 @@ void kmem_free_up_q(struct kmem_free_q_head *head)
>  			kmem_cache_free(node->cachep, node);
>  		else
>  			kfree(node);
> +		/*
> +		 * Call cond_resched() every 256 objects freed when in
> +		 * process context.
> +		 */
> +		if (do_resched && !(++cnt & 0xff))
> +			cond_resched();

Why not just: cond_resched() ?

>  	}
>  }
>  EXPORT_SYMBOL_GPL(kmem_free_up_q);
> -- 
> 2.18.1
> 


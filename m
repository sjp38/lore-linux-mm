Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27F09C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 11:49:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E633520693
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 11:49:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E633520693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8747A6B0003; Fri, 22 Mar 2019 07:49:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8242F6B0005; Fri, 22 Mar 2019 07:49:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73B7A6B0006; Fri, 22 Mar 2019 07:49:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 54E1C6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 07:49:27 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id i124so1579839qkf.14
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 04:49:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DFg4D3dCP/iRJT6YFn1pQsE7E9H+XSzdonnlFHV49DU=;
        b=ZXTlFrN39LDTxwFl89P9n7mw62mdQ0W0N2fjfJyTSNGjPxmkFyslz37SFG/x0QW5VZ
         4y1zpEJtTim+Dgy1JpLz+L07tv+5+Rui+jYfpXStsVhI2Riwaep+PCJOOJAos+Y+WotN
         USI7dVR8KqXgSVEbSfyJ9Sh0RWLlgvz6TUOa83LOUGj6RDGS80NlCXB5M2iVQwB1ryEr
         LEX7rQNC23P6dvB0i0GMSJWs2VPBALeTfawFaXAP88D2CdXJhB21tZ7x6tUlPmynTGAs
         X3AsFxc6F5daAkxDffOQScbW4F9r5eSk8+D82XZyUECGF6qUuDhzmuOi/8bhONtOOaT6
         aOBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAViz/gXWwYiYUknDoS1Y0uWQNwR4SH2C+EdOYDsa1E9xY2c/zMS
	mBJ6T1aKoHLwV+bwao4si2qaXjfdh9q3na+a+HAbxPMT5EPX0mEa6yf5K9T4XUC1hYDS7QU+igm
	JXeD3/rFRWWofIPvO7fYUjmtPX9q7B8/JR04F6JjbjLWoc8YFDSXZFUc7Z7bgiiGbEQ==
X-Received: by 2002:ac8:404b:: with SMTP id j11mr7414161qtl.155.1553255367141;
        Fri, 22 Mar 2019 04:49:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWE08F78arbmR59Ni+Kpw0FchtBC4+Jo5ERADfwRfUqXADGPP9FVJ1LIUZZIF9FEGjc57g
X-Received: by 2002:ac8:404b:: with SMTP id j11mr7414127qtl.155.1553255366548;
        Fri, 22 Mar 2019 04:49:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553255366; cv=none;
        d=google.com; s=arc-20160816;
        b=YYUlHSI9QVz7TpNSTV6bn6SLQVn2rXoL1nsHzJeGysgoGTSTDF91V4UZSa/728qI9Q
         RhSvT3KotYAK895HQHNaKeRZi8Lu+bt6S/o0LOp8uWn2te0dD2uUyX3e7WMNfHoCUHcc
         wiin5YpukbpkJ7oj+MV5EnPh2F9vg2+DKcQPdL/JqGNvIxXWqBspq1bkFStTZqFV7cVx
         HnDJW3pDk57lP7Au167QzTUEEkpwy/qoRfGfhTqk9eyCCLvM5zZMZiAyY6liORMYBwwm
         O8bnxlhm8bFAtc4DTROjIs1X/4yq6gXpS2vPu7whY4Af3eYKEIIlH99PgsxKmrhh/HV0
         oD7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DFg4D3dCP/iRJT6YFn1pQsE7E9H+XSzdonnlFHV49DU=;
        b=NQDaVcDNgj29oMLc7xZKAhZPNXj1Jf/ZuJYymwvpBu76zLhxJ/RvKh0fQK68rKD3js
         O+faqBDOYLq3QefBHy9rN7gsTGjvf1nGCE5ZJtItmYXZYLeUEycBxg+vy+jFy0H1Ms7z
         8jKr9dvEZfWGlLfkCR8Je05NEDgrLmxk9sHPYpxBjHnkOWb6inWpCzngC6zR2MgjxgsV
         YzDeJvdUjb41IA4RThcVXcF+fuRF0wbQ3Pg6eUlTl5tD9Xl07rWcz3O4K088/6B2rQHB
         p/nRVnWcqcL8GezjpyCfMfgWc3U5CdbfjOuEeXjmOTl0IXCI5opXhBH+XHc+DdmQPl2e
         oMKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a3si3958839qvj.12.2019.03.22.04.49.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 04:49:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 758D8A12A7;
	Fri, 22 Mar 2019 11:49:25 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.32])
	by smtp.corp.redhat.com (Postfix) with SMTP id 2DD3417160;
	Fri, 22 Mar 2019 11:49:20 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Fri, 22 Mar 2019 12:49:23 +0100 (CET)
Date: Fri, 22 Mar 2019 12:49:17 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Waiman Long <longman@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, selinux@vger.kernel.org,
	Paul Moore <paul@paul-moore.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>
Subject: Re: [PATCH 0/4] Signal: Fix hard lockup problem in flush_sigqueue()
Message-ID: <20190322114917.GC28876@redhat.com>
References: <20190321214512.11524-1-longman@redhat.com>
 <20190322101535.GA10344@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190322101535.GA10344@bombadil.infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Fri, 22 Mar 2019 11:49:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/22, Matthew Wilcox wrote:
>
> On Thu, Mar 21, 2019 at 05:45:08PM -0400, Waiman Long wrote:
> > It was found that if a process has accumulated sufficient number of
> > pending signals, the exiting of that process may cause its parent to
> > have hard lockup when running on a debug kernel with a slow memory
> > freeing path (like with KASAN enabled).
>
> I appreciate these are "reliable" signals, but why do we accumulate so
> many signals to a task which will never receive them?  Can we detect at
> signal delivery time that the task is going to die and avoid queueing
> them in the first place?

A task can block the signal and accumulate up to RLIMIT_SIGPENDING signals,
then it can exit.

Oleg.


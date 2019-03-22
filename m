Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89696C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 10:16:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 476E621900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 10:16:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="eHZqkMXu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 476E621900
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4F556B026B; Fri, 22 Mar 2019 06:16:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D028D6B026C; Fri, 22 Mar 2019 06:16:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCAF36B026D; Fri, 22 Mar 2019 06:16:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7FBE36B026B
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 06:16:02 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o4so1807254pgl.6
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 03:16:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nBJewWCbdaJ5X4iQT6hRh0j0tFDuXREWOR4IbUJXZrw=;
        b=cU4gA0/wtvStYZKxeZ9nE4XusKlvBfa0CWsvtGle2aN6fKWKY39bp5fQFzz5gBZPua
         Vf/V+o0uRd9RfPZR6T+zos46mUnYyzotFykyz7e8zFldsjOPDDtTKQjRxkVWtlc7QFxe
         zAqpKqNRnnx6VkqsZWF1z7YbCoAi3OS90Ic7Ixsg7q56m29y3k8RBBo3WirTOiLYexkt
         kOLGtI0EXeDbYKm753FsBUgr73XbRm4Yky4cznf+2zG+rJgkVN7+uL9o3xg8E1kbf9Qj
         QjKjWXg+SbY4WDS0OEqrUq4s065NBPzkK1sqmcjgaDvj5CGBHYdcaG1DTLNDSxB0mP0i
         Abhg==
X-Gm-Message-State: APjAAAXLwMUICjABd4RUCL7SuoNQW+bHC0LGOc1YVQ0ynZaVSE5vCsRU
	JtDL0rLdvqfEj4PRDALtQQbEFHOLPXq/4oIiqASfMPE1ykQ2VtbvqJo8J3dSS6hx+eleLY+oaP/
	CUkorn6cLEIQSGsIWIzYn1OYjJQU0zLWX1CVN8088QM58I+0kHW7inVEgH/IqtWGFzQ==
X-Received: by 2002:a65:52c8:: with SMTP id z8mr8137408pgp.259.1553249762046;
        Fri, 22 Mar 2019 03:16:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkUy6A4YmIuPTEM+3/yRbHknHvQAQD30Q3cLguHILtT/Yy0PSlq3dpLKh9K8M4Z7f3uXxA
X-Received: by 2002:a65:52c8:: with SMTP id z8mr8137357pgp.259.1553249761223;
        Fri, 22 Mar 2019 03:16:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553249761; cv=none;
        d=google.com; s=arc-20160816;
        b=DlLKrAx/wyjN4Mb1eKMsbLkPDcbkvJVMxJTtMH9XmyyksxD2GSHpq+EhJEb7Hrrq8L
         JHOMRuihPtStD3QnBVGXyYy9mMt5miVQYQNwBV+gtUrKXgAbmOsCRxK+5bIHahbcekbD
         jIUXvIMjjRPJ0QAVKnGdw8ExFQ97cYDDRn1dhRGJLbCVFETd0DwSRljHlm2r3zWU4iE3
         B8vn3rF6v0193VY+yq/N65X/LaD8LmiuuL9m+1j7v1vtO4wIEI7B8rHpnJ6EfSKL0L+3
         pkXjGBYnHVDL9z3c66k5OzchfHXjhtvAcW5DBNPnHmJoSqgKJp6lcXTQPFx5ooaWmWK0
         zmFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nBJewWCbdaJ5X4iQT6hRh0j0tFDuXREWOR4IbUJXZrw=;
        b=gQs6BF5gn6YWFLuFXwgXAmMxiCPRFSjDCKsBY+2oH9tlXZSatzII4BfHHc2boWquik
         lkpbm7cYhPmxHH4qjrwiiBko1c390eGKX5Q0rXaROiDBishB9TcRyMI+rWjnOi9tNEqH
         E2KEli/pYcDXbXMjNTPUQrfB3SIfXNCxdjBG7b7N+smjf5mvnMk4CbEeNsLBeDvLu+E5
         CFmHrS8HKIPka6BQf0suRYJ9bn1JAgnKjss110wIL/hBGeYImBFyqwiQ3Fk+EUsm8BlR
         UDD5meyqsagdpkel+DxV7BXTRFlAjhsD9yItKC2k7NDwLtzjaOz6/cus1+udv6FvjO/a
         prSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eHZqkMXu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v198si3958763pgb.204.2019.03.22.03.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Mar 2019 03:16:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eHZqkMXu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=nBJewWCbdaJ5X4iQT6hRh0j0tFDuXREWOR4IbUJXZrw=; b=eHZqkMXuJaUupBq5agtV44k7F
	rlUiJ5cff+KL4dk+vjyMIFhLoq4JYR0WhK1ryKV7Nym63LnjGzMxBoF7HODFZyQuc1Zbb2hlBIlFH
	77oZYullmVvDUschGOvwJxz1lqJf73QZPU364tHP/Wo7XGZICNCGIETJO/443iPrcSIWCock3qWYB
	9nDvjnTkEZr6RyExdNRDyrQGRTu1GNBu4BevbyT/ZPs9HTctSQpu2/n+OiuQ19rVZT2sBOg2K/2B1
	VVl/vIvTNpogP3pjWIta6k4fqBzVTHxeU0lc9vuMrv+O1eq+CzFe1WDPpeNaHB1W3Ep9RfU4VoXd/
	KUnsSV5IA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h7HD6-0003yd-1c; Fri, 22 Mar 2019 10:15:36 +0000
Date: Fri, 22 Mar 2019 03:15:35 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Waiman Long <longman@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, selinux@vger.kernel.org,
	Paul Moore <paul@paul-moore.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 0/4] Signal: Fix hard lockup problem in flush_sigqueue()
Message-ID: <20190322101535.GA10344@bombadil.infradead.org>
References: <20190321214512.11524-1-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190321214512.11524-1-longman@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 05:45:08PM -0400, Waiman Long wrote:
> It was found that if a process has accumulated sufficient number of
> pending signals, the exiting of that process may cause its parent to
> have hard lockup when running on a debug kernel with a slow memory
> freeing path (like with KASAN enabled).

I appreciate these are "reliable" signals, but why do we accumulate so
many signals to a task which will never receive them?  Can we detect at
signal delivery time that the task is going to die and avoid queueing
them in the first place?


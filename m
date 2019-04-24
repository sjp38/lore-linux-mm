Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E5A1C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:46:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31DE3218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:46:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AmuSwOyL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31DE3218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA1A36B0006; Wed, 24 Apr 2019 15:46:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C51DC6B0007; Wed, 24 Apr 2019 15:46:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B40E96B0008; Wed, 24 Apr 2019 15:46:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 96F8F6B0006
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:46:20 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id z7so15164969iom.14
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:46:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=4eVIy3czAn23vobeXz8xHXFrh4HunqErlYisbzn2mkA=;
        b=Uidaolja4yyINYna7eQj/TXjktLXanp6Mp52z9Xgq2Tl3jxibQDbcQ3Zepws3R2K7y
         1Y5WK5CSBWQTXZ8n6zCR8NCZUQ8IvJVT2kZ20fBeEUNrNHZSRfXyU7pCi7V4AETiIBWU
         xhbHZrHrcN8gTbMbiYPGMGyUuAn+fVsg94+7PFKuvdLZMHuZFVsAfvDtUybdoskLCEZQ
         9UoTnf2LRPXYueRPr8opbZAQi2ocXG+sXZ7wIpQd01hepmzTDowUpCUxzWXI+pDu6X+C
         9KG4Kmp+SVCfLjAhGFc1ZWm8+lpJloVDP0TdJNxS2q9BeWDpcccY9E8g/JG5DFiLzr7+
         4HVg==
X-Gm-Message-State: APjAAAWYETeyhL+3ntw62N4P1FtJD9KlQsJYtrw6Nb8IRiCaNBQ8WSzm
	sBPxL5WcbocVaEZroM/vwexMh8nOHWTltXrqCkxe6m9CZsyDJGoFYMy++Gva2kFKb5f6eAI15XK
	XVAS3Dgy6mEAOGbN4B/rzubXzWYbYtH+dXV3GH1p+KLlgiquY2uPP31UFUWk9rluSlQ==
X-Received: by 2002:a02:741c:: with SMTP id o28mr10543944jac.144.1556135180417;
        Wed, 24 Apr 2019 12:46:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMh4p+eFdH69nxTtUdZ98Ax7DDV4/Dh1HcaLNHzUxpMVRnyRFwyCRX0J8FZ8oxrHjuPdaf
X-Received: by 2002:a02:741c:: with SMTP id o28mr10543908jac.144.1556135179762;
        Wed, 24 Apr 2019 12:46:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556135179; cv=none;
        d=google.com; s=arc-20160816;
        b=r9hJO9GwvBJzasJRf+oCSaOMl0cU/XNHAUN10ymNTWrAgbmECP1tcwCbccP9KNRdMS
         t5P8VUvPxBXXcY13JNHAjnZYnFvy0lDJA2H4TGIVxylSjESzvh56Ka1xoia2K9D9YtfU
         V1asB/zlzxLfGWhaCfem0Dev1b59r3VKOTcWWPo3f6qdo2D4EhYvi2wAhkRz4QAJi0WZ
         BA2jky4q3EtwpFFytUO+jSbRugGL31r86BC63VC/pKsHtEuHcuk1HgjqliPYqtbkSLgM
         WC8DTcfQc5l0cZlMZ0FHjCO0t/TLoDRbslCw5Y/rdNb+tq54DrgOh4AuldmQJwqYhvUn
         rCqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=4eVIy3czAn23vobeXz8xHXFrh4HunqErlYisbzn2mkA=;
        b=zeTh6DAetpIvPf2R3/qVJ58ZIYSogzpG+g+p8J59jhh8IpJRGDKlLvD6slGTup1A66
         abu4Q6HSxrAtE7LYyAb91f9f5bNH3CFaZCEdc2I6pC9GGBwnNtmoIJsUPqD+Zhf3xruw
         M8/v9FovaIEEBFTxLMmkdaAPSbyVyyF6KwdYVWA/Zp8awagP8Zb5e/pj9xWmabegjgUp
         oERUgOzQF1+ZAf6bB3OEzy5Mmphw5B14EolnrdUSPNPnggJ/BAohfpKBIC43tIusLjnn
         3b9YsFTRexQRAEeJMTUH1Mme5SFzRZL/QbxBXj5hlgbVo1w5Y6PhGlj+3oOgA0VofVpB
         LFBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=AmuSwOyL;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id w136si12579660ita.120.2019.04.24.12.46.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 12:46:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=AmuSwOyL;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=4eVIy3czAn23vobeXz8xHXFrh4HunqErlYisbzn2mkA=; b=AmuSwOyLbSNnfdXnlzatsx9qY
	etKIJrLorbJq3EXK61vUd8O6UjB1tDm59T91RkmblHQHYL9kVvFLXBB4NDqQJ3e8J6cQsFpQ6RQPg
	x/0jl79kRahYdX1mB1OT1NUGOwigYBklCJuAC3e6Nf0kYdorKNltiBd3Mg+w2CdVUNE05cBwdHkkK
	93Ang+dOQJKq9RTFsMGIn1cJW44e8nUljTFZ34DeOmrCGMmUDz8DUDDvmxZPIBsaPUPbpNvhM3TYc
	S2sKs+5OOdj/eYDuOG6AvUfkGGsXC4DpfB0HcAgZAVEGWjd3kUZOzbB8LQ7ix9rfzhcBf1ceye29i
	ZUIRYwwWw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJNq6-0000yX-Cu; Wed, 24 Apr 2019 19:45:54 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 553DD203E8871; Wed, 24 Apr 2019 21:45:52 +0200 (CEST)
Date: Wed, 24 Apr 2019 21:45:52 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
	David Rientjes <rientjes@google.com>,
	Christoph Lameter <cl@linux.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Daniel Vetter <daniel@ffwll.ch>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: Re: [patch V2 19/29] lockdep: Simplify stack trace handling
Message-ID: <20190424194552.GS11158@hirez.programming.kicks-ass.net>
References: <20190418084119.056416939@linutronix.de>
 <20190418084254.819500258@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418084254.819500258@linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 10:41:38AM +0200, Thomas Gleixner wrote:
> Replace the indirection through struct stack_trace by using the storage
> array based interfaces and storing the information is a small lockdep
> specific data structure.
> 

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>


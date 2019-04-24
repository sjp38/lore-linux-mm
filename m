Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 921FCC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:45:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46D7F20652
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:45:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jnXyb2lO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46D7F20652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D66E46B0005; Wed, 24 Apr 2019 15:45:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D16A06B0006; Wed, 24 Apr 2019 15:45:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C05AB6B0007; Wed, 24 Apr 2019 15:45:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8AEBF6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:45:23 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o8so12722740pgq.5
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:45:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nXNCzgXPp/MC/y/PJgs7pmMKbFnjx8a6N8WFYhwtNcs=;
        b=TvWdz52Q3Ust32TJZG/IT4y1iSCmAdZ3+1Kv/Xgn8ldFJq+mBs/kVs/QwmIodEP7T+
         He+5ZxSR0idx7K3uOQKTiI3Qqdfb/PaAs38HQjRIRENzx4BuID4FuRa2ERhJFGaxCTJX
         LeqlyYCf+1xn+klEg2JfTBK9v9D3278MiA5BUiYhgCs6x2L0uToBoZH59eEzxMVkFazM
         70LfHIIEmQELYOIXoWWAD7hDm6zDma9JjnvqCbW+Lnp3eYyL/b5IpEt9L2ddBK6bFJ1m
         gSfpDJN7aiV956LIvxMNsXrdVj2hdtxg3g4lX8MfUD4IQPrs4Rn9nljYXn+x7bUmrJif
         Rmmg==
X-Gm-Message-State: APjAAAUf46/fLnn1no6zE4XxJlRtrloiqb5hfc7HJ6pK1ntEBOVTFnQJ
	zmtPKKPK4oSMZ+eBFgbO/rhPfZLtmHnkBYOEkB8O+8V0HtAQ1/p9tqCQRl2Lx8IM8nU4z5E/pW1
	8rFp2ipevPZNZcPK64ALIUOzlEhchB1I+1HrNCS4UbAw1jqEctXryUWs3DxNPPoZtQw==
X-Received: by 2002:a63:170d:: with SMTP id x13mr32234525pgl.169.1556135123059;
        Wed, 24 Apr 2019 12:45:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8AB9ZV4FnJ3VhLmh05RWCpsegR/352dXkOjIcrW+2fu4o2MXcOHuC6wpY8UkR36gunIwN
X-Received: by 2002:a63:170d:: with SMTP id x13mr32234461pgl.169.1556135122391;
        Wed, 24 Apr 2019 12:45:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556135122; cv=none;
        d=google.com; s=arc-20160816;
        b=hTJMGK/iLTaqucg6qoayhO2Yy4BOrkeThF2tuoyF+hwY03J1tWX7LANRqhIt8/IXjM
         gKzHBj97RdNmJg41vWOsqWh9mSv6RmZl1wFYeg5aiWzN4aEfVg7+93igsSBU+Ve9CL8/
         eqtb5GXjg/+hX1yAtuh/TGr77DdyKJa2OKxIIg+tB48AKFhwjtUcDB1+sPoVpOGhPoFA
         pokrDT1ttTczB1LxIFCcX6nE2jFbDzt7649qhUuzAtWtI0SCPtSyoqQ/ODLhXauLWSSr
         4Q/CvWMdilmRCj3t/Edh7BT4B+qKXx5G7WiEB/c5tznY4oyCTFok/20LJVDMyMdGU4QW
         XdgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nXNCzgXPp/MC/y/PJgs7pmMKbFnjx8a6N8WFYhwtNcs=;
        b=GbANy7bM4ToOpVhZ34EJVjZtpFhFRzN/ILy3xCP+tU7FwvaTmdAFHjcdu46yOm2JPO
         D+qDHc5TBLG7K7wam/6pMtMrznvvoEdWNFAQEvyDAvkISxGgIZeiCB6/OySHjMvaHfng
         AVX2rcxsB6dMlcDKqpZZIuVrsa5+M9oUCW8A8D8FeprhDdfG9l3XOvGYK5JhnbEjn4+5
         mc9+LcyMbmgGMnUh+RAWFDeFPRikOJkQl5OqXlEZa+/JjZriPfhhiaQRwtNqJ67o1M3s
         TPeyjQyBV4SU++/qTvvjmlPD7iRWupeoabtjajpQndImt7MswfMeEa3bumbtEGRHdcZ2
         HUCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jnXyb2lO;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v9si18274905pgr.167.2019.04.24.12.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 12:45:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jnXyb2lO;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=nXNCzgXPp/MC/y/PJgs7pmMKbFnjx8a6N8WFYhwtNcs=; b=jnXyb2lOVttIJoTmHH09wDdgf
	n8NwsMb9Q8EZ9BhZYTUEmA/PHtyPiQZOmqBu9mXa6yS7FNimIsZTp3th5+3stcuYygHbNmLLYqBGT
	QahsATylTqjWyQwmQWDXx0qU89AA6/OXLd2NCoPGpUOZ+2qhJ4st3eHGbksMYs7v8Vz1EtlVHBU/V
	0d2uWTvtE1ut2NEV0rW9PoEWWmPOPkZ6B4Ll/v8YqCWjQwzFWcsIDvwui3aaYqTf72W1WXM1j/0xM
	JpCvyP3P7MY/egBVMNbkcye19upsSYlZcw08/CLq5k4oepPII8zRfmSr6JNXtPbV5jb8VqzdiXZp7
	XpWmu0naw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJNpM-0005aH-OA; Wed, 24 Apr 2019 19:45:08 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E5F80203E8871; Wed, 24 Apr 2019 21:45:05 +0200 (CEST)
Date: Wed, 24 Apr 2019 21:45:05 +0200
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
Subject: Re: [patch V2 18/29] lockdep: Move stack trace logic into
 check_prev_add()
Message-ID: <20190424194505.GR11158@hirez.programming.kicks-ass.net>
References: <20190418084119.056416939@linutronix.de>
 <20190418084254.729689921@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418084254.729689921@linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 10:41:37AM +0200, Thomas Gleixner wrote:
> There is only one caller of check_prev_add() which hands in a zeroed struct
> stack trace and a function pointer to save_stack(). Inside check_prev_add()
> the stack_trace struct is checked for being empty, which is always
> true. Based on that one code path stores a stack trace which is unused. The
> comment there does not make sense either. It's all leftovers from
> historical lockdep code (cross release).

I was more or less expecting a revert of:

ce07a9415f26 ("locking/lockdep: Make check_prev_add() able to handle external stack_trace")

And then I read the comment that went with the "static struct
stack_trace trace" that got removed (in the above commit) and realized
that your patch will consume more stack entries.

The problem is when the held lock stack in check_prevs_add() has multple
trylock entries on top, in that case we call check_prev_add() multiple
times, and this patch will then save the exact same stack-trace multiple
times, consuming static resources.

Possibly we should copy what stackdepot does (but we cannot use it
directly because stackdepot uses locks; but possible we can share bits),
but that is a patch for another day I think.

So while convoluted, perhaps we should retain this code for now.


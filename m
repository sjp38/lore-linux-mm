Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F042CC06513
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:44:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD49621881
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:44:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="VGm4cgty"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD49621881
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51F1A6B0006; Wed,  3 Jul 2019 13:44:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D0668E000D; Wed,  3 Jul 2019 13:44:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BFEE8E0001; Wed,  3 Jul 2019 13:44:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 00ACD6B0006
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 13:44:53 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x18so1924062pfj.4
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 10:44:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=E+nIXNVtybGCJQ9qhR+v7ySrKVmdYkqu+JpBB3XRK44=;
        b=iK6oeMPfAw4zf0NDwT7QRGT7Ln9OU1TKET6J8OuuaCYp3eINirY9JQ0MJFWu9BmNSK
         jLxzG3mAXGbzADRlIRKEjLu/TfvvOMgJAFOI7CONZYYCAAJ2nQgNw6XFfk0rX4q0gMtQ
         wbJwJL3KcOrzaFpnj4BpbhGJVcNHAzMjAtBDtDzGaYmNlYnWHbC234Z7eQnG4pnN6U7O
         5xztCYs1LKwiCe5ZLbKYd1S1CHeFCpmjLfzm5Bni9KSlL/OcXTS1F9USb3gKYLw2o2AS
         PexjEPtt8HLNuvpkrWfuV9wSfMxJL9PLGgi6Z7/X3JO3NpX7+1OeQYPBjuQiWG0sHfMC
         wf3A==
X-Gm-Message-State: APjAAAUjHq1Uc7lDDHHo5SOSZqDEy4D7oyq88UCKS2kGmhvlWetq7Rbe
	9rsYf7MSrbPeqwA1EIP+MIEfyTd8LXUkG9nf00R85jvP0Zr3yuuCRCg3z1ec9PfJJRzDtqahcY6
	wbKeL7vjNOuk1dWyOgBgLxVGSwWzDW4lzNCbH39QcxJVq86NnmZw04EjWvmVG6LTLqg==
X-Received: by 2002:a63:fa4e:: with SMTP id g14mr38270117pgk.237.1562175893532;
        Wed, 03 Jul 2019 10:44:53 -0700 (PDT)
X-Received: by 2002:a63:fa4e:: with SMTP id g14mr38270000pgk.237.1562175892185;
        Wed, 03 Jul 2019 10:44:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562175892; cv=none;
        d=google.com; s=arc-20160816;
        b=xMgyZuMxXVVkiok5NFT5C/yq2O2vTSgZlbwFjB6l7MSKWjctjN2jVlNVXADs8+uX8A
         s8PLHlpKboHk+8y6kH0ByYQX9+RGI/ugWo6mJWBAHQJAcd5EkXfg00Li/x5m+Wqh7YZp
         KrJ20ATbNJJbSVjfWykA1rUEJZCJ+tjVl2WoPvd0lGL63xFmKYLU2KqqdTY8PgTlBtGR
         Etef3i1cCI5ZGij/w3tvigHXC8GQ2aqCBLxcXsF1dbcG0cl1CempqgBavwsLrYoWBX2G
         Npwhlc+tCD81adCo3OFcXEH6hu+VhOOW6roFSEHZacZhnX569/pMYwPTjCZT0PS5L5se
         gOcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=E+nIXNVtybGCJQ9qhR+v7ySrKVmdYkqu+JpBB3XRK44=;
        b=aj8g5I/mpGIGS8HjKSqGp8KOaVxH54PgulAUpDyXLuq9UYdHjuLvqxpHoL1TWAKb1t
         vxtCtmzeiHTkTfvzbShEHMPH1fy8dPYIMbL5JAeBqa8NNBUryt1zNFq/KGTkQ/pAvaQV
         LhVk4LrXMNiKJwNQouL2nyDRpq9rNS6z/Z05DQ1ecNYvxglQDq0BbLK9dBoyPDR6nxb2
         aHBRjTQ7G6+6ERBxd0mfeQjXxIVQy1SgtiIkiyDisoC/86+Y4YtFEFCcFgeLzxK+5/sc
         YUC4eoc3cx2SX3inteN9Itt1L5fDvO4enZs09q2ZKbDbsw5wQoWiCuKLGDXTNVmhd1VF
         ZH9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VGm4cgty;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 19sor1512579pgo.69.2019.07.03.10.44.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 10:44:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VGm4cgty;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=E+nIXNVtybGCJQ9qhR+v7ySrKVmdYkqu+JpBB3XRK44=;
        b=VGm4cgtyuTX82jA5Q7OkqzviUC7ZS3E1fwHKamsDm+UAbbNRF67b8ZYcwOoKfx6UvT
         yD5jrQPVE8fBsT1+7vjAyGEBXYa708NL3AAHTpXQubo0l2bhrBSZ871MN0nZ/AJiwdd8
         xrfc7Y7NXHqF0sXfiwb+/eqvImMniB0H6K3E6+fFwnJ7JwlfEe20OqqGToK5uwTXqNq/
         4pye2K9cVhUqpj6h3YTAUMB9h4p5cICiXBCmdrbIp416i+hvmLHO+Baviv4uDez5FViF
         v9o1XoL+AFUzvC8K+LVa3P09MOhAkKLAup6cLLiTT5fr0x9vDqitwp12MaBNuyZM4TFU
         CSew==
X-Google-Smtp-Source: APXvYqwArpI7P6wKPUVysPVfB3+fPhZXcp1OWM5P/heFWlYBdzn2JqcYRDrKS9rawXIy3vL2I9zG4Q==
X-Received: by 2002:a63:6286:: with SMTP id w128mr29708938pgb.12.1562175891115;
        Wed, 03 Jul 2019 10:44:51 -0700 (PDT)
Received: from [100.112.64.100] ([104.133.8.100])
        by smtp.gmail.com with ESMTPSA id y68sm3021050pfy.164.2019.07.03.10.44.49
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Jul 2019 10:44:50 -0700 (PDT)
Date: Wed, 3 Jul 2019 10:44:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Oleg Nesterov <oleg@redhat.com>
cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, 
    Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, 
    Qian Cai <cai@lca.pw>, hch@lst.de, gkohli@codeaurora.org, mingo@redhat.com, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
In-Reply-To: <20190703173546.GB21672@redhat.com>
Message-ID: <alpine.LSU.2.11.1907031039180.1132@eggly.anvils>
References: <1559161526-618-1-git-send-email-cai@lca.pw> <20190530080358.GG2623@hirez.programming.kicks-ass.net> <82e88482-1b53-9423-baad-484312957e48@kernel.dk> <20190603123705.GB3419@hirez.programming.kicks-ass.net> <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
 <alpine.LSU.2.11.1906301542410.1105@eggly.anvils> <97d2f5cc-fe98-f28e-86ce-6fbdeb8b67bd@kernel.dk> <20190702150615.1dfbbc2345c1c8f4d2a235c0@linux-foundation.org> <20190703173546.GB21672@redhat.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jul 2019, Oleg Nesterov wrote:
> On 07/02, Andrew Morton wrote:
> > On Mon, 1 Jul 2019 08:22:32 -0600 Jens Axboe <axboe@kernel.dk> wrote:
> > 
> > > Andrew, can you queue Oleg's patch for 5.2? You can also add my:
> > > 
> > > Reviewed-by: Jens Axboe <axboe@kernel.dk>
> > 
> > Sure.  Although things are a bit of a mess.  Oleg, can we please have a
> > clean resend with signoffs and acks, etc?
> 
> OK, will do tomorrow. This cleanup can be improved, we can avoid get/put_task_struct
> altogether, but need to recheck.

Thank you, Oleg. But, with respect, I'd caution against making it cleverer
at the last minute: what you posted already is understandable, works, has
Jen's Reviewed-by and my Acked-by: it just lacks a description and signoff.

Hugh


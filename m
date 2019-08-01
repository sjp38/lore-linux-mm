Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97692C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 21:59:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30D1B2080C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 21:59:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NFJ5mx3p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30D1B2080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 865F86B0003; Thu,  1 Aug 2019 17:59:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83C986B0005; Thu,  1 Aug 2019 17:59:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72B9B6B0006; Thu,  1 Aug 2019 17:59:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52D3E6B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 17:59:22 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id h4so80923027iol.5
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 14:59:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FlbNAsgaWkp1ShDCheHxAkj85en9Tu2y9Hru44fhYz0=;
        b=jmfgnhDd6agb1J36NPPR3DoL4weF4iVB1zmkJ2nD6EI5r/WlG6klx4ri4V8ei3z60J
         0eNRcTIIrcIoYekv3bWdapMWb7jskyRDSUBfqxIMW2SdhVWJXLfcx+eiI8KxiKHREtMU
         DnX42NXIPHOfU/JgCrgugzLiTMjSArlWWNH/aLAyJK3CuVQqs72czsv6Oi/CpdouDND0
         p/1PI3As2keFg6Ms26yDB4CM+zGRpKnnwZ6+HdrJsVpoGPzlE+BNxlenqwcMzqUslkb0
         5Po2ZPguDWXfiUBG0/HI4a/8bxSD61mKgO8sa4+GQqLxvvAxr0pMLInlnLfms10jR5p4
         p5vQ==
X-Gm-Message-State: APjAAAUX4+k/QW9RY2DF/TGSzhxGEG4dbknWayyOsDAcg3O/ffHS+uRM
	dpvP7nU/Wo3bUXokg1Sj6LLZdt+27jxadEqo1KDJnYEVj9wvomdEj4oureTYYu09elz2c0BRA3T
	5Zu/E3A190EmPFNgQ7FBUdApRxliUAp042Eo2w1rDn2/lkIrcvMMVNSdWNoh2RcmWwQ==
X-Received: by 2002:a6b:f910:: with SMTP id j16mr314049iog.256.1564696762069;
        Thu, 01 Aug 2019 14:59:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhjkk1nbAJMdgyHn2vhVzahAP2IBOBlFdNkdTlPoZYKmCKD4mvWnB15/yiRe8KwsQr5BP8
X-Received: by 2002:a6b:f910:: with SMTP id j16mr313970iog.256.1564696761111;
        Thu, 01 Aug 2019 14:59:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564696761; cv=none;
        d=google.com; s=arc-20160816;
        b=Xgarl+Tw1lOpf7sEzQi57axIVOEcnLTNAV24d4rbd2/L6cRNcOzjTb3zP1cLSwqHJe
         HHsKi6IK/qhQz4Q6xKr40qzfFTIF/q5Z+dBpJEQaW1KtTHWtwGT+QtUrH7tihjEdHsSK
         SQ35vz2oMVbmCpNDl7H31903i+pXw/pPcW0f4c90M8qWBWSrLQm9OBzNDOac8Xx+yJ01
         r1Pcv+mvWsy6KQwZq0W3wXcPceZ6AbeJ5Gkgs3GbHEygNg8FzCsQTfQuuf2j/Ru9uZVY
         oI4yuCmPZ87YfzEJmcJVw3WkvMMWyZ+kidj9dkp46VoMJoGD5cHUfPJnF0V4H1I2RB7+
         wi4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FlbNAsgaWkp1ShDCheHxAkj85en9Tu2y9Hru44fhYz0=;
        b=evHmSEq2ios8XnH0NQbhSRSoQPI5xlXKr/eCSTWRBxtFKpOMMDNKDmG1UfKTg/ByhK
         8+cp1eAOTDoPzoc6oE9ibRV2v6/Yg9n+m/UWg1/z/Tc4GNn7WSr6WGZcnJX3Avx/sN/r
         KEpcgWIuknKVLG989wNFwMIpmc1pkLcTE3FOVQ6MuIUdq+b6ONXFxJbCAK/HLlXqbM2x
         Q1CE1Ce7giSt0+k6soUfsl+TAFl9t0HNbi3uzhMvXA/USDdyFg21V4xTgLMJd1AgjeyW
         p5JSMs/AOLBhICUktqiqmht0jPQnw+waPW1sQIZnIbR0ZS9asyVNhLAlR33oY//ADClp
         0FtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=NFJ5mx3p;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id q3si85349703ioj.22.2019.08.01.14.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 14:59:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=NFJ5mx3p;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=FlbNAsgaWkp1ShDCheHxAkj85en9Tu2y9Hru44fhYz0=; b=NFJ5mx3pun9BIYphO0C68UAUu
	bNIl5t6nnsxHXQq8rOyvK1+2xENKG1banbuqonFceMoKyQfDoNijJJq1cmdDthZGkLdEJaHaa+JRR
	sy9AZHK01JafhzTXpLIhZcM24Nt52lWl/kRGtNf5E6LX5xx1DNeoa8ZNntincpMLRDHuDoi7WC/+y
	HA3O23EObKhT4TPP+bFOaHWWnfil3CE5Ggc/aCnZxceKFfwCToLfXOTGqgxuInpjTOEyU5G52eQ61
	7gsEOZqcrfczHuU7P7Dx4ONddvwcraEmcYcTxxpMkFOgVNQGyPcL7cM+eMlCVnQ+Z2HDd9+SLiVEF
	If+0fSSdQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1htJ6I-0002fJ-Mv; Thu, 01 Aug 2019 21:59:07 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 51E57202953B0; Thu,  1 Aug 2019 23:59:04 +0200 (CEST)
Date: Thu, 1 Aug 2019 23:59:04 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Ingo Molnar <mingo@redhat.com>, lizefan@huawei.com,
	Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk,
	Dennis Zhou <dennis@kernel.org>,
	Dennis Zhou <dennisszhou@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-team <kernel-team@android.com>,
	Nick Kralevich <nnk@google.com>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/1] psi: do not require setsched permission from the
 trigger creator
Message-ID: <20190801215904.GC2332@hirez.programming.kicks-ass.net>
References: <20190730013310.162367-1-surenb@google.com>
 <20190730081122.GH31381@hirez.programming.kicks-ass.net>
 <CAJuCfpH7NpuYKv-B9-27SpQSKhkzraw0LZzpik7_cyNMYcqB2Q@mail.gmail.com>
 <20190801095112.GA31381@hirez.programming.kicks-ass.net>
 <CAJuCfpHGpsU4bVcRxpc3wOybAOtiTKAsB=BNAtZcGnt10j5gbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpHGpsU4bVcRxpc3wOybAOtiTKAsB=BNAtZcGnt10j5gbA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 11:28:30AM -0700, Suren Baghdasaryan wrote:
> > By marking it FIFO-99 you're in effect saying that your stupid
> > statistics gathering is more important than your life. It will preempt
> > the task that's in control of the band-saw emergency break, it will
> > preempt the task that's adjusting the electromagnetic field containing
> > this plasma flow.
> >
> > That's insane.
> 
> IMHO an opt-in feature stops being "stupid" as soon as the user opted
> in to use it, therefore explicitly indicating interest in it. However
> I assume you are using "stupid" here to indicate that it's "less
> important" rather than it's "useless".

Quite; PSI does have its uses. RT just isn't one of them.


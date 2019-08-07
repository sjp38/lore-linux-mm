Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41E07C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:12:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02B29217D9
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:12:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="rZ0i7K+4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02B29217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9503B6B0003; Wed,  7 Aug 2019 17:12:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D9AC6B0006; Wed,  7 Aug 2019 17:12:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A1CB6B0007; Wed,  7 Aug 2019 17:12:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 471286B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 17:12:54 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so49425947pgv.0
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 14:12:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HDsbOqdqt6WL/tNlrJsj+N++Ozhrzy+jd8MDoupW4xM=;
        b=bBmnEo7omVKj+HawDBLsskJu/x51uJN4DZv8xQFLqgDOonRbKXgqFgXKwrnrN8iZpJ
         4EVwzXNBfWt9mFMxZ3LrPhP2ddVjY9TtHjfV2vylvFtuglxTn02BotZfXo1m1u+OrBnr
         mubYhVhkxamkl099yeXYXBmoGjF5EouomKGFhQC7fTAxNmFkZBnWRKFWNYnmgfP0zm2X
         PiFv+5XrKUwTtBbYp9sIJH/Ck8o7qmRfwGlsH6i7fFp510IhQg3/jHfn3ASBdBh4T4N2
         ywWQXoj9t0iWD8i7rqHDdFub8YSxgq6tZayPBxWbq6E8T8IlbLJ8qxJpyM/u/ybaFXru
         uG4g==
X-Gm-Message-State: APjAAAXmmLY5aFLBcU7pqZMpdV5+kIVqp/1mBfmgrH4+yQCsnS8GzXW3
	Nmh3PGhmKymGUFj9c5kE7d7UFHVe9d2l2h29rCnurowoE2FciMPCxztgGs2T6Xcs7URP+qOcAbQ
	IbfCKf0kzpAf/+oUCJnQ0yyLGddCDWLA8a7UO8dHv0Yg9yOxzOvPZT3qVziZFV0czKQ==
X-Received: by 2002:a63:5823:: with SMTP id m35mr9637070pgb.329.1565212373547;
        Wed, 07 Aug 2019 14:12:53 -0700 (PDT)
X-Received: by 2002:a63:5823:: with SMTP id m35mr9637014pgb.329.1565212372778;
        Wed, 07 Aug 2019 14:12:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565212372; cv=none;
        d=google.com; s=arc-20160816;
        b=v5HveeshfSLAu+dz6vOsYWDm6ov8oKVuHRqzhO2GS9iM7exzb9MLt/pM2Ovf6CRrdS
         h+D6ucM0LSaMULRdyQH1YKvvCyAjAo7J9Qbn94TRYPbFX46jhuKHJFIo+nJhKqBLH8sK
         ap5kN11nLDbtKrOzMlbj/D3yVLZFjLVed/YvaXKgoJoFAum/DCxvUy2oB2pRBzcPaspJ
         hKzp75swhXEJg09bstcdrH7/RdOBo5SIg1YcPmSOKlEA8Nez+9UhIyoJ2Rg/8AtZy5KP
         HZpPfcFv+ZT9MctJ2hRSNpKWBQfNA5VBUUnWS3n9tXrTtsT5dlqORoMKg7xr2WGRzlKB
         3Aiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HDsbOqdqt6WL/tNlrJsj+N++Ozhrzy+jd8MDoupW4xM=;
        b=eQiNxXaNWdzwqmJ8WWe3iXGS3pAcv1CIV/LZCU6QWGsZ3NDpYHiM3ag4Io1bT5v3U3
         PcEZ8RMchi9fiJ1GzYeEtS51RL3U0TFZ9ATp7qNWLSGyERDvIe8HYLZKIu4fjjO4QlzM
         Ss3bdG4vBYCNt8cf3yDJjdIL8WWigagD1FztJB4KU5yEhKENdGMVcak2DhwnKE2FKsX4
         L/cklsUz+gbM7DsPCr+aDPEqXgsy4sqEmzF1hyuQJLwVgKycmNeKGV9UJwmPcJ0ACVeO
         cLKx0dPlIyebg8KYFFvztAAhEypz7J6ZDbf4XWfs3+Cv0x2LgMDldbQ7KmWhVbLE0TXa
         2kxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=rZ0i7K+4;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p10sor61777373pgi.61.2019.08.07.14.12.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 14:12:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=rZ0i7K+4;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=HDsbOqdqt6WL/tNlrJsj+N++Ozhrzy+jd8MDoupW4xM=;
        b=rZ0i7K+4dO7YAgZr7g3eTN78Jx4YSreaML2nif7MCjeuCG2DcmetfvCHzYeNrxmOvI
         GgNIgk9auMbqEEL4L2Dq9xyLKXeJMKWWeLM4AqNXM7Br7+IG2anIx5/oI+zxEGfohjvB
         v1zGLGk/Qlid4kz6oWC1tVPUNHQkwN67sJEI0W3zw1nH6nLbmXJXLircrwcOItO9oRbX
         TvYbSjDDcgzXn5vO5RhaOWZo/FQL/WpG6HO+tCEHlomMbyhrislSd4//md2/z6bniBmJ
         8ZWDyU7PRL4sXRr65HxiDpbWjxA2+qAgo6lB/V7mYpK7VZHAmXLX/usE4cNGwbcvxUml
         yhRQ==
X-Google-Smtp-Source: APXvYqzHU2Qv90JaGiam0/j3y7qiJAsqUy0QsTn9ntikZSQbDjZ92rTTHkhUSHGxO7ewruuC5ndDhw==
X-Received: by 2002:a63:2b84:: with SMTP id r126mr9751854pgr.308.1565212367528;
        Wed, 07 Aug 2019 14:12:47 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:f7c1])
        by smtp.gmail.com with ESMTPSA id u16sm24716337pgm.83.2019.08.07.14.12.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 14:12:46 -0700 (PDT)
Date: Wed, 7 Aug 2019 17:12:45 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Artem S. Tashkinov" <aros@gmx.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190807211245.GA11071@cmpxchg.org>
References: <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
 <20190805193148.GB4128@cmpxchg.org>
 <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
 <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
 <20190806142728.GA12107@cmpxchg.org>
 <20190806143608.GE11812@dhcp22.suse.cz>
 <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
 <20190806220150.GA22516@cmpxchg.org>
 <20190807075927.GO11812@dhcp22.suse.cz>
 <20190807205138.GA24222@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807205138.GA24222@cmpxchg.org>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 04:51:42PM -0400, Johannes Weiner wrote:
> Per default, the OOM killer will engage after 15 seconds of at least
> 80% memory pressure. These values are tunable via sysctls
> vm.thrashing_oom_period and vm.thrashing_oom_level.

Let's go with this:

Per default, the OOM killer will engage after 15 seconds of at least
80% memory pressure. From experience, at 80% the user is experiencing
multi-second reaction times. 15 seconds is chosen to be long enough to
not OOM kill a short-lived spike that might resolve itself, yet short
enough for users to not press the reset button just yet.


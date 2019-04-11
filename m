Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98300C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:05:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59AB620818
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:05:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="qU0c29yC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59AB620818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D514B6B026E; Thu, 11 Apr 2019 13:05:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDBCF6B026F; Thu, 11 Apr 2019 13:05:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7C516B0270; Thu, 11 Apr 2019 13:05:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90A446B026E
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:05:44 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id s65so4909243ywf.10
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:05:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7jjkT3BK3TrD5+yfkCQiasOngzvtZFHArOGePxAfgQY=;
        b=TDr0nvwXHSxRCjalZcd1znuo17bZkRsN4YS0TkGYjB2OibxLnzpgn9P770SprGaFXw
         Xq8iye3colupFR/OGq1imtphZdrRu7l5jvNE3qWyoMJIfb83E8yUNlYoaOMhiLxHTYUO
         j8pNivS7bnGH70zc9C5BGEWOvsOfyi8D/91u26xMf4/K7b7NkY2JPBmL3ZfEfcH2xm5B
         GIWHLdHhbJ9nq3es27u4u5pvns8ly2eGJyGlFiLIs3L5MEGBPH3tMV9+aYX+bpHNVEO8
         iL5r21/3SVVdJOcECV7dQV0OR3GJMlG9Y9iAjBmE72x++netpguTzzu55wBBQGqmZiY2
         1WAw==
X-Gm-Message-State: APjAAAXQQqDzV2WN4k1nzSa4jc/NaROZrlfLElQi5dsgcukf12rrMVmO
	yibK5Q5lgUXFMKhY7fBIy3QbHeHENeT0CtAk4Staa25E4KWfzVb35E6VNgWrmZJRkzDcrePGg30
	E8WeCJmRAkO6dKnxLxtbN+3OgJFUQjlTaQ0hX4HdTwAFoxLn8YzeBrfzRyS5t9Z9rXw==
X-Received: by 2002:a25:3790:: with SMTP id e138mr41012354yba.162.1555002344258;
        Thu, 11 Apr 2019 10:05:44 -0700 (PDT)
X-Received: by 2002:a25:3790:: with SMTP id e138mr41012273yba.162.1555002343448;
        Thu, 11 Apr 2019 10:05:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555002343; cv=none;
        d=google.com; s=arc-20160816;
        b=eEkOHQtx1R8oB8VfV2ZzIR+MQVb1HcX0bJvpZVOeLklm7tHjayAfez1S5Z5uQe1mjR
         QPeGAfHTGzUbAqmJpbWZb7sVSL4WLjwzvBeIA1pwDPl6hYIL5HBu0xALkOoLBW99xCb4
         W/6kkVKAQekye3U1viVVhUIr1Wvqoj6FglzhO2lvSP8Oz2MT7uN2r35AC8N4jbQibEqi
         l7sTnl8WVVlGd0FgGCPyRM9HAXhqEVXfRa0Uu0f6rEDUzhl/TuOrIVtfvaRsb2KkGgtd
         vk/qzDcjv46GBaakche63nMy94Q9tdWWy3SfPKIi6Lj0AqLZRFlk1cxBv/uh3+/clPpj
         bszA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7jjkT3BK3TrD5+yfkCQiasOngzvtZFHArOGePxAfgQY=;
        b=No7lioAJihLPyMJjcrVRjbIistPnfARA+cd2PUeITZrEchhMgyh6orGGzI1C0PuQaZ
         iaeveGQJ8vRIduPQvg6i0e+bJGHsgsSOpBSGKS/DTJBtwXVSVKaykDZKkblyblH4oaMv
         6w+nV4UwJu2KHnVd79pC5MVKlT2RfMqFtBJMpvITBiEW33uANI19NgUgzJMuIHMUv4F0
         rzClwFfsT7TFkoOt1SzEoB8vMRQNIn+g6iU4OQxri+BpSIyqvVtn6N+wncjQWGzB1n42
         8EiEC4ka7jBkANLMuHqm7o9w6oJPTMD4XPHSw2myLEYW/Af6BGD+Wcq9L0N22KV6Q+j6
         diJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=qU0c29yC;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 189sor21908291ybi.189.2019.04.11.10.05.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 10:05:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=qU0c29yC;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7jjkT3BK3TrD5+yfkCQiasOngzvtZFHArOGePxAfgQY=;
        b=qU0c29yC3Jj2uhWf//ABSUwx8aGOnQVAOyECPol8iMOkmoVx3rfLlnPdd3abk7ZIrp
         cBnWLlTqwPlbX1abhPCMls/eFNIMnUkF0DlH2l/IQsX0oCd6JYIEG+PECn1nS6tPnOCt
         URhwJBR07oEmOXuZrKhyuYUEWY/+PaNLauQKgcppotczYrHtnkwitBMUiCdjhy+5xKXI
         o5wwWqjLBHPqgWxYJU0rDmT3PWJv+SWGJTH2lxRsPbBRvdYvEluu5WsyoZSNTJ4KuzWN
         Om7O9RGcwc0wsTPbTuDNdsg2r4/EBvk7VaOXYH8jueQDOkSlPikaepIw1aT4oXZyFcop
         d9OA==
X-Google-Smtp-Source: APXvYqybSGDxqGfs0YDwR/MRKFuproumSYuZA3xfdWLANrwNc6cL+PJzmEZqmBocDRbJxqob5OWAlA==
X-Received: by 2002:a25:4e08:: with SMTP id c8mr27714529ybb.339.1555002342830;
        Thu, 11 Apr 2019 10:05:42 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::3:2a81])
        by smtp.gmail.com with ESMTPSA id k125sm24528572ywb.26.2019.04.11.10.05.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Apr 2019 10:05:41 -0700 (PDT)
Date: Thu, 11 Apr 2019 13:05:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Suren Baghdasaryan <surenb@google.com>, akpm@linux-foundation.org,
	mhocko@suse.com, rientjes@google.com, yuzhoujian@didichuxing.com,
	jrdr.linux@gmail.com, guro@fb.com,
	penguin-kernel@i-love.sakura.ne.jp, ebiederm@xmission.com,
	shakeelb@google.com, christian@brauner.io, minchan@kernel.org,
	timmurray@google.com, dancol@google.com, joel@joelfernandes.org,
	jannh@google.com, linux-mm@kvack.org,
	lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
Message-ID: <20190411170540.GA5136@cmpxchg.org>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411153313.GE22763@bombadil.infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 08:33:13AM -0700, Matthew Wilcox wrote:
> On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > victim process. The usage of this flag is currently limited to SIGKILL
> > signal and only to privileged users.
> 
> What is the downside of doing expedited memory reclaim?  ie why not do it
> every time a process is going to die?

I agree with this. The oom reaper mostly does work the exiting task
would have to do anyway, so this shouldn't be measurably more
expensive to do it per default. I wouldn't want to add a new interface
unless we really do need that type of control.


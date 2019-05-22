Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7BD6C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:48:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88B6F20881
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:48:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="KNnxG+9U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88B6F20881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 164696B0005; Wed, 22 May 2019 11:48:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 115EB6B0006; Wed, 22 May 2019 11:48:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 004326B0007; Wed, 22 May 2019 11:48:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id ABCB56B0005
	for <linux-mm@kvack.org>; Wed, 22 May 2019 11:48:28 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id g1so566382wrw.20
        for <linux-mm@kvack.org>; Wed, 22 May 2019 08:48:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=oucC8M3nZCcEbyMW2+s60vcv+usbO9AOXsL/5EkWU+s=;
        b=oVSWVWEbQiI5APqpqeishrg4tlZJZBOGltFmuW0DNIpr3muRr2X+3IlV9uZCgbc7TK
         Hujhwnp/uQ+NQJicg3P9TZFapxnCedEOWCnH/keFp3gIplVaV1GiMOGbM48hP+yT2kDP
         peRKe4XNPsHs8qmXJThdHggyA29qMVc+VxiM0UpDFrA1HsVLRKNOFELCxBcQGxal3nKF
         q4q8k7nUD4y3Osc7f/dUE5W+qbaEaYSF1keKoPw/inMy0pIp12Sf2eEQWxJaiE4YFYIX
         BFMg5Wd2dMom5MLJk6M+LqoWhNOSGe3h26UpP1a8doRMNtfRrpx7BBvOg9vgZmRJZSsd
         MUCQ==
X-Gm-Message-State: APjAAAVFx1TERH9pTwEDLXDuVPJHYvo93u7arwMXznd/jjWvJwk9Rt9u
	Wjrk9W2BuH4j6PoatVIRLoAvGa2rUprVeHISEHhInecHBWyLzEYfvJU/qLUD3VbS27us3tMabxf
	5QUjzCK8Aw74nYsaYCT3DOR8EZMsD94Ievo3KDjbgL9kLikYo5T9aTJoNfOkYbWzP8w==
X-Received: by 2002:a1c:a815:: with SMTP id r21mr7649201wme.66.1558540108297;
        Wed, 22 May 2019 08:48:28 -0700 (PDT)
X-Received: by 2002:a1c:a815:: with SMTP id r21mr7649154wme.66.1558540107434;
        Wed, 22 May 2019 08:48:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558540107; cv=none;
        d=google.com; s=arc-20160816;
        b=y1nODjwClACDZhz3qGmUdXVim9Mnmm8edTX9S3bNAkb4gQzuaIRRs76OHOwB//VS7R
         S8kDSgd27DjnA0/OBFtDn8JnLoTxXcbpJWigf6lAN+KfJ0e6g7Uqpx4iHrXTa6UXmJfD
         hsLZ/+IRbq5U7GYhyUKWaNJHYOSYfdnghNjAQ8VTbSLGthVJxUPxE0OqD8DcQNXRSUP1
         pufbezVA2+maiSbaCMp9BHz1WuJWk1HHX5Umd0zXqVOv1Hawm5Rq0NObOzBse+DqHyga
         +MP46LnS2hk8qXAcHv3IGtXs4akowzci2NfLXdvA9Z+HR53VoJ1YCEW31JXMQkQMjNDJ
         q05w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=oucC8M3nZCcEbyMW2+s60vcv+usbO9AOXsL/5EkWU+s=;
        b=M/TuE9jhPfF+42AwtYC2qEK61rrc0le70ZgANcP5nA8cJcJgTYPmK3INGLDKBPx5Wb
         u3es7ljX8FNPWKVBVzmwPtdZZKGeOKHgvZ3bfocYc7Lpgffzai48erPi1H4ek3M/mqbH
         YWwBlS8S9rDqcBWG5vwEgXOF4UL4MXuyZ/2FHRtYkYnjU3f6Zs7v9vjCJ9i+KfbrbXCi
         liGSxJKCZnUJmt+Rz8RTJf09JvdghFeaugUa+7D8k+y+01UA7vHv5j73gqB2lU4tAwkF
         AifUKMzs6gQ58lm17pweYNbrwpGhBF+a7z7ke/C+kleHQHTTUsaO9OF7s4aFgUA55ShV
         UWpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=KNnxG+9U;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q18sor4960902wrr.44.2019.05.22.08.48.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 08:48:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=KNnxG+9U;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=oucC8M3nZCcEbyMW2+s60vcv+usbO9AOXsL/5EkWU+s=;
        b=KNnxG+9UdfArtLGjhxfLQyQbRBbcZqyz7xsk+XEAzHZTtQRvp0fElhyJjevhcLT9l9
         iArpc3ll/0902ERfuDg9borY5t6L/qsbpTPWGVUn20smnvKCtwfN6lAad1LvBzX+ID9O
         7dpPjMy5igrMK7Yc8G1X/azBJiGLiPUDBHWYuNRrg+rkAVDtfnv5sDbQRG1nfnNz+QFR
         xuyXGDLrWUrTO9gsSzOwQcAyRjdTym+JZGQFeCryofMDsah/PSN8lejM8Pgpwh8e94w6
         GkVufsnlcj84ZiPD4gfpERImVkWPuBBvAuD5dmRafM9yDNb+XknITApanmBGJ8qgiDyd
         XpsA==
X-Google-Smtp-Source: APXvYqzyz5WGn5HyF+nsXwQJs/jSb8LE75/f4KRMw/vmZSIjK+0u7kRcaFAsumgBY4JF7bUFPaLVjw==
X-Received: by 2002:a5d:63d2:: with SMTP id c18mr3781938wrw.134.1558540107031;
        Wed, 22 May 2019 08:48:27 -0700 (PDT)
Received: from brauner.io ([185.197.132.10])
        by smtp.gmail.com with ESMTPSA id m206sm8191293wmf.21.2019.05.22.08.48.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 22 May 2019 08:48:26 -0700 (PDT)
Date: Wed, 22 May 2019 17:48:25 +0200
From: Christian Brauner <christian@brauner.io>
To: Daniel Colascione <dancol@google.com>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, Jann Horn <jannh@google.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190522154823.hu77qbjho5weado5@brauner.io>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190521084158.s5wwjgewexjzrsm6@brauner.io>
 <20190521110552.GG219653@google.com>
 <20190521113029.76iopljdicymghvq@brauner.io>
 <20190521113911.2rypoh7uniuri2bj@brauner.io>
 <CAKOZuesjDcD3EM4PS7aO7yTa3KZ=FEzMP63MR0aEph4iW1NCYQ@mail.gmail.com>
 <CAHrFyr6iuoZ-r6e57zp1rz7b=Ee0Vko+syuUKW2an+TkAEz_iA@mail.gmail.com>
 <CAKOZueupb10vmm-bmL0j_b__qsC9ZrzhzHgpGhwPVUrfX0X-Og@mail.gmail.com>
 <20190522145216.jkimuudoxi6pder2@brauner.io>
 <CAKOZueu837QGDAGat-tdA9J1qtKaeuQ5rg0tDyEjyvd_hjVc6g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAKOZueu837QGDAGat-tdA9J1qtKaeuQ5rg0tDyEjyvd_hjVc6g@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 08:17:23AM -0700, Daniel Colascione wrote:
> On Wed, May 22, 2019 at 7:52 AM Christian Brauner <christian@brauner.io> wrote:
> > I'm not going to go into yet another long argument. I prefer pidfd_*.
> 
> Ok. We're each allowed our opinion.
> 
> > It's tied to the api, transparent for userspace, and disambiguates it
> > from process_vm_{read,write}v that both take a pid_t.
> 
> Speaking of process_vm_readv and process_vm_writev: both have a
> currently-unused flags argument. Both should grow a flag that tells
> them to interpret the pid argument as a pidfd. Or do you support
> adding pidfd_vm_readv and pidfd_vm_writev system calls? If not, why
> should process_madvise be called pidfd_madvise while process_vm_readv
> isn't called pidfd_vm_readv?

Actually, you should then do the same with process_madvise() and give it
a flag for that too if that's not too crazy.

Christian


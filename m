Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25F7CC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:14:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA06B20850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:14:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="I2y8SRdd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA06B20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68C286B0010; Fri, 12 Apr 2019 10:14:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63BEF6B026A; Fri, 12 Apr 2019 10:14:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52B1C6B026B; Fri, 12 Apr 2019 10:14:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32A516B0010
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 10:14:44 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id b142so1997071vsd.17
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:14:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=pRoGxbJdzk5VSz+J5WZP/kt+pljWluiqtLQrAx6TCuI=;
        b=rbDFvnSa3WTHfE8Ce1r349crRTYj6FEKUWNgIEd2dmAvkZKlFBIxFmxdSkVmpV1DsE
         tKe+cdkpPDlwE1t1Qis8438er5Akn8a8cEeDTq7AJKAIWNnsXkC2ZSKk+EuvTnX1uxoL
         R4AnOPr+T4OdcdoJczBEJiRek0kdfK4SBUaTqhjew1g+/yHdOx5tOF/tkpCwgWRS0s3T
         oyXScj+S7rkcuuxuFODQu3iAVoyV28jdFuRAKf/Vzs0FM4y+zD96r3kzwZ+DoEfDmDmR
         WtzQJHNFv6M4HDkfsZkWk6dUnGqGP6uk83cxvaQHKoDAHT2DQ3WOfzIzqiKTs4IdiiWt
         20oQ==
X-Gm-Message-State: APjAAAUt6zCLfDnguv+T1c5U0U+ZKb2DzYYVbdAJTpXKnVxOIWlFd/Tq
	vNqFCoeeE6YX9LamJzxCfI14wYck/nmhmz+XMozC1kcBkdl00OakUk8WG71V9n9Yawom/kxMZvN
	B37FQe+v1Rrqlg1fala432XIBVf5enBgkdsCqXq28NN+X1EWAEjjd4veUnq6w3szkiw==
X-Received: by 2002:a67:f849:: with SMTP id b9mr8466472vsp.188.1555078483648;
        Fri, 12 Apr 2019 07:14:43 -0700 (PDT)
X-Received: by 2002:a67:f849:: with SMTP id b9mr8466423vsp.188.1555078482977;
        Fri, 12 Apr 2019 07:14:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555078482; cv=none;
        d=google.com; s=arc-20160816;
        b=hipIEah87R1H150xLydrXq/mOsF7WjyoeFUMykAspALj+WpH1f7JrpTIZWLphU+7bK
         okjH8VQFIQYEk8a0lWSyOdC7xXJyg37cAS9nQIwrLgj+RfvlqxOEUSnK1IhKHTjjfmm7
         hrPOi6uU7lnMkwzkKdLQEvpSnSG4dv++/TeBrov8Z7qIHiPHwsGSqtzxYYnQDpDUR0zc
         CJRPZBA/2CaF3eY7G8rhBUuaZnX2fstzZnfQ8UgGQ3dL7+Q5v6CtzXgKVR7SJc4YPT1S
         oZRi6zQy17FLSU7UZEh+MVPRShYfrVBt4LCcXuAt84hcsFdKP3BLfY3vIBhBfGHPukRd
         IRbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=pRoGxbJdzk5VSz+J5WZP/kt+pljWluiqtLQrAx6TCuI=;
        b=CPSQCJxla0jbBdWTYr+Txs9Rs7/dEkKEBPUPUj0Ayv2ifSIC7aidtNFIGbQ/b36+WO
         U0G6LsL975vbU1er6hLd5il21V3j9we2vDvw1YGDYfCLco8cWD2qFlLjrTY1dQCRSvSN
         etuziwvpPTNC998Tn901Fm7l7PlvUoKdPuH0vb43UixikP58QJ21u9Z6Y7fVqhAzKamP
         uX3RLVIio5Wjp0X2tLVwuPrT0T85uDy9LyG260fsczbb4GmOqonUDDUZjYqgGrEWQcKZ
         eIEXlMFQspR7VH1Wv9FxRKnoUOxDdF2JlHwyiG9TyrEM3dYx0F9d9/RCiexMclZDTHsM
         Auzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=I2y8SRdd;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r6sor25485481vsp.109.2019.04.12.07.14.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 07:14:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=I2y8SRdd;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pRoGxbJdzk5VSz+J5WZP/kt+pljWluiqtLQrAx6TCuI=;
        b=I2y8SRddDRNqAugRlPVyKaj1bSoHn3ghQl8DCaK1P1dXAsIS/lng2hR+VeAdB8hLex
         tb6tZ3i7e6rvBriPoLAs4UCeEHrYLuX17Op3KMmub0c6rb3hrU4KwK/oVCPDCJTqaJU3
         08DVZHhKgWljH8seJAKg9vLBdNH9RWvwil0OKY8Zkp/jyHmCeNEZ690BPyl+Obg56vbL
         M17lF+LdnoDqy8nXNH78D8o7OPJnodT+tCOv02Y7hhfmZ2zaggvO4EZD7Q2D1xyWn/kN
         PdjWyQajqDa6Gy4M+89LjMYNqhqMaMihQlTT/QoE/i2MA4eoYHJugVFqrj8UuW5csK3C
         hf2A==
X-Google-Smtp-Source: APXvYqyu+/gmNYP2ogerG2Yndwwn3Grs2ZHb1phxFDU65FklJPoSvR4EM09M3KxMW143zzvBhxqw+7a9UvSE6NBly/s=
X-Received: by 2002:a67:6847:: with SMTP id d68mr31562611vsc.90.1555078482224;
 Fri, 12 Apr 2019 07:14:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org> <20190412065314.GC13373@dhcp22.suse.cz>
In-Reply-To: <20190412065314.GC13373@dhcp22.suse.cz>
From: Daniel Colascione <dancol@google.com>
Date: Fri, 12 Apr 2019 07:14:30 -0700
Message-ID: <CAKOZuetQH1rVtPdMNgw0sdnzWidd6v9eCWscRiOb7Y+3-JQ14Q@mail.gmail.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Suren Baghdasaryan <surenb@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, 
	yuzhoujian@didichuxing.com, Souptick Joarder <jrdr.linux@gmail.com>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, Shakeel Butt <shakeelb@google.com>, 
	Christian Brauner <christian@brauner.io>, Minchan Kim <minchan@kernel.org>, 
	Tim Murray <timmurray@google.com>, Joel Fernandes <joel@joelfernandes.org>, 
	Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, 
	linux-kernel <linux-kernel@vger.kernel.org>, 
	Android Kernel Team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 11:53 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 11-04-19 08:33:13, Matthew Wilcox wrote:
> > On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > > victim process. The usage of this flag is currently limited to SIGKILL
> > > signal and only to privileged users.
> >
> > What is the downside of doing expedited memory reclaim?  ie why not do it
> > every time a process is going to die?
>
> Well, you are tearing down an address space which might be still in use
> because the task not fully dead yeat. So there are two downsides AFAICS.
> Core dumping which will not see the reaped memory so the resulting

Test for SIGNAL_GROUP_COREDUMP before doing any of this then. If you
try to start a core dump after reaping begins, too bad: you could have
raced with process death anyway.

> coredump might be incomplete. And unexpected #PF/gup on the reaped
> memory will result in SIGBUS.

It's a dying process. Why even bother returning from the fault
handler? Just treat that situation as a thread exit. There's no need
to make this observable to userspace at all.


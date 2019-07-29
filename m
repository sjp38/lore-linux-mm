Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBB6DC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 16:23:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90439217F5
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 16:23:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="d5BbKW8/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90439217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A8B38E0006; Mon, 29 Jul 2019 12:23:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 258AB8E0002; Mon, 29 Jul 2019 12:23:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1212E8E0006; Mon, 29 Jul 2019 12:23:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0A488E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 12:23:00 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q9so38503061pgv.17
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 09:23:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=TGe/geZ87qC/Bj1IMgqU+ytXYrP/0N7tQMUhQt/p3/s=;
        b=rnn/1TzvDqNVswRGiqkp3a4EFUuJYcm5ZLpAx3cbRHxI3t1i6xjwpDsz1nnZfye/2D
         17/yDgQN0BSlhJNIG7yzdUxeQw5C7t94CnPC8k4hKzFsZuu0q3mf8tgJzsM2AyH7+asN
         EeF3KgpqtqgjYa0mmz2qXe7fNMh4Uj8gCR2yelnPzbTYBLsoE51Xcz+F1R5UHc303CVA
         xUmATyWP78oF7bKIRrkjX7cTEX6QXyruB+VSnTI6uCia20Tx+xADsdZwcejzrI6+xqUE
         uKKxRNQCVxAtoUh2doVQdUueXOiuJd22y0R9fDfqOIl+FRJ/eMZ2wao2XOBYY55w2CaD
         zbMg==
X-Gm-Message-State: APjAAAWAaHkRFIthwEnRp4Olkkeoy0UAfHn0ebkoBeXeo+ezI0RDcvZk
	wiW/ciFOhTa2rYs7PBqdyqM1iMHyMrUb5kbbIq949q7QVvJCSaRjNhxT5QPMtoIWUPPa36Ha0u1
	1daGe/tSYf+Ft4JmaG3ul6qiIPp3s7424RmHqCsocx+6So1W7qtQR6krqGCGqSQpU1A==
X-Received: by 2002:a62:1bd1:: with SMTP id b200mr36787293pfb.210.1564417380405;
        Mon, 29 Jul 2019 09:23:00 -0700 (PDT)
X-Received: by 2002:a62:1bd1:: with SMTP id b200mr36787256pfb.210.1564417379759;
        Mon, 29 Jul 2019 09:22:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564417379; cv=none;
        d=google.com; s=arc-20160816;
        b=kWhL8K+vcvr3N2ZfmJwwxiNIPZ/OG0pK6c1oR+XtgMBM/FoeDpUsi3zn6kXsmGlnZQ
         BSgTx6k3SWIGh0Lq2MuWPdE6iZvNfUQAOmtE7pcYk5zKYWIN0+7WMqvVNNnKEwSaSQ/j
         do4PgXOtSSfr0WQfoBxOUiX89JQLQ8NskgD/SZAu+YkCxFORllwnD8EYVSIRFm8pvfXN
         /P/Kdsp6yDHu9McniziRYBTnZV3whK8vi6BUUDCeMEd2Miqy3qa7tNwEyOvX1MqRA6hu
         wBDEwJkuKtfgprEVeu5ysJJDsMWsQMY6p2OIXOa7UD2ysGQbTZpXx547TtqkDLxEnqFW
         hhvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=TGe/geZ87qC/Bj1IMgqU+ytXYrP/0N7tQMUhQt/p3/s=;
        b=JmS2IHcaark2ce/jUIaRmaIJ0NL/XGtrgfu9k90xbpdRCjMetFV8s3XzZKhRBZSxse
         49g9BwGPladK2faX62mZvbWe2q0bWiCXECd/thjGzHSysc3VBuc01xNK9Zw1B23N+02n
         QoLhwYhLWtYeuCIJd9aRCF6q/niJsKXKvCqmCJQs2UC9dSV4g4zs6IosndJyuB4ZJ/MG
         AOeigViWQhHGmCEBDN2/fXW+TLpljXmA8/SRdb/oTcLswT+1RZHUHiqByignk1Y1VK7t
         pPTYTWsCTZI13xaGjlIQrGznMzqSGFPvfHYjmYoGIUdpKqF1w3/FZrQxx9j+ZNzijMIg
         VpRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b="d5BbKW8/";
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p187sor32049859pga.43.2019.07.29.09.22.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 09:22:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b="d5BbKW8/";
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=TGe/geZ87qC/Bj1IMgqU+ytXYrP/0N7tQMUhQt/p3/s=;
        b=d5BbKW8/plsBM1AKOfuFUhf26MKZlqMYSKZDr8YVVWH1IQPUij8aMiPu4C+K9FSEMO
         r4nAW5vgRlXPfAiJoR2Mo/SVuNnvyA+9FpLZefF+PeC8iy3gma6OYYB3emW4chRNY+Oi
         Up2xrTvtE4xPfvotTloTBiJcshYpwNAdYxWuzPcg8qsDe+cMHsRul3r18mDjwMymD2pr
         EllcF47OUaf0ugNxSYdeljZCTi/tC4FKHS14+RTLb+YtgIJuVTtnlLNx3WIh2aZHvOB5
         xWHx/cfPosBIEtg1/8Sq9RROEL8NTq3owgj/7WE/vEEf0dPBKloa07fUa0FPY98fAIeU
         SgCw==
X-Google-Smtp-Source: APXvYqxa3zdBmZyR2hRDHMLO+UBzY5e8eP5A8amqoK/P8m6Ef0NEtSeTPeXrCXXju44jDTKGgVZhvg==
X-Received: by 2002:a65:6256:: with SMTP id q22mr104646436pgv.408.1564417379277;
        Mon, 29 Jul 2019 09:22:59 -0700 (PDT)
Received: from ?IPv6:2600:1010:b041:eebe:98d2:d02:46c3:a133? ([2600:1010:b041:eebe:98d2:d02:46c3:a133])
        by smtp.gmail.com with ESMTPSA id f27sm45266394pgm.60.2019.07.29.09.22.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 09:22:58 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of kthreads
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <20190729150338.GF31398@hirez.programming.kicks-ass.net>
Date: Mon, 29 Jul 2019 09:22:56 -0700
Cc: Waiman Long <longman@redhat.com>, Ingo Molnar <mingo@redhat.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>,
 Rik van Riel <riel@surriel.com>, Andy Lutomirski <luto@kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <D6DB6BFE-BD85-4329-B313-5D84539CD2FD@amacapital.net>
References: <20190727171047.31610-1-longman@redhat.com> <20190729085235.GT31381@hirez.programming.kicks-ass.net> <4cd17c3a-428c-37a0-b3a2-04e6195a61d5@redhat.com> <20190729150338.GF31398@hirez.programming.kicks-ass.net>
To: Peter Zijlstra <peterz@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 29, 2019, at 8:03 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>=20
>> On Mon, Jul 29, 2019 at 10:51:51AM -0400, Waiman Long wrote:
>>> On 7/29/19 4:52 AM, Peter Zijlstra wrote:
>>>> On Sat, Jul 27, 2019 at 01:10:47PM -0400, Waiman Long wrote:
>>>> It was found that a dying mm_struct where the owning task has exited
>>>> can stay on as active_mm of kernel threads as long as no other user
>>>> tasks run on those CPUs that use it as active_mm. This prolongs the
>>>> life time of dying mm holding up memory and other resources like swap
>>>> space that cannot be freed.
>>> Sure, but this has been so 'forever', why is it a problem now?
>>=20
>> I ran into this probem when running a test program that keeps on
>> allocating and touch memory and it eventually fails as the swap space is
>> full. After the failure, I could not rerun the test program again
>> because the swap space remained full. I finally track it down to the
>> fact that the mm stayed on as active_mm of kernel threads. I have to
>> make sure that all the idle cpus get a user task to run to bump the
>> dying mm off the active_mm of those cpus, but this is just a workaround,
>> not a solution to this problem.
>=20
> The 'sad' part is that x86 already switches to init_mm on idle and we
> only keep the active_mm around for 'stupid'.
>=20
> Rik and Andy were working on getting that 'fixed' a while ago, not sure
> where that went.

I thought the current status was that we don=E2=80=99t always switch to init=
_mm on idle and instead we use a fancier and actually correct flushing routi=
ne that only flushed idle CPUs when pagetables are freed.  I still think we s=
hould be able to kill active_mm in favor of explicit refcounting in the arch=
 code.=


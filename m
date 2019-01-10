Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BD68C43612
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 20:39:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8E0420879
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 20:39:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Q6mPHXay"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8E0420879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 080E68E0002; Thu, 10 Jan 2019 15:39:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0325A8E0001; Thu, 10 Jan 2019 15:39:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E620F8E0002; Thu, 10 Jan 2019 15:39:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF4B88E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 15:39:54 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id k90so12924042qte.0
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 12:39:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:date
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=BM10tUvFqe2/qUpdcNvy1XQgs7cykrDXn4NqoVqHHkY=;
        b=CAoPXdH2J2JLdY6QRkt/91L8/IfNNwvWl+EveoiGFzQXWOq4WXq6NmxvgAHpHg18uq
         V0rB3w1jOc3wPOCBza0Kb7yZrhIIB9L0LGoZcVyfDwEElL8LRnPbNU0p+Nm9gQ4P5IIL
         EenXwuuEdaEPsV4f7T26V2hJp41epV+I7ZOv7YoASTPhXmO1aRCVWnOTPLNmjO80XSVy
         /7I8vzFYwfXBGVregPmknQTaVEyCVIgMXFKaJlAqw1nBE2IKzyfarhhIab15IkeCGCAX
         YO7mEv4qy7Wzh/4R9jlV0KYsntRKxckvmJsdUbomaXqiDzJ02tt9Msd2i97Tjdm3zJ00
         /EKw==
X-Gm-Message-State: AJcUukdNtOxEU02NFHvx9TEMJ9r1ASrY/5Jc+p2EhkAo6ydGod466WPo
	IGhRAeEjOyo3Pe/Rl6n6Qhn2CmZSihUJZOE+KfGiJa8KEWiDQOcvOeQmmTVSxaBiTSdTp764PJH
	MbYG396Lc2ZOBqZKlloAmcX+Mwl12dTDKYlFLVWVyJ4Gp1awA7xfp5d4zX2/Lm2e0QSh8KP6dJx
	mfW6PcfW04ZSKu6eli4Nb/FSr2Xt4Vbww1xxWbbwzVGJbegamQ/q3/i3Adbtw26Ubzc7pMgS9k1
	5mcAtcZDWLT84T7gBSxC6KC3Cyb1kle6pH8qq6GiPMBVMOf/OpHCVCvoIgM/ewgxzuElGSS7SIX
	cpeC6TaebZuLAzvWhXfsSBBff34I+7pclQ3vjA8IB6ZTmLXvmOqk+wvdDKXr20ebxvEDKYOUXLy
	w
X-Received: by 2002:ad4:5282:: with SMTP id v2mr11339274qvr.195.1547152794386;
        Thu, 10 Jan 2019 12:39:54 -0800 (PST)
X-Received: by 2002:ad4:5282:: with SMTP id v2mr11339235qvr.195.1547152793635;
        Thu, 10 Jan 2019 12:39:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547152793; cv=none;
        d=google.com; s=arc-20160816;
        b=SIe9nPRqzTBdYd9+qBiL/8/DO3ECmgAT2VtyJiLEyLU2dLtgVEuIaHOHKWy08DWKtT
         bUdrJGdG7zB2CZYqUaf1JoZ2V2VTVOvrB4YWl5gvT9q+5QXqp2FHwy/G7DW2flfwv7wb
         hP+lKcxG2usw5sFl0laliqoe/6F/PIadUSvm0XGITxRhWb5hYWELOY7vyWASGC1UPZhm
         3LhFYlTjBKgq/uu56zZ3qWA4d1oDZB5Msn6t888cw3+ipHVN2eN1wEsvS3t+Lw0NEXLr
         k9EclM+7uX+kI6NMDZO+CS563cblK6MieP75d8908oVHNgdLOL1Vt6Xi0LA+G16AKzTi
         MRaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :to:from:subject:message-id:dkim-signature;
        bh=BM10tUvFqe2/qUpdcNvy1XQgs7cykrDXn4NqoVqHHkY=;
        b=R4hVpiF7ELXq7PYhfcTmvoLnvVPVH+1VqeqfYo8HZ0/CJ96dlQ0JBlmQSf3GBgdsk7
         eY0W9OCfS/jx8ijpkA0cHj/w4N+Oz6dQc5KbinOf2+QZWuQgs+/3Xb0oQtjUJSXovzRi
         QEH+pnuPTY3yHJKWNs+obAR+gCR/kk0xXSU+lZM4OJ2ogHVQnelwu1JUNsO6ZRGB4mu7
         l/mWtp82AIl6exoCQC1KO2uBevTY3toO+IrmjfLZLdn5Sp8Ydij+V9J6yr4g8tN6LICW
         bV4VXY6EcyObOf2VdXcC3c5ZdCumub6mIqAwos8GkjQuoU1+XpyFF9aDeuhlPUvpaW4r
         4vXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Q6mPHXay;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g20sor72798413qtb.45.2019.01.10.12.39.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 12:39:53 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Q6mPHXay;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BM10tUvFqe2/qUpdcNvy1XQgs7cykrDXn4NqoVqHHkY=;
        b=Q6mPHXayVjek0lCitJARjuKVeid7Jc5go7wKFZq3bHcPjCrVC9Dsm7ChkkeoysRtyx
         BXgrutc2eJVsQvb2iHHu7lwoYRxXCTFjC6RQQCCdPHhnX2BbaTb5h14Z/mjgIr7yMV12
         axEsxiKKxUluoB3lwIW5yGeSdGKgUgwcj5sO0ufz0m10FPs/nEYwonKSMH7tIYX17lrj
         09mqVdXPYhWG0pOqlWSwxE/Hbhro3lfU9KSQPtOXvrKF1mQQ1bbOVgAdhR7MrRkax0EN
         vlK4qmrM2NLad0H+XYUfvUbR62pYPZUcV5WZV1IVmbR8p4nIYlc5U3Q+Ly48te+pdztM
         q0Vg==
X-Google-Smtp-Source: ALg8bN56UGDqEEIeHs9djrF+w+asnMO+rW3niboUIuSnWfEL3QljA8fXBJ1tEB9ABBBMzCTj1LnRFw==
X-Received: by 2002:aed:35c5:: with SMTP id d5mr11137276qte.212.1547152793305;
        Thu, 10 Jan 2019 12:39:53 -0800 (PST)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id z30sm48643977qtz.26.2019.01.10.12.39.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 12:39:52 -0800 (PST)
Message-ID: <1547152791.6911.6.camel@lca.pw>
Subject: Re: PROBLEM: syzkaller found / pool corruption-overwrite / page in
 user-area or NULL
From: Qian Cai <cai@lca.pw>
To: James Bottomley <jejb@linux.ibm.com>, Esme <esploit@protonmail.ch>, 
	"dgilbert@interlog.com"
	 <dgilbert@interlog.com>, "martin.petersen@oracle.com"
	 <martin.petersen@oracle.com>, "linux-scsi@vger.kernel.org"
	 <linux-scsi@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	 <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Date: Thu, 10 Jan 2019 15:39:51 -0500
In-Reply-To: <1547150339.2814.9.camel@linux.ibm.com>
References: 
	<t78EEfgpy3uIwPUvqvmuQEYEWKG9avWzjUD3EyR93Qaf_tfx1gqt4XplrqMgdxR1U9SsrVdA7G9XeUZacgUin0n6lBzoxJHVJ9Ko0yzzrxI=@protonmail.ch>
	 <1547150339.2814.9.camel@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110203951.EybVaQHQA7O0a1kRvO7EIn73TRQK8xz1d7hb2T0CZGg@z>

On Thu, 2019-01-10 at 11:58 -0800, James Bottomley wrote:
> On Thu, 2019-01-10 at 19:12 +0000, Esme wrote:
> > Sorry for the resend some mail servers rejected the mime type.
> > 
> > Hi, I've been getting more into Kernel stuff lately and forged ahead
> > with some syzkaller bug finding.  I played with reducing it further
> > as you can see from the attached c code but am moving on and hope to
> > get better about this process moving forward as I'm still building
> > out my test systems/debugging tools.
> > 
> > Attached is the report and C repro that still triggers on a fresh git
> > pull as of a few minutes ago, if you need anything else please let me
> > know.
> > Esme
> > 
> > Linux syzkaller 5.0.0-rc1+ #5 SMP Tue Jan 8 20:39:33 EST 2019 x86_64
> > GNU/Linux
> 
> I'm not sure I'm reading this right, but it seems that a simple
> allocation inside block/scsi_ioctl.h
> 
> 	buffer = kzalloc(bytes, q->bounce_gfp | GFP_USER| __GFP_NOWARN);
> 
> (where bytes is < 4k) caused a slub padding check failure on free. 
> From the internal details, the freeing entity seems to be KASAN as part
> of its quarantine reduction (albeit triggered by this kzalloc).  I'm
> not remotely familiar with what KASAN is doing, but it seems the memory
> corruption problem is somewhere within the KASAN tracking?
> 
> I added linux-mm in case they can confirm this diagnosis or give me a
> pointer to what might be wrong in scsi.
> 

Did you enable page_poison with PAGE_POISONING_ZERO=y ?


Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1455C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:40:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EFEB213A2
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:40:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a2FlGNoN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EFEB213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FE7A8E0004; Wed, 27 Feb 2019 09:40:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1ADA28E0001; Wed, 27 Feb 2019 09:40:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C4B98E0004; Wed, 27 Feb 2019 09:40:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A86D78E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:40:08 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y26so2312189edb.4
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 06:40:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:reply-to:from:date:message-id:subject:to:cc;
        bh=MOgh/bT2lLs82PHKl5zKpphansWjf2LBnlGErB+EY9c=;
        b=qex+cLEm+Hm6oHpm8kIxgjftA4FKIjpT+s6o5E2BOtOAVotKAb3FFvxqXhO4WQn+B3
         xPQ/7NEEvxTaD6feAAAD6lcCBGZ9uyfvjS2DOLMJOlLt7bsEjv/olsGVSfK0mIGZ6Rcz
         hD8I6RiIONl5ihs/Gcy89o+1VuNxeehSvC8ekVyJvkEdKbIsSEenMA3vmQdvRDy+MlAh
         A4/LywZ62xiY2nHoBIL0NZlG0Zqoos6KXuXE1h/FO1iqxJVb+KJaTTe+2lzHK14JBAVD
         RzrrNTeuatn79aEeW8heKR+Gw3HXCTmKcU1RVl58Ztf0ANO2/NpwqTYJ1kI7EQJbQoWA
         hv7Q==
X-Gm-Message-State: AHQUAub7v5T8PWn9uX6cF7PolMsflH1eykIKBsV1wcus1mbOjOutQpCx
	YRtwdkXPVYXYN0xT+DEoWjUZvCeD+nIJ1m7Y6EXfzCTY/8Xz83SfzeG5GEqvpk0nOmb/Ba+VBXC
	x63zm0OYflzh/lMNOZ5hg4c5WdVv8y4SLM3IRGLIE9aMuRYmyc4+CjB5cSbwiIgAGzAIqY+/o7W
	7TcOaf6Zw5IQn/Pht+7QZKkiZ662KHX3pjKN4KjSQOMq2u2Kg435Ua8mXsQKaqwC06wrVC60nBN
	8FB/TrZnThukFymiV1kkhWouId6xfkvQ8AIl8CTpWIAj3Y+OmKC58zLNygz4Z6YXLPDC4cXZj0Y
	SfiawWIgg+fO+Qx5yddXjhSFczhe7TX/6VvImFUlpmnBcS6y9kghaJv0xU2RJbcBF+9N0baFzRz
	F
X-Received: by 2002:a17:906:4ada:: with SMTP id u26mr1810038ejt.191.1551278408241;
        Wed, 27 Feb 2019 06:40:08 -0800 (PST)
X-Received: by 2002:a17:906:4ada:: with SMTP id u26mr1809981ejt.191.1551278407239;
        Wed, 27 Feb 2019 06:40:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551278407; cv=none;
        d=google.com; s=arc-20160816;
        b=mKV20PaX0uwSk07qEQhZCNj04hDKcHy66OtjfMkDHFlZqAIN63tAK+cMrFZwZNPPrK
         +wAF2jeNGQaS88F+Z7YawC+TG6TQvLJuy5oplDQ6Pv1r0eQjoysTeMVZMeIVWyFwwRe6
         KzTow+vLjd3KFARyKmiRLgdtyn+ccZ5rvgQgizOojgskjSj8wJia69l585AuLUiPOvA8
         G1cmLLbyHzcCcFxr847M6ozMfLWveHL5WkrC2us0CWkzkaWk21qdpoJhJ6ubSyMo+T9Z
         OlYrIKE57r20+g0dUs2h9JyTFUjKErPKaiFvvoiNjU7P6k42r+ff59HDF54I9DXUbQ84
         SMug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:reply-to:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MOgh/bT2lLs82PHKl5zKpphansWjf2LBnlGErB+EY9c=;
        b=nGhay25CB/6nPWvJhNjlfl0sT9M94XYzyXgeWr4dXWazrHSfmLEiFP20gnmRNnRyEe
         xhWZANMtFh8Kk+u667m1c+fAAGRus/JLiuebWORwe02febu4SpTY3X3gOe/Hg1XsMzcj
         IGcIh6cadPp//GVWLJOvpicThbQJKTgN4vSs0f3oqwW+5UnLbchLaLbnGEdMyupTE86V
         XoQmps+8cMMbZf/MOv5xeiNDi5+BmRBBac6aqZyvKDl94Pme2NIcbHSvOaxHYYA2qhoR
         3Kq+Q2mV+Yc9s3dFe192CarP6WFf14ENV7Do6EXYtS2vAt34vBmKYdy/aBIBE75E0/Kh
         gN1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a2FlGNoN;
       spf=pass (google.com: domain of mtk.manpages@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mtk.manpages@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bs8sor4505670ejb.23.2019.02.27.06.40.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 06:40:07 -0800 (PST)
Received-SPF: pass (google.com: domain of mtk.manpages@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a2FlGNoN;
       spf=pass (google.com: domain of mtk.manpages@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mtk.manpages@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:reply-to:from:date:message-id
         :subject:to:cc;
        bh=MOgh/bT2lLs82PHKl5zKpphansWjf2LBnlGErB+EY9c=;
        b=a2FlGNoNKdrtf4//jjJJKNNXVqVUu2FzY13UF5fXEhIl/AAi6q9PtByTyrF+CsC9j/
         yQBUw4CTt+6qrlykUiwXZlrPZvJtGoZDk+kdzA4FKveme5oMDk1HV3Wu5N7qgIukbU9U
         rth23saVwyIL/Kviqdfi/jpheKYdkC/VhYsQudUCB6u69jvSFry0jLGyz0k/FuBvBQzt
         St7JpOQCWsGtyVUkJipNszLjufgmshQRmdfUynC1AevC+PcQq4zSvOD1BlC8WRXJVRbI
         DQHWL/2/v7T9Qgvg3QEnvj+PtSc6/s0G/dKlfjzBL9C1Im4Nra1ZCggnpQPIlZpNS1m7
         icxg==
X-Google-Smtp-Source: AHgI3IYVQ2vxPBQpXYnK3sH7FWn4xrIp8usbZnZVJUpU+U5v9+L8maZbySZWkPp+7YhCdNxINBdb/PaotCZW07CT/aI=
X-Received: by 2002:a17:906:4ccc:: with SMTP id q12mr1792662ejt.201.1551278406834;
 Wed, 27 Feb 2019 06:40:06 -0800 (PST)
MIME-Version: 1.0
References: <20190214161836.184044-1-jannh@google.com> <CE9479DC-7D40-4AA7-A382-FEC4B016DE89@oracle.com>
In-Reply-To: <CE9479DC-7D40-4AA7-A382-FEC4B016DE89@oracle.com>
Reply-To: mtk.manpages@gmail.com
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Wed, 27 Feb 2019 15:39:55 +0100
Message-ID: <CAKgNAkgyAM0oerDJ1eN9HRrpRFv32+tRdgHkMfaR=kpUT5jsuw@mail.gmail.com>
Subject: Re: [PATCH v2] mmap.2: fix description of treatment of the hint
To: William Kucharski <william.kucharski@oracle.com>
Cc: Jann Horn <jannh@google.com>, linux-man <linux-man@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2019 at 15:37, William Kucharski
<william.kucharski@oracle.com> wrote:
>
>
> Thanks for updating the man page!
>
> Reviewed-by: William Kucharski <william.kucharski@oracle.com>

Thanks for the review, William.

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/


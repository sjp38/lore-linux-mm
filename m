Return-Path: <SRS0=llCs=VE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38C84C5B578
	for <linux-mm@archiver.kernel.org>; Sun,  7 Jul 2019 01:17:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D621320836
	for <linux-mm@archiver.kernel.org>; Sun,  7 Jul 2019 01:17:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D621320836
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=namei.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 273BB6B0003; Sat,  6 Jul 2019 21:17:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2262E8E0003; Sat,  6 Jul 2019 21:17:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0ED168E0001; Sat,  6 Jul 2019 21:17:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id E2A446B0003
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 21:17:07 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id f11so6761778otq.3
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 18:17:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=MEZ+NUsgBGKn34IXP2rWfsP2tUsOFfozQxHvlc+g5cw=;
        b=BGg9CCEMVIViAfSFvCT4mq7toCdNz7smHlBHAW0cTH+wSGIXJg/hlxZEvmX0jgo59V
         iJh0wi2Uk/qbMgpbnYjWVznVVRFSUMjvxKgNIEwpChv2I3zWwM1Cyj5WtAxSz3kDItMw
         MNT0P1V8DtwHQeKpUpVPlqZwLXyiG4yCOu2ivhMD2wBY89oTSSb+0ajD95Asl9SianmF
         SWY5wzqpxy+OIjmZwOKPjgk5LRvtKHaHsKcqxFAW5Sn84j8Hvi11M9QE9kShDprcWu4U
         9zb5/b/pY1A50JkcMuBZ/s0r+4o5AZmmmTTKXlUwqtgiZ6mfl0lkpq+qLLULlBXI8frI
         IXMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
X-Gm-Message-State: APjAAAVMdGMu2gHpSwnHzrguDbeqDihoYE8Wz5ZMRU/GiTEFMYFZB12X
	nSNfs49NdOtrk62Vxyju4f6gIK67AVCIteeZur+fxqwfp3V6LewuETXnb8HHcafgdqDRhkmZNn8
	h2NMD0FW+OKOhLk0msVe0ykoO0diI74aqbH+81NQHeToX8zDQ9xkhxkTNGRXDFSYr6A==
X-Received: by 2002:a9d:63c7:: with SMTP id e7mr8944141otl.165.1562462227599;
        Sat, 06 Jul 2019 18:17:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7Ams93nVg2TF0bs3u8uDNlSSqG2WEI2w13fFXhrCJ7rMl+coj9Orb3yBM48zkiGN7P5MU
X-Received: by 2002:a9d:63c7:: with SMTP id e7mr8944122otl.165.1562462227033;
        Sat, 06 Jul 2019 18:17:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562462227; cv=none;
        d=google.com; s=arc-20160816;
        b=YyXTb+wHHR+CSxLVsZ5WwHg48JYBF7Shdhyas/1dBteeXiNI4M1smC/cfbNPsgm7kL
         QfXtDxh1OEmBpVZc3jjYN+KMtXMamdOB81CZ8LWM9bWEIuIIYvTkPfxeX9ks0bXljyc9
         OH+Sece6SEr/HgyrWYAbHl8cMGfCRQLBXSCYpTvHR8dClV6Z9wMq2VCX5VIz85K87+9E
         v5vQJVJ0zVdBhUAKpb4aMc/pfiSIygw+dSiRkWlyorM2LKwKeVltLh3WKFiZ1JyYH7z+
         6KBSW8HvlowtGCfL2xGIQt2yiAIij+7JzYlbgJTjvwjU3DRgHi5lavPoDY6SHAlbm+T6
         J7DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=MEZ+NUsgBGKn34IXP2rWfsP2tUsOFfozQxHvlc+g5cw=;
        b=hfkObh+JZ6rRvplq2YQ1Cu3Ndt1c4cCMMiO6+XpQlrpeImtmqj/YL4xo3NHZ1I7ZhO
         RY7w2JIwUvy+/X63ey1PUmKsO1fKdknVEwzv5lTaLyk4SEpxg0Y2ob5j2Z8rxWxzQBEm
         nF7bk8OLPB6YA0lw1eNhBrPbTvktBM+ru+UWPz4uPnuD4EwCoBra9fpOiLMdePgsnXpb
         IzBf12CLPtJ9iGkJDnyHrq1NQ3f/+1aNpdhVQM13D9h8jGzPBOFVm8sS5CtR8LSzvS7W
         4uXUgWmMnemApQsQBKBEq04nAhGMNxmQuqStMc9phCxXizskpSeOV3OFpDSWSfIQ/3OH
         r2Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
Received: from namei.org (namei.org. [65.99.196.166])
        by mx.google.com with ESMTPS id m3si8191744oig.82.2019.07.06.18.17.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Jul 2019 18:17:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) client-ip=65.99.196.166;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
Received: from localhost (localhost [127.0.0.1])
	by namei.org (8.14.4/8.14.4) with ESMTP id x671GBjI025045;
	Sun, 7 Jul 2019 01:16:11 GMT
Date: Sat, 6 Jul 2019 18:16:11 -0700 (PDT)
From: James Morris <jmorris@namei.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
cc: linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com,
        linux-mm@kvack.org, linux-security-module@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Brad Spengler <spender@grsecurity.net>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Christoph Hellwig <hch@infradead.org>, Jann Horn <jannh@google.com>,
        Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>,
        "Serge E. Hallyn" <serge@hallyn.com>,
        Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v5 00/12] S.A.R.A. a new stacked LSM
In-Reply-To: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
Message-ID: <alpine.LRH.2.21.1907061814390.24897@namei.org>
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
User-Agent: Alpine 2.21 (LRH 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Jul 2019, Salvatore Mesoraca wrote:

> S.A.R.A. (S.A.R.A. is Another Recursive Acronym) is a stacked Linux

Please make this just SARA. Nobody wants to read or type S.A.R.A.



-- 
James Morris
<jmorris@namei.org>


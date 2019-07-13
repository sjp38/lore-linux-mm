Return-Path: <SRS0=cxLU=VK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96A79C742D7
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 00:15:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63E5B20863
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 00:15:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63E5B20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=namei.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 035948E0006; Fri, 12 Jul 2019 20:15:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F27E78E0003; Fri, 12 Jul 2019 20:15:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3E8C8E0006; Fri, 12 Jul 2019 20:15:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id B89888E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 20:15:03 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id f143so4897586oig.22
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 17:15:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=q1Sk+82d4NQ3lSaWAlWZJTHnNm1ZB8RdB/LgG9TsUN8=;
        b=Hyid2uCDlV87wpU3OW7JU6ggbXTC+xe6PTKJWPhynbaZ+UHh09w5SWxKA+85zg8A5X
         5u8hh5iy8THuozjhOhzMbimgpHboYZVmi8CzOKWDuNZfFQf0ExXJO0F/7qQPpYZjopg5
         ODVvqEoWVsg1841tjgFZTXOhas9zOfFgorPqCQLuLrbJNAICyEtUcLpXPRS306494caZ
         BNAGatBMZqMXkrhN2XsDiKFbpMDChVrztX3X815ioXrpeFsFgGGD5KItOIlW9box70ft
         JtqdtbT0GPoxLGs8T2Ugx8Hms14hdPCyVTHxELpKVlwvUs6yGlg02j70fs0vv1QHFeI7
         zIRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
X-Gm-Message-State: APjAAAXMIqtu8t6gG+5BkkYjIsiyCVj8Fy1R9U7CKqqzWTnBu/V9WLC6
	QTKlYZgOFOYTZDr3ep1DhASiYYsbEA1Lbepe2wR9D8/DuCOgh8wQyN5JP+TkaBvvhaq0vVT1ort
	1gjwE1OPmSprUi3tncAERQhdH1UmJqaMdXi1nDbH5CDeUguGu7pHHoeJydrt2RZ8p/A==
X-Received: by 2002:aca:d511:: with SMTP id m17mr7278274oig.54.1562976903351;
        Fri, 12 Jul 2019 17:15:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/xtqPEGoOEAQdN9SM9WyhuurCYjI7/ltvugTq9hdDEp2kzezFY+O664Y1GWftaMocIiNK
X-Received: by 2002:aca:d511:: with SMTP id m17mr7278249oig.54.1562976902606;
        Fri, 12 Jul 2019 17:15:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562976902; cv=none;
        d=google.com; s=arc-20160816;
        b=gTtQ7HDEUE/70OgzLFDkkYhYf+kmYlvS9qPBycJpczaSs/oeIjGGgjtgdCn3MP4mG6
         bQknyzAtFAzenbvs81+25rBbgvhDQstkhfGAhz1Mvrr5ZgrpDTiTwxjcyZUH0cHldUTo
         ZSaFRX9jTPImZnaCWtXrmrinX6o5khowcf0bg8Xo2LdIh0DYsiv/Ypb47ZWCb8e2T1JH
         9z7DgeTgi5S3+f9JLjL7rpoGWpRa/veVIHRz6pNtqMxm/Ebenm3Uuy+EqqCspEEBpXPe
         AylubshHkPrrnoOHJ0tnKCTTswH4GVjVlmL6WiqhoUfjpkdICMVjp5mNWaRGZ4XblKL2
         EIyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=q1Sk+82d4NQ3lSaWAlWZJTHnNm1ZB8RdB/LgG9TsUN8=;
        b=K0Ym/DX04qoBzbx1qfKuOxuoaMEGyVr8Vtj3vHoSQi4Vh215Mfv048NgfiC+iGIRmX
         6Exooz47E4DyAYxlMFC76HxI67zpQgbe0mQDcIb7UuWq8+WQoW5MOvtozeMq0Sfoc/CY
         oJx1cQ3RDRuAu1AGCCAI+Pvcr0loNKwFSIlRzPtJRfYLVLm0xU5+OeNhW7IqJmTeb3ne
         xhXpOPA0qfpRGVAatcImfVwTp/2MSd7xrWBUvFJiIHPsslyJdotDZSTDUV34bdd2Z78L
         2G/AdTqBwuPtk+XZirXeebObdTnP6Kb91Y3x6ZA5afsi9YQSkkgTGIVJU+9JU9R6crBd
         sGQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
Received: from namei.org (namei.org. [65.99.196.166])
        by mx.google.com with ESMTPS id b26si6298747oti.246.2019.07.12.17.15.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 17:15:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) client-ip=65.99.196.166;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
Received: from localhost (localhost [127.0.0.1])
	by namei.org (8.14.4/8.14.4) with ESMTP id x6D0Efvn025905;
	Sat, 13 Jul 2019 00:14:41 GMT
Date: Sat, 13 Jul 2019 10:14:41 +1000 (AEST)
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
Subject: Re: [PATCH v5 01/12] S.A.R.A.: add documentation
In-Reply-To: <1562410493-8661-2-git-send-email-s.mesoraca16@gmail.com>
Message-ID: <alpine.LRH.2.21.1907130953130.21853@namei.org>
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com> <1562410493-8661-2-git-send-email-s.mesoraca16@gmail.com>
User-Agent: Alpine 2.21 (LRH 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Jul 2019, Salvatore Mesoraca wrote:

> Adding documentation for S.A.R.A. LSM.

It would be good if you could add an operational overview to help people 
understand how it works in practice, e.g. setting policies for binaries 
via sara-xattr and global config via saractl (IIUC). It's difficult to 
understand if you have to visit several links to piece things together.

> +S.A.R.A.'s Submodules
> +=====================
> +
> +WX Protection
> +-------------
> +WX Protection aims to improve user-space programs security by applying:
> +
> +- `W^X enforcement`_
> +- `W!->X (once writable never executable) mprotect restriction`_
> +- `Executable MMAP prevention`_
> +
> +All of the above features can be enabled or disabled both system wide
> +or on a per executable basis through the use of configuration files managed by
> +`saractl` [2]_.

How complete is the WX protection provided by this module? How does it 
compare with other implementations (such as PaX's restricted mprotect).

> +Parts of WX Protection are inspired by some of the features available in PaX.

Some critical aspects are copied (e.g. trampoline emulation), so it's 
more than just inspired. Could you include more information in the 
description about what's been ported from PaX to SARA?
	

-- 
James Morris
<jmorris@namei.org>


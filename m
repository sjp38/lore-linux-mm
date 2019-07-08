Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,GAPPY_SUBJECT,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6120FC606C7
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:38:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AFA62173C
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:38:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oTS27VBG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AFA62173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A296E8E002C; Mon,  8 Jul 2019 13:38:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D99F8E0027; Mon,  8 Jul 2019 13:38:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A20B8E002C; Mon,  8 Jul 2019 13:38:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 612438E0027
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:38:02 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id u200so6405882oia.23
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:38:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7dDlUWXE3BDiYJAkGp7CGjzY68vf5TiBs2gkLxCROPg=;
        b=Mn4dCL/qaISi7u2BAG9LFc0q5Dj55E9Nb9LssgoGe626owcNCg43pRxTzttitytpUL
         m9un4KoEvytLvnXAnzpsVknDKiOMHT1k2Qtd0FdpMUpyOBMh26LdsCU3akZQ9vZQdkM0
         vQpD54KwjI2gSgMoKLwcchJY8PfBRty1IP+/6kizWBsTTKuUn1AxQNEmxLV0unSgazqC
         jrt0cCpkAuz4CO/w4z9uDkd72Rxu1R7rE3V7swzuR60NncFzQae4J2DV3+Ruwb4qb4WZ
         XIvQZpkZubuS6DY1Tu01rk/W68FxGwuPuRCJKxAVp0sSvYDaSdyOmMXKmo/zMj3s7Pca
         j3Ow==
X-Gm-Message-State: APjAAAUQCSzgG65T+qGIddp1DDU9WsoxrSbcNvOwZB3m2o4E+YXK3mTW
	D4yYyh7QL8VD2hh9RnvLlibjKWCcC8Kfsvmj4LLos+eJdqGs2L9i48btOlcbLMba1vK6vAuOe29
	genLhAmlOA1maxFS4CmDWbBZKkOOV8hMuvvAF995OahYnLcSlVCrsu2DIDQln6TbR4g==
X-Received: by 2002:aca:7203:: with SMTP id p3mr9956789oic.87.1562607481765;
        Mon, 08 Jul 2019 10:38:01 -0700 (PDT)
X-Received: by 2002:aca:7203:: with SMTP id p3mr9956771oic.87.1562607481112;
        Mon, 08 Jul 2019 10:38:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562607481; cv=none;
        d=google.com; s=arc-20160816;
        b=fYg9RWFoBu8BJzXc4il4iOHZrb35frKm6msHkBwpYAF/bKnOGYTAlZCtiUdKOw9BdG
         S9Ln3wT+MdlBXy58YtlS9R1Pefr6RqxBicuELIjgbzSJd3PN5SVnLhUbjqjHtkAlvRaa
         mA31N2O/SMFT10lnINbcx/yuDitn8OX02EMmZQGyqd4dHFnWWQ/zGBUfMWK++Q8D/L+x
         x0b2qwJH2Kh+bpDtwHMh8bHaXp7dqYjjjnRWZmNkkTtHhPNZgbd6EzxfgHDsyxqcs3WS
         lDSwmFs0iSI5vS+EyjHLzm46hBJiFsoPBjNb7jropJ5x1G6htVjrWY65MAy8egZPkhvy
         ffTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7dDlUWXE3BDiYJAkGp7CGjzY68vf5TiBs2gkLxCROPg=;
        b=iw9OySLC1COCCbvuer/ewjx9Y42BzzuUfRzXw3H2lVCDFtoy2OtGnGtD90j2p9icBm
         vxVGvsOkDsGodn8M/fRf+v9sVKY9//06oPeuFZDFbmr/dlVLVzn41haQwlHDkvE9jJ6+
         SIIhOb//x+rtWc83EBOaLOQMV2Z+dk1YdPMOeTFtY5F86GPkOaoHJEoMAt0o8DRqktWE
         5ZzSs9atekTrNPU1eM9bWTPDm8F53eXiat5xPQrt3hvB7XPX9AG9rBHUfYNHmtdKDv9u
         pRCBxXYiTHqCjyLnyQBiX/SiQsp/ICr+PuSLV3a3XD4LpvRxxOXchB7616zDZq50E7ci
         Fk7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oTS27VBG;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m203sor7525258oig.134.2019.07.08.10.38.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 10:38:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oTS27VBG;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7dDlUWXE3BDiYJAkGp7CGjzY68vf5TiBs2gkLxCROPg=;
        b=oTS27VBGAXTGyWJrG+1bRf5KktV5vuIvxa8IWh1u4JAjBQEhi23d4SyczOUH26kY2R
         y//ajtI2TI29q75dcyp4FSN6kHo6UyR1wPu6Y62WtELMtJtY2Xkr824CBphlKwNvrFuO
         ieIrosIuDlKuPw3h2M3licdQ3No/OcsZmxHFpt3c0Kc+o5hSNDIzOkDfH9Z91ZQWyD9C
         grhZTvCUxZJhweX5ja9rWveALtoabLG30fihRzI/xTkp6fk/mdSPQab2R5qH1XoaWpiD
         o9GNdIcFxNYegyyTxVLrvQTgO8RvIuuA7e/Fsm1h2c1BcSOCqsarhQ/oMOQ4o/vR2/An
         BE2Q==
X-Google-Smtp-Source: APXvYqxWC2WzfHpl8ZigyXVHyyT6QtrbedYXY8/NrWJL/zNHr0x2cmYj/XsDrwdBKxwSxPY6OsYxHdMmiMEzeBNat6Y=
X-Received: by 2002:aca:b06:: with SMTP id 6mr10585303oil.175.1562607480451;
 Mon, 08 Jul 2019 10:38:00 -0700 (PDT)
MIME-Version: 1.0
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
 <1562410493-8661-5-git-send-email-s.mesoraca16@gmail.com> <CAG48ez35oJhey5WNzMQR14ko6RPJUJp+nCuAHVUJqX7EPPPokA@mail.gmail.com>
 <CAJHCu1+35GhGJY8jDMPEU8meYhJTVgvzY5sJgVCuLrxCoGgHEg@mail.gmail.com>
In-Reply-To: <CAJHCu1+35GhGJY8jDMPEU8meYhJTVgvzY5sJgVCuLrxCoGgHEg@mail.gmail.com>
From: Jann Horn <jannh@google.com>
Date: Mon, 8 Jul 2019 19:37:33 +0200
Message-ID: <CAG48ez2f1TbUZt_0F99DLyzn-3DhjuoTJZ7Dwxgmto7J9ZQ95g@mail.gmail.com>
Subject: Re: [PATCH v5 04/12] S.A.R.A.: generic DFA for string matching
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Cc: kernel list <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, 
	Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, 
	Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Thomas Gleixner <tglx@linutronix.de>, James Morris <jmorris@namei.org>, 
	John Johansen <john.johansen@canonical.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 7, 2019 at 6:01 PM Salvatore Mesoraca
<s.mesoraca16@gmail.com> wrote:
> Jann Horn <jannh@google.com> wrote:
> > Throughout the series, you are adding files that both add an SPDX
> > identifier and have a description of the license in the comment block
> > at the top. The SPDX identifier already identifies the license.
>
> I added the license description because I thought it was required anyway.
> IANAL, if you tell me that SPDX it's enough I'll remove the description.

IANAL too, but Documentation/process/license-rules.rst says:

====
The common way of expressing the license of a source file is to add the
matching boilerplate text into the top comment of the file.  Due to
formatting, typos etc. these "boilerplates" are hard to validate for
tools which are used in the context of license compliance.

An alternative to boilerplate text is the use of Software Package Data
Exchange (SPDX) license identifiers in each source file.  SPDX license
identifiers are machine parsable and precise shorthands for the license
under which the content of the file is contributed.  SPDX license
identifiers are managed by the SPDX Workgroup at the Linux Foundation and
have been agreed on by partners throughout the industry, tool vendors, and
legal teams.  For further information see https://spdx.org/

The Linux kernel requires the precise SPDX identifier in all source files.
The valid identifiers used in the kernel are explained in the section
`License identifiers`_ and have been retrieved from the official SPDX
license list at https://spdx.org/licenses/ along with the license texts.
====

and there have been lots of conversion patches to replace license
boilerplate headers with SPDX identifiers, see e.g. all the "treewide:
Replace GPLv2 boilerplate/reference with SPDX" patches.


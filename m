Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19539C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 11:58:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B95A421743
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 11:58:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MEROJahA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B95A421743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BE316B0003; Mon,  5 Aug 2019 07:58:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 295316B0005; Mon,  5 Aug 2019 07:58:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AB156B0006; Mon,  5 Aug 2019 07:58:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED8DB6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 07:58:21 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x17so72358325qkf.14
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 04:58:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Cf79lRbjTxuYvrjTYwQy5DclxuSwBZtPZCw1u1tZDjw=;
        b=IAHZDYCd0TwAXqyWsRrz4uR4EGhXd+afSRQgYhL5v4PQyB3H9lZJ5w2ZAATMjevB2t
         vDkPmG85B8ZEfq1JMETt4TLt1t0/Yh+s5GmQX+RlLOzz958J02PTjkaIR/Bk/30lPGcZ
         O01a9njmf3GoC8t+IiF5QtiKjVoX+Mec9XlkHgJvxNM9HOc3sQ0Dk5IPwvpcGAOCakaD
         xohoHIg+/J/qK/3wM9ziVvdXVw9n9oi0x61sYBwqIQ2krrCC+mGFM9KQ+o88VYa9GipN
         LTqQP0C65q97I/IK/Y+y3hNAMyuOn2cGwyr5l/uDYa/WaxCdwrB6rDzX5tpCMYvNTxhC
         vUhQ==
X-Gm-Message-State: APjAAAUnNqOteUp3VR9iB8qx7J3NulsQin94kipzeG3yZGDdBYVlqmVe
	4ooVc52OPAWc3pWpLKS4ZGHUjNTH0cheMycF7pHJfzDy48MwHEZoAIWGa7rKZKxq3Wd6eWNOhrh
	9thiFBsRs894zbDgmr6cbmx6qmMcONDb0nGm7At+g7uSOYdSsDEp9XqwaAC/Aggs6jA==
X-Received: by 2002:a37:9185:: with SMTP id t127mr95179587qkd.405.1565006301789;
        Mon, 05 Aug 2019 04:58:21 -0700 (PDT)
X-Received: by 2002:a37:9185:: with SMTP id t127mr95179562qkd.405.1565006301307;
        Mon, 05 Aug 2019 04:58:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565006301; cv=none;
        d=google.com; s=arc-20160816;
        b=AHI+o1m7dk/dGXsbUKMcQ2v1ADWWy021hufdh9xncGZp+4QkSp5YMOyAHnhkCTaeU8
         dBmfBG43+YQ3Kte1PJL5CjwkXn+CaJpXOH8NfGUILDoQUTHneuV6zyg43uo1qymQ/9sn
         aYE5JD94HX5akcw6UvNzNJKkqcagORWxr6ObWIhSnzb52a3JuhpbEncSR7AtWAJaOWC/
         ZZm5Eqtb66hGfRImPzH5yThgUjvML6rrwXDuTf+/bX2kMAU6iRpYUQ1N49DaX/MxTwio
         xCl2dt+Mzas7/trDk5smJYMhtsTvU9m6jUtdOQBjqNXE8PCFPpa4t8hSGOr72BGTmyKj
         nqOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=Cf79lRbjTxuYvrjTYwQy5DclxuSwBZtPZCw1u1tZDjw=;
        b=NOudBHTZcS//ak1OmuFSxak0T87AR2g68YVXEpNKx5KtRhiKxCSYIhIhu1V4gaRso5
         gQwBNWEs0sJBuSLSqOoXB+JHmmjjt/Th13IgidUroEIM9b3OJFSzN0ENiat6N6c+mTAa
         EfTGKoSI5jB68Dq8nHrqD6FFB6jj44tPyuhdmEWGly/nU39OLd44nTqHwTRo3j7/5vAL
         At3AhH0MOOpKRC76EBT+EvGUKZ0AQ4K3WzdushTc7Dg9CIP2oB18SHmRcDiNRwXXRbzo
         Ed5lAt98lZXyO9AZlKnHOkLyNjn+rrk3bI+WlIAC0NKyeCRqdq4yikTvSCkxB0efDwuR
         HfRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MEROJahA;
       spf=pass (google.com: domain of mathstuf@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mathstuf@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p53sor109463190qte.29.2019.08.05.04.58.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 04:58:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of mathstuf@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MEROJahA;
       spf=pass (google.com: domain of mathstuf@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mathstuf@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Cf79lRbjTxuYvrjTYwQy5DclxuSwBZtPZCw1u1tZDjw=;
        b=MEROJahA3aFopIyauLYvf1B6zTAtFRQGVywLTvuOwy0JV4Azcl0Amnbxf4zUVIqC/G
         5kTOuNGsltVhyCAHagN0JycjpE1hWV9by85hkhO/e+7MOMdTir8envu7FOhORPmE+286
         Rrll9tSc18atKkAuKx4mDNGgcbTqwXWZzHoKEGJ9EBYA4Qu3jZJIZjuPs+D4LuugbDMq
         TMArjd+Kq+lMGFYUAQPDTWziIsUQLdTMdCJiL+xRYXHehHWHrlnDLvfUjCcu6lV7t75R
         CeJhw2oihej2DOdXP3Y+mMlHNT4OYC236xyTHU1Qpvtt/KG/LwaKs5PpyEP/H38MYFBd
         KujQ==
X-Google-Smtp-Source: APXvYqzR5O4gZkb0h8p/vmE0FqgjnI+i2nL2OnMMo6DdX+NKyxRyToVMerzJYx27wg9lgahrIR5eNA==
X-Received: by 2002:ac8:34c5:: with SMTP id x5mr101803128qtb.91.1565006300868;
        Mon, 05 Aug 2019 04:58:20 -0700 (PDT)
Received: from localhost (tripoint.kitware.com. [66.194.253.20])
        by smtp.gmail.com with ESMTPSA id e7sm34167209qtp.91.2019.08.05.04.58.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 04:58:20 -0700 (PDT)
Date: Mon, 5 Aug 2019 07:58:19 -0400
From: Ben Boeckel <mathstuf@gmail.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 25/59] keys/mktme: Preparse the MKTME key payload
Message-ID: <20190805115819.GA31656@rotor>
Reply-To: mathstuf@gmail.com
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
 <20190731150813.26289-26-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190731150813.26289-26-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 18:07:39 +0300, Kirill A. Shutemov wrote:
> From: Alison Schofield <alison.schofield@intel.com>
> +/* Make sure arguments are correct for the TYPE of key requested */
> +static int mktme_check_options(u32 *payload, unsigned long token_mask,
> +			       enum mktme_type type, enum mktme_alg alg)
> +{
> +	if (!token_mask)
> +		return -EINVAL;
> +
> +	switch (type) {
> +	case MKTME_TYPE_CPU:
> +		if (test_bit(OPT_ALGORITHM, &token_mask))
> +			*payload |= (1 << alg) << 8;
> +		else
> +			return -EINVAL;
> +
> +		*payload |= MKTME_KEYID_SET_KEY_RANDOM;
> +		break;
> +
> +	case MKTME_TYPE_NO_ENCRYPT:
> +		*payload |= MKTME_KEYID_NO_ENCRYPT;
> +		break;

The documentation states that for `type=no-encrypt`, algorithm must not
be specified at all. Where is that checked?

--Ben


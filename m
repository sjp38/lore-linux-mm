Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 341B6C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:35:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC98120818
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:35:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC98120818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79B898E00E1; Mon, 11 Feb 2019 07:35:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74B5F8E00DD; Mon, 11 Feb 2019 07:35:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63A3B8E00E1; Mon, 11 Feb 2019 07:35:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0ECE58E00DD
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:35:21 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c18so9229374edt.23
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 04:35:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=+wxmfskF7vbLdDz7xTSS2N4psaEXRFRPGps36I3gfDI=;
        b=GPOs0SoN4E7Wl+EDHP7hyhd3rxpgkYTXSFipjSWzpx2qeHp4N2z8EenZCecTYHxCC7
         MP4ZgdeGkj+EaYf5dT7gw/ob1IDwR4+FDbhTGWSopVIypVBT1M6z+nrnl8P75YNSMnMo
         YJB8aFmrWQQ+lU9POvZTunW31t7tymkIRpAl8YXekz986qnQB8UQXDpqnLZAANiKPmHe
         ssKXx04owfVQG/07bq4pqbSRvaJaq79GR3WUbzLpraDyng50afk0tB5fGdGFvYumgo44
         KpYyDtBv7Twvqf2AB3nN0NVv/EVQXXRcrksGoYXbG99MuKRR9k9XBTvPoTJzvXf96EGt
         mn+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: AHQUAuZrtGmw334hgn1iFTHdQRF+3103G1GcBSeiMBt0ekTHDoDh1Ju0
	k+RBpG9/KV5Gdqg5Z7yc6BcUafcAoqEbgK+OO/HqCmZyDpf9ni0F3RXpUEooRtEmHOgeOn9IdWm
	p0+hSCpJcg9OrlIbhVtU84T8DBDq/9QQ1JupjgjOwDk3OIcz3PCzUCanyUTFmXt6rXQ==
X-Received: by 2002:a17:906:580b:: with SMTP id m11mr9500211ejq.137.1549888520616;
        Mon, 11 Feb 2019 04:35:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaCfCrrPJXQ/mQx8XGWz4V/fE5/so7BIKLOha/Wuj+La5Z2POAWkjVClu5m5N3xymXkzS1u
X-Received: by 2002:a17:906:580b:: with SMTP id m11mr9500165ejq.137.1549888519752;
        Mon, 11 Feb 2019 04:35:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549888519; cv=none;
        d=google.com; s=arc-20160816;
        b=arniRMpRdPzn99dLbKQjrsxO8t7VOCFiCCg7TsnGsavqaP8QE8dq4G+HzkLkeInEkO
         O8LA5ZCfL93YIEYDEOmD4Kt1vvqL6ApVOHkiroIBKtfD3l1XhdM2q07gEMEzsy9EYxN2
         yJi0zcoVdXc6Kv9JaCP2LUMypFrRsvRg0ZXIH/xO2ZRZJysjDck0At2QWfzVX3dqrS9L
         I11skgJB/15O/JD1VihmRQxoUMgDVRqw+R8TwIIrBUTziBe6hEM8gIPk+y3ty/2N0RYB
         I7vpiATA6lt293xBcQ5e/R3pWfgkttlOofC0F2BHAefJWvUBi70am6eVyw4kgRKIwohC
         KuWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=+wxmfskF7vbLdDz7xTSS2N4psaEXRFRPGps36I3gfDI=;
        b=k1s/cp87jqjOO1lgSYtmn8wZW9PVoi6xGQdjROw+x7jEeSNH2EB6FHm5AhOZLuajN6
         pC0CuOZQ1tRjIbJfteVftqnc7IUIQnR6LNNtSGUabQLKYKSH10jBAg33Cd5bk3MAkxBt
         27XK1kgI1rVH77qJV0y1w/IcbDiQd8rEj4ABbNvkoZVuoiXu8q35Vmfc5CUBTHuXQ/2r
         /eWJU4el0v+zRDiqV92i68ZBlDtaxPLuWn0Io5T7as+vOxTHJC2s7PTEDbq3NygPOvR2
         ww6yBagKKJpTuAhOtTdT5p+aIvtZZOh/Mto0q8AP/pZTaYUWXwCPhqJz3Cw8SebUCvCQ
         kOlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i14si2227952ede.434.2019.02.11.04.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 04:35:19 -0800 (PST)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9DEAAAD38;
	Mon, 11 Feb 2019 12:35:17 +0000 (UTC)
Subject: Re: [Xen-devel] [PATCH v2 1/2] x86: respect memory size limiting via
 mem= parameter
To: Ingo Molnar <mingo@kernel.org>
Cc: sstabellini@kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
 xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com,
 tglx@linutronix.de
References: <20190130082233.23840-1-jgross@suse.com>
 <20190130082233.23840-2-jgross@suse.com> <20190211120650.GA74879@gmail.com>
 <bd5863a2-291a-43e5-7633-c84c1026a31b@suse.com>
 <20190211122308.GA119972@gmail.com>
From: Juergen Gross <jgross@suse.com>
Openpgp: preference=signencrypt
Autocrypt: addr=jgross@suse.com; prefer-encrypt=mutual; keydata=
 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
Message-ID: <39e8f05b-868b-8ab7-a310-b4ea7ef92bcc@suse.com>
Date: Mon, 11 Feb 2019 13:35:16 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190211122308.GA119972@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/02/2019 13:23, Ingo Molnar wrote:
> 
> * Juergen Gross <jgross@suse.com> wrote:
> 
>>> If PCI devices had physical mmio memory areas above this range, we'd 
>>> still expect them to work - the option was really only meant to limit 
>>> RAM.
>>
>> No, in this case it seems to be real RAM added via PCI. The RAM is 
>> initially present in the E820 map, but the "mem=" will remove it from 
>> there again. During ACPI scan it is found (again) and will be added via 
>> hotplug mechanism, so "mem=" has no effect for that memory.
> 
> OK. With that background:
> 
> Acked-by: Ingo Molnar <mingo@kernel.org>
> 
> I suppose you want this to go upstream via the Xen tree, which is the 
> main testcase for the bug to begin with?

Yes, I'd prefer that.


Juergen


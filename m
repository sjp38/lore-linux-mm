Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDDC5C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 13:30:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91E262086C
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 13:30:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="bE3CSH7m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91E262086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C9AE8E0002; Thu, 31 Jan 2019 08:30:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 352978E0001; Thu, 31 Jan 2019 08:30:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2253B8E0002; Thu, 31 Jan 2019 08:30:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id BCBCE8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 08:30:08 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id y129so777924wmd.1
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 05:30:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yFtcBfMUUYkbqUgRtVFMbksJPGrUCYA7EaPgerWMiYo=;
        b=VXLXD6u2z9uTM1ZnHcK7xGKN//ZHBegD37/fRXlpHh3prPMfzSsFEBH2r1/i9+xm6V
         sn9wpkWp/YtjnTwBrXt6N+Bm8aW8sXr7bVMXY+B1YHy8RHxwkfw4DEbjn8aZOSQhVnAQ
         xBD4xAQPcu8v59BcCNnBMbJNmkGkziqC9DL+3s1p0X0O8sLV7Ni5B6re7d0hXWOPwPkN
         1AO6JQ3sFknrE0XHEy8EEjmhzcFy3ioAkQF6A2FtiUJhZFAL0+NWr8HioSqzeM6SR5oL
         As5tNJUnuBkf7buwBcq8RhkTG9aTjm358cs+s18xzqt6gu0jNIMU2/oWAtnRofTVReLp
         voMQ==
X-Gm-Message-State: AJcUukfALWuAwSISSFxjWOAW1Efm1kB6dlhJ2HhWm3HmK0ywH62/WusW
	O2hnCg1wb5kUuob0PYbNCVfjmZnz+mLr+lSJ4qS2JHNlgSWArKNIdAdpJT66GVj6LhOXIrhgKkB
	F3iUyB7W3vC5a87Aa4OHXQM98i0Mcv8xHMMLMqh9q/SK/0ZLPv7qdbmheCPs/HtQFsw==
X-Received: by 2002:a1c:87cc:: with SMTP id j195mr29168294wmd.2.1548941408297;
        Thu, 31 Jan 2019 05:30:08 -0800 (PST)
X-Google-Smtp-Source: ALg8bN47IjRj7ZRV/a4WG+qkJ1BYy+HgWSiLCfMPQPRYGF1EkYQWXkFKaK8Th+H+WbmI7yMVuCfY
X-Received: by 2002:a1c:87cc:: with SMTP id j195mr29168235wmd.2.1548941407351;
        Thu, 31 Jan 2019 05:30:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548941407; cv=none;
        d=google.com; s=arc-20160816;
        b=i9+z2oiCAiyXQEgMPiH9HuWQBIz/URa5sJg+VR070pVhnEdnJOpmTy8Alo+QC0atD7
         DjOgONx+laqBif+0v4ecq5cI3sZ18YmrNOMo2ZEsQvmOtFAkuFhsKdztspghH94WJySi
         U+xuNrze2PbCbbGvb4PBUU0VC4nmGZsv63X+bNfsl/BAsJ0bKNC2P7pDbWyGNOC9xXLz
         L7OqIoEQXc2ykOFIKmEDVzS9hVNBgiTej30a5zuUHvv33HGp6loSEsda20uvMu8KNuJH
         3HxkTWxxWOncnj32wMS1rWdEEXVdSXx2JjT3v3ef/iAlW7/QvlRlXtd3bbWfZY3lR2Ui
         yO5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=yFtcBfMUUYkbqUgRtVFMbksJPGrUCYA7EaPgerWMiYo=;
        b=bdNUPXvEqaKetC44TQKNi6v6UaMKVYmetC1jwMppr78wSGMDKcqfpklCjtBXn0w9mk
         tbVTJ2t4CtAkEfFxmZZZQOhj8UoD+sL2Luj04n7/E7WDb3CmzJQdFeNl69dVm0fxgK5M
         /zEu+P2NW+pZJqqI0vfK4UTBwUEgzqnO/GcBX0F3dJxynp+GjaZ1XqU662JkUz8Nfg2F
         UxmFZ/HlRMKq40M+3gN1lophiAvVnHeqkkFyuBLflvOSasNRwU14yuJX3EoFrfu9s4RV
         Qj02MxExN/LvMvHnijQoccX3P/9O5HwAzozo9exNUrkyTQg1RCuuVhJGP+hzJO02JGpz
         fl/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=bE3CSH7m;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id m5si3554070wrq.289.2019.01.31.05.30.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 05:30:07 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=bE3CSH7m;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCC5900651C63FB93E4C575.dip0.t-ipconnect.de [IPv6:2003:ec:2bcc:5900:651c:63fb:93e4:c575])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 70B9A1EC04FB;
	Thu, 31 Jan 2019 14:30:06 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1548941406;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=yFtcBfMUUYkbqUgRtVFMbksJPGrUCYA7EaPgerWMiYo=;
	b=bE3CSH7miRGbUMKqe9kS9V9fY72eYAYVC4BYNj6g4HVgDZEGDurkcQyvtjbvO6Gs9PYA6b
	Ti/SUND6wI2RU0OfxtXiAfGn5+pKzQPotfYHuVatH3pI/a1sf9ECtenz11UbkLVQuRaP1G
	PW5t8QUjBSyjxmHw0PNxsF5DiKErDRI=
Date: Thu, 31 Jan 2019 14:29:58 +0100
From: Borislav Petkov <bp@alien8.de>
To: James Morse <james.morse@arm.com>
Cc: Tyler Baicar <baicar.tyler@gmail.com>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	kvmarm@lists.cs.columbia.edu,
	arm-mail-list <linux-arm-kernel@lists.infradead.org>,
	linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
Message-ID: <20190131132958.GJ6749@zn.tnic>
References: <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
 <CABo9ajArdbYMOBGPRa185yo9MnKRb0pgS-pHqUNdNS9m+kKO-Q@mail.gmail.com>
 <20190111120322.GD4729@zn.tnic>
 <CABo9ajAk5XNBmNHRRfUb-dQzW7-UOs5826jPkrVz-8zrtMUYkg@mail.gmail.com>
 <20190111174532.GI4729@zn.tnic>
 <32025682-f85a-58ef-7386-7ee23296b944@arm.com>
 <20190111195800.GA11723@zn.tnic>
 <18138b57-51ba-c99c-5b8d-b263fb964714@arm.com>
 <20190129114952.GA30613@zn.tnic>
 <c17156e4-278b-7544-367e-50e928407a03@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <c17156e4-278b-7544-367e-50e928407a03@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 06:48:33PM +0000, James Morse wrote:
> If firmware has never generated CPER records, so it has never written to void
> *error_status_address, yes.

I guess this is the bit of information I was missing.

> There seem to be two ways of doing this. This zero check implies an example
> system could be:
> | g->error_status_address == 0xf00d
> | *(u64 *)0xf00d == 0
> Firmware populates CPER records, then updates 0xf00d.
> (0xf00d would have been pre-mapped by apei_map_generic_address() in ghes_new())
> Reads of 0xf00d before CPER records are generated get 0.

Ok, this sounds like the polled case. FW better have a record ready
before raising the NMI.

> Once an error occurs, this system now looks like this:
> | g->error_status_address == 0xf00d
> | *(u64 *)0xf00d == 0xbeef
> | *(u64 *)0xbeef == 0
> 
> For new errors, firmware populates CPER records, then updates 0xf00d.
> Alternatively firmware could re-use the memory at 0xbeef, generating the CPER
> records backwards, so that once 0xbeef is updated, the rest of the record is
> visible. (firmware knows not to race with another CPU right?)

Thanks for the comic relief. :-P

> Firmware could equally point 0xf00d at 0xbeef at startup, so it has one fewer
> values to write when an error occurs. I have an arm64 system with a HEST that
> does this. (I'm pretty sure its ACPI support is a copy-and-paste from x86, it
> even describes NOTIFY_NMI, who knows what that means on arm!)

Oh the fun.

> When linux processes an error, ghes_clear_estatus() NULLs the
> estatus->block_status, (which in this example is at 0xbeef). This is the
> documented sequence for GHESv2.
> Elsewhere the spec talks of checking the block status which is part of the
> records, (not the error_status_address, which is the pointer to the records).
>
> Linux can't NULL 0xf00d, because it doesn't know if firmware will write it again
> next time it updates the records.
> I can't find where in the spec it says the error status address is written to.
> Linux works with both 'at boot' and 'on each error'.
> If it were know to have a static value, ghes_copy_tofrom_phys() would not have
> been necessary, but its been there since d334a49113a4.
>
> In the worst case, if there is a value at the error_status_address, we have to
> map/unmap it every time we poll in case firmware wrote new records at that same
> location.
> 
> I don't think we can change Linux's behaviour here, without interpreting zero as
> CPER records or missing new errors.

Nah, I was simply trying to figure out why we do that buf_paddr check.
Thanks for the extensive clarification.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.


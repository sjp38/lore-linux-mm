Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D057C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 11:28:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC17920872
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 11:28:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="kf8vx4Ds"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC17920872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 164238E0011; Fri, 11 Jan 2019 06:28:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 116F88E0001; Fri, 11 Jan 2019 06:28:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F222A8E0011; Fri, 11 Jan 2019 06:28:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 955F18E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 06:28:50 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so5808307edd.2
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 03:28:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=hCfXYtQjUYbpfemdO/BMKeV7KyCEeg9EzgbAR4onQaM=;
        b=YXzm6cz5x8Rit7S3OEkWtebCZKBXuW64C4hSKqpq/rL0glbLpIXNEs2i7LSdcgi7Oj
         zNmrMzUvJhpxOtDMfM5sG2xy0BdvHcsYfcxoql8Hc1E9lnRTqGZfWbOQpDrNG6bHIUR7
         kUJhP6gbS4kASH2DiYj+xMZoZ4qx70Mz/+0ERwkkBiTU6jMy1tZ3v+eOUQ5DTcn76LKs
         XI3xkTWS5onwcyfIShGCIfv8/a2/Tev2p4MPoqO/xW6uhYUkFQUBxi853OlbtrA5EMFi
         jZCSuAcExiqqPZYA8ItCzFyP8oLwXcM+rLoT8oINcuBtn2TMkZBHCiAC68W2pTj+5gui
         Ja4Q==
X-Gm-Message-State: AJcUuket+uB9mtlPpdSbfoUwRihx9aN6+MS2svZoQ0aydNs56HeXxCAY
	QDrEz5PDo7hVVc4zZkKRGd/rwf2XlXyemn2eUCrs48XH3DXwuKds6pYWtSHhHxkTj7Z72DCV3lD
	KDzsjqFS9BU14bwzMSbvqp2vrwLVt9O6+nYbGHmIpcuEjmcwaX/iEiXSXWpGGV6EsSg==
X-Received: by 2002:a50:b4f1:: with SMTP id x46mr13195753edd.289.1547206129871;
        Fri, 11 Jan 2019 03:28:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7UjXblC2ugC/cnpoIl4E0M1uwH43Ky5Fuf9UegMLZTTRrTHFsf1NGsD3sRBGUJFNUlqFXd
X-Received: by 2002:a50:b4f1:: with SMTP id x46mr13195699edd.289.1547206128700;
        Fri, 11 Jan 2019 03:28:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547206128; cv=none;
        d=google.com; s=arc-20160816;
        b=O4vihJR4FVKwuayQix+N7YT7SjR1GRKR/2FW47U00NQE2SQHhO68s1zB0NLQwnS6wu
         4eAqciwtHQO3VuVR6Y1yKgjAin/3N6qQmUqRJ2iRGF5uTZp3O9fP4yV6BTlJ12mDtLWi
         x/JoqgndNenHbRsejG6xfoWtvXf84Upv3S0M/jSF+eeVySSPh/q0lduOKEFgLDKaJTnA
         yFYZMIj0ZMUjZkgXaqR6fkifqx7xGzjvmETKEJCjpbQDwAltAJugDAndSIHQclLngnCZ
         T/Ogblj/Vppwq13fet6c0WZHhaj/viYRFLfd3ta2QT+wYZlzf0s+xwbTpaNDniD30UFX
         sB8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=hCfXYtQjUYbpfemdO/BMKeV7KyCEeg9EzgbAR4onQaM=;
        b=sbQAoCqvAx2ynV10Vk/75qt4FRn1BxhKXqyomsI1UohDl34DZnblD5+0anFVNvIsxg
         mdwPIeGAgNqBxHgQrn6AmBgUCYypbC/3L8i6AUQFFtGzHlTVmqc4bGQ002feq/NLfLTL
         6KtKwVPsxA9UUiS8woTTrGKLJ4hky8NXLC3TIbeAPmZLrHx0A+zVW56X3XyvJ6mVzT2Q
         Rn9tt9qxp1wzTrApNGSgr+mZCPUYuPubb9+wcnAWfO1BO5RW0C18exKFI2YXCgLqJdj2
         vAXwgB0cHJU98e+lr0nBcD5sfXuIwlbtBwVtVlf/5jjxQT2xuxxX8ylEgChScX/aZntE
         S7mA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=kf8vx4Ds;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id j30si4189368edc.365.2019.01.11.03.28.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 03:28:48 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=kf8vx4Ds;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCAC5006CCD8D4D75E662CE.dip0.t-ipconnect.de [IPv6:2003:ec:2bca:c500:6ccd:8d4d:75e6:62ce])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id B4DD91EC03DB;
	Fri, 11 Jan 2019 12:28:47 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1547206127;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:references;
	bh=hCfXYtQjUYbpfemdO/BMKeV7KyCEeg9EzgbAR4onQaM=;
	b=kf8vx4Ds58lhzBpSZx0kkKyt1+ja5ObmR+3a331sGWk1ZqQRce3wBwLmP4y61squ0aHDh9
	rUEXhymnTCgkSdcIq5DNNBG7xvUBP4w6EyI1cLe1emdOqjs8HzTGgQZ+Egr2ZZ0cfFArL0
	Q14SuAC2zP9ffp8oRxKesLOjxHtsWyM=
Date: Fri, 11 Jan 2019 12:28:40 +0100
From: Borislav Petkov <bp@alien8.de>
To: James Morse <james.morse@arm.com>, Tony Luck <tony.luck@intel.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>
Subject: (ghes|hest)_disable
Message-ID: <20190111112840.GB4729@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111112840.Vm7xSGiAhd2ojx2BvyP5fkJeCu2Em-fCYCNvKyHq454@z>

Ok,

lemme split this out into a separate thread and add Tony.

On Thu, Jan 10, 2019 at 06:20:35PM +0000, James Morse wrote:
> > Grrr, what an effing mess that code is! There's hest_disable *and*
> > ghes_disable. Do we really need them both?
> 
> ghes_disable lets you ignore the firmware-first notifications, but still 'use'
> the other error sources:
> drivers/pci/pcie/aer.c picks out the three AER types, and uses apei_hest_parse()
> to know if firmware is controlling AER, even if ghes_disable is set.

Ok, that kinda makes sense.

But look what our sparse documentation says:

        hest_disable    [ACPI]
                        Disable Hardware Error Source Table (HEST) support;
                        corresponding firmware-first mode error processing
                        logic will be disabled.


and from looking at the code, hest_disable is kinda like the master
switch because it gets evaluated first. Right?

Which sounds to me like we want a generic switch which does:

	apei=disable_ff_notifications

to explicitly do exactly that - disable the firmware-first notification
method. And then the master switch will be

	apei=disable

And we'll be able to pass whatever options here instead of all those
different _disable switches which need lotsa code staring to figure out
what exactly they even do in the first place.

> x86's arch_apei_enable_cmcff() looks like it disables MCE to get firmware to
> handle them. hest_disable would stop this, but instead ghes_disable keeps that,
> and stops the NOTIFY_NMI being registered.

Yeah, and when you boot with ghes_disable, that would say:

	pr_info("HEST: Enabling Firmware First mode for corrected errors.\n");

but there will be no notifications and users will scratch heads.

> (do you consider cmdline arguments as ABI, or hard to justify and hard to remove?)

I don't, frankly. I guess we will have to have a transition period where
we keep them and issue a warning message that users should switch to
"apei=xxx" instead and remove them after a lot of time has passed.

> I don't think its broken enough to justify ripping them out. A user of
> ghes_disable would be someone with broken firmware-first handling of AER. They
> need to know firmware is changing the register values behind their back (so need
> to parse the HEST), but want to ignore the junk notifications. It doesn't sound
> like an unlikely scenario.

Yes, that makes sense.

But I think we should add a generic cmdline arg with suboptions and
document exactly what all those do. Similar to "mce=" on x86 which is
nicely documented in Documentation/x86/x86_64/boot-options.txt.

Right now, only a few people understand what those do and in some of the
cases they do too much/the wrong thing.

Thoughts?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.


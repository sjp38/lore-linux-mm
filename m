Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BC4FC43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 21:56:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA647208E3
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 21:56:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA647208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86B388E00B3; Thu,  3 Jan 2019 16:56:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81AF48E00AE; Thu,  3 Jan 2019 16:56:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70B238E00B3; Thu,  3 Jan 2019 16:56:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED738E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 16:56:25 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id y85so9347124wmc.7
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 13:56:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/KSHXE0+n/3lqpCjfTNfvkRLE/VYKjLu2w9kYLHlrBs=;
        b=Ucf8QtFYV7AMrjBLt2AkJFfQ7uGRfPU0y3Z1gIFYPiaEZJOwcOq3aF5p/intjqRWuY
         za0bJn2HjRnj658YzUCmur21I501nh2nRuqQRwkLvrp4dy4ti9SONFmkG8fKGe/BIx2I
         zNYdeSSqU6Yd+IZa+KvYMVSSAt6i+y6zlubZuj4Da6Ne5YL2VsscpfzR4xNFefhkefxQ
         pbVb0f3htGyj1//fqtCqP9ZOx8WxJSWxSwySUIAP2+eU3s/St6Dy/WItrHqYNQQRwEhk
         tyQgljgre8p5j0MYU4STmvgcfrkI7VIbKUiucSdIJpItBjRhFvRnl6uwQRdsp4YTXKJ9
         +3bQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of gael.portay@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=gael.portay@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: AA+aEWZtkw4QwDE7MMl9NiB0zGLosqbOeh/pctkN44rM+XOb6W3Y8RhF
	Essq6cdTh5JdUfepKiFcNO8kWpPWLo2CNIDmUuPjqNhK8UKK1K58BelywysWahkOCsrewO+Gz+8
	sHy6fJ688SBuQ4FPGCxZzT/Haump+Zzy/L21w3T488v5Jbe0aB+DvGoLHjce670m0EA==
X-Received: by 2002:a1c:9a0d:: with SMTP id c13mr40501726wme.41.1546552584622;
        Thu, 03 Jan 2019 13:56:24 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4zxEFjLNjwEx8gbr3QwQV67zgSivFGbvMz3cWFayggE6oWq5tu5xtFuH8pvemoEbjtvV5y
X-Received: by 2002:a1c:9a0d:: with SMTP id c13mr40501703wme.41.1546552583874;
        Thu, 03 Jan 2019 13:56:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546552583; cv=none;
        d=google.com; s=arc-20160816;
        b=j6/vqVX15RGyOgqGj1Ztk+D7ExA9bVuODWXIqLgO5IqIlmlMWo99+qv+Jc7F5ahoCK
         EKKqjNPIGvaeY5m1kvUyenVUdexXuHTTL3PcMbb/DRlHDX3LKZ7ic/cgPWxfRpP39guS
         C0fN/HOC9NWwEUQjZgwR0Cj/O+F67IraAzRl6M17BMkvh6V1IudKVHve4MobI5Ip255c
         kH6hnknrL7ndvTQSXlt6jp7lm63xmJIx9/KXPSM5po2lEIvlAcDXisFnKL/f3xoyQDtj
         KXLmTgIOoO/vlURSc+Bb1Wzjfoi1CaVjabJ0wiNwdqhYYunsjEzCfa1t9bHqXCS3trFl
         C+UA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=/KSHXE0+n/3lqpCjfTNfvkRLE/VYKjLu2w9kYLHlrBs=;
        b=eUaw6cvX0U1k6CzIDCgGxz2HuxU9iGGV9SX9QX6rM0ymmj7bjDhvMd11Fk5OtfH9SK
         UAcvv6EP38A2NVj9E7VbZduUJ7m2/aH4XW1ZFwqNT4+UoyMM5/7m8nnVp/K44+h1B4rA
         v+LobKqaQQO0P+YFOBxtfjUHjj3lA3CrH3anBCbvFC2ueAcOjNzENgg0+Qjqofd9uG8A
         B5cO7pT0XZc1tZyhqeK+02diRyHY+Mais+a2LGN4DyADrhq7/fduoEhgqeb0cuXB5ec2
         iJ6Jglai+20896Xm/FH4DdC0oT8JABvpi3lQQxqo8V8irOycSg8eiQELcTWBiR8IJXIi
         9gEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of gael.portay@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=gael.portay@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id g14si29939362wrw.285.2019.01.03.13.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 Jan 2019 13:56:23 -0800 (PST)
Received-SPF: pass (google.com: domain of gael.portay@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) client-ip=2a00:1098:0:82:1000:25:2eeb:e3e3;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of gael.portay@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=gael.portay@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from [127.0.0.1] (localhost [127.0.0.1])
	(Authenticated sender: gportay)
	with ESMTPSA id CE9EE27DE42
Date: Thu, 3 Jan 2019 16:56:24 -0500
From: =?utf-8?B?R2HDq2w=?= PORTAY <gael.portay@collabora.com>
To: Laura Abbott <labbott@redhat.com>
Cc: Alan Stern <stern@rowland.harvard.edu>, linux-mm@kvack.org,
	usb-storage@lists.one-eyed-alien.net
Subject: Re: [usb-storage] Re: cma: deadlock using usb-storage and fs
Message-ID: <20190103215624.d5ofgpoajq7hu3ob@archlinux.localdomain>
References: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
 <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
 <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
 <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
 <20190103185452.pwsl7xsf4cp4curz@archlinux.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190103185452.pwsl7xsf4cp4curz@archlinux.localdomain>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000009, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103215624.jbsDJZdiuQrl08avxj95hvrZcC7xgQUDKADuzT_GB5c@z>

Laura,

On Thu, Jan 03, 2019 at 01:54:52PM -0500, Gaël PORTAY wrote:
>
> I thought it was not working until I decided to give it a retry today...
> and it works!
> 

Sorry, I figured out that my hack is totally wrong. So forget it.

Regards,
Gael


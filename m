Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AC4DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 08:03:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63596222A1
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 08:03:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63596222A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD8618E0002; Thu, 14 Feb 2019 03:03:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAF698E0001; Thu, 14 Feb 2019 03:03:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC5498E0002; Thu, 14 Feb 2019 03:03:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC218E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 03:03:14 -0500 (EST)
Received: by mail-vk1-f198.google.com with SMTP id x85so2210343vkx.2
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 00:03:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=NF+3L53BNvZkogBeIQvWy8YJNldDSZkGj555Q/LewKU=;
        b=FubOabZvqGBeYLOcp8Wb09qd3CT7WaOSUct6D8wysvqFe1WLyu4Hpkvg2Vxk5ULdoT
         RowF+6oIaHJmKB9MstNtne+AUkG66Oh9Tk7ZLebEdbRtxtB77crKNB58lTQw+1x57T+D
         UeO2nhCrZJp+ymchdu1HwLpVfdEcntxKBlHTP+gz0JJfyZKkv3V5rh+aLC4CyS+LSHOv
         KloXAoexG52ySFMT9hMCiQ/95JeeT/cE/cIQlCbmU+dIO40+LA3CxJ/HVn2Q7c7K/eLk
         hiP9S27a+Vmj3BW8Rl+uLPKlcNdtqzYuwYjNxjM0J4FOEQe5YhvND0F7mr5ku+T+CBJe
         02kA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Gm-Message-State: AHQUAuZteYyPPNNNKHcqZlL4DgEpfrguZrLIwkeq7IPHxT33RvgDEaYb
	RDseSKJW/yq6sHDjswtZanUaphyOtcmJQOok8AlLG2oFXkGal8cGdicUoqoO1jhsjVwrmG2ffBz
	4WWJFmmT7QW1NTWmApkBqNryb9f36oo+bdMukPlifOj05MtDBjLsBiC8x5QjM6KaMOFQ69UR7JZ
	lEejhnD6J2qt7ZbonIA6660BucLpV7UL2CilxMcqXVBodc7DBaF8bbRrvd4bZH0XbKgnPheYKKg
	9aNdg+l4Gv8XlRFpq2L2UGy2s1RZjq2mFTOH6/5cqejjmJUGr/lzZFwXdgwYSMpUUaXXrysbvuu
	UuPv8WZzY320eK5KmvxC8DFmJPOYuQMHxcG34845UCp0/AHyHIHgMdi6yjS0CAKLQjohhx8RXg=
	=
X-Received: by 2002:a1f:5742:: with SMTP id l63mr1224365vkb.85.1550131394319;
        Thu, 14 Feb 2019 00:03:14 -0800 (PST)
X-Received: by 2002:a1f:5742:: with SMTP id l63mr1224341vkb.85.1550131393571;
        Thu, 14 Feb 2019 00:03:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550131393; cv=none;
        d=google.com; s=arc-20160816;
        b=Lo8vG0QES/dL/5qd6wZBPO6T1kz74vyhx0XY9TjT1Ecgf8qcPJOH67Q3Dl09S3pXgE
         WeZRB4qfndVHzitIRbOalmGEMea9wA7wLaYJozUtHkIs5LSPIJRn7Mk0kUR762wTAvuY
         2Kr4DstfcEtGr9/f5PI4r6MtwCPRm2bouh7qSyNZQaqW+vH6TKRfAAYx7P8A9TL0ew3z
         tXWhEmck77/HnFRAkrPWIgVPrrjJtcIu+WP7y22o7Ryzf/R6XD6GTGx0pgRPTpzetJlD
         1MI66Hggs2TCUaNRAMtbAMushBj+odSCfQDjFURGem2gqAbyRDZp6edOBRydj3Y//bOw
         QkqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=NF+3L53BNvZkogBeIQvWy8YJNldDSZkGj555Q/LewKU=;
        b=FtBDOTOxtjkvPtpqWb5YDaouZKEZwhet3IjmJB/tIBCnkTCSFkWOeAxHspDoEZ0Uxm
         vk4oEVk8OYxiHcr65E4yNE3ZNKihCqF+/HL3ElEhpvQRIxijJ/TWN3tkJGT4Qn5k+gmd
         mKWtiEo0ybLISvdT+uSYWrQCva9vuaWSABSgEhE1mbb5tPFf+BnlCnzVHeyzWGYACrYv
         RcfuxbWxoaBa3jlDdIq3y81lvFrLolFWfYjllHTVt/xj7/o8ik8NKnJyo5NdaJAjEH/5
         q4yo+3EARevGaEwCtTWjh9GsP9dJQFAcVQjW+3WQ7e9ErYzOCiZlCFMpFwpjP+2hL08a
         sy0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w4sor1009790uao.21.2019.02.14.00.03.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 00:03:13 -0800 (PST)
Received-SPF: pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Google-Smtp-Source: AHgI3IYuwLbFH4xBoLJND8KWDgiGKKBj02ToPLGU+20FyrmwcFmKg50xLpk/vXNoc6k9cTcyD9Hb8gWxJbpWMgOdiZA=
X-Received: by 2002:a9f:2726:: with SMTP id a35mr1272618uaa.75.1550131393111;
 Thu, 14 Feb 2019 00:03:13 -0800 (PST)
MIME-Version: 1.0
References: <20190213174621.29297-1-hch@lst.de> <20190213174621.29297-8-hch@lst.de>
In-Reply-To: <20190213174621.29297-8-hch@lst.de>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 14 Feb 2019 09:03:01 +0100
Message-ID: <CAMuHMdX0oJeGO90E9O=vVoDjahS5M8Rku+JGD1Tt+t-oKHnPJQ@mail.gmail.com>
Subject: Re: [PATCH 7/8] initramfs: proide a generic free_initrd_mem implementation
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Guan Xuetao <gxt@pku.edu.cn>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux MM <linux-mm@kvack.org>, 
	Linux-Arch <linux-arch@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 12:09 AM Christoph Hellwig <hch@lst.de> wrote:
> For most architectures free_initrd_mem just expands to the same
> free_reserved_area call.  Provide that as a generic implementation
> marked __weak.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

>  arch/m68k/mm/init.c       | 7 -------

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds


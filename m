Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.4 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8041BC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:23:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3ABF82075B
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:23:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pttgxhEn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3ABF82075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC09D8E00DE; Mon, 11 Feb 2019 07:23:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D965E8E00DD; Mon, 11 Feb 2019 07:23:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C86908E00DE; Mon, 11 Feb 2019 07:23:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 71E2E8E00DD
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:23:13 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id e2so1557225wrv.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 04:23:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=eh/TVc3vwawfZK3+n/VsTq2wbskK3TcfJruKTFJ09/8=;
        b=e1LHAovi8v1vncaD81gLnOQwru8Zwai2BSTjBObWnSJW1OcIs47iJKni6G75mvVqIA
         yjl1jxvopWm71j8F+ok8UiGz61LuU3YP6Ec7fQU1FbBtbENODDmhcJgnPSQ9LhTCt2LE
         wP9PCFwvO24jaIQYtMoIb4QsXmdYCshE5lv2KWVMwCppLnf9ZjvkJRsVbFSly0eSKdkS
         Spy9CqUC9Bq+fq0TZLJbuSYR6TdXOkSb48Qaa4yOiCAcprBCyoJAGUNZUxd4gq1iku8z
         1iUF7N5XTHL2vzW1ofVvjA6W1KZPvuJz1VCZ8Esrx5+DZOB8vQIAiWFpp4d2AMNeeNt0
         NkYg==
X-Gm-Message-State: AHQUAuYfIwIPe35hYVNIE95MPl1GPn3tNFbOWDWZhQ1XNL4RqAIjZzVR
	Ho+e/UsIH+BnEYp5w8GxkmeEm9D6Pr/AwwFzB8nxwmhvCSAvALT2TsCbK8BOza9rpMMqjUH0gl/
	HOAVezVZohft9qjVqgspRu+1OwGdgno2FDKATKDK896hdTXj9jrM9cjm+VUytjdDQ/mDr5s6icY
	Z8sDWs9UbydyuRnqhNOt/2vs7CB6gW8q4pgN1UENgPuMI14LhCZM1cB8busbmcxqFry9JcbseaY
	8/9i1VW4wYZr73GZSHAV+CuoDXB2p8R7SxkZQmzsDmGj81rhQLy264TBSwpVUsfyl+jdcCmkupj
	uTJHfw0EhKpbo25W/9YDz29lpWt3Jmk09ile3dkfuOrJ8zvl9NGoI00l63MhrgrJ4+dt/ZvNDA=
	=
X-Received: by 2002:a1c:2547:: with SMTP id l68mr9112017wml.11.1549887793042;
        Mon, 11 Feb 2019 04:23:13 -0800 (PST)
X-Received: by 2002:a1c:2547:: with SMTP id l68mr9111970wml.11.1549887792309;
        Mon, 11 Feb 2019 04:23:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549887792; cv=none;
        d=google.com; s=arc-20160816;
        b=a8/bqdlMY1m0pm0AcbhMx9HY2cSPjg5IelUquv+B4M4TqDlgcX6WxUmxv0T5aIW5gB
         x+A494FjDeP+J7JzBawRecgucZrLkGafbWPDVQT4aDt9bjYXcQ6UnvTNAsvp6m/q7MMd
         2mhj7ZQSjQIpikWcYMHefT0OF7SqHtEdocXFu7/JopC2/4C1MrI1j6dKaYUHkUDBu2EC
         Kj13rRyj3VLalh1EJgnFh2fRTS4C5nI1No9V3tfyzCTsEEWoHrt8asCTSB5GKepkKLP/
         U8CfUl1fHyxgN4Cmha8zOoSu115f4IyraBYicSo+k4gAbJmez0ew8YzmvAHJmAYFHIBL
         w7vQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=eh/TVc3vwawfZK3+n/VsTq2wbskK3TcfJruKTFJ09/8=;
        b=aIfKIgmKKQ3mGYkY1ok1WQtG0Rf87fsIM8Wk072jmFy7IQmglUTswWIKQr+VYmx7eV
         QWSvv+P3VXybjPSUovG6qVyddNG1F4MxWjU4kGMNFmqECx7CDle8TrczEV2GdLW3wEMZ
         sEtgBqBNB/Blh+II47Sw6AXKmwbYHz13Kqr1FK+7uz2ymryw8kZ4U9Zlr9BcTuW6YkaM
         V4bu5AnLaGbcx6+hkw52m+5+jqHRygsRMYI8qZiS4INBf+jzsoBmZaLYzJvsO432BT3Y
         6eE8Lo/ZkFThL104KYa+dfeFnzu+APufz059xSinS9OO1WUkg0epdh/aEmFhFA5KPj8T
         cV/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pttgxhEn;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z64sor5889357wmb.4.2019.02.11.04.23.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 04:23:12 -0800 (PST)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pttgxhEn;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=eh/TVc3vwawfZK3+n/VsTq2wbskK3TcfJruKTFJ09/8=;
        b=pttgxhEn4Fgdm5/rjgnK7Q5icBrpDT/5IkmcFmo/+id09nqF0EnUFG3QcBp+p0hJ1q
         CHRp0tMqAa7HFm1rgwTtDu5C7jtBbacnxRG2ajGAk3ecJ6tOBEGGVrl/eWmQw3dpwWPJ
         iRahTV5rQ0hxUvW0oro06QyuhHjeo04lq10ZAxsSWXA7WZXEtRKqjKbYi/YAQxS7bvih
         1qEaS8d4Ioi6ZaK6kf/RumCXd7aDwdafKGD6h7rUdIW6lWt1sLLNBHqdX0v9EFD2rfPS
         xwiPB+yl+5xS+9g2kydB8Oqu7bGtob9SKjmKRBfjK5ojPfAmVJsMBz3Vc3l6j65zTerv
         Qy1A==
X-Google-Smtp-Source: AHgI3IZnuz6Zul0+8Aj5t56OGC7jOwt9WIlya8vDHbIy8ndFEqguVRTy/W0Vm8nAT0HL8NFcL0vsxQ==
X-Received: by 2002:a05:600c:2147:: with SMTP id v7mr9561541wml.41.1549887791911;
        Mon, 11 Feb 2019 04:23:11 -0800 (PST)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id z3sm15386338wmi.32.2019.02.11.04.23.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 04:23:11 -0800 (PST)
Date: Mon, 11 Feb 2019 13:23:08 +0100
From: Ingo Molnar <mingo@kernel.org>
To: Juergen Gross <jgross@suse.com>
Cc: sstabellini@kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com,
	tglx@linutronix.de
Subject: Re: [Xen-devel] [PATCH v2 1/2] x86: respect memory size limiting via
 mem= parameter
Message-ID: <20190211122308.GA119972@gmail.com>
References: <20190130082233.23840-1-jgross@suse.com>
 <20190130082233.23840-2-jgross@suse.com>
 <20190211120650.GA74879@gmail.com>
 <bd5863a2-291a-43e5-7633-c84c1026a31b@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bd5863a2-291a-43e5-7633-c84c1026a31b@suse.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Juergen Gross <jgross@suse.com> wrote:

> > If PCI devices had physical mmio memory areas above this range, we'd 
> > still expect them to work - the option was really only meant to limit 
> > RAM.
> 
> No, in this case it seems to be real RAM added via PCI. The RAM is 
> initially present in the E820 map, but the "mem=" will remove it from 
> there again. During ACPI scan it is found (again) and will be added via 
> hotplug mechanism, so "mem=" has no effect for that memory.

OK. With that background:

Acked-by: Ingo Molnar <mingo@kernel.org>

I suppose you want this to go upstream via the Xen tree, which is the 
main testcase for the bug to begin with?

Thanks,

	ngo


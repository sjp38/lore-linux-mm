Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68BE0C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 22:31:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CE8D2081B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 22:31:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CE8D2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE3488E0063; Mon,  4 Feb 2019 17:31:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9C3C8E001C; Mon,  4 Feb 2019 17:31:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5B5D8E0063; Mon,  4 Feb 2019 17:31:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 71E948E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 17:31:34 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id x64so1291861ywc.6
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 14:31:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XgmVIz2EDz4KH+I2dNa7InV3AIXUsuAuDfIa1Ztp+LU=;
        b=GOPwKbaKkemu7jbn/vGvHqkLBmmXsdyzUUw5YV8u8hNc/9Utc9iY5jiBtWmEgvpUDB
         eFgy/aWBn4F00zAmZKoYZOvF8/7tLMtYaNhhwBPzuIbBSUwGaMfbwpgu2ZV/OeeBvxfb
         8N0pJRaxfvFiLK089UaxuU6kWzT3mI6fQbYJBn7bc0xFpGdK/VizOyg8obkR7rTJ6XFB
         8NCLsLLnQZgmupTfwoxA2F65ml6rkt5sjrgyAFHWB5MnvJ/3Up3XdJsrCarRZnkw6tn8
         dY2/KBWzWji+vO0XUZZBrk9lKJC+kFGPzi47UbTHvRv1sC8TSr6txZ019NA5pmdUIyTr
         oE3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZyUnEqwjZg6L29ax1uKFkFnoAx0LBQZoqwePPchmW14pSqITrB
	qI1XZvg4feLWhDoCamXB1Uve3st0MEAwNqqasksmurwOJ/7G5cdvDCyLoK5WoxoqXMXgPqIPmvZ
	FMe9HQ8rdYJq7HlYXL3DPfqggpAs47M5/U/ysQy8XnGwccG0nddznQvI76z/9PMG7LdfHBDcXOX
	DvTzSxRtERjnlMAiICsMIpM2+7KU9YooHvkrFw3cAI2t5POyA+Zqyhvai3d0aWkybX/eAQYimO3
	8J+J3CUC3gMbT3LJ3NcqeJwpiBQC8JYgMqeQim5gFXKwiGO2K24CRDtJfUcxUoBhW7bRmq6L4wl
	zusA/gfDk6sdPCtF2Bc/rNyq57+bBTBiP4K3DOUsR1915k0X4DpZNOrNJ54IPx/1Ijb+baEbqw=
	=
X-Received: by 2002:a0d:f7c1:: with SMTP id h184mr1469107ywf.473.1549319494208;
        Mon, 04 Feb 2019 14:31:34 -0800 (PST)
X-Received: by 2002:a0d:f7c1:: with SMTP id h184mr1469083ywf.473.1549319493750;
        Mon, 04 Feb 2019 14:31:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549319493; cv=none;
        d=google.com; s=arc-20160816;
        b=QPfAKJ4dNCXN2vr8qmFoP0KK63BLPCVp7TBpwtMAC6J8AwkPYBRF0JRZ7e4LOFlG05
         2xtfuNjaRw5YZ21eakYtUmg3EipEU/Qd2U+XPFsn28fHhtx8yfd8CpfPyNyRrC+VUGzc
         4OhfK3kDdTaRajA9sBv6nZSLMXq1DWK8iU5/01WIv4fbM9IIWUObN2ottF6J/yyeoZSB
         9e382E5uOsIQwccTYnA836IkxZ+J5e44909UPzOW2lMGDVNRSKiTeqw7dG6Eh3QcRGCt
         CuOi+w127P/1UhRRvH5JVf1zDwOhvtvXUB5eFoj0lkcaQWFs4Ec71uJJBNXHBcpfROlQ
         /qOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XgmVIz2EDz4KH+I2dNa7InV3AIXUsuAuDfIa1Ztp+LU=;
        b=HrEP8qXlSnLS1TEBiInQoa+BM1gusuxnVFP4K9fYJ/7Qjz/kfU8VrgzBBajGtlnZpO
         2BbpaylTGaBWeSlLtAGiKCb0/eZh8QHvpKT7Z6J/QZIYahHN8ST7qGlKI4efOBzxoggC
         Eh2mr30+u4dnG/47kqP/T6eiiHvflYPNlRHXnyKPldh8eyWm9UDFbHF2DQSPvHrS5ynj
         qBViVO7y9pe1Lnxd37UDm93bcyU8rlUKKRTl14Ifef2tv6uBXP5u3m3DPODP9SV39kbZ
         yx/KeefMIFJ4u0jI1+stwUej3HxgEk/7prRUwZbXm7ryiqUAfFBSRzYH4Deu97N1KIS1
         rwjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o17sor640490ybj.198.2019.02.04.14.31.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 14:31:33 -0800 (PST)
Received-SPF: pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IaGtjxjCx24VN1GfDKJS3LM3t0K8xjiEXGakYlCt/nHmX1FEb2AZ6giwBbuKR8d1ABddMjVRA==
X-Received: by 2002:a25:b1a6:: with SMTP id h38mr1470469ybj.58.1549319493408;
        Mon, 04 Feb 2019 14:31:33 -0800 (PST)
Received: from garbanzo.do-not-panic.com (c-73-71-40-85.hsd1.ca.comcast.net. [73.71.40.85])
        by smtp.gmail.com with ESMTPSA id y2sm1837098ywy.107.2019.02.04.14.31.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 14:31:32 -0800 (PST)
Received: by garbanzo.do-not-panic.com (sSMTP sendmail emulation); Mon, 04 Feb 2019 14:31:27 -0800
Date: Mon, 4 Feb 2019 14:31:27 -0800
From: Luis Chamberlain <mcgrof@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, linux-doc@vger.kernel.org,
	Kees Cook <keescook@chromium.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jan Kara <jack@suse.cz>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@kernel.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Larry Woodman <lwoodman@redhat.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	"Wangkai (Kevin C)" <wangkai86@huawei.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND PATCH v4 3/3] fs/dcache: Track & report number of
 negative dentries
Message-ID: <20190204223127.GS11489@garbanzo.do-not-panic.com>
References: <1548874358-6189-1-git-send-email-longman@redhat.com>
 <1548874358-6189-4-git-send-email-longman@redhat.com>
 <20190204222339.GQ11489@garbanzo.do-not-panic.com>
 <cef8c6ab-6aaf-cca2-1e94-e90c2278afaa@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cef8c6ab-6aaf-cca2-1e94-e90c2278afaa@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 05:28:00PM -0500, Waiman Long wrote:
> On 02/04/2019 05:23 PM, Luis Chamberlain wrote:
> > Small nit below.
> >
> > On Wed, Jan 30, 2019 at 01:52:38PM -0500, Waiman Long wrote:
> >> diff --git a/Documentation/sysctl/fs.txt b/Documentation/sysctl/fs.txt
> >>  
> >> +nr_negative shows the number of unused dentries that are also
> >> +negative dentries which do not mapped to actual files.
> >                      which are not mapped to actual files
> >
> > Is that what you meant?
> >
> >   Luis
> 
> Sorry for the grammatical error. Maybe I should send a patch to fix that.

If its already merged sure. Otherwise I don't care.

  Luis


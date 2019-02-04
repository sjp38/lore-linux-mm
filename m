Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FC50C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 22:28:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5058F2081B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 22:28:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5058F2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E57798E0062; Mon,  4 Feb 2019 17:28:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E06E88E001C; Mon,  4 Feb 2019 17:28:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCFEC8E0062; Mon,  4 Feb 2019 17:28:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A39ED8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 17:28:05 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id p24so1673090qtl.2
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 14:28:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=4pRIVYS03Cpus6A0KkLdX5eS6ZWkQRNTKgzu/m+V1gs=;
        b=YUKy4j3GbQjpPU9/d4cnHpUjkC7HGXHmPObTmttqRqj1fby18ZWJx56hFI9FR+htf2
         yivRhHMz67BgbCDgPplIts5s8XKbsUXx2yuSxWOtUjLyU2bta5ebl2h4aSK+W5op+s+i
         44QfGfmhbiSLwh6N3MoTntr8qC274bT+f+fmxzalXZEXgfrPlPOJLu19MicJ/cJESfYm
         MnXdrOFO42iX79+kbbGmi8gvABr79LPIJnsYZr2NSHNB/TkJqNu5RGWGcoO+b+4iAi6M
         FmC7YPXh0OUC6LYrusBy5b5CHm8GnnpMIOZU5yGF6ppB869VRCyHVzYNozRFGrC2R09z
         wFgA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaiSXqHlCwpm4NISyyN6Xf1UuJe5yUpXV5Mzq8pzpA+iF6DlUmM
	MfS9A8/usCCYa1UjOL2KU2hczBS5f+XpfFlkklCo8b7NDkHwPu5NAtWCa5i5V05smTCqWIoC2GP
	hZrIMkylZIf+tDH1tb/iYbI1kBh81OkIdrgHUTxLbdwlGlIwPHmhgmx3IqxcV9du5OA==
X-Received: by 2002:a0c:ec92:: with SMTP id u18mr1337201qvo.168.1549319285478;
        Mon, 04 Feb 2019 14:28:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib9Ptu5iuh/JNYIeB//hAwBVPksgu2alqjJaLwR/xivhngbZh0kKyVBCEApjESVEosQtPAE
X-Received: by 2002:a0c:ec92:: with SMTP id u18mr1337185qvo.168.1549319285087;
        Mon, 04 Feb 2019 14:28:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549319285; cv=none;
        d=google.com; s=arc-20160816;
        b=dFZex00Zm+ipmXnAYSHSCh3FqkJXfv+FJ/QJurDOSCvzzAqLV67tGlF54tu8gw6/q2
         fQ4LaIctO0hXNmDgKAPi33LhFqj3ILxv4Ou8OOgxWEk5tWryJlAZPDOAX4m5HzNHT0Ye
         zbYPhb/Vwc1cLnDZniduuqyv9jkE0do2fD5ZnzOUAYf3hjA3CscnlAnrcHDUrANxTOqm
         WJqIoXrPFnu3tzpMGzg2qv4USC+W7jADIO3MFDn8+Y4QvmugJX8Nu+o//H4afXmPrQgM
         B1xi/pRCWCf7YZR7CncQAdaCW3+Lmnp9peILt9Ch8okLusi/DNBjmIWiRMGJbNJ7BZHa
         pn5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=4pRIVYS03Cpus6A0KkLdX5eS6ZWkQRNTKgzu/m+V1gs=;
        b=tETuGlPoPrrurzm99MD9Ha5UUB4v21Lh8zI0okQOp4Zv5EJhtgtLjON2D2/ETfM86x
         1nMtQm8E523GdBK/67sCS9he04bWwzR2YkEw0Jpiz/YLFYcxG5PgcG5fplttBk6AqVDt
         bKMF3TqMgtv9oGYml94UMxe0iyUmggKpuSbUnkTy/z2pPm1f2CFvnCt4gC19NWdGK9pU
         i6P4w0xcZivgt3s5UKSd4hnkksQ55MSFy0Rz24zv2mJ+PeAxo7Ry89XD+lrfpFdPpE2V
         ag8wvCCrJebLXzLHSnocAFdcmL5DpJaostto351G2zzngp6PzqFqr2hftA6rCxcF8PJ+
         0CaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y13si5061581qti.151.2019.02.04.14.28.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 14:28:05 -0800 (PST)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A6F8C13D726;
	Mon,  4 Feb 2019 22:28:03 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-91.bos.redhat.com [10.18.17.91])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DDA1076FEC;
	Mon,  4 Feb 2019 22:28:00 +0000 (UTC)
Subject: Re: [RESEND PATCH v4 3/3] fs/dcache: Track & report number of
 negative dentries
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet
 <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-doc@vger.kernel.org,
 Kees Cook <keescook@chromium.org>,
 Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
 Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>,
 Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>,
 James Bottomley <James.Bottomley@HansenPartnership.com>,
 "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>
References: <1548874358-6189-1-git-send-email-longman@redhat.com>
 <1548874358-6189-4-git-send-email-longman@redhat.com>
 <20190204222339.GQ11489@garbanzo.do-not-panic.com>
From: Waiman Long <longman@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=longman@redhat.com; prefer-encrypt=mutual; keydata=
 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
 weim8xU=
Organization: Red Hat
Message-ID: <cef8c6ab-6aaf-cca2-1e94-e90c2278afaa@redhat.com>
Date: Mon, 4 Feb 2019 17:28:00 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190204222339.GQ11489@garbanzo.do-not-panic.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 04 Feb 2019 22:28:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/04/2019 05:23 PM, Luis Chamberlain wrote:
> Small nit below.
>
> On Wed, Jan 30, 2019 at 01:52:38PM -0500, Waiman Long wrote:
>> diff --git a/Documentation/sysctl/fs.txt b/Documentation/sysctl/fs.txt
>>  
>> +nr_negative shows the number of unused dentries that are also
>> +negative dentries which do not mapped to actual files.
>                      which are not mapped to actual files
>
> Is that what you meant?
>
>   Luis

Sorry for the grammatical error. Maybe I should send a patch to fix that.

Thanks,
Longman


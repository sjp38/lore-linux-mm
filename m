Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 37A968E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 12:30:17 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y2so1836312plr.8
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 09:30:17 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u28si18835904pgn.436.2018.12.20.09.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 09:30:16 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBKHTHAb048545
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 12:30:15 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pgffrg5e1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 12:30:15 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.ibm.com>;
	Thu, 20 Dec 2018 17:30:14 -0000
References: <20181219213338.26619-1-igor.stoppa@huawei.com> <20181219213338.26619-12-igor.stoppa@huawei.com>
From: Thiago Jung Bauermann <bauerman@linux.ibm.com>
Subject: Re: [PATCH 11/12] IMA: turn ima_policy_flags into __wr_after_init
In-reply-to: <20181219213338.26619-12-igor.stoppa@huawei.com>
Date: Thu, 20 Dec 2018 15:30:01 -0200
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87pntwumw6.fsf@morokweng.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Hello Igor,

Igor Stoppa <igor.stoppa@gmail.com> writes:

> diff --git a/security/integrity/ima/ima_init.c b/security/integrity/ima/ima_init.c
> index 59d834219cd6..5f4e13e671bf 100644
> --- a/security/integrity/ima/ima_init.c
> +++ b/security/integrity/ima/ima_init.c
> @@ -21,6 +21,7 @@
>  #include <linux/scatterlist.h>
>  #include <linux/slab.h>
>  #include <linux/err.h>
> +#include <linux/prmem.h>
>
>  #include "ima.h"
>
> @@ -98,9 +99,9 @@ void __init ima_load_x509(void)
>  {
>  	int unset_flags = ima_policy_flag & IMA_APPRAISE;
>
> -	ima_policy_flag &= ~unset_flags;
> +	wr_assign(ima_policy_flag, ima_policy_flag & ~unset_flags);
>  	integrity_load_x509(INTEGRITY_KEYRING_IMA, CONFIG_IMA_X509_PATH);
> -	ima_policy_flag |= unset_flags;
> +	wr_assign(ima_policy_flag, ima_policy_flag | unset_flags);
>  }
>  #endif

In the cover letter, you said:

> As the name implies, the write protection kicks in only after init()
> is completed; before that moment, the data is modifiable in the usual
> way.

Given that, is it still necessary or useful to use wr_assign() in a
function marked with __init?

--
Thiago Jung Bauermann
IBM Linux Technology Center

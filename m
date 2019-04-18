Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03ECDC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:10:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA88820693
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:10:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA88820693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 668686B0007; Thu, 18 Apr 2019 18:10:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63D646B0008; Thu, 18 Apr 2019 18:10:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DF096B000A; Thu, 18 Apr 2019 18:10:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBE16B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 18:10:36 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 3so2239505ple.19
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:10:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bVRrs7liWCvLKU0L8L2fkE3OSuOowOViHuRcXFqIZ5E=;
        b=C8/vOeHxpX1k5qc7hO0LUhk0SNLOvSc0M+PnbL6S10Z6SclJushsRHe3CfXRTI5I87
         Svgi0juou2wRyZDeSOntyPDKxKzPCCVYRC/GJs+H6x5KBajlZ6mTWTqk59dDYd2WgRnT
         WWWIhfry3GqT41YKQGWKyfnMoAMDCFCw8AR+IXKZMcvwqkEQ40egAm79yCnovtbAUnBW
         V651b2L0cL6fh/4VFhPcODE+KjSQEa/ysAhcdY5EAiIO1iH+Dnp05WYt3L49gT+YluIA
         14xreEhUQjK26qajRnLH8pbnIAGuZT/TOQGSGpDErJJ+DujqYvxT66WQ1pQLTl+K5Nex
         /tpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAXAldOACJZmCayw62HUFVGXup3IZ4ZPwSUxYvlIfvyJKHDbSl3T
	zyHZA9qHi9Rc+F5XCbCsxjhi79G/T755RkIWAj5arC7WfMF1rjLVIMUHLVd+UJ+sQFko+DRPsD5
	uELGh/MAJZTJZhvDsZ/JnZhlwBermI6PApFxrXXS67kQ24mBJ0ACGcMMkTN79gt0gYA==
X-Received: by 2002:a63:2015:: with SMTP id g21mr353434pgg.226.1555625435679;
        Thu, 18 Apr 2019 15:10:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4IeeFLMMEbRLhFcR6ABdFe/Rvo78I7yZZkfCv+4Py05oT9ofZ0jZkDtoGU/EWXksq2oqP
X-Received: by 2002:a63:2015:: with SMTP id g21mr353369pgg.226.1555625434907;
        Thu, 18 Apr 2019 15:10:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555625434; cv=none;
        d=google.com; s=arc-20160816;
        b=YXw/qyo4Mlgc41WAxWNK6/tMx542pQfAf78L3HrP6PjEMdulbFBv/EU1Klr0dqPR0T
         f7qroWaEB8+2XnuK8XxcEP8jrUJCNpJ7j3EMrSSY+Z3zaxJDGnYeG3QlkkgcyZKmxGpJ
         FhQ3JQkYe/LPFRiI/0ZLRx3dW/ZaIhceVWZju8dXpLxUuiHTrBCw/td3Pr/+6FBwMm+4
         IYy69urkH1HwPSm3whv2xI0+yn4JokIQ0RklzqjWQq42e1DErvDRhqY+QmZgyPuZY/eV
         fSipmiSnNsnj4g4ud9uOBKVcYUJNRtJiHe8Z3qGLbSNAviFQLhdqMZTFq0V8zxRHHMyN
         eZOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=bVRrs7liWCvLKU0L8L2fkE3OSuOowOViHuRcXFqIZ5E=;
        b=uzpbWWiPa2OIwKqgFk1LkIGrRpCmV9AbRNUCKGOi51XXe2N5CkzJY+MU+UHySEuTij
         ixovi3yvv7yJdUvYQNWoxFy9W/W8tQwaGMHbe8tmzL1Cj7pYq4kPRmrMsI2wrBHrFHpX
         LXKSYvsZ4CN7vZACaQJKyKFlaSikE7oYZA+7YqzhZWQOEpwOvqve3jcdGL4GwsQ/L6tD
         7J7bfq34KKCPOfKqwFBb+INawEFb8Hotu8BYt33iJm77isCpexLeYvdVAAf76YYBuK5u
         J44kW+JBCyXjUMP/UXEyp4p2wFVmuVUDflCeajn+1jJOm6zPPXT6PGWgUbqPNz4wyrwk
         iWdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d2si3842306pfm.253.2019.04.18.15.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 15:10:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 3A1091C54;
	Thu, 18 Apr 2019 22:10:34 +0000 (UTC)
Date: Thu, 18 Apr 2019 15:10:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Matthew
 Wilcox <willy@infradead.org>, linux-mm@kvack.org, LKML
 <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>,
 Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt
 <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo
 <tj@kernel.org>
Subject: Re: [PATCH 1/1] lib/test_vmalloc: do not create cpumask_t variable
 on stack
Message-Id: <20190418151033.9e46ec06c1d7482e6dee14bc@linux-foundation.org>
In-Reply-To: <20190418193925.9361-1-urezki@gmail.com>
References: <20190418193925.9361-1-urezki@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019 21:39:25 +0200 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:

> On my "Intel(R) Xeon(R) W-2135 CPU @ 3.70GHz" system(12 CPUs)
> i get the warning from the compiler about frame size:
> 
> <snip>
> warning: the frame size of 1096 bytes is larger than 1024 bytes
> [-Wframe-larger-than=]
> <snip>
> 
> the size of cpumask_t depends on number of CPUs, therefore just
> make use of cpumask_of() in set_cpus_allowed_ptr() as a second
> argument.
> 
> ...
L
> --- a/lib/test_vmalloc.c
> +++ b/lib/test_vmalloc.c
> @@ -383,14 +383,14 @@ static void shuffle_array(int *arr, int n)
>  static int test_func(void *private)
>  {
>  	struct test_driver *t = private;
> -	cpumask_t newmask = CPU_MASK_NONE;
>  	int random_array[ARRAY_SIZE(test_case_array)];
>  	int index, i, j, ret;
>  	ktime_t kt;
>  	u64 delta;
>  
> -	cpumask_set_cpu(t->cpu, &newmask);
> -	set_cpus_allowed_ptr(current, &newmask);
> +	ret = set_cpus_allowed_ptr(current, cpumask_of(t->cpu));
> +	if (ret < 0)
> +		pr_err("Failed to set affinity to %d CPU\n", t->cpu);
>  
>  	for (i = 0; i < ARRAY_SIZE(test_case_array); i++)
>  		random_array[i] = i;

lgtm.

While we're in there...


From: Andrew Morton <akpm@linux-foundation.org>
Subject: lib/test_vmalloc.c:test_func(): eliminate local `ret'

Local 'ret' is unneeded and was poorly named: the variable `ret' generally
means the "the value which this function will return".

Cc: Roman Gushchin <guro@fb.com>
Cc: Uladzislau Rezki <urezki@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Thomas Garnier <thgarnie@google.com>
Cc: Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Joel Fernandes <joelaf@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 lib/test_vmalloc.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

--- a/lib/test_vmalloc.c~a
+++ a/lib/test_vmalloc.c
@@ -384,12 +384,11 @@ static int test_func(void *private)
 {
 	struct test_driver *t = private;
 	int random_array[ARRAY_SIZE(test_case_array)];
-	int index, i, j, ret;
+	int index, i, j;
 	ktime_t kt;
 	u64 delta;
 
-	ret = set_cpus_allowed_ptr(current, cpumask_of(t->cpu));
-	if (ret < 0)
+	if (set_cpus_allowed_ptr(current, cpumask_of(t->cpu)) < 0)
 		pr_err("Failed to set affinity to %d CPU\n", t->cpu);
 
 	for (i = 0; i < ARRAY_SIZE(test_case_array); i++)
@@ -415,8 +414,7 @@ static int test_func(void *private)
 
 		kt = ktime_get();
 		for (j = 0; j < test_repeat_count; j++) {
-			ret = test_case_array[index].test_func();
-			if (!ret)
+			if (!test_case_array[index].test_func())
 				per_cpu_test_data[t->cpu][index].test_passed++;
 			else
 				per_cpu_test_data[t->cpu][index].test_failed++;
_


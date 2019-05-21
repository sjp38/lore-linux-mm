Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F837C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:14:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D94821743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:14:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D94821743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D26226B0003; Tue, 21 May 2019 00:14:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD6386B0005; Tue, 21 May 2019 00:14:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEBB06B0006; Tue, 21 May 2019 00:14:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DAB46B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:14:30 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id p4so14492052qkj.17
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:14:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=fQ7aQmhE8+dRZtKkpkNL7qpCKQOKXf/QHauGKs6H4lU=;
        b=HiIRN0XWJEFdXDukgprJgrfxbskVqliZq+yWZrBoBzJvobHM/QIzfCTWnDCOgZMa6V
         c0fJ4y4Fr1Qx+RjiaGIz0RE5RY7XqEBO02lSwyO39bDOCsRoanMNgXcNZ2l8JGILC68A
         zS1am2c4hm0+nfsE0QOdarOBVkF9y8v6LqPO6JmtcnHnJeYNfYOunc7efGhJce7S2Urm
         h3pkHHc62Vg0xWXf/pCEm4qct4Q+zHo/u5Rv332iNh4wopFxbFhg7JF9UZTOciZOnenn
         m5PbDe3bPVWVRYk0ymJNi4T5ETAQl3KaabnZNuAoLuT2LAIbABVzHzoHbC9+V0PjOyFz
         lm1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUCPsnoGukSzQHWs3FgYw7+cCI78ZDjn70qS8KJH9tEzpMvdm3K
	W7jlV/ehjcV8qDmh+TrORkjv7gp27Uz60wjaSlgtvjf9XAxxQpJ1txeZwoIhT2jm/lq9kZf2r3Q
	vWo0DpNjWJmtq5wxzl6b+hexStgWe816XFMpfQ7QEXdKBL/ooQAtp454T3cu7u2QyVw==
X-Received: by 2002:ac8:31a4:: with SMTP id h33mr67280072qte.5.1558412070388;
        Mon, 20 May 2019 21:14:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx94iKZ6sDKWB36M+lhNLVx0KptegtafYpsWiLK2dYyqECtBUmC7kj2XQxn6RrEl2qgB/M0
X-Received: by 2002:ac8:31a4:: with SMTP id h33mr67280033qte.5.1558412069700;
        Mon, 20 May 2019 21:14:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558412069; cv=none;
        d=google.com; s=arc-20160816;
        b=YnXQhbj/LzQ2iH+3jvOu5liTT+eIbkyreW78dlJMkAgf6TFlVncvz0Bu9EEMRefG2e
         i0uA45Z8saG3HjtWxsU6jqCl9d0koi/G5B90+tmOZcFARI39hiCN6KF38Hz0pZQyrOPk
         RQgKWvLKLRSrwHTBA7/H13ofb+9f0/uTL5rNLhluLB5KDu+g3x/D763QVYCElWhSEHxa
         DGt7vFzv2Qw5nIelHAoK3NrqUBrQ5uzSERSbVk/l2rdWvahVk1Xrr9UOZbxy+C6DDnFd
         B8EoKtVtLvejQq/ra/F0u3QMs/jtkVXc9nIFuTcBdd2QohmKU1iT1lw8rPME0QE0fkzd
         GFiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=fQ7aQmhE8+dRZtKkpkNL7qpCKQOKXf/QHauGKs6H4lU=;
        b=yasYuj2XF5Fv31g4m2/hfgk5F46xxMwg8mP1q31LJGKC5bkOpui54OTGsdLGqSpez1
         zxrklu2IYLBmzBw8WD/wuH+jOLws3K1hoI7P4Mxh0qA5hr+AfedpCFKcMzRhHJPPNf4m
         m0kIIEETBRNPcrrxuUNOBluHfJEsRfTVVT/A8lvaZcnxpea0KLBK8b19FiqXDV61kvSq
         altCGn2uLUptvHLT4qQYCFBEBkMK8RFjy7cGE9kmQB7iTVJKkCgaFKL5qaUEXDr388Y1
         BqMuSOFKf3ffciC2PvZ3QLb79RNVk64KaK9WyGTwqyjOgFGTzAifq8BYIKDbbTbLvNrR
         Ngug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g15si638539qkl.100.2019.05.20.21.14.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:14:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CCFDDC057E65;
	Tue, 21 May 2019 04:14:28 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C0245600C6;
	Tue, 21 May 2019 04:14:28 +0000 (UTC)
Received: from zmail21.collab.prod.int.phx2.redhat.com (zmail21.collab.prod.int.phx2.redhat.com [10.5.83.24])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id B2B924A460;
	Tue, 21 May 2019 04:14:28 +0000 (UTC)
Date: Tue, 21 May 2019 00:14:28 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
To: Jane Chu <jane.chu@oracle.com>
Cc: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	linux-nvdimm@lists.01.org
Message-ID: <255137178.29997735.1558412068338.JavaMail.zimbra@redhat.com>
In-Reply-To: <1558403523-22079-1-git-send-email-jane.chu@oracle.com>
References: <1558403523-22079-1-git-send-email-jane.chu@oracle.com>
Subject: Re: [PATCH v2] mm, memory-failure: clarify error message
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.67.116.97, 10.4.195.29]
Thread-Topic: mm, memory-failure: clarify error message
Thread-Index: 1DbEf0kdw7K8egROywjW6H/tEghkdQ==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 21 May 2019 04:14:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> Some user who install SIGBUS handler that does longjmp out
> therefore keeping the process alive is confused by the error
> message
>   "[188988.765862] Memory failure: 0x1840200: Killing
>    cellsrv:33395 due to hardware memory corruption"
> Slightly modify the error message to improve clarity.
> 
> Signed-off-by: Jane Chu <jane.chu@oracle.com>
> ---
>  mm/memory-failure.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index fc8b517..c4f4bcd 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -216,7 +216,7 @@ static int kill_proc(struct to_kill *tk, unsigned long
> pfn, int flags)
>          short addr_lsb = tk->size_shift;
>          int ret;
>  
> -        pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory
> corruption\n",
> +        pr_err("Memory failure: %#lx: Sending SIGBUS to %s:%d due to hardware
> memory corruption\n",
>                  pfn, t->comm, t->pid);
>  
>          if ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm) {
> --
> 1.8.3.1

This error message is helpful.

Acked-by: Pankaj Gupta <pagupta@redhat.com>

> 
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm
> 


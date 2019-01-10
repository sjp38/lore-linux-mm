Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A913CC43612
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 15:03:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7279D214DA
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 15:03:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7279D214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F37AD8E0003; Thu, 10 Jan 2019 10:03:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE5E38E0001; Thu, 10 Jan 2019 10:03:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD5688E0003; Thu, 10 Jan 2019 10:03:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B005E8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 10:03:47 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id q3so10969122qtq.15
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 07:03:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=PDR/bdrTz3E2jzVYZSQ/dSwPEl49mCFxhnqppZN6Coc=;
        b=HzWcqGVDz3QJ2k5gIO5yarO3HCsHOG7761JyQ3SGmHeHaaJU4bYDk4YZlyDn+0OdzP
         v51h4b0iaj4+yCQaEiwHhSK23J2jmpHAIHQ8OehRLu9F9GUL8vQrBgOVBLdRCkLWay1t
         iD4Hv9mfl5NB4cRLl6DItbn3WIRrsCVMJ7tKIfRzKy+3maYhtC9xR3dJ85DYsWG5Bhqm
         JOjSVYjsp7akNPyrZJhDaAdmFnp86XIbtF30XNVQHBh76JkMoUkAZenhCBpqa2Ii4AhB
         OstLDpfvaVmYMHgR7K2DF1dzmezfgpsA/QwqsqEsgMOjWLeIbr3nThs9USx9xcsTDIE3
         4qdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdrYZFjRIGkruSQVHtRHJE/SC0mWeKqj4robESGIZqurxMlAp0n
	lKDCWUywalJiLQwk5N5ddF8T4GTOLlYcTLXs7EqpvhXTeE2e/1NSQbERRT3NID/J1kS4sMQTu0X
	dU9+lNx9le/bDWjtu2Ek7CkpugwVJXkmH2gyhmxpoZY6OvbKyxUFoZPscrfmzO3isjQ==
X-Received: by 2002:a0c:a086:: with SMTP id c6mr9716236qva.154.1547132627483;
        Thu, 10 Jan 2019 07:03:47 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5i9Vs8xJhweEJZnkfdzzA+s2KTLXuvpapKLiFdLZdkOC6akPItKHRQ8CkYLGt4zd4aHjL+
X-Received: by 2002:a0c:a086:: with SMTP id c6mr9716168qva.154.1547132626694;
        Thu, 10 Jan 2019 07:03:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547132626; cv=none;
        d=google.com; s=arc-20160816;
        b=0c800yBXal6JjVGMjPkZ9fb25dHarnCCzhAN8NOI/IxtLG0Lh4ysy6s2s1z3Da7Dez
         MNf4XVLG6oXiYMYwG1jiEuMnHZ4FPa/dJMdnpYWcAV2uE5+Zif3IU0fmuDyz5KjXFFQH
         BVSbIh+usKhjk7Iii+GSuzp2wO4WRPBBYJUzMJBzUEuEtOjWrEwfzkk+9wuLcsZNipzD
         cvn75xK6xQaUrnaEp3wA1Bp2QWQ7OyXoiWHmhutc/++a1W8+A61kf7IfUECMubBFOe23
         vLbGe0hETsJnEQGoRxLe90uvBhr3u/cJeEld4etAStdwfk99sooTPv//E5hVMPZ4P7nH
         Zssg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=PDR/bdrTz3E2jzVYZSQ/dSwPEl49mCFxhnqppZN6Coc=;
        b=rhhBKP/Guk01/YvU83y5miS+t7BRrMx5mu1J1wWXDYOMdKC411nwwSXmpE4vISPve3
         GnXMRHc14GtIObAljsKW114WgX3QyC3958PYWXJGhkutviTyXcayvVAbBu8rcf4MrokI
         i7DVGt5pqfPyLHaDFC75EHhrdrTyjHJ4PB77s4pdzhA1zN3qxCFjV8S45sNsr8R9mxcU
         RzYp+1LyZeZJ05W0jEBMVL9Vz3htenK3OecHrUmOiPwEBli8qxWp2QuDFqjTRl9vGdm8
         QcTznIH9L5HSBkkkOOaPI8alJs2hmkkhNuI6IdyW1PMKyd/PROP9vMD/HZKfbmEfIEXs
         ws1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q45si3998217qte.344.2019.01.10.07.03.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 07:03:46 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C16CD2CD7FE;
	Thu, 10 Jan 2019 15:03:45 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.215])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 18A727F1A2;
	Thu, 10 Jan 2019 15:03:45 +0000 (UTC)
Date: Thu, 10 Jan 2019 10:03:43 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hmm: Convert to use vm_fault_t
Message-ID: <20190110150343.GA4394@redhat.com>
References: <20190110145900.GA1317@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190110145900.GA1317@jordon-HP-15-Notebook-PC>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 10 Jan 2019 15:03:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110150343.ICj-PXHoinhOLy1qGtNlX6N6mRjVG_4QOZMtP7j60KA@z>

On Thu, Jan 10, 2019 at 08:29:00PM +0530, Souptick Joarder wrote:
> convert to use vm_fault_t type as return type for
> fault handler.
> 
> kbuild reported warning during testing of
> *mm-create-the-new-vm_fault_t-type.patch* available in below link -
> https://patchwork.kernel.org/patch/10752741/
> 
> [auto build test WARNING on linus/master]
> [also build test WARNING on v5.0-rc1 next-20190109]
> [if your patch is applied to the wrong git tree, please drop us a note
> to help improve the system]
> 
> kernel/memremap.c:46:34: warning: incorrect type in return expression
>                          (different base types)
> kernel/memremap.c:46:34: expected restricted vm_fault_t
> kernel/memremap.c:46:34: got int
> 
> This patch has fixed the warnings and also hmm_devmem_fault() is
> converted to return vm_fault_t to avoid further warnings.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/linux/hmm.h | 4 ++--
>  mm/hmm.c            | 2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 66f9ebb..ad50b7b 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -468,7 +468,7 @@ struct hmm_devmem_ops {
>  	 * Note that mmap semaphore is held in read mode at least when this
>  	 * callback occurs, hence the vma is valid upon callback entry.
>  	 */
> -	int (*fault)(struct hmm_devmem *devmem,
> +	vm_fault_t (*fault)(struct hmm_devmem *devmem,
>  		     struct vm_area_struct *vma,
>  		     unsigned long addr,
>  		     const struct page *page,
> @@ -511,7 +511,7 @@ struct hmm_devmem_ops {
>   * chunk, as an optimization. It must, however, prioritize the faulting address
>   * over all the others.
>   */
> -typedef int (*dev_page_fault_t)(struct vm_area_struct *vma,
> +typedef vm_fault_t (*dev_page_fault_t)(struct vm_area_struct *vma,
>  				unsigned long addr,
>  				const struct page *page,
>  				unsigned int flags,
> diff --git a/mm/hmm.c b/mm/hmm.c
> index a04e4b8..fe1cd87 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -990,7 +990,7 @@ static void hmm_devmem_ref_kill(struct percpu_ref *ref)
>  	percpu_ref_kill(ref);
>  }
>  
> -static int hmm_devmem_fault(struct vm_area_struct *vma,
> +static vm_fault_t hmm_devmem_fault(struct vm_area_struct *vma,
>  			    unsigned long addr,
>  			    const struct page *page,
>  			    unsigned int flags,
> -- 
> 1.9.1
> 


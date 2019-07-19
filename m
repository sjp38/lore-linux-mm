Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 945B9C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 00:54:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4710F20665
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 00:54:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="CONRw+ZD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4710F20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEE7C6B0005; Thu, 18 Jul 2019 20:54:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C789E6B0006; Thu, 18 Jul 2019 20:54:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3F1A8E0001; Thu, 18 Jul 2019 20:54:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F07A6B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 20:54:29 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id r58so26078311qtb.5
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 17:54:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=K31Jec0W2mQbHyXuEIzSZRFeM3U2FIL0QtGmgtdl6yI=;
        b=pp1ApnefbR87iRXB2UVPR/OUhuuiqM1e3Z8qm2Yy2KMYA8uSZFxHdSLB85QR6pJ6JW
         n5CInJ+aoMC42iE9FmOZdI1NI8pUoIDxCYD/ezvdTICrN41ARBG1pt08QZIq3qSxfYkN
         XMdKscgz54U9gfkeDfKOseKNeI0Ek3l/SpIAG0wWGfS1ii2nn/wFjHOGJPkj7p36vQ76
         qVKS/fe700lIcc3IR4GNsq2X8UrMbUPc6ZZW5o3iFMpo7iCnnzWXcaszu8JxjMTvX7Uv
         FnVVzszxPVcaacl2Om939vbkYyOnQHE4/6TJpogn/619YiAbbR+41w/g2m4dLPnBlVWb
         KpYQ==
X-Gm-Message-State: APjAAAWu1Dfpu5ipWJ8yL2F6SjiVKd+22aJwh63HO+2A7HMV+q+li23t
	w2CsYI3ZnJPUhadEINfu3XEK1WtF8bgYJEH/8EaKVvwcNV+v//cNaq11Xo8FB8TfiQyp89eaW/T
	Y90UKadOTpg34ckettOIVofoFv5SAMlNt2EtdfpMBAqCmw6HMpC7yhTNZkiwUuku1yQ==
X-Received: by 2002:a37:6984:: with SMTP id e126mr32304900qkc.487.1563497669313;
        Thu, 18 Jul 2019 17:54:29 -0700 (PDT)
X-Received: by 2002:a37:6984:: with SMTP id e126mr32304871qkc.487.1563497668642;
        Thu, 18 Jul 2019 17:54:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563497668; cv=none;
        d=google.com; s=arc-20160816;
        b=TrPYrWYAb+2gbPlazl4WSn9PHO+pXz1fBOJJVXexkJ8rMrm8yM0gwoqJm4ZqIgjkDD
         lrLqrwm9IbdhtnleKFiOPCubhoNjwrC8NX7PfQw9ol0e4OFRp0k9vrrM9JNM8WdD4jYt
         r2zKCe1+j1Abt/avW+Wb9c737+83xBlUcljymk6wNvZSg0UMCaY0xyyBa5Q55h3bxiUd
         iGMUmf3weH86yrXfS++oeijkQtJg4+SlUcw6Y26nTWi97PiALggky31y3B/Rio2FH+2K
         YtYhYVG5nwyZcPWJiu+5fpYoT68xXf3bTX4zhrQ5wn6VMA67qM5kQ0xWZ+7Hm74FnnCl
         b3jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=K31Jec0W2mQbHyXuEIzSZRFeM3U2FIL0QtGmgtdl6yI=;
        b=LWl6182NZM2CvPeuMPDYpuv39T2Cbund/uSFC70mtPJ4csEVvLzxkq62lMgIRucnxc
         Zp7rF6KgtMe/Cfl1RhB0WNJ5QpwZYtkqhnFZl4GzccbadRaOwGFmdZpci+OnsCCvo67+
         CwBA6BwgIxq4/SyWdFSQhg0NqENaVnvDxrPvyAK+BJ8m8VTUGkrU52HQ6XmU0z6ux5SJ
         WlIwdNSQscP7nEk6EIeIQgdc9pvEaf5N4FHIvzyPmZyXWwkkWxXr3aRD7L/Uzctgo+ky
         AkljySRLv8p+PMTGm/OWK6g8+NmybpyK02ukWxVwP9pmIYS/I+AYpHSodzhMN8nazMif
         /ZvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=CONRw+ZD;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20sor39365084qtq.33.2019.07.18.17.54.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jul 2019 17:54:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=CONRw+ZD;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=K31Jec0W2mQbHyXuEIzSZRFeM3U2FIL0QtGmgtdl6yI=;
        b=CONRw+ZDbyL6SigjzXgbs22T5kD96B4YkxXVm2v+BWfBooVj5EHT6qerx928f0yxNs
         mELaZH42520yRXTr07RvgDzpayrKWE32Pdqgh1E2P6oJDnWlzuq72qSyfYR0xM7/jmuy
         UFTsodSQ0aU9yok0aqnHUw/w30/bGKg5sRhoWexAh1R0IuRU+H+MOgD9gXxWqUgjE5y1
         FMQv8iRAzUBW/HGajYme7/QdPLhByxWWiP3SnCOQgg7FZwmz2tAvISx6kmGOaAms+CBd
         f6qubvenbDwLyh6PQxVkRCor+CXncXKtbs6Aw3LKzXBjtJe7EZoZ2NlqpDW0jPr1Kgfy
         SgIQ==
X-Google-Smtp-Source: APXvYqzALV1XPPR4i5aqgRIPRRb+IDBHew//lXaUHh/2wKGi/FH2zhHYKNj2BVqecoPG+aOz3nB1Uw==
X-Received: by 2002:ac8:3378:: with SMTP id u53mr33464649qta.318.1563497668282;
        Thu, 18 Jul 2019 17:54:28 -0700 (PDT)
Received: from [192.168.1.153] (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id o71sm12320194qke.18.2019.07.18.17.54.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 17:54:27 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: list corruption in deferred_split_scan()
From: Qian Cai <cai@lca.pw>
In-Reply-To: <b38ee633-f8e0-00ee-55ee-2f0aaea9ed6b@linux.alibaba.com>
Date: Thu, 18 Jul 2019 20:54:25 -0400
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linux MM <linux-mm@kvack.org>,
 linux-kernel@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <9F50D703-FF08-44FA-B1E5-4F8A2F8C7061@lca.pw>
References: <1562795006.8510.19.camel@lca.pw>
 <cd6e10bc-cb79-65c5-ff2b-4c244ae5eb1c@linux.alibaba.com>
 <1562879229.8510.24.camel@lca.pw>
 <b38ee633-f8e0-00ee-55ee-2f0aaea9ed6b@linux.alibaba.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 12, 2019, at 3:12 PM, Yang Shi <yang.shi@linux.alibaba.com> =
wrote:
>=20
>=20
>=20
> On 7/11/19 2:07 PM, Qian Cai wrote:
>> On Wed, 2019-07-10 at 17:16 -0700, Yang Shi wrote:
>>> Hi Qian,
>>>=20
>>>=20
>>> Thanks for reporting the issue. But, I can't reproduce it on my =
machine.
>>> Could you please share more details about your test? How often did =
you
>>> run into this problem?
>> I can almost reproduce it every time on a HPE ProLiant DL385 Gen10 =
server. Here
>> is some more information.
>>=20
>> # cat .config
>>=20
>> https://raw.githubusercontent.com/cailca/linux-mm/master/x86.config
>=20
> I tried your kernel config, but I still can't reproduce it. My =
compiler doesn't have retpoline support, so CONFIG_RETPOLINE is disabled =
in my test, but I don't think this would make any difference for this =
case.
>=20
> According to the bug call trace in the earlier email, it looks =
deferred _split_scan lost race with put_compound_page. The =
put_compound_page would call free_transhuge_page() which delete the page =
from the deferred split queue, but it may still appear on the deferred =
list due to some reason.
>=20
> Would you please try the below patch?
>=20
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index b7f709d..66bd9db 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2765,7 +2765,7 @@ int split_huge_page_to_list(struct page *page, =
struct list_head *list)
>         if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
>                 if (!list_empty(page_deferred_list(head))) {
>                         ds_queue->split_queue_len--;
> -                       list_del(page_deferred_list(head));
> +                       list_del_init(page_deferred_list(head));
>                 }
>                 if (mapping)
>                         __dec_node_page_state(page, NR_SHMEM_THPS);
> @@ -2814,7 +2814,7 @@ void free_transhuge_page(struct page *page)
>         spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
>         if (!list_empty(page_deferred_list(page))) {
>                 ds_queue->split_queue_len--;
> -               list_del(page_deferred_list(page));
> +               list_del_init(page_deferred_list(page));
>         }
>         spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
>         free_compound_page(page);

Unfortunately, I am no longer be able to reproduce the original list =
corruption with today=E2=80=99s linux-next.=


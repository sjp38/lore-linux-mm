Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEB09C32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 15:24:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DAFB20B7C
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 15:24:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DAFB20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 149136B0003; Fri,  9 Aug 2019 11:24:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FA416B0006; Fri,  9 Aug 2019 11:24:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2ADF6B0007; Fri,  9 Aug 2019 11:24:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D1CC06B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 11:24:08 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x28so9447137qki.21
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 08:24:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wSO4J9RxbZR+5gjikIcAlJnQCDsF+FVDzbTJ1RCEu2k=;
        b=fCIW5YRBv/t+dhDJ9yW7pL04f6rjhtfXgkFXUw/JJ8Pj82DhRqycqf9c97ju6dNq5f
         gVRDXW5T3u/e57bztfhd1zJ0NQKnaQd6ebZFe7PPvOn6tXtSpTiUqfrV/qd2x3J7PtA/
         2bT2gptNuN1cBq7K14YSOpA/8noly3J2dJZZPa8ty2GCy9oH42+kSdYH6/u9zKlWhD6H
         LbWm75b58E6LfQWL8doPAbjQexyT86ygYCecxhZW+yVNFgKWU5Tvd5PMBlwG2GXejSNQ
         6HecXXTdg06VYmYDJ6kwlmFCWUiut4XTzxCqhZ0xO0LiQGQmpOrzBhy71uxLa02X2IwH
         DQyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX1oCNPvY/uJp0y3/2E4LYoxVoX/2S1Ce8f2rzGCPki8yAQVyr3
	AohRobbvUHq8qc53SaDxohi9SkE+ZCBbJCWpMWrKNOi2GQMCVHBez2Kr7IAr7v5xYz//xHSSV3H
	yfuW7DK2P/1lVxrFqlPG/bT2OjNcPyXvsRwBbNfgYee56Q8rn/qFgDnLfNNNVFOsX+A==
X-Received: by 2002:ac8:2225:: with SMTP id o34mr18387570qto.222.1565364248651;
        Fri, 09 Aug 2019 08:24:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwj9xfK8i0qYp/JxsGYHuS4BtEo5Sjyhlohrzmnnrwbk107cEeo6vdU2UwAolhpmrTc4/60
X-Received: by 2002:ac8:2225:: with SMTP id o34mr18387523qto.222.1565364248143;
        Fri, 09 Aug 2019 08:24:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565364248; cv=none;
        d=google.com; s=arc-20160816;
        b=yjI+BebJkWNMJaz7j7f0CZvxZQfQHIpDH9gstZCCXyaxNssKWqdR+I0OH9hbTSnuJY
         odl8tWhUkcMjNRsDsl2jMWn1bII8lbuA1gZ1WhGjloAUpFmb60tNWki2qdA1V2hFR6/r
         yQ8WTTE+hO6kPJLwT84h2iBeDvaoQg3qnbtS6EqOJRkOdYBHQlZD1492Xc0EnShI43Rg
         kILPaV9THsv1o7czfuaEjkSL2L1Jq2N9RxVOvmoP854mRTmO/wbZeBbkz3WKneNP3zKE
         voSG/Ge5mZH7KynWnU7HMTtrYzK8HI2VZr363tREVzXIOWnDJH2sP0FEJ73T5ybW23t8
         EtuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wSO4J9RxbZR+5gjikIcAlJnQCDsF+FVDzbTJ1RCEu2k=;
        b=fS31aGFggZ6I5v5mrb7vYjQ7RXMUXoN34eLsJuYFG2AEXimTRma3rRA6rIWYn86u13
         tBfcChyEDW1G/DmlU7Kh0qzDTPsmMIV6ma5DLA+wixnnd6POQ9ntuQpLvNnsVg3D5OaF
         4A6dNLju8V/J0wGjTUgK2A/FUjLJqXh/istrXoSRjDqmNr2GY26woJH2e6pVAwdNEwdd
         5PLbUkncB4FLiFZcbrwnjEutm5ePFbBUBYn/A95WXGW26hx0Oh3siOdU6KVNgoJQ/y8T
         aATGeOzMnUiRU7XJdDqzQOohALcmSx2mI620XqqiU/zRVpawfe5l9QIe9QO7Bmf2BxH7
         uXxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a8si25601207qkl.176.2019.08.09.08.24.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 08:24:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 58AA930C2425;
	Fri,  9 Aug 2019 15:24:07 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 95D7260600;
	Fri,  9 Aug 2019 15:24:05 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Fri,  9 Aug 2019 17:24:07 +0200 (CEST)
Date: Fri, 9 Aug 2019 17:24:04 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <matthew.wilcox@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	"srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Message-ID: <20190809152404.GA21489@redhat.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-6-songliubraving@fb.com>
 <20190808163303.GB7934@redhat.com>
 <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Fri, 09 Aug 2019 15:24:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/08, Song Liu wrote:
>
> > On Aug 8, 2019, at 9:33 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> >> +	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
> >> +		pte_t *pte = pte_offset_map(pmd, addr);
> >> +		struct page *page;
> >> +
> >> +		if (pte_none(*pte))
> >> +			continue;
> >> +
> >> +		page = vm_normal_page(vma, addr, *pte);

just noticed... shouldn't you also check pte_present() before
vm_normal_page() ?

> >> +		if (!page || !PageCompound(page))
> >> +			return;
> >> +
> >> +		if (!hpage) {
> >> +			hpage = compound_head(page);
> >
> > OK,
> >
> >> +			if (hpage->mapping != vma->vm_file->f_mapping)
> >> +				return;
> >
> > is it really possible? May be WARN_ON(hpage->mapping != vm_file->f_mapping)
> > makes more sense ?
>
> I haven't found code paths lead to this,

Neither me, that is why I asked. I think this should not be possible,
but again this is not my area.

> but this is technically possible.
> This pmd could contain subpages from different THPs.

Then please explain how this can happen ?

> The __replace_page()
> function in uprobes.c creates similar pmd.

No it doesn't,

> Current uprobe code won't really create this problem, because
> !PageCompound() check above is sufficient. But it won't be difficult to
> modify uprobe code to break this.

I bet it will be a) difficult and b) the very idea to do this would be wrong.

> For this code to be accurate and safe,
> I think both this check and the one below are necessary.

I didn't suggest to remove these checks.

> Also, this code
> is not on any critical path, so the overhead should be negligible.

I do not care about overhead. But I do care about a poor reader like me
who will try to understand this code.

If you too do not understand how a THP page can have a different mapping
then use VM_WARN or at least add a comment to explain that this is not
supposed to happen!

> Does this make sense?

Not to me :/

Oleg.


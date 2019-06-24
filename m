Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B01FEC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:27:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67F4F2133F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:27:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="jtU1r3t/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67F4F2133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16CFC8E0006; Mon, 24 Jun 2019 10:27:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11CA48E0002; Mon, 24 Jun 2019 10:27:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F26628E0006; Mon, 24 Jun 2019 10:27:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A74478E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:27:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k22so20749564ede.0
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:27:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nMad3CaCSZkzI4gyvFvbmTY8mwA5a8Sp7vTVJg617is=;
        b=paGxa3FB/InS0d7Wq84agA6dsugsYOpXMRXeIPsh61vAa9/q1TJYxHTPGYM68BG8r/
         ReBINEjtPxgnIXGHH9GL/o3W3qavVdCVkqp+Cx99RN1UeyDYUZhfVw9acTkhcvq+PUhA
         +bVRnM9k8NONebtq3P0Ys+QL+j5atgoiOoT3/tvhOEs4La8LxG1CsrCYTfU9e6tQLMD5
         b/yjzdqmj08LM4bdEe/P8SrO4e8VJGjQ4vlYGNGOGV9d7IT6WMm94TPhBe/V4oVybTWb
         mjIXeG4c1nCQrYXfwgS/ZQkRPz45DgsaQsrcNNa/bYPYdpt73L3fdePFIKbLtU2tZkKB
         da0Q==
X-Gm-Message-State: APjAAAVhYP2TPPzpqORntD9z0It/npZxXcMmf+EoL75HPqRxc/8YQajR
	MIEu2vt09nFDxVxTFrup1hjcNKi/baLtpdJvLuNQnewZA1opHMlMV80Oe+7oXm5GDmX9EOO32na
	SPBoPfS9fk8/ewH1jpEBfIFmEiQ5L0j2Q4NDrpDjiTIp7TnTx4Ohb0Ewgb2/j91GaxA==
X-Received: by 2002:a50:94a2:: with SMTP id s31mr125810252eda.290.1561386463271;
        Mon, 24 Jun 2019 07:27:43 -0700 (PDT)
X-Received: by 2002:a50:94a2:: with SMTP id s31mr125810190eda.290.1561386462652;
        Mon, 24 Jun 2019 07:27:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386462; cv=none;
        d=google.com; s=arc-20160816;
        b=ykqBSSOU5sUegom03SKHmmM3mmXYbPR75aSWuQBB4jj76kThOeUO8vbtwro9gW+1IL
         GHPUfgSTRTrHPcJYYidZBTV60tcaR3R4COXxO8Tj35lcxJgNDk8C4iXjiBIAR4/I9Byq
         jJJsHixb4ToePi+vfhUE+0G3AXPavQoIMR7encP9gXu1QK/h/XERDmk9dpv1CzkV/T1N
         sOVzF2onfy6abeyHYmVkqcls3DQwCbZj7tbDo06mrJVyaa7vqnXLOiaZN8QvKIUATMzW
         G7mE0x8iiTtYjd8UHpzmoFNrPUGeK7OqeEejjj8yaBA9JeFGhwfl30C9bYvmkBNvkbWF
         HtpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nMad3CaCSZkzI4gyvFvbmTY8mwA5a8Sp7vTVJg617is=;
        b=uncfEpp6xzIbHIUf75ZT2zHaNs1B5G0UoZOnJce8S8y6dMCY3YvelG9+wDhkFQNTH3
         +YohHsnpaTP9PwenIdz7BHX5kXVqgqs6nB8qlf4y/vQEEVYg7LB/o4zDrVKBlqoYoOpD
         YidYOFfXc7QCNnPCx8cLSjiz0vDh95u9hEOPlmCNMJkKu0Hep2oJcYT7B2gNZ9OvOpDW
         qSlzG6JsFhtv5csf7+4KCmq6oxlrzGd/F69a7lQu1flXcxgL5Awvy1FTIRZyOFhHcSnc
         jXbwAsUINd3Ueerev30TQ4BLqPfKRW9SN8MSeaD8nw7SebaXnAEg0I83PguCe2kg6G6q
         7Sbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="jtU1r3t/";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p15sor3433932ejr.10.2019.06.24.07.27.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:27:42 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="jtU1r3t/";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=nMad3CaCSZkzI4gyvFvbmTY8mwA5a8Sp7vTVJg617is=;
        b=jtU1r3t/2UsWRHp4cHYwBYGPpiZUxz1/KLoBCTrKS4GUbo9DYoiKDE4ko+tPLCvBZu
         kVU2KDKQj4bZshQa9gZS8SkpWHRzIIr1zMHVlq+h71f92Sb1sMdH5cnBrexMB088xYoj
         lsqFXhocWNoaRaULy95jAMLyLmMA7bfqik/wFGsDEb1zokXQv1eavf7pI0rdaS0SuOiE
         7dXJYQcgVtIul74lHRgtWv1FCERbkHxuQATQxfehC89AGfJA6TAGFluhj8wPparDYqeP
         dx75xVh4boioNOkMS5RMHsVzHq+Fqmr9V3rUsM9KoOJQYU4Kgjhf0MyUkXvlsYHXp7+O
         n7Kg==
X-Google-Smtp-Source: APXvYqwqid3EK2KULR3HvJOfTxPaV9NVV4GB+bO31X1U4vpGtxWUZczZsb76evJVJFcgmV4mVSqaMg==
X-Received: by 2002:a17:906:3c1:: with SMTP id c1mr34162609eja.221.1561386462321;
        Mon, 24 Jun 2019 07:27:42 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id a8sm3743134edt.56.2019.06.24.07.27.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 07:27:41 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 0F1161043B3; Mon, 24 Jun 2019 17:27:47 +0300 (+03)
Date: Mon, 24 Jun 2019 17:27:47 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hdanton@sina.com" <hdanton@sina.com>
Subject: Re: [PATCH v7 5/6] mm,thp: add read-only THP support for (non-shmem)
 FS
Message-ID: <20190624142747.chy5s3nendxktm3l@box>
References: <20190623054749.4016638-1-songliubraving@fb.com>
 <20190623054749.4016638-6-songliubraving@fb.com>
 <20190624124746.7evd2hmbn3qg3tfs@box>
 <52BDA50B-7CBF-4333-9D15-0C17FD04F6ED@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52BDA50B-7CBF-4333-9D15-0C17FD04F6ED@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 02:01:05PM +0000, Song Liu wrote:
> >> @@ -1392,6 +1403,23 @@ static void collapse_file(struct mm_struct *mm,
> >> 				result = SCAN_FAIL;
> >> 				goto xa_unlocked;
> >> 			}
> >> +		} else if (!page || xa_is_value(page)) {
> >> +			xas_unlock_irq(&xas);
> >> +			page_cache_sync_readahead(mapping, &file->f_ra, file,
> >> +						  index, PAGE_SIZE);
> >> +			lru_add_drain();
> > 
> > Why?
> 
> isolate_lru_page() is likely to fail if we don't drain the pagevecs. 

Please add a comment.

> >> +			page = find_lock_page(mapping, index);
> >> +			if (unlikely(page == NULL)) {
> >> +				result = SCAN_FAIL;
> >> +				goto xa_unlocked;
> >> +			}
> >> +		} else if (!PageUptodate(page)) {
> > 
> > Maybe we should try wait_on_page_locked() here before give up?
> 
> Are you referring to the "if (!PageUptodate(page))" case? 

Yes.

-- 
 Kirill A. Shutemov


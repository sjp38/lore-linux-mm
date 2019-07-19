Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17577C76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:43:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD6FD20880
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:43:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD6FD20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 882316B0005; Fri, 19 Jul 2019 17:43:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 833756B0006; Fri, 19 Jul 2019 17:43:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 720DE8E0001; Fri, 19 Jul 2019 17:43:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39BEE6B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 17:43:22 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 191so19449249pfy.20
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 14:43:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=vBej2vyGTC2AaDufHl59AjZ51D572k9Qava++dZu72Y=;
        b=fuJO59g40LRb9pZ4qQY2oqPIbEkUE8QTgh1YWOmKJ8d+zV2WyKtmjBns/s7pjrJu/b
         PXKYRnNVJyDT0zkuXVZtD1S/b4Z+r9nn/2nabMW3JoHz8r78AdQf8lDmwg6O6t8bt36b
         u0WlBFMM+PHbdPBpL2O69cgJwHn3Ry43Ry+k9KMJYXreXMggWCFnUqJui6RGd9GWOxZN
         2xubrJH4Pb/8miOgWGI+3jY3MiXoTPUZzbdAYTb/3aWAovfPcF/FBZmpn5isc/Pl2XVl
         851V0wunG1x3M30Kd1nqqQOFJd7JEcHyjxgtxvw35TcQujTETRv/riNEDzDFjLy5aQYk
         xHeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bo.liu@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=bo.liu@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXXdxhNLQfrvy4qUMuDcquW5vzJ8p4ygdGx9mxunpbmY4QCYKR0
	Her+duW57f+a2DU2a5PT1AxQvGA+UDq0DY577GTnAMFoh1P9JTQ6eNB4HBmMPFMWPrJcMsvquxm
	WgLJ4w2MmVcRNJnx8RRwDtu+GAhpWBAihdhHlrQkTlunore+OR3mGA6yslQKkxhNZzg==
X-Received: by 2002:a17:90a:db42:: with SMTP id u2mr60458890pjx.48.1563572601907;
        Fri, 19 Jul 2019 14:43:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaPxhBUXxzju8c4D5gr4jqJQwLAotfZYAbDgfJ8RfoPtA+eizNlv92d9f6O0G1KpNu3PsD
X-Received: by 2002:a17:90a:db42:: with SMTP id u2mr60458856pjx.48.1563572601209;
        Fri, 19 Jul 2019 14:43:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563572601; cv=none;
        d=google.com; s=arc-20160816;
        b=XAQdL7ejwnwmKb2YBPDnGx2bLA/OjX5ekESnkg+7xwxCUE6SIGf2gLUhw0p0Qpjqtt
         AwuofLfLZG3QE7nlGXSH/+EgoxbTY/z2tisHp02XTPj0cB0B+T3bbrndx/QhT8b4S/7j
         qiUbOfXBc2rhC/xwCrcD3BTZjE5u3hGCZ4ysZFnhgeDaAJZ2dsERtxCHJ7h1qPP/5jCQ
         NvaSgaLdzWKFKOCg+pgcXppfPFozI4iz0wE+zvvZWcUejEYWg2fLNZMR+B/TpNYBW+UJ
         8TUGMIMk9EBRhNLLk4d252Qmkpjt1483Z6L9EalnNsfsqts8wZ6qDCZXTOGuQew67PPl
         N4yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=vBej2vyGTC2AaDufHl59AjZ51D572k9Qava++dZu72Y=;
        b=PrjKw9Wbt+U5oX7r1PhdpsmIGMLkM4+RWMxFZbFl79x1/q0C4yVz9vIucHoOhs1v2a
         CBxuHg3qn4UJFQmh9sMtMrm8PckgmXeRtLvdmSrr3Cz/AFFh1MusMnAxtRpUNZmM0T9m
         Ytl+ehR2wTdDNrcvZ7XKvdQiWWL0KMM2jhKudUsAQzVpio6gycXI4UUKu76cEEnHcJor
         DBQpCETFX1sDZu8zKU5CezozdXrdmUFNWN3t/DQ8TXrNenbIDj7CbRpD1Kjzicjf9UHn
         u2S7KgwzoGZZAiMsty2HgB6xnrvuF3fHriPnkZSrOmsJLROUIc3QTJ029+sECbImWJx5
         6XFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bo.liu@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=bo.liu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id l184si29427458pgd.203.2019.07.19.14.43.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 14:43:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of bo.liu@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bo.liu@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=bo.liu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R121e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=bo.liu@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TXJI3wZ_1563572595;
Received: from US-160370MP2.local(mailfrom:bo.liu@linux.alibaba.com fp:SMTPD_---0TXJI3wZ_1563572595)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 20 Jul 2019 05:43:18 +0800
Date: Fri, 19 Jul 2019 14:43:15 -0700
From: Liu Bo <bo.liu@linux.alibaba.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
	Peng Tao <tao.peng@linux.alibaba.com>,
	Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH] mm: fix livelock caused by iterating multi order entry
Message-ID: <20190719214314.26ftdpdyf4tixxca@US-160370MP2.local>
Reply-To: bo.liu@linux.alibaba.com
References: <1563495160-25647-1-git-send-email-bo.liu@linux.alibaba.com>
 <CAPcyv4jR3vscppooTFBEU=Kp4CNVfthNNz1pV6jxwyg2bmdBjg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jR3vscppooTFBEU=Kp4CNVfthNNz1pV6jxwyg2bmdBjg@mail.gmail.com>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 07:53:42PM -0700, Dan Williams wrote:
> [ add Sasha for -stable advice ]
> 
> On Thu, Jul 18, 2019 at 5:13 PM Liu Bo <bo.liu@linux.alibaba.com> wrote:
> >
> > The livelock can be triggerred in the following pattern,
> >
> >         while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
> >                                 min(end - index, (pgoff_t)PAGEVEC_SIZE),
> >                                 indices)) {
> >                 ...
> >                 for (i = 0; i < pagevec_count(&pvec); i++) {
> >                         index = indices[i];
> >                         ...
> >                 }
> >                 index++; /* BUG */
> >         }
> >
> > multi order exceptional entry is not specially considered in
> > invalidate_inode_pages2_range() and it ended up with a livelock because
> > both index 0 and index 1 finds the same pmd, but this pmd is binded to
> > index 0, so index is set to 0 again.
> >
> > This introduces a helper to take the pmd entry's length into account when
> > deciding the next index.
> >
> > Note that there're other users of the above pattern which doesn't need to
> > fix,
> >
> > - dax_layout_busy_page
> > It's been fixed in commit d7782145e1ad
> > ("filesystem-dax: Fix dax_layout_busy_page() livelock")
> >
> > - truncate_inode_pages_range
> > This won't loop forever since the exceptional entries are immediately
> > removed from radix tree after the search.
> >
> > Fixes: 642261a ("dax: add struct iomap based DAX PMD support")
> > Cc: <stable@vger.kernel.org> since 4.9 to 4.19
> > Signed-off-by: Liu Bo <bo.liu@linux.alibaba.com>
> > ---
> >
> > The problem is gone after commit f280bf092d48 ("page cache: Convert
> > find_get_entries to XArray"), but since xarray seems too new to backport
> > to 4.19, I made this fix based on radix tree implementation.
> 
> I think in this situation, since mainline does not need this change
> and the bug has been buried under a major refactoring, is to send a
> backport directly against the v4.19 kernel. Include notes about how it
> replaces the fix that was inadvertently contained in f280bf092d48
> ("page cache: Convert find_get_entries to XArray"). Do you have a test
> case that you can include in the changelog?

The root cause behind the bug is exactly same as what commit
d7782145e1ad ("filesystem-dax: Fix dax_layout_busy_page() livelock")
does.

For test case, I have a not 100% reproducible one based on ltp's
rwtest[1] and virtiofs.

[1]:
$mount -t virtio_fs -o tag=alwaysdax -o rootmode=040000,user_id=0,group_id=0,dax,default_permissions,allow_other alwaysdax /mnt/virtio-fs/
$cat test.txt
rwtest01 export LTPROOT; rwtest -N rwtest01 -c -q -i 60s -f sync 10%25000:$TMPDIR/rw-sync-$$
$runltp -d /mnt/virtio-fs -f test.txt

thanks,
-liubo


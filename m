Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA504C5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:23:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7686A2085B
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:23:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="poetBkUA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7686A2085B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BB656B027C; Wed, 11 Sep 2019 11:23:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24AC66B027D; Wed, 11 Sep 2019 11:23:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 161516B027E; Wed, 11 Sep 2019 11:23:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0110.hostedemail.com [216.40.44.110])
	by kanga.kvack.org (Postfix) with ESMTP id EC4796B027C
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 11:23:48 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8DE5B181AC9C6
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:23:48 +0000 (UTC)
X-FDA: 75923009736.19.86F4545
Received: from filter.hostedemail.com (10.5.16.251.rfc1918.com [10.5.16.251])
	by smtpin19.hostedemail.com (Postfix) with ESMTP id 6A6D21AD1B8
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:23:48 +0000 (UTC)
X-HE-Tag: birds76_3d20ca030bc02
X-Filterd-Recvd-Size: 3586
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:23:39 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id c19so20963715edy.10
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 08:23:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bdRXlyq4l4A8bpgzomm6eF1x1mYYtVmO70wKMu77KXc=;
        b=poetBkUAgbyDnI3y/qa1TcPN6avL7jZvYR1xuvOR4FYgMjSzY40Ez86GbhxUHGeiuV
         OV3euIHts64HIU4Xzlj4S+3jIbtb7oDOg19eORR5vIx6G6RInuzBwciIB60mpznuxeSh
         yKBvY/OePNkSFcqk+zwRD1MpMpVVcYY1Q/bjXb7Fomelex8GuamZMdzf06WyyAD55m9J
         VnuuqSnc1+vy32kWxUhtQgIU4Hh4to4oylRr9XbWJn4dB4R2N+FXadF7FTR7TaA85m0a
         NPy0XKaEmseSM4oumr3Zb5qkaTDI/6BBRiApwIvibKuiJFeGdKJkWki4mmBwygxDeNZ8
         nFFg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=bdRXlyq4l4A8bpgzomm6eF1x1mYYtVmO70wKMu77KXc=;
        b=sSHpK3QuqFVvg4y4n2E2zZm/tZUX9ZXD7N0PhaNtddnm1BQZViSpmnGf2MOT/G253A
         BTxdXZeycdWVET1u+UFIFV+ku7XFH0BrEtBQ744AYy0M0mCKT/ehWsyn1wt/KcC2PXIx
         v5HP77lBLUe7tvFqRha93wqQNpMvxbXBxKjCHbTlkDiIMzFl74e5Vfba96OBweJeLJLB
         nzh2fgPd21E3Y3FgSzv7io0zDttnkGoOl3SgERlMYBaGzsGN8wuht+XJYHLZLbbMkXLr
         AdGOrmeNVi37eszPMGJJZpEb75HE0Uu7+3tnyexnCW7GcRBw0asqSfHEqIkzb5C1/gh9
         lBuQ==
X-Gm-Message-State: APjAAAVnh2AyEPaZ1EQN5RMgvLWKoMI2l+MaVejjN7dYW1qf8rxt4d8v
	208R8G6cCD90HEW3mGK+H0l7hA==
X-Google-Smtp-Source: APXvYqwYuTgslFkpD3GVu+/ZtjWa6+TgqNSXkaGo/8pTyfEMxmrTMrRhfUjxMtUOPKOTQwdqzarKOQ==
X-Received: by 2002:a50:9734:: with SMTP id c49mr37498960edb.93.1568215418672;
        Wed, 11 Sep 2019 08:23:38 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id d24sm4264007edp.88.2019.09.11.08.23.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Sep 2019 08:23:38 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id A385D10416F; Wed, 11 Sep 2019 18:23:38 +0300 (+03)
Date: Wed, 11 Sep 2019 18:23:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: Josef Bacik <josef@toxicpanda.com>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: filemap_fault can lose errors
Message-ID: <20190911152338.gqqgxrmqycodfocb@box>
References: <20190911025158.GG29434@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190911025158.GG29434@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 07:51:58PM -0700, Matthew Wilcox wrote:
> 
> If we encounter an error on a page, we can lose the error if we've
> dropped the mmap_sem while we wait for the I/O.  That can result in
> taking the fault multiple times, and retrying the read multiple times.
> Spotted by inspection.

But does the patch make any difference?

Looking into x86 code, VM_FAULT_RETRY makes it retry the fault or return
to userspace before it checks for VM_FAULT_SIGBUS bit.

-- 
 Kirill A. Shutemov


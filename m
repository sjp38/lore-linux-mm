Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 914B1C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 13:33:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4523121872
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 13:33:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="i+vNEoXI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4523121872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D26D18E0003; Mon, 18 Feb 2019 08:33:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD7058E0002; Mon, 18 Feb 2019 08:33:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEDCF8E0003; Mon, 18 Feb 2019 08:33:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8037E8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 08:33:41 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o24so3525658pgh.5
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 05:33:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3WMTodfPuoC7pIQeJ4r7goXGSg2DbqIaR1ESJWyxvBM=;
        b=loSWCLr9TlSWNWzo6jwfDI4UtsWiDsclc3yXQ/x8LvFPQBC3B3TDE2iFsI0r31BoHQ
         eTSJV06o9dBZo4NKDhe2qCxPHBrbaJS2Qj0Tehx1iJkbesgfs//9foF8OqIEEKBpZQmx
         nrDSMqCABs6/XFV/wlAUHXII12kzBA3FnA1V1txrQ85dyoBP5rIbboB503IKn2p68FM6
         rJcCkPGXGgdk+WI1tWyhgis0DiHzGAZRuqj/4E3zOvWC6MU9sRCLlpGH0UhqkYjbbH0C
         IlQ46S+4e8Thkq2a5yBmTtZ+PvStMZBmDjzYQD1zH5eWFY14l1u2odSI40pBBC9W1Ddq
         Wyug==
X-Gm-Message-State: AHQUAuZLVsKIQRdxS8gUf584LVYcGy50t1AjGXQwyk8Jxn5c7zOBfweo
	wLhZtwl6+27fOmTibWcv/dEFVg4MeJx09+vNie6JQY9LCeOFyCztG+XN0BTyKxOLi3VblqJOg9k
	qa819VGAE/8UBArXQDHiqhRLixYQ6Z9JGTK/wyQMK24EUp9Xeh+ZpaDNGVNH17P0=
X-Received: by 2002:a17:902:8e8a:: with SMTP id bg10mr25392150plb.192.1550496821092;
        Mon, 18 Feb 2019 05:33:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaqmAOaDnN6sWfLZyc9TCgW7f0E2CSjy6a7gZ+6ocJM3qp3dFlAHy/X6MMFdbe/3fuwq+tA
X-Received: by 2002:a17:902:8e8a:: with SMTP id bg10mr25392095plb.192.1550496820349;
        Mon, 18 Feb 2019 05:33:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550496820; cv=none;
        d=google.com; s=arc-20160816;
        b=joyGMD7cEEJ/5J3vOG6fgaWPeD/9VSIgk/1lwhfI+g+h6tF/wxRlhi+RwJUOnZ3ymv
         KPf6mVVHbP7F3GDB+zXNpimXp2ncX0c1hv40CZXJz259qgKJEoQhZEHIwWUjZP7zuVU5
         N8RN0fLF+iW85FJyXVTxC6vQvzrtEsUYAwu/tDpXZUE157vJXzv9nzIsJ2pH8/avg1HA
         cpZ/n1w+J9Ogq5Nbw0yZtYcb17+78svYMFimWE2b1Dlxj//no2zsVe/NRynKL/rKC1hj
         cC8unG+0D5kDq5eqkGb7zy1SMZbDqR3FV9s5Zy6f8UNtrn6wJEbHiTCEinacn3IS+DIU
         3/QA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3WMTodfPuoC7pIQeJ4r7goXGSg2DbqIaR1ESJWyxvBM=;
        b=wtuFiB4I+J7Qn//abXWbMA+neHBiidotO/vEo84n8Q+XDTV00/ChdNfghMmoZROfCu
         AwmqW1G5cNTCIdgMKRysQAruF5XmThvEhDY3ZRr97mpmpRLYqdkPHb5HWU9VK6uRwDtb
         CclbDzhsq/jSD9XZvdEyPGobKgUiwG+3ekDOPgTC3c8jOG7tWBwfqcVazP8CE31uRw8K
         //wGybk0xd6URTBCMA4Arw+dMr52s1oIyI5FXzn+wEADDUZFplcDpB2g+PYdXC3mbzo/
         NtkejfOi8ZfhF1a1b9bHxONsuhCfNenyZVwz699pj2R3rAcn8ExIN/SM06NgTRFafMIB
         TgRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=i+vNEoXI;
       spf=pass (google.com: domain of srs0=7u7d=qz=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=7u7d=QZ=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s5si13120986pgl.481.2019.02.18.05.33.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 05:33:40 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=7u7d=qz=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=i+vNEoXI;
       spf=pass (google.com: domain of srs0=7u7d=qz=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=7u7d=QZ=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6ECB72147A;
	Mon, 18 Feb 2019 13:33:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550496820;
	bh=xVTxS5W0tuWQ5kJJ1jNbiEp7I+LCmqfv6UhLLql9NBg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=i+vNEoXIxe5Hp1OvQ3NurLSZEfbbTCugflAEiqrk1O0eIUhxAFb5bOL4tSSXw0HYW
	 9TIgap/24VjKTuROt9nlqGLWGolZBGEod/0zgEzcwouV55+7bYQukHYSzotXbKmJrB
	 KRxlv3QugaQUeWU/qrRQ0vP6jEtObUY3fvs8LWoY=
Date: Mon, 18 Feb 2019 14:33:37 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hugh Dickins <hughd@google.com>, Liu Bo <bo.liu@linux.alibaba.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix the pgtable leak
Message-ID: <20190218133337.GB30139@kroah.com>
References: <20190213112900.33963-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213112900.33963-1-minchan@kernel.org>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 08:29:00PM +0900, Minchan Kim wrote:
> [1] was backported to v4.9 stable tree but it introduces pgtable
> memory leak because with fault retrial, preallocated pagetable
> could be leaked in second iteration.
> To fix the problem, this patch backport [2].
> 
> [1] 5cf3e5ff95876, mm, memcg: fix reclaim deadlock with writeback
> [2] b0b9b3df27d10, mm: stop leaking PageTables
> 
> Fixes: 5cf3e5ff95876 ("mm, memcg: fix reclaim deadlock with writeback")
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Liu Bo <bo.liu@linux.alibaba.com>
> Cc: <stable@vger.kernel.org> [4.9]
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/memory.c | 21 +++++++++++++++------
>  1 file changed, 15 insertions(+), 6 deletions(-)

I fixed up the changelog text to be correct, and now queued this up,
thanks.

greg k-h


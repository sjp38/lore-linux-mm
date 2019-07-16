Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CBD8C76188
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 07:17:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30DA220880
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 07:17:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30DA220880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C0CC6B0003; Tue, 16 Jul 2019 03:17:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84A016B0005; Tue, 16 Jul 2019 03:17:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C3C56B0006; Tue, 16 Jul 2019 03:17:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 149EB6B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 03:17:55 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id b6so10086850wrp.21
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 00:17:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vHHwRSF3LnN+YkVovl1LAzvIiipSiXildikrjwGSyHg=;
        b=reEaufFHilKfx4QKbwMVMv9beEFMXKSk0ks/53odVLo2BVY2ghsCK99tuJa8flGI9j
         biCzckFCK/N6Bi+9z74M5DRUBKY/fQqFY8GPEUvtwu7g+lg5RPYw9udAu9uM1aFMDrlj
         CjHH0tQ+l/FmmSJFP6TEUg6bL124G7DHixK42t1ghVoN1HC6aBLk0hQzbIsSjG7n8F6A
         1FhFhz/VQUn9zl9MLVOGhOhJFGarDgo5zNnIZLMozbZZp4QQrH9m217j3yNu//15g7vm
         sNOIGlRYpk85ENPp+HhXj7IuTnhOAnJxdDdKmXL5rqvcrE1WpQ5vmJdURgjbrgW4B1Yz
         Q+Sg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.12 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXrPHxewa1CS7/ucTYdtE+f4Qy/EydUJsCRPzco6X+Md2lFPzPH
	qzNKd+0vBmtVyyjiSaIjHfiRm23sulYD/RNO87IBmh9aW97LqIM/QXJgLEUSiy1/zqMlurWtcQu
	3GyGP4egjGpzHkPB4r+MkS9qOsjj1L2+0mH5oESJWvvn9HN/3GFhS8/rGgqyk14NsAQ==
X-Received: by 2002:a5d:6182:: with SMTP id j2mr32010092wru.275.1563261474539;
        Tue, 16 Jul 2019 00:17:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZDDP8Xz7vUZ8BdPjT7Bq9ai5plyYg+HrlmeOSq/vrtOeO87EzKvNiEwt9o73RaQUE4DhX
X-Received: by 2002:a5d:6182:: with SMTP id j2mr32009971wru.275.1563261473616;
        Tue, 16 Jul 2019 00:17:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563261473; cv=none;
        d=google.com; s=arc-20160816;
        b=TP8Ceg5OK5bnn4F4bj2slGZF0DFZ2hEVLPPW3h1GZR8TXF+Fa1bds7X+1yJMtUtoSh
         fEejwfPDWO6qeGPBzfZG/ZHK6DwqkyRNohPShzoGk0x9dvOHdfbuNGyAvbf+urrNS2Fu
         CCO195/mU/rqM41/MTFhzgkYGDLXitKnv5cv5o+V2xTajqbySQhiacmgkwXBfwGLPJcH
         SDEOtA5nngZo5UiV8t/TAmIqU0Qjguw28eFfpuuL3xRJqIFos5aYn3KNh/+PaoLJj5Le
         7NNwveMsKSDW8P0zfSq0CaGtDXdJdCugrI2wjj+z4l6dECoygLqQ1NhdJWXnzNqCcceK
         rntA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vHHwRSF3LnN+YkVovl1LAzvIiipSiXildikrjwGSyHg=;
        b=pi3aN6L/cEfTHpaIS0tcxZQedHw/tDCp6tE6c/oaJcZ5+OZXJZOKb7kwQjeXbXY7En
         qAULjYYho/P0FWJs7HLF1HWxC6nPxuwI12AqHDSXreocB7+oRLcQnd57pcNacZ4nc/Rr
         zURmNwMJvBG2vRh+d5skynM3o4tbxQHliy21Wul4bBlvLzoq3V3/44ymhFsupvtQAZ9B
         JW8KETgQaVoKKCbjRRckgTRNV1rPI005rbVAxP2PZ8PzMUmoGTWdfhO0DCmubXWA9akw
         wkk2QE2BOK6Qvmk6FJWU+WDGcUgXvBnPHZjLOlZoz8yDSZTEw2HuOAPL/rCCmbXfljX3
         I2QA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.12 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id l18si16233694wmi.47.2019.07.16.00.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 00:17:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.12 as permitted sender) client-ip=46.22.139.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.12 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 218BE1C1D96
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:17:53 +0100 (IST)
Received: (qmail 2237 invoked from network); 16 Jul 2019 07:17:53 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.21.36])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 16 Jul 2019 07:17:52 -0000
Date: Tue, 16 Jul 2019 08:11:21 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: howaboutsynergy@protonmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [Bug 204165] New: 100% CPU usage in compact_zone_order
Message-ID: <20190716071121.GA24383@techsingularity.net>
References: <bug-204165-27@https.bugzilla.kernel.org/>
 <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
 <pLm2kTLklcV9AmHLFjB1oi04nZf9UTLlvnvQZoq44_ouTn3LhqcDD8Vi7xjr9qaTbrHfY5rKdwD6yVr43YCycpzm7MDLcbTcrYmGA4O0weU=@protonmail.com>
 <GX2mE2MIJ0H5o4mejfgRsT-Ng_bb19MXio4XzPWFjRzVb4cNpvDC1JXNqtX3k44MpbKg4IEg3amOh5V2Qt0AfMev1FZJoAWNh_CdfYIqxJ0=@protonmail.com>
 <WGYVD8PH-EVhj8iJluAiR5TqOinKtx6BbqdNr2RjFO6kOM_FP2UaLy4-1mXhlpt50wEWAfLFyYTa4p6Ie1xBOuCdguPmrLOW1wJEzxDhcuU=@protonmail.com>
 <EDGpMqBME0-wqL8JuVQeCbXEy1lZkvqS0XMvMj6Z_OFhzyK5J6qXWAgNUCxrcgVLmZVlqMH-eRJrqOCxb1pct39mDyFMcWhIw1ZUTAVXr2o=@protonmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <EDGpMqBME0-wqL8JuVQeCbXEy1lZkvqS0XMvMj6Z_OFhzyK5J6qXWAgNUCxrcgVLmZVlqMH-eRJrqOCxb1pct39mDyFMcWhIw1ZUTAVXr2o=@protonmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 03:57:30AM +0000, howaboutsynergy@protonmail.com wrote:
> > PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> > START: __schedule at ffffffff987f5a0c
> > [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b35c6
> > [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> > [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> > [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> > [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> > [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> > [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> > [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> > [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> > [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> > [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> > [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> > [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> > [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> > [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> > [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> > [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> > RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> > RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> > RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> > RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> > R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> > R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> > ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> > crash>

High CPU usage in this path is not something I've observed recently.
When it happens and CPU usage is high, can you run the following commands
please?

trace-cmd record -e compaction:* sleep 10
trace-cmd report > trace.log

and send me the resulting trace.log please?

-- 
Mel Gorman
SUSE Labs


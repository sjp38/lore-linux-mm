Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEB94C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:48:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5D2220883
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:48:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="YdV2OgLA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5D2220883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A6196B0003; Tue, 25 Jun 2019 19:48:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 331938E0003; Tue, 25 Jun 2019 19:48:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D1938E0002; Tue, 25 Jun 2019 19:48:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D6F6E6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:48:12 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k136so336402pgc.10
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:48:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Fut5FnHrfteY/qts00UaKFKHi2yGPW5kW7WBkcXK5zo=;
        b=oMqAwUNaiJNWTMdyGlFroToiimCme0Wfbp1RWmbWEwuT9/FQlrdrbM8KfzM+nYT5L+
         W9SsbeSBmku+IGNNrpLX/BJhz0dSrqFdIPy66+iJL5Bh7EzUkyF5Ovq/ZLs0wk8nNkW0
         8TLpf3UN6FOU7mwWcm3FqB1hiV/bzzqTcsUVCZtDjS/6HpROZA+dMwAiukih9EFT3bRW
         CKQQ2hW60qnt1zcuIWh4lN3MmrML6Yt//jQAGxqj+KdG8iUDNXH5f0w8vURta3etGB++
         pph6RS6/wooxCflId4d2ibNXvfB3ID+q3SsN7PEh9p86m6WkWKFX4WRilbUcg+VK4dUr
         N0HA==
X-Gm-Message-State: APjAAAWyUDFIxSM5jdDhBUSbNJxl1RYuSFFbg2aDOnoTG7jnKQQ05jol
	W9umzrYSM04/XTqOl3GzzNFqOGUkJpnSHQhjZ7zT6vKpO2tD+KJjMhNpLfefvP3eTDHAHB4fRA9
	9IY31fLvqsUpvqt2nkzh2lNTbBxDyAaJMJH2HlfhLBnnc+fW/pkckM+jCyu9lTQ618Q==
X-Received: by 2002:a17:90a:b00b:: with SMTP id x11mr601851pjq.120.1561506492332;
        Tue, 25 Jun 2019 16:48:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygzWOTNQTiviszL6q5hQ+ZJUbTq0INZFT0UFJirWZvA5/V7wSdXhAcLd6BK+fap5HPAo//
X-Received: by 2002:a17:90a:b00b:: with SMTP id x11mr601784pjq.120.1561506491486;
        Tue, 25 Jun 2019 16:48:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561506491; cv=none;
        d=google.com; s=arc-20160816;
        b=gms8znePUtORcqryod5DWQghcTkaGXfigWziH0VTmZTWIOMzKlBwxIQImrcHQyDHYQ
         jocjRIklcsOPxOFBa3K5BpTlAWjW3n/CAg/xU407MF+cLqGKaepM/YTqubn9RenTFJVA
         tfgQe3RbhcYQw99xCL0U5ZbBccvBDmRyIpPYzrK7HTXpJr6Y3xSh3uFa8Mq5e/PcOpy1
         A4Lmsb+VZFNWDAfbx+BUdFRLb/4s75Lx6cNNcuk4ynY4bSHB9/QDZ+2P97XbCB6VlRAk
         0cwBNcZZidE6nI/6ZrHZCEjH5m1ze6g1jTIwjMevza9rDSnyfUCqpjB/2xEJ8KTABh4j
         9Zgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Fut5FnHrfteY/qts00UaKFKHi2yGPW5kW7WBkcXK5zo=;
        b=oqoOhNW5NqQrhS+ctMWaLqxnz7iwWoXr03w3oXqN1UycA78prpOFGVCOQEKV1bKtBu
         /z7tIHrfdcY0oS6DID489R4+DUnvin+uFveYYZsqSdDjpjI8X+uWzO2nizOeaiE6IRS1
         RCxoKYcyFfHg/AORhILffHWK81VCqtjoMNnLQir7vNJDsIXQY+1Z3Xyo2Mx4jlYCKLPa
         S8npY/RNtt6+KxofX0rXAYc9+Epefa51tf32aLOkCDXv5NyQVnOhLuoHl8HTGdD+I/Il
         o1Yh+WqRKe6grkNMTARo1CKFMwGEj7oVrE46v58Mfb0uH8LqoRmepADeFHZM62zOmmYM
         GYJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YdV2OgLA;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w16si1455499plp.329.2019.06.25.16.48.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 16:48:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YdV2OgLA;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from gmail.com (unknown [104.132.1.77])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 905A92086D;
	Tue, 25 Jun 2019 23:48:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561506491;
	bh=IIPnw17DMud2IaI5vgEyfR+P3UuBx+ITkJ6rG4E0/Zw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=YdV2OgLAzb3QWIbIVBE+1Nl4jWGTlSEpUeKyjuhshQ5iyMDWHYzMnPwdXtw4XiTNM
	 Qlxvmu3vya3XBKrFZhs2Es4bATlzE9X90mNaVtgT3Pb2Mf6AIFRrheD9lOiitAgGAM
	 aOWIXSJfI4ZF3nZLsa28aqfknN+f2T7fsNojlPCM=
Date: Tue, 25 Jun 2019 16:48:09 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Cc: syzbot <syzbot+8893700724999566d6a9@syzkaller.appspotmail.com>,
	akpm@linux-foundation.org, ast@kernel.org, cai@lca.pw,
	crecklin@redhat.com, daniel@iogearbox.net, keescook@chromium.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, bpf@vger.kernel.org,
	syzkaller-bugs@googlegroups.com
Subject: Re: KASAN: slab-out-of-bounds Write in validate_chain
Message-ID: <20190625234808.GB116876@gmail.com>
References: <000000000000e672c6058bd7ee45@google.com>
 <0000000000007724d6058c2dfc24@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000000000007724d6058c2dfc24@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi John,

On Tue, Jun 25, 2019 at 04:07:00PM -0700, syzbot wrote:
> syzbot has bisected this bug to:
> 
> commit e9db4ef6bf4ca9894bb324c76e01b8f1a16b2650
> Author: John Fastabend <john.fastabend@gmail.com>
> Date:   Sat Jun 30 13:17:47 2018 +0000
> 
>     bpf: sockhash fix omitted bucket lock in sock_close
> 

Are you working on this?  This is the 6th open syzbot report that has been
bisected to this commit, and I suspect it's the cause of many of the other
30 open syzbot reports I assigned to the bpf subsystem too
(https://lore.kernel.org/bpf/20190624050114.GA30702@sol.localdomain/).

Also, this is happening in mainline (v5.2-rc6).

- Eric


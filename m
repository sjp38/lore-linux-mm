Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19931C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 22:25:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1C8C21738
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 22:25:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H4+gaLab"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1C8C21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D8E48E0003; Wed, 26 Jun 2019 18:25:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AF6E8E0002; Wed, 26 Jun 2019 18:25:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C6068E0003; Wed, 26 Jun 2019 18:25:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2413D8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 18:25:04 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i27so140737pfk.12
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 15:25:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:message-id
         :in-reply-to:references:subject:mime-version
         :content-transfer-encoding;
        bh=5oPhE3qEEt+RsciwWt3P6Fjbl5mc7GWFjnz4iQlRxp4=;
        b=Y4sRGCj/2dFrEa4IdSxIf1xt/e/9Rnb3qaj1Rfx/u4u+55ENE9hSawBksPhBbJoKpU
         F4dWIFHdWY/DD4QF4IZvxnbfCvBJKE9kG9NL7yjWBJ7+ONEwJ5csI8XExd+YHnBcKJes
         QGHomPwJqJh1McTN3G2pznHCBXBMtPPBeQGb4mE3nk3pm+DgpW77fv8ziMoDQ1aJzyjK
         7/ZeMeSe+2xoMo88WQjghg3WEPGVWdgrQm1snBOxO2Aoec1s3oHyRZ0XfDjULiFi8UNB
         TGVbY8WO4wddU1s6ipRZoiF6xKH7xMAs3I0ui1lZMfgHwgdc+toMDv6dp8vrsFIIPSo8
         2O7w==
X-Gm-Message-State: APjAAAVCNyG+W8BQVPoOKZmjDdtEyqUwi1ixNrkAgzvcswlsQMzLWinB
	Xu+TWVreB3+O+bkJuudt3roPhW3jBlroS4YrBLCXagaqSFONfBnCePACB3C90LuPFeV4GHqIZyz
	B0pFS/oMIBNtoSpPf1FM0MuolEhzgtGsxYME6eG//zXJdZ6Y2fYOXsTxGkCm1VjUHHA==
X-Received: by 2002:a63:6103:: with SMTP id v3mr290239pgb.161.1561587902099;
        Wed, 26 Jun 2019 15:25:02 -0700 (PDT)
X-Received: by 2002:a63:6103:: with SMTP id v3mr290172pgb.161.1561587901222;
        Wed, 26 Jun 2019 15:25:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561587901; cv=none;
        d=google.com; s=arc-20160816;
        b=rNEOTADmyr/ouNvuZEIvRySC8wQuY0ULKNLn3v76yvoRCRxeUd3C4hiQHLWg57g9+P
         6ydj2hCqjheEbPOJ1hQjf5RoHaelBrASigCA9FhNtlRRo9LhfnB+XRL7OPuH2Y0hKgIG
         fgN5TAQQn381lilUHfzsWQl1+KF4rDwxjPdJHaQ8cG+ak75OVmJMjYIOLu89JBQaGnq3
         ZupKUFbXD9Q7jkix2RNO/GrtDZHgv1GGtEfjRXJMlD+nMtNGVN+VS2HsnmU8y9l39kVU
         LFmZ6PU3FgAkx2CY+hx4LcKrJi9g4+lIyOvLwbbeXgno3+Esco9b1kZHEQTd+GP39hwK
         tD1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:subject:references
         :in-reply-to:message-id:cc:to:from:date:dkim-signature;
        bh=5oPhE3qEEt+RsciwWt3P6Fjbl5mc7GWFjnz4iQlRxp4=;
        b=P03wwkozmHfnmn6qS325dixMJr05R2KUM0lttx6zQNyH65OdmG3RkuitVQ1igN8p4i
         AQRwzX7jZFwAg07KqhnuoeE6s17M8ATkCBVZoC1YxCVeBww0EllMpU1R5hCbMxhhBYnI
         q69ESqtgJLgJ6E35wor7cOtaCIjGv2V+Rh49YOKQrfoqDypKDcsqaBOBxhD/mSPWAIOa
         K/qRnSNNOeUMSHSeofVv5CDe+64ktrD0fs6Ynr9zBrz/EcNHgKQ/p8zAKKm1KvtVgZpn
         t3QgTev5S60IvlXQrM8P+d3aaW0oPwVAS5OhIUot2MjfZABU2mpjE3jm5rcpGMlrpqxz
         7G0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H4+gaLab;
       spf=pass (google.com: domain of john.fastabend@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.fastabend@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r184sor48443pgr.87.2019.06.26.15.25.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 15:25:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.fastabend@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H4+gaLab;
       spf=pass (google.com: domain of john.fastabend@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.fastabend@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:message-id:in-reply-to:references:subject
         :mime-version:content-transfer-encoding;
        bh=5oPhE3qEEt+RsciwWt3P6Fjbl5mc7GWFjnz4iQlRxp4=;
        b=H4+gaLabIccSX6EPGUvDOCU/qUWZUMhDbwijJ4DRhclRYA8njNCIhVON5hmDAmRjyP
         us29dx6wXrDFhkSBYtZP+QnMwkUxbt/b/NT9soEdmAxHwSGDaPDlwMwZgzNqXvOH3aso
         2f9q6yIIHe7gJ8HNtc/aWgiuXhoX0rzuU/K2diGjE5ZK7pdDMd0B1uW+/Dqe1477OhVx
         IrxhZdW9rbOcpZWyMwh65fNWDmD1Ll6t3XZRsVs/yuRwUQPPont7siNBs5QFWibv8n+w
         EzcCqvqSOhG2s0daMmj+Bt+KKOTRXLXfDo7Yn5/MIDQw8qOb7G3VrVDpkXXeUeybpeyV
         P4mA==
X-Google-Smtp-Source: APXvYqxmpsROUGAEqYL8EDVOV7OByHymtS0Mqk4ScvgHjMvlv0A3sn919heSyv/nLXtsc2sr0jMmeg==
X-Received: by 2002:a63:e40a:: with SMTP id a10mr260601pgi.277.1561587899713;
        Wed, 26 Jun 2019 15:24:59 -0700 (PDT)
Received: from localhost ([67.136.128.119])
        by smtp.gmail.com with ESMTPSA id u128sm297015pfu.26.2019.06.26.15.24.59
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 15:24:59 -0700 (PDT)
Date: Wed, 26 Jun 2019 15:24:58 -0700
From: John Fastabend <john.fastabend@gmail.com>
To: Eric Biggers <ebiggers@kernel.org>, 
 John Fastabend <john.fastabend@gmail.com>
Cc: syzbot <syzbot+8893700724999566d6a9@syzkaller.appspotmail.com>, 
 akpm@linux-foundation.org, 
 ast@kernel.org, 
 cai@lca.pw, 
 crecklin@redhat.com, 
 daniel@iogearbox.net, 
 keescook@chromium.org, 
 linux-kernel@vger.kernel.org, 
 linux-mm@kvack.org, 
 netdev@vger.kernel.org, 
 bpf@vger.kernel.org, 
 syzkaller-bugs@googlegroups.com
Message-ID: <5d13f0ba3d1aa_25912acd0de805bcce@john-XPS-13-9370.notmuch>
In-Reply-To: <20190625234808.GB116876@gmail.com>
References: <000000000000e672c6058bd7ee45@google.com>
 <0000000000007724d6058c2dfc24@google.com>
 <20190625234808.GB116876@gmail.com>
Subject: Re: KASAN: slab-out-of-bounds Write in validate_chain
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Eric Biggers wrote:
> Hi John,
> 
> On Tue, Jun 25, 2019 at 04:07:00PM -0700, syzbot wrote:
> > syzbot has bisected this bug to:
> > 
> > commit e9db4ef6bf4ca9894bb324c76e01b8f1a16b2650
> > Author: John Fastabend <john.fastabend@gmail.com>
> > Date:   Sat Jun 30 13:17:47 2018 +0000
> > 
> >     bpf: sockhash fix omitted bucket lock in sock_close
> > 
> 
> Are you working on this?  This is the 6th open syzbot report that has been
> bisected to this commit, and I suspect it's the cause of many of the other
> 30 open syzbot reports I assigned to the bpf subsystem too
> (https://lore.kernel.org/bpf/20190624050114.GA30702@sol.localdomain/).
> 
> Also, this is happening in mainline (v5.2-rc6).
> 
> - Eric

Should have a fix today. It seems syzbot has found this bug repeatedly.

.John


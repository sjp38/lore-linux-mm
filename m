Return-Path: <SRS0=P3wr=RM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84289C43381
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 17:00:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2393E20815
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 17:00:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="CZ3rOn3G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2393E20815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DA408E0003; Sat,  9 Mar 2019 12:00:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 660F58E0002; Sat,  9 Mar 2019 12:00:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5513D8E0003; Sat,  9 Mar 2019 12:00:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE0AB8E0002
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 12:00:43 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id d8so135779lja.5
        for <linux-mm@kvack.org>; Sat, 09 Mar 2019 09:00:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8nS/lk8A81pkD+2fljOTlYL+nQ4SnSSZkiN26ES9CJs=;
        b=foAiU506m9qeWxf6M8YHvErDTcXfYX6XssjPN89oBRie6gaLRfaRHJ3bp5RkLHi8a1
         NZXK3Oai8j5o3JOKcQkX17QTjkMw66S/OoPM2GJF6X7zMZLtZ2Pi3lIVOpD/WRgQNYq5
         KBkf/yMgWBSl+8QD5+IdTV0wHDt9B+xb1n99/OYaTHKGv4t61HQFpVWDZYVncq1GKSH+
         i22dxp1DCo0T9NoQhi5Z1ich7oGR8+HQpWmMLIBcrjrgQ9BaPHdGAC7B7gWH7st9c1l4
         AWDWOYg1ar2vjL81Bgd/NCAsg5b1LqcAjHOaW9LY3+39TzERl30Re6Rp471roKiNnE5H
         Br/g==
X-Gm-Message-State: APjAAAVQkx5sewh7W7AIaxmtqFmrBo9AJIH6ND9I5m9eUA7XPnPVr77q
	fip7n1/Ozs81Bo8AfAeqW4raxOf/8ZiBrp6x2Hitpp//yAhiGATaKnP3YLCLVV8Al8q7fh5h3yX
	hQV8yt4E9xnzav8rQJ7l+6/YaNe4qxagQ0EMMoMCbXY5+egcB5PZEJu5tsCFoB9DTk/C86Q0CCx
	EqUeR03oqtbdInu2CwdXQq/suwy3/LPPocHee10mhhO+z2yg0Iyw9KIdPJAybB/hwo4WzhNPBwo
	MwDFtn4mCBjo+k28HsCi7iQw1Zag6gZbDaHbgMBmY+RhVwqUFYaPQaU/liWfLrdmFu485n0nmgu
	eaCSs5qHK/GbwbpGm4CPeLN0Y3DcI5XSIomaf9GnNU9XJ0gABIpb1Ue06pwglvJIenhEOe7tDNG
	x
X-Received: by 2002:a2e:9001:: with SMTP id h1mr12307644ljg.5.1552150842948;
        Sat, 09 Mar 2019 09:00:42 -0800 (PST)
X-Received: by 2002:a2e:9001:: with SMTP id h1mr12307606ljg.5.1552150841731;
        Sat, 09 Mar 2019 09:00:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552150841; cv=none;
        d=google.com; s=arc-20160816;
        b=PPlUkXzAd//np1ftiLX7Sp5u1GZ5t8E3YaZ5HkOs6PARVhGxi/6RSciUvMeVOnDDaO
         q8mhKs93YUhgTZMf9geMg4uZzkBnK9G1EX2Wow8T2uCUj1CEUOvqe3cHnRHMJwTQijne
         J8MsvnwDYaL5jZB4fL44pgnPGttcZhdDfbHeV1PtgypMqPZQ/wiK0b8fGSrjY/fuP1lz
         WAO+yLXLSKa2tVgRQHBMRGGQGGOcZ6RSIbmVNTkHkRjWqP4BiXFez4rV1pIBlHNSKgbf
         lqCTDY+fxryQ1zOFC3QlKiBQbm+0xdtNg3K8mPewyfFFCBnD3fMSamv+QCwPZM8ignHE
         cfxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8nS/lk8A81pkD+2fljOTlYL+nQ4SnSSZkiN26ES9CJs=;
        b=XqL1YFGJYQmmNlepEUydT1RwAHJge9L7XX24o2gtsCrobN0629BvQmZqpJLLVNsTeF
         ms3WTZhVI2GfRNsRFzAx2f8lHgCsnC7PwoDMAtAQiCfFQub0NadwMBoGUlh3Q7R60vtv
         qQkdH+BJdIMcdRpMw1p7wkYWqo3Yzp9Qg7M2iC6bSFR59DUPuleNEmB/fVYbyzFaddhg
         3OdegoXutS+BoZ0/eUYuWbtWP/9GzLEFa2/dp9hXN2eQ64T/7ol1Dek5zoLiY9L8jqGE
         v+PaG+FJUGV0UG5aGTmsnSb6PbMfCGSVXYwTJO7dVFlBMpV1jo63bWxx9SKr+QB7d0dV
         mMIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=CZ3rOn3G;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s1sor177341lfc.5.2019.03.09.09.00.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Mar 2019 09:00:41 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=CZ3rOn3G;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8nS/lk8A81pkD+2fljOTlYL+nQ4SnSSZkiN26ES9CJs=;
        b=CZ3rOn3GPwFOfxnLDMNaGjr8n5f1YrWoh1zA962LIUR9OBeJasmMnAl4pi8BlgnXzp
         4kIiTQ0obTUZ2heVpdvDrw59sf8p9Ym0wW3ErL+G0dFZE4bwIhys+QTuhFJh0whsyKBG
         976yXRGJiqF0Hbdf7sbBXP9V67fQSGk719sI0=
X-Google-Smtp-Source: APXvYqz0bEvzSPVOwP0mhNMFkE+xRStI2qLP5bOIjUXI8qP/cxw/Nr1WDdCxnV7HFUuzZ6zjuiP98Q==
X-Received: by 2002:ac2:54b8:: with SMTP id w24mr13311027lfk.9.1552150840673;
        Sat, 09 Mar 2019 09:00:40 -0800 (PST)
Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com. [209.85.167.44])
        by smtp.gmail.com with ESMTPSA id g16sm202761lfb.56.2019.03.09.09.00.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Mar 2019 09:00:40 -0800 (PST)
Received: by mail-lf1-f44.google.com with SMTP id h71so544427lfe.0
        for <linux-mm@kvack.org>; Sat, 09 Mar 2019 09:00:40 -0800 (PST)
X-Received: by 2002:a19:48cb:: with SMTP id v194mr13725272lfa.166.1552150448462;
 Sat, 09 Mar 2019 08:54:08 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz> <nycvar.YFH.7.76.1903061310170.19912@cbobk.fhfr.pm>
 <20190306143547.c686225447822beaf3b6e139@linux-foundation.org>
 <nycvar.YFH.7.76.1903062342020.19912@cbobk.fhfr.pm> <20190306152337.e06cbc530fbfbcfcfe0dc37c@linux-foundation.org>
 <20190306233209.GA7753@nautica> <20190306153819.3510a19ffe510b674a7890ce@linux-foundation.org>
In-Reply-To: <20190306153819.3510a19ffe510b674a7890ce@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 9 Mar 2019 08:53:52 -0800
X-Gmail-Original-Message-ID: <CAHk-=wgFY+yu=mQU=WqAC-_2aU+A6dFcY3D-Um-Q3hXobB8JfA@mail.gmail.com>
Message-ID: <CAHk-=wgFY+yu=mQU=WqAC-_2aU+A6dFcY3D-Um-Q3hXobB8JfA@mail.gmail.com>
Subject: Re: [PATCH 0/3] mincore() and IOCB_NOWAIT adjustments
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Jann Horn <jannh@google.com>, Andy Lutomirski <luto@amacapital.net>, Cyril Hrubis <chrubis@suse.cz>, 
	Daniel Gruss <daniel@gruss.cc>, Dave Chinner <david@fromorbit.com>, Kevin Easton <kevin@guarana.org>, 
	"Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 3:38 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> Linus, do you have thoughts on
> http://lkml.kernel.org/r/20190130124420.1834-4-vbabka@suse.cz ?

I think that's fine, and probably the right thing to do, but I also
suspect that nobody actually cares ;(

                 Linus


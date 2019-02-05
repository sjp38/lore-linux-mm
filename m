Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A006C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 04:05:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F1E520818
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 04:05:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="LugmjNOo";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="aj5iM51Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F1E520818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF6C58E0072; Mon,  4 Feb 2019 23:05:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA6858E001C; Mon,  4 Feb 2019 23:05:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C94D58E0072; Mon,  4 Feb 2019 23:05:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2078E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 23:05:31 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id m37so2365812qte.10
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 20:05:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zjdfF6fptfX7K6A8RaIXFGiKuRzQA5sSSQPwlsRUNkI=;
        b=ZXVzb5kys6TFNZDfAxixA5umBcM2SZh6KoF6WqRkT4rEqDV3keQ2h6lDVHijErU6X1
         7xq1X6jWeGdccN5fdFNi+fLvzGie4Zw/R85BM4hcq0Xhiqmvy+nC3dkgAhLpGWQZjVOI
         6z3OnDOq7p8/SH/YELTxxItEPvRzy+TiCvjFStNn9ZC2DrZAMStDCSupfoi8igu9xi2l
         x4FNqFfDCut9fZ/L+eaX2szM1D2rpI8H+7MCzKxbpK3kbzO/rxQ0yJDk8gKe2JooSQwV
         O0jdUzHh0l1L/GHWtl0+I0LkuFeKs62leyB5ve3/6eSDijN2vrvvFeqCY1QjkQFUvrgG
         kjZQ==
X-Gm-Message-State: AHQUAubi8LAwW4DbgiQWQqLMB0e6FlSInFdHEumZf6r+jaURxXOAgXJU
	qji29/VG07cWsljYb9QlPHJQf7EI10j51NXFqI2d0/mU4xEgcU6Bt9wYSPFQkeS5KqMyVj2u3tt
	oO9wboExQCy3QkfB3etCU+QFGeSs/7q6wul4F4d+dqTMAbVZpomfAHy1BXPmGOy6GwQ==
X-Received: by 2002:a37:8882:: with SMTP id k124mr1997854qkd.1.1549339531386;
        Mon, 04 Feb 2019 20:05:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbBIpC14/SElZ7Ec48e6wjrk/AOj9J4l8pXfXtxG9awRqDOz//N53npbpBulgWhlW/+p4HQ
X-Received: by 2002:a37:8882:: with SMTP id k124mr1997833qkd.1.1549339530797;
        Mon, 04 Feb 2019 20:05:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549339530; cv=none;
        d=google.com; s=arc-20160816;
        b=1AD8dut6P3eLg65OaVj/C/5hm+K0a0ABj7PdSywaC5r40S846eA5xF6KpaMGQ2Wg/o
         L0uMYla9b/gkghrh+ZhVTytYWu+M84TcAdwVOTQkNFRYyT3kJo2ozW9gwxj8F5Fa0eLU
         c1gEXpR6uABog61PLpLMEk+YhpLJJ3CG2vd0JQ1X1N4SynYYuUIFG289L6ez/0FVXBac
         c2bbV/5opNoeTZn2si4n6+QcUPPP/YZ+KoccHCV5YXrR8/qGbU7aQf6dMIqqkcD1nU4z
         neYGcebLV89cBOxEWOkaDCrEhl074CgKt7cTMJwB/VnbKsOg+1Uzu6eFHXDyxnwHVqSE
         Saaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=zjdfF6fptfX7K6A8RaIXFGiKuRzQA5sSSQPwlsRUNkI=;
        b=raN2yarRXhX8by23wYDNndKwIZu67Cj8HeodMoG9wgt8wu49yNBLvSZPVBqnQXZD3w
         Fev15QKOKG8WQ+Jz5Ulhs3wCelEb0BjNLS+iJ6S3FE9kGxeWxIIVgCk0br4CKd7JHYox
         jWOifSJFF5usuDBfgQEc7elBBy2U++WVnFjuqjGkZReYaY+UtoGV04/H0D3XahnmjuYL
         u57Rvzomr72l2Qqj9e88zZzfCzTZdEF9xoDeC8p/keq1UcgirN0WmvqcmTX5VsH4rT0l
         mfOJZCuWWXRKqqmOGGpPt6px8SNhvA9a82+zQexBoULXWkfLZwjEK+k5qmMB1Y3Z7+im
         TSuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=LugmjNOo;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=aj5iM51Y;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id q128si2778774qka.151.2019.02.04.20.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 20:05:30 -0800 (PST)
Received-SPF: neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=LugmjNOo;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=aj5iM51Y;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 35D0021E49;
	Mon,  4 Feb 2019 23:05:30 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Mon, 04 Feb 2019 23:05:30 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=zjdfF6fptfX7K6A8RaIXFGiKuRz
	QA5sSSQPwlsRUNkI=; b=LugmjNOo8xPlcZpoJSrbsH4HqYVvyMsgfdkS39bI2mP
	0Rj2GLsP30vReN2b/TI7L73VqJ9Gt47reLRcEvREwkAhLv89+hZuTDpsbz48dcs5
	UdfaBt85rUYM3fJEyeFkjbbXCwETRh1LXOjkxBpIP0me3cfTGrZdjaeQFjR40CNS
	bVavL6Qh62AzVn6vc932Gp/3yQvw/Skp3B71u0zTfR5MjxEcfJJrdwb4nmja/LHg
	d2oNS/0qE2SLe+uciJKuoWsLgdQ3Ndx9RtWNA++t41oBmUbVdjdEJ/eAws4SRcLx
	xQi0Oksh4DQZQQghsfdjIxMBdRctiLVOKhixuS2Pb/A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=zjdfF6
	fptfX7K6A8RaIXFGiKuRzQA5sSSQPwlsRUNkI=; b=aj5iM51YIuEY22ew+Ns4P+
	Kdw1r07aVzPWKMdzYUUBj6hHiTLCIXvj0N3QlKtgi1FSN9SInDwgf/3ZjSikFrsO
	zp4l88etf6QOhFtLO0S/45pgMJGcjCw4MWk0b8TqYIX7bU6eUY1A2Wp/lWZAX2XH
	MIpGkEiGJwSym3edafz3ipNGDvB9wUh544iTogSswc98/+UtlVopH78hlAnkKJZl
	m8g4uL6BlmGud4iw+++l/+Ixg3BFBwhgcyZ0YeLX5r2NnOF7zgMu4KHGlKhBT/to
	TaONxCw5bD6Z9XnoM5O77MoHAr5oNMyPJPUK3P19Yr62mYw1/aEswvQKbiEAXzqQ
	==
X-ME-Sender: <xms:iAtZXHJ8W9ASse7Tb6dFvhzK7O_Jbw0lqgYZ64njkkZi0uVOuu2eMw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrkeehgdeikecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnegfrhhlucfvnfffucdlfedtmd
    enucfjughrpeffhffvuffkfhggtggujgfofgesthdtredtofervdenucfhrhhomhepfdfv
    ohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecukfhppe
    duvddurdeggedrvddukedrvddtudenucfrrghrrghmpehmrghilhhfrhhomhepmhgvseht
    ohgsihhnrdgttgenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:iAtZXEtgqNo3ELnQBPlOUbIgbPPRimLbKMnOItGk_zmDNAptXRbBYw>
    <xmx:iAtZXLJE5QxF0p4TyFRSl_QoaJaZiVlcEl7FFLg-A03llUA6axjqoQ>
    <xmx:iAtZXPFszyjgAftuTROa7heIlLRs36ts1reOnhnfkR8rZXjheJtoqQ>
    <xmx:igtZXFX3_5YGDM7jJ83l51edoII50ubWESP8DgX5TvFUtz3caC83uA>
Received: from localhost (ppp121-44-218-201.bras1.syd2.internode.on.net [121.44.218.201])
	by mail.messagingengine.com (Postfix) with ESMTPA id A5106E4046;
	Mon,  4 Feb 2019 23:05:27 -0500 (EST)
Date: Tue, 5 Feb 2019 15:05:21 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	William Kucharski <william.kucharski@oracle.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/3] slub: Do trivial comments fixes
Message-ID: <20190205040521.GB30744@eros.localdomain>
References: <20190204005713.9463-1-tobin@kernel.org>
 <20190204150410.f6975adaddfeb638c9f21580@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190204150410.f6975adaddfeb638c9f21580@linux-foundation.org>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 03:04:10PM -0800, Andrew Morton wrote:
> On Mon,  4 Feb 2019 11:57:10 +1100 "Tobin C. Harding" <tobin@kernel.org> wrote:
> 
> > Here is v2 of the comments fixes [to single SLUB header file]
> 
> Thanks. I think I'll put these into a single patch.

Awesome, thank you.


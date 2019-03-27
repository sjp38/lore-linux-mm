Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 923F5C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:27:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 509DE21734
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:27:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZqY9P5Fm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 509DE21734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF0486B0007; Wed, 27 Mar 2019 16:27:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9E266B0008; Wed, 27 Mar 2019 16:27:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C69CD6B000A; Wed, 27 Mar 2019 16:27:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81BD76B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 16:27:54 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 4so5032377plb.5
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:27:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=90GUhgxAUgMQ4hrgT2Dhn2xc52MqyoCxjdH1nrO5eeA=;
        b=tTOivGV/FjCOjziGVzijug2k7DsolkENNKbJQnqsIm4OIRpjH1HujflpQnobb6ar5m
         P8Vihx2xJftDr6z7s5bkxsdQYeYs/zaZumgRIiVMEKmFqF0j6H7U8xtWI0/kPPgoDT9k
         Lb6JkHBLZQyGY1EziYnP4jAGEDZdN5em2AKo+WQxuYWA+Ddj50MkCUc9bDex17kRxIcG
         PJFrq65AiE1qRyL3p8R2nLC0fvNRd4fu+suFajZrCGhw3fWRB7jVGf1fKW37RmwQagzz
         SmDoyWZPb6PIhmjQ11ox1rcCb2cgcE6KVtf6V1W2dh7pH21oTDV3/dnpWqlEsMDmDZbA
         O8SA==
X-Gm-Message-State: APjAAAUzFnph7EtYPBorQWQwUZwTJ7Hf7Cf5QF28nBgkgdb/cM1x3IVI
	v5/R4ZkFYwfU/jnl3JG/LfV0ndX2sCBp1fv2MeVELtw/0TYeyll73mBaBbMkQ6H/AzCigUI7pGy
	0enOeKWkfZISw8ubx9KpCcA6A3y6hqSo1qYzRs5aUIqKMJVw3R8f1G7Sp3JNfP410Rg==
X-Received: by 2002:a17:902:f81:: with SMTP id 1mr4636056plz.216.1553718474173;
        Wed, 27 Mar 2019 13:27:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2IbOHwc0KI9oonuz8gVlPo1puazSN4OzH2bGpRZ6MveBkKZwF7mAeGX67oAVrYbAYrF8d
X-Received: by 2002:a17:902:f81:: with SMTP id 1mr4636013plz.216.1553718473535;
        Wed, 27 Mar 2019 13:27:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553718473; cv=none;
        d=google.com; s=arc-20160816;
        b=Yn/7MMjZy+s3rDy7w0NmgfNVdWgbr3Js4pQpvrCO3VG6TzsYrcfvCF7N/NF9TofBBk
         CumjJYdmmKlZgZ+sDFwdRqhQQKRbkAmM3E5m4bQr4rIyRUxMjNmFuwdKJdOtjU3hFSnq
         /oebrICXe5nFDQgw/RKypqMmXipn+D68HuPEchyt0Y7COgulKWfLiQh1Sr91S+3reHVu
         zyyDR2fl0PUA2BJqTtueq3bf1qmmDeyW6FCUzlRfkpBSRERALWSwRSubol/WD4EbuWTL
         OLYkb3VwLyshp5Ydzv8MZbF0DVreviX8j7NkjhK41U7gNoIVONp+6XYqW2Bxvb9xrAAh
         chDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=90GUhgxAUgMQ4hrgT2Dhn2xc52MqyoCxjdH1nrO5eeA=;
        b=in70iiddrVXy0g/2rvPZiKQC10Sv/rDRu7OdpR21Heb/Cy+cs/NSnmXA1eRp2kh7Et
         O3b+ZOKDiP0MQu5tKW7Zx7uC5ffU74WPf9bkiewbrwNONJrr312fzRygQagRDIE5KKx9
         xezht0ljqcdTPkM0cY0o4djlfPYzQVEcTjZt39NErbTgoHPgpzWGioPaK9lk0uxpfOsL
         A6PgHkUlfAxlck7zWYS0pPkcbFWPWB9RrSa6pdLJ8rlmv8ze/XMbZnlvfSSaXI5ckD9z
         Dwn2dghhIfjp//B3b7H5OMVDhyoQJ+3vs7G12BKlx5QST9U3Owxm4mJCAeIVjN24Rkii
         Ws6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZqY9P5Fm;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g59si20569393plb.281.2019.03.27.13.27.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Mar 2019 13:27:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZqY9P5Fm;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=90GUhgxAUgMQ4hrgT2Dhn2xc52MqyoCxjdH1nrO5eeA=; b=ZqY9P5Fm5UcLyF3hCh9EE4QHV
	ngdGeotfI8cMt3n/M4+mCTPbB0ywkGXExP326Ap0V4poQH1Owb+uhkg3pemx2sxPFvNNGKAiaSVTp
	Qc73irjwqG12pJqYpQ1eoYpdreJermGCY9xfdriwO1kWPzaurLEND2uUzSiMygYZ/wrJQRYct6JCz
	UEbUv56taQUOIEYOyndt8U2ASFKyn2fxtE7fLwzPOfqxAiCQdiox5eo1DeYbOVOTRKH0OorOibzMU
	IUXNpd1gAIU59jf4YdCBMTkSLDeQSIFVRqRBIHfepPc7281qvKCNRVNoHyw2XBpBP75QTwpGGRPcZ
	h/Qiq7eWA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h9F8i-00035n-Ps; Wed, 27 Mar 2019 20:27:12 +0000
Date: Wed, 27 Mar 2019 13:27:12 -0700
From: Matthew Wilcox <willy@infradead.org>
To: syzbot <syzbot+1145ec2e23165570c3ac@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, clm@fb.com, dan.carpenter@oracle.com,
	dave@stgolabs.net, dhowells@redhat.com, dsterba@suse.com,
	dvyukov@google.com, ebiederm@xmission.com, jbacik@fb.com,
	ktkhai@virtuozzo.com, ktsanaktsidis@zendesk.com,
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, manfred@colorfullife.com, mhocko@suse.com,
	nborisov@suse.com, penguin-kernel@I-love.SAKURA.ne.jp,
	rppt@linux.vnet.ibm.com, sfr@canb.auug.org.au, shakeelb@google.com,
	syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com
Subject: Re: general protection fault in put_pid
Message-ID: <20190327202712.GT10344@bombadil.infradead.org>
References: <00000000000051ee78057cc4d98f@google.com>
 <000000000000c58fcf058519059e@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000000000000c58fcf058519059e@google.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 27, 2019 at 01:10:01PM -0700, syzbot wrote:
> syzbot has bisected this bug to:
> 
> commit b9b8a41adeff5666b402996020b698504c927353
> Author: Dan Carpenter <dan.carpenter@oracle.com>
> Date:   Mon Aug 20 08:25:33 2018 +0000
> 
>     btrfs: use after free in btrfs_quota_enable

Not plausible.  Try again.


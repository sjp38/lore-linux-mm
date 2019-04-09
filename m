Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C0CCC10F13
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 02:54:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA45A213F2
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 02:54:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="clvnIESy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA45A213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57CBE6B0008; Mon,  8 Apr 2019 22:54:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52A1F6B000C; Mon,  8 Apr 2019 22:54:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 419796B0010; Mon,  8 Apr 2019 22:54:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 09E736B0008
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 22:54:57 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id x5so11356955pll.2
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 19:54:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0Xj8zhLCzeTFxHr8TcWbrxXHhH4ZpaJguBiDDKrkeXc=;
        b=nlSlW/m85zH+IhWDG3JlMHUrpna2ueWioHPC0mFZ0q5VpjiSk4cInglB9MvyWWXPRL
         Y8lhd7G5jhLZDyCkTfzSVkwB3eUbZVoqct5r+1nkg28USrnrutPegY7379lSqfJpuwuM
         DQZoMi8QsBdsOtqI8UZdBpda+tYSPg1Z+NjMSi6Z4f0LgVDBa5CqpWn1zacWxV9P7pbC
         siIK8FxeKPiUgc9moOwaofdWPhmXF+PVe3KNav4pX1dUOJjg/A4cHxZ3qyH1uCYPpXz8
         QjBGe9F5eIHsWI3ANNXmNzm0IFRUlCAfDg5Vy9YWOib9CZwqkJZLGHK7bl/DXhwIcls4
         8HFw==
X-Gm-Message-State: APjAAAWiX35m6nFAmaAM1cpT6VTcTAuCW3T0vf4bWK6jYYUCmVHNvbzV
	VQ2DDrOTj4P4+nQ9AqCmcz8yLwr3GrPUBMroT4wHknFCQ7uEwIlOziVcbbxiUrztoVXsVTd8D4d
	sSMNmeSfQYmLD5rYkWKJnt1B3SHajf7tIPJr4jzyw4zyc8fMfJGxcs1Qt7Zy8zMy4Bw==
X-Received: by 2002:a63:d444:: with SMTP id i4mr32689882pgj.149.1554778496543;
        Mon, 08 Apr 2019 19:54:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOhVHaACDGNhQxbKkZj7sVoSV0EllsBILJgXom/8ifODHNDp63MDQeqn6WEFt5C+9JAhZE
X-Received: by 2002:a63:d444:: with SMTP id i4mr32689841pgj.149.1554778495819;
        Mon, 08 Apr 2019 19:54:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554778495; cv=none;
        d=google.com; s=arc-20160816;
        b=ZC7DzrxKLk4K7pKrR5hLqMOXP1AD+DJKEOXm+nv+7U7pweh/AapcJDNY9XkU37qGBo
         BN2KTIZs0jP/YaMkmm3t+qryI3V74Uc5gJ8zM2NSXuB+phA1fWQaG08rXqlUQwSR8QAx
         USkAy/lecoCGr8GXSOETnEPJeFDuhH0MIjwMm9F2F/QTTgjWgiNbcvM2tTenhDJvB9zs
         vpOBgF66BdlQo5zcnFtEM1SBMPj+UZT8uWY9pziGOmp9402KiNBkTKtJn8+o8DB4Jx3f
         1u3aLYYiT++wltPccXj/TjYkMwxjNYy9bX0mTv5GptWaO+zW02j2kuy03fJ9o4gMMWow
         8YjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0Xj8zhLCzeTFxHr8TcWbrxXHhH4ZpaJguBiDDKrkeXc=;
        b=HwlCy3YnlxTV4fqGJJ+CatFAGNlpapNWovr+idA1dohmF32RgncuaimsjEIy1jYQO1
         Z4gtz2u8bdFR6doLBCi6io6UP6CxBO8xLwRC7Jie7MFGrJUXW79G9m9y0ZgRVQsp7UUp
         A+oeMywfast17dS01G1vmD/WT6V7vPM+3eeLx8BccPgykomwFPvmFRjSVkZ77VW9z9X0
         R5tEdHUMO+2jAgmZtv8g27bQ41Gwp431cw7grpCb4L9vjz0wfzb5EmT4sYL/cYMQuLNT
         46ZMzfypbAQvsHKk7jHWK9opkHEZsYBB2B5m+B+UR0ypLXC/vz8lD9aADMqUkjUg5yAp
         ONkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=clvnIESy;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q4si21858178pll.127.2019.04.08.19.54.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 08 Apr 2019 19:54:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=clvnIESy;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=0Xj8zhLCzeTFxHr8TcWbrxXHhH4ZpaJguBiDDKrkeXc=; b=clvnIESy+HewfFcgtwh7/pkRG
	Pp59QzSClAziE0ntBSnSD//KmxwWt/zqY1c/gPascj1STKUXPFPvAbEIrLxw6MzWJmNBlhvQT9nH3
	F9rgUPkXTpXu5oSHZfnbsLPsntKWXMOzm5FMpwV+mOelg1TUg32BGXgq/0gcY1BrsuT49/qkSL7lT
	9oO880iHtITsCgihrl+mdEJbTioys1V+VmtlogAk0UnlCKPuPbjrdvupz2+Ff0ZicdiXw8Ec32VrF
	rrhiYxSkzDD+5OpmlSLVdAWHMd6gKYZ+qZUBUuFxmXNGKVC4PjVqVaYRAZedM1Jga/9iozNkGd9MM
	74TbGlUYA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hDguU-0002uv-Ol; Tue, 09 Apr 2019 02:54:54 +0000
Date: Mon, 8 Apr 2019 19:54:54 -0700
From: Matthew Wilcox <willy@infradead.org>
To: luojiajun <luojiajun3@huawei.com>
Cc: linux-mm@kvack.org, mike.kravetz@oracle.com, yi.zhang@huawei.com,
	miaoxie@huawei.com
Subject: Re: [PATCH] hugetlbfs: end hpage in hugetlbfs_fallocate overflow
Message-ID: <20190409025454.GX22763@bombadil.infradead.org>
References: <1554775226-67213-1-git-send-email-luojiajun3@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554775226-67213-1-git-send-email-luojiajun3@huawei.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 10:00:26AM +0800, luojiajun wrote:
> In hugetlbfs_fallocate, start is rounded down and end is rounded up.
> But it is inappropriate to use loff_t rounding up end, it may cause
> overflow.
> 
> UBSAN: Undefined behaviour in fs/hugetlbfs/inode.c:582:22
> signed integer overflow:
> 2097152 + 9223372036854775805 cannot be represented in type 'long long int'

This patch can't fix this bug.

> @@ -578,8 +578,9 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
>  	 * For this range, start is rounded down and end is rounded up
>  	 * as well as being converted to page offsets.
>  	 */
> -	start = offset >> hpage_shift;
> -	end = (offset + len + hpage_size - 1) >> hpage_shift;
> +	start = (unsigned long long)offset >> hpage_shift;
> +	end = ((unsigned long long)(offset + len + hpage_size) - 1)
> +			>> hpage_shift;

I suspect you mean:

	end = (((unsigned long long)offset + len + hpage_size) - 1) >>
			hpage_shift;

Otherwise, you're going to do the arithmetic in long long, then cast
to unsigned long long before the shift.

BTW, don't say "this can be reproduced using syzcaller".  This is an easy
case to extract a small reproducer from ... which would have helped you
notice that you haven't fixed the problem.


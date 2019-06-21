Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46E4AC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:16:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FA1D2083B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:16:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="dAlun1Hg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FA1D2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BA2A8E0002; Fri, 21 Jun 2019 09:16:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76AAF8E0001; Fri, 21 Jun 2019 09:16:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 633068E0002; Fri, 21 Jun 2019 09:16:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 445248E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:16:13 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id j128so7421023qkd.23
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:16:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=IQElyJy7GWkNBjpDGeWXQk4uiZdHF4DIvT5Nq6LmxE8=;
        b=TivwZSfugsUzBcYZ9RhFHV3gzhSBWUKVs2t7PJvZy/0ocUK9mPBYoA04YbDLtL28lS
         FdmNwc6EyDfdkfCGgu2BYONt6XPZYV8yN5HBqM4yMurDDgTqWhSdSTgJtvlMtNYxHkhF
         Kynt6LpPXa+ZQNmUpFbNiSjLJMluBr8Chn4a9aXLPM09ga/VaNZLpvlSxWiljokbQrJI
         72F1W2Cw/m8nzIsItKSuMi1t9NCyTFT9Ro/726Xm7zqI41RhassbXy864b4QwfnsDva/
         1ME6XMzYmLtRdPV0Qz7ErKCSnfd0+vko7WXaXCtlpgj1nZsWMZrQpCGbcp2f3sr5QLIU
         ovQA==
X-Gm-Message-State: APjAAAU9G+TuQ062FxxnARbqlNlwBzJP8MYD7SHWbgVlRB3ry3MFyTHa
	bc4HvWhzhsmD0dOFaD3ZCtv24Ven6SFzQpXFE5qDxV/DWi4GA7VmlDuzcscP0qHIOw8sc+KKngA
	YC5riqtWtMwHegNqiq9dKB0jkwo9c/VW1bUNX5gIg3o8/tn3aou7Mlba5h2VaCa5kyw==
X-Received: by 2002:a0c:bc07:: with SMTP id j7mr4525855qvg.76.1561122973066;
        Fri, 21 Jun 2019 06:16:13 -0700 (PDT)
X-Received: by 2002:a0c:bc07:: with SMTP id j7mr4525760qvg.76.1561122971880;
        Fri, 21 Jun 2019 06:16:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561122971; cv=none;
        d=google.com; s=arc-20160816;
        b=AB8LGAYB9RhEN/xOA3WznfAmi9kAbF63wejhXnnftza2uTgcs6FYxJf9/nDpmOskyW
         oEg9OIuJV0cwGakbPCR75H9KWIYNqS2pWhkjA2F16YJNlNv45Fqpq2I6I6jb6Oysu8Af
         8Gnp1ZrVUbL3+9I7VU8AzgKMY3wkGtiODmOH/vGUbU8mcBcOe5Y9opYhoJZHprlKVIWB
         7wTOQdGkm5SpHPKWqqny5YlyIEALSxIJfTx+fb+MEXMiYT1xdvyEyDxiZto1v5ZDRVyd
         YAAyohXUPwmZvqzrsNcWwZr4w2/k1JJznoeL+Wpb/6Tj97z91EoBF/ICk1rLqtnZMgki
         NAtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=IQElyJy7GWkNBjpDGeWXQk4uiZdHF4DIvT5Nq6LmxE8=;
        b=XzC8uewGOatn+uynjd93SHoqCpVTr/88f/UT+h6ECeY8q3zooXHDi6zKAo3DT0RdMp
         K9RrK2fWMMz05Xc7kiyyIbxcH2Ob1NIHF6bgBFecVM7HVT7C5aY7/YVM6fUs1cYfNXto
         tUpSEYC1SWW1k30EqwTSy4UytCfFQKbyhJs7lU1VhaDFO84D2fgPO3ppK8oaoT399QmL
         pYk7MjDW0ZS8zIjYVWl8AlFuI9vS7xApp3XH6vmBIIN+nVv+KZ+nrG0RIj149FW9Wbhj
         Dq8Dyd8wi49uSg+5c6LIBuCxoYIdhj8JeQjnroC6FX4xXf2dmy01gRS1k0KeeK1QmUfV
         kZhA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dAlun1Hg;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v188sor1490083qkc.93.2019.06.21.06.16.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 06:16:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dAlun1Hg;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IQElyJy7GWkNBjpDGeWXQk4uiZdHF4DIvT5Nq6LmxE8=;
        b=dAlun1HgnUe7022YkQS6GWMYxR1o5c8vpg7JqEcJa5EPCdLDLVoVyNKQvqmZhtNBLF
         WpB9JM8/T8dBcxbgb0A781lKzoM1O/pMV5gbPgxu5rSpwSDOdrQZP84Rnb3SOamIN0Wr
         zqwvpJy81nkQ5T+CDcckayqmm3eCo60vgpfs1x9K8ufP7D9ZXElAHaqtpaYy7p5iJE/y
         l4SUnUVsNsnn39sHqAifpgiGxKut8u7nW0gFTVC/+FCOE5qrTg5md8qyqRNjEUqfK8fM
         2IShZOwM3jYukwEVdkuYU+31+Rw+P2EKrT1nUVgmbwp7XxSFSraMeiH+ei/K/LHG/DXJ
         LUbA==
X-Google-Smtp-Source: APXvYqzJ0dyt2+hyzdXxi/NcBy96mwSHUO+pPyyWhj5oMJpKDFijtNxh/f3duoRgranP7T7lVqZ1hA==
X-Received: by 2002:a37:a093:: with SMTP id j141mr90247251qke.244.1561122971647;
        Fri, 21 Jun 2019 06:16:11 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id s23sm1691094qtk.31.2019.06.21.06.16.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Jun 2019 06:16:10 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1heJOk-0008Dq-Dw; Fri, 21 Jun 2019 10:16:10 -0300
Date: Fri, 21 Jun 2019 10:16:10 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 01/16] mm: use untagged_addr() for get_user_pages_fast
 addresses
Message-ID: <20190621131610.GK19891@ziepe.ca>
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611144102.8848-2-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 04:40:47PM +0200, Christoph Hellwig wrote:
> This will allow sparc64 to override its ADI tags for
> get_user_pages and get_user_pages_fast.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  mm/gup.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>


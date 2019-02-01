Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E12CC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 04:28:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AFF120869
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 04:28:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="vEw40XIW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AFF120869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2F1C8E0002; Thu, 31 Jan 2019 23:28:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B8728E0001; Thu, 31 Jan 2019 23:28:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8803C8E0002; Thu, 31 Jan 2019 23:28:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7B08E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 23:28:38 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w15so6413098qtk.19
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 20:28:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lSJhzX9ZcefE+FtHKWw9/SxqHKLxMMc4ebOyRuovNFY=;
        b=T8VPpBL2H23HRvGNyzStji/iFPzJgdfm6Ihl798Wyh422djjd951q6VIqwuZJubVuU
         JVdLHWGmkiZsKoYjh37BUnulptbzf2ewkJ1pWMuDiQGB1f1N4z4Tt4D5r+TAWeeLVXDS
         D4S3icby9iw3R+kc0IeVnes4b1fSZhQvzROgYh4neSRexyk0aYZrxL6p7y8j1R3xHFwR
         MPxr/lwgi5gnPDsPlnZGb//TmW48UZcDGdkChcxJn8tkTK1oS/7d8/7+lowWEt3Cl2Mq
         g3U9v3Kc+XOG2xMKiD60ZLkoT+CEC70RZCKTDVw6ezk9OS8DHxCKGe1u/+ZS/0Fh/3Xc
         0VWQ==
X-Gm-Message-State: AJcUuke19mDCPou5371kGWbNRhb/cEjqd95Qtx9C4oQUriIU0E4L986a
	9S58EsWzU/w5QgtMoRuR1Y//PQoBpUh3YWLwzyhnYz+mPN8YUMzJmyqr670d7gxk2RNdBz/y+qL
	+mo+E9M9kyYehw4i19+Ow7vQxHPdMnF2LK+QjKcGTghdVBfghDIiNqT3ZSnVF13GH+ZMQoX2tMy
	gNRsgtqgC+sH69NTHNloTLFohl3kYkzDJAbLFFSho00NUaP32rQzNgisJbaUP/sTcUOKYhyXYvs
	L0HEzmFSA7Exgu914sWXry8FxRUEdRLAMdsx/5BQPy0s4+VK/Utzz9U2mMo1fXQRk3KwLmWlPRQ
	/ItJe1YwrCNw7Lu+KlGhBLBQzWQ8YPlPIwcjHdrMwLFUOyt6qB3BUF45rfPfCGANALmDjkmu0wL
	e
X-Received: by 2002:ac8:1490:: with SMTP id l16mr37727493qtj.222.1548995318089;
        Thu, 31 Jan 2019 20:28:38 -0800 (PST)
X-Received: by 2002:ac8:1490:: with SMTP id l16mr37727476qtj.222.1548995317600;
        Thu, 31 Jan 2019 20:28:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548995317; cv=none;
        d=google.com; s=arc-20160816;
        b=jqJWULLpomBxNcRo20OS1gmuEIraF/wWWoY/+tBbVwBrsmC93+4xjjA72VZUKNCIuz
         6ihqGOXhWfyivV7KRClI42qSZ2xwR5vBkK+Xi7WVaKa/QdMiqdDurEoY8uW+KiJqQe9D
         dqvVs1KUJIimFSw7o6vEI9hDTLBW2D5EeQM9VjLWq/uUXGeuYG0KkS72b7kF19+QqI6Z
         2nMRcSzMYyIVkiHIaJwhrkUCmDyazNJJ5I5TYClegHzemjSxC5etQV+Ivz4o/j8hrgLY
         Nsc4t2CEuwbFiWosIBp48sL2finBi2+Re9WFN+Bd4PGhbTDPQ25HyIFso7UAk1PAb49b
         WRXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lSJhzX9ZcefE+FtHKWw9/SxqHKLxMMc4ebOyRuovNFY=;
        b=R0h6L4EFsNOLMv0gg0vCZlr17GqDP9bRUbwyrmSR/hgvV/8FLWMqgzgP+OcCFyBWXw
         iYfXHGyXCTVKoRT0refnT7chX/7Lyv38FUDUjClxbCIF/WbGkKiZ7OD5M66TpLiP6CvG
         qoXXoXt1qFf2e1vxsG/6uowIGAnqFUKH+5lLqKqp0QWFJD4HACfhcMRysRCFXvxrGVbC
         qOk/VNuzEIdfoIi1RJJFd3mBnCOor1k3S8jTpc+yIpNbqWDYa+1P0z/NK2QGjMEB6w+f
         Rmzm/Dm8bXzs2DqRkrMrNMldgF5oQkDuFRR9EWuuRJAJgL7XVed5J46ZgLRqjUy0ndmB
         VLCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=vEw40XIW;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b18sor7241085qvj.55.2019.01.31.20.28.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 20:28:37 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=vEw40XIW;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lSJhzX9ZcefE+FtHKWw9/SxqHKLxMMc4ebOyRuovNFY=;
        b=vEw40XIWD7uCLn+QNRWDXmerWbm1nvBuAuquUXTwt0VyD1W3Xa8ISPNIr8nBxdtnqp
         bdPTrmZ1h7eU4MhGhk8+fXGTmncml3zzLFuDjSz2J+chKd5TCn+8nmVHA3p8P6Jcz2to
         cSxdBtGNNYUao8Uqns6zFCmPlhR3u9zbImi4Q=
X-Google-Smtp-Source: ALg8bN7tIg3LF4vRVk8yjLiFgnYPoQ91hY+SgNbOa4eOi3VWH30PzTJwVn/tePmXxv5YHY6T9llWrw==
X-Received: by 2002:a0c:cc8c:: with SMTP id f12mr35463112qvl.102.1548995317084;
        Thu, 31 Jan 2019 20:28:37 -0800 (PST)
Received: from localhost (rrcs-108-176-24-99.nyc.biz.rr.com. [108.176.24.99])
        by smtp.gmail.com with ESMTPSA id t43sm14565667qtc.53.2019.01.31.20.28.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 20:28:36 -0800 (PST)
Date: Thu, 31 Jan 2019 23:28:36 -0500
From: Chris Down <chris@chrisdown.name>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org
Subject: Re: [linux-next-20190131] NULL pointer dereference at
 shrink_node_memcg.
Message-ID: <20190201042836.GA1529@chrisdown.name>
References: <201902010337.x113b72e028186@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <201902010337.x113b72e028186@www262.sakura.ne.jp>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hey Tetsuo,

Tetsuo Handa writes:
>Commit 8a907cdf0177ab40 ("mm, memcg: proportional memory.{low,min} reclaim")
>broke global reclaim by kdump kernel due to NULL pointer dereference at
>
>   protection = mem_cgroup_protection(memcg);
>
>. Please fix.

Oh yeah, memcg is null if memcg is disabled at run time but is compiled in (so 
this works with CONFIG_MEMCG and !CONFIG_MEMCG, but not CONFIG_MEMCG + 
cgroup_disable=memory).

A fix will be out shortly, thanks.


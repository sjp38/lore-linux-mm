Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 175A5C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:05:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC941217F5
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:05:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IvUXzBPQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC941217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19B2B8E0003; Mon, 18 Feb 2019 16:05:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14A8F8E0002; Mon, 18 Feb 2019 16:05:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03AB28E0003; Mon, 18 Feb 2019 16:05:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id C6ED08E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 16:05:08 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id p62so11823491ywd.3
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:05:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9DzCR79XKeIjL7+2ReBiux03I1IsbcYYGjv2zjhhJ2U=;
        b=h3t/fPPdeHJ3hHQuIJyDZLV+lSeDK2Eeo1U68frwrALKTY+hLQ3TBdjmgoUtJau4rY
         JIxdl5yHKGyO+jw2GboC7Mhskc5uT/uNJ6FWETtNLlKDUONZteX8TFUn0JZoYWUdN20G
         2wJc1EwJdW9N6TheR10Z9kQvQTYSV11d3JHccYDn9tfige8+o3eO/Dq8J7gwWum3R3s2
         IEN20i6D+JDzPAHLaHS4HcVPMLEvnFCYgUDZc315EcZSqpr2Hk7sEuJPVTD4YiZpYfGR
         1AGaAhFNeyt7hFddSqB2nEj8JBMNsedMirKecMKbWGLqpLXkQb4cbgsu/L0zt4U/Kdon
         kuWg==
X-Gm-Message-State: AHQUAuZ/IaZr1PxxCQYFZYG0RzTe4EQmN1zGkpEgfMfbSOqL2n7aFRwH
	NpRRbuj8g2izfGYHSrxT2NMDWwlIBnQbYG3qkDwnaR2oPFTB/JogwQSyqUPFr7K96Iiz2gaRtOn
	78Lc1Bpj+txdXfhewXibVWVQ9/nfQyHRsx6/icN7TjOdqwE6XVqkY08+e1joi5eC6KhwjuTAxzz
	RRuSkez9XCWaCvrPbxxd3LI4cGVdFuBUTXuizdoQCBLz9Odd8cUyh8pxx45hHXYaGXHqu4PZak4
	oa0yBx4mfJNbY2RX7NJ0CO0LmPsyCDTzhDNppI7xEuDA0hYjYi2wJgGj+WyTJ87h7hA8wlvQp6S
	2umTK1AC0Q3bCzUxB5LVjHEpLKVOZBxckLfvVvq28ofx2pfKgHzfq92CWD3YTbFXJZvS2PK7zA=
	=
X-Received: by 2002:a81:6c86:: with SMTP id h128mr20857484ywc.477.1550523908414;
        Mon, 18 Feb 2019 13:05:08 -0800 (PST)
X-Received: by 2002:a81:6c86:: with SMTP id h128mr20857430ywc.477.1550523907814;
        Mon, 18 Feb 2019 13:05:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550523907; cv=none;
        d=google.com; s=arc-20160816;
        b=oA5cyynlEVLDYhZB8ERgfR8LPdzPIhnVUSRfLU03uByox9n4eDbHXTGYQGXmKFSxap
         Yx0PEujXk+F2eG9IRMWubcBQ8pSbpzpL9jYRX7uWtBHWuC+juqsf2KJoISC3b3efjYap
         ore2tje/31aOVISk4A2KSZtb+SiUKR0/CK840UOEdkgDg0OIapkYyPrHd5rwMrJfMuaE
         nDPUjmIeG/od1vXtjm+7VF39JQclBemaJ/BkR6bzw9cuZacxa02PuQMevaI00QT9VnaJ
         Raai18qUNR99w1v9Djnmlyy+1zb1jeluTuCI0PbzVujCB5tMduW29rnXs8hO2upnHqFs
         EYeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=9DzCR79XKeIjL7+2ReBiux03I1IsbcYYGjv2zjhhJ2U=;
        b=RcVKXJ5yYJHSpLLRvNqREZkcOD7nqG4xy2sYRvdMRJ0mzhC4lYw5PvN8wgYSK8cu7b
         luj2LsPwPesfdxFd1LsAGE1lcLwXKaNsXFPhftwtHDwf0pWp0vtpOnFf6yHNHW/boAEw
         yjJ5Je+87A9YVs8gipU88+EkggvS2d16YIPGmldKnA4MUQpw9yFse0fzbeNUwOuMaghN
         vs+1TODlziO6cIahAPfvMW8XabBjtMZ8sQpJpsnyYCWQKL85OPiYnAeJp7rtDkg0gHzz
         vnl1niHPEN0e23sdKZNajCx88kvn9111Fhxz1FKsw+801CWbjX7ly+1+X9ofGDNYAM5v
         q47Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IvUXzBPQ;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 80sor2437578ybf.129.2019.02.18.13.05.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 13:05:07 -0800 (PST)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IvUXzBPQ;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9DzCR79XKeIjL7+2ReBiux03I1IsbcYYGjv2zjhhJ2U=;
        b=IvUXzBPQJEIyKxoXbz4dX0We4ImmqwmBbZb8b00WHoEnhmrQvX86N2WSx0rP1NzXFS
         uwDuVGKTJxW0Bg0RNeRMY2lqSxHlylMUB1QW2kusIPBR/1eSRw3pLDFw0DxTiX4xKIJH
         HI39c8dzh86yRNfROF1J4MTzi+z8cRaElf9D2wcp1bxf3Ak2psiTe3TVvbaMcSCeL0xz
         0v5+CKY58TFKGjYiJixaNyF/JCodpDsL5qER8CF0AdDGaUzq7o2WyEBYDVhxhqSvThX0
         wA2HOyR7hXaqWcIJ88Uhcpnx5RhK0K7pvEyKDaPBn85ZliSQTNNAHNknlI/GapPFjD4Q
         6KrA==
X-Google-Smtp-Source: AHgI3IZQ85hICO8PJBHbJ2RZysx/uNUHQA80/Hg8S4A0SZHPMgNXU2TbgLlCgJHTrnqFDEdrI6avxw==
X-Received: by 2002:a25:d04b:: with SMTP id h72mr15655803ybg.152.1550523907337;
        Mon, 18 Feb 2019 13:05:07 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:2c70])
        by smtp.gmail.com with ESMTPSA id z23sm7007499ywj.36.2019.02.18.13.05.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 13:05:06 -0800 (PST)
Date: Mon, 18 Feb 2019 13:05:04 -0800
From: Tejun Heo <tj@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: hannes@cmpxchg.org, corbet@lwn.net, cgroups@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] doc: cgroup: correct the wrong information about measure
 of memory pressure
Message-ID: <20190218210504.GT50184@devbig004.ftw2.facebook.com>
References: <1550278564-81540-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1550278564-81540-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 16, 2019 at 08:56:04AM +0800, Yang Shi wrote:
> Since PSI has implemented some kind of measure of memory pressure, the
> statement about lack of such measure is not true anymore.
> 
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  Documentation/admin-guide/cgroup-v2.rst | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
> index 7bf3f12..9a92013 100644
> --- a/Documentation/admin-guide/cgroup-v2.rst
> +++ b/Documentation/admin-guide/cgroup-v2.rst
> @@ -1310,8 +1310,7 @@ network to a file can use all available memory but can also operate as
>  performant with a small amount of memory.  A measure of memory
>  pressure - how much the workload is being impacted due to lack of
>  memory - is necessary to determine whether a workload needs more
> -memory; unfortunately, memory pressure monitoring mechanism isn't
> -implemented yet.
> +memory.

Maybe refer to PSI?

Thanks.

-- 
tejun


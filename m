Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCAABC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 17:55:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 926B820857
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 17:55:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="kFFLkALG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 926B820857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40E536B0005; Tue,  9 Apr 2019 13:55:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BD8A6B000A; Tue,  9 Apr 2019 13:55:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AD716B0266; Tue,  9 Apr 2019 13:55:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06AB06B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 13:55:55 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id j62so10082543ywe.3
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 10:55:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3OMM1jjLUtp77ZuZftwNpMZ7UA8qcMysDy9G8TMkvI4=;
        b=f+WtlNLwuQrYDpmWX7NXxw495ls3xGoG9txBqoPKVT7q22oxuWUnRzk6aNzTpxJxxK
         KV4D+OKVuHXs3Rq3j7w3rnR0q83UJJpo7FJEEbG+BLh8bW01wMsWaXWtJep6dHIOPHKD
         XErotvNEHBxCnkiUeLJTJGAtStky36eUanofdqds0Sfzd+kpr0uM8PLc+d16WVYLKF/G
         7TLHCO766Z3d599ANev6EPi8nQxZtQcVvF6Mlc3WPEeXMThujoAPwVcDxIfY0bHexDE4
         6WhV6uthRWuH+QIZjX65XyMd1rZVnfM+zCiXLkJtHKREDCex0rIiSbheNzUla3PLlqrU
         aY8A==
X-Gm-Message-State: APjAAAUHzWkLcHnVb5bxtmjq/L+8aYIfN4IgLmx5PJD1yMJlUIU7C8CV
	qWnvR7M0S2y0AsLbKkpO/nLgWAMziBCeyaruvGsZ8Sqk0+2It6ObUHUm9eQc1DvpA9Y7oRp3mOp
	IZaa5tXQCIdgjIdc+CVa0JdGgAAeuoAyROtHx0wguxlKBg/427WvfYJB3bRSo/yYrEA==
X-Received: by 2002:a81:29c9:: with SMTP id p192mr30227853ywp.250.1554832554596;
        Tue, 09 Apr 2019 10:55:54 -0700 (PDT)
X-Received: by 2002:a81:29c9:: with SMTP id p192mr30227823ywp.250.1554832554077;
        Tue, 09 Apr 2019 10:55:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554832554; cv=none;
        d=google.com; s=arc-20160816;
        b=zkjBSYZrE+3e6WqKylimQcwYXAk3l8odcmzxNXmE8IeGIepqQrOL/ZQ+DSKyPzHlFB
         u4keCXKERKdjmeBvYEBFTpvL6LBxoZgNOaYIf2Cj35z6PC4u4RemLvXTMW4Xz/DkQvJW
         c/kphlU0cdTJg3lhwRT6TICVs0k3fWbI6Vq7kLLZ+bsuN0GtQx0mCF9jBnLEcPxTUdCh
         t9ONbcqnp2/WX0nMQx0KIFgz7gZ3eg8QjtaI32FzpNCVtf6G299ajRjX4k/Qv/hzwS78
         7hQtbq+PWfbpel257YxnbwDLGjlZwxKCkJyl+2o6rl5bSuOIQE7HRSywm9f0DCfr8oyW
         KgSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3OMM1jjLUtp77ZuZftwNpMZ7UA8qcMysDy9G8TMkvI4=;
        b=yGItshJjXS+6n/Q9DU1i4ib9OsLevMqDN+h+Uu+DlLvf7l0//6FV5w7QZk4cU6hE1e
         SK1HfLbErP72vFiDRljEYRGXfNJc6vlDlEXLITKX+oc9Jiza3kKVPgdijAlz9XJUX3Cx
         YwqS1leXU5VK/gufzlwnOyz81tc0JgZXESHVjqSFQeQvwnYLqZ2BUmCzKcZaksmveRVt
         I/lyaDa9YiMfzRgyFQ9e6SgbiXtYjMEvXeLbZE++5Jz39V04YtOvRsbVw7uA9aOnGlos
         MSwX2BNT8wGgrVD3HwWIdG+l1qrXGLF6f0+X7c+FWNPmTI2xoq09FQsmce/PuQ0kwS3T
         LZJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=kFFLkALG;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b8sor12098754ywh.21.2019.04.09.10.55.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 10:55:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=kFFLkALG;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3OMM1jjLUtp77ZuZftwNpMZ7UA8qcMysDy9G8TMkvI4=;
        b=kFFLkALGNh7D8fYI43wL8e00FCgu6+qHknpBz51qXjk7+N8z22Sa/whoCzFqZDomqg
         bANlSDVuWdu0zBW0ew4aBG8xMatZjKNuMDMeXWbTLjsS6lBhb7grzg0NotNCTdvCVtPj
         fgHetcOk4ABmu11Tlk08Pa2UQx749eqjdxYNd87IBNs9w5MN6VQSuN7uuKqIWyvhEF3N
         Ui3DONtR4xHUyo4yJtNIAn99yelruMd6QGILoBhhLLX2Ftr3Xr7xylbGHfPBuX3SSjW7
         0ca1ECy6la8pQv2cg/jDDz9JBolpflOhMgDHqCUfLfEsTYMTHDfqOkpHuV08JBkNIC/n
         0tHA==
X-Google-Smtp-Source: APXvYqyc7FjoTH6KTLVPh3Js/lAMap6TIXWrwir2DQRko1TMyaigZLz/z/Caq92ydhEsnxcO2uGOLw==
X-Received: by 2002:a81:9bc6:: with SMTP id s189mr30407604ywg.431.1554832547252;
        Tue, 09 Apr 2019 10:55:47 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::3:701])
        by smtp.gmail.com with ESMTPSA id 74sm13091832ywo.5.2019.04.09.10.55.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 10:55:46 -0700 (PDT)
Date: Tue, 9 Apr 2019 13:55:45 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: mhocko@kernel.org, vdavydov.dev@gmail.com, akpm@linux-foundation.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/memcontrol: split pgscan into direct and kswapd for
 memcg
Message-ID: <20190409175545.GA13122@cmpxchg.org>
References: <1554815623-9353-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554815623-9353-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 09:13:43PM +0800, Yafang Shao wrote:
> Now we count PGSCAN_KSWAPD and PGSCAN_DIRECT into one single item
> 'pgscan', that's not proper.
> 
> PGSCAN_DIRECT is triggered by the tasks in this memcg, which directly
> indicates the memory status of this memcg;

PGSCAN_DIRECT occurs independent of cgroups when kswapd is overwhelmed
or when allocations don't pass __GFP_KSWAPD_RECLAIM. You'll get direct
reclaim inside memcgs that don't have a limit.


Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9B13C43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 21:20:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EB8520820
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 21:20:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="K33EzM6D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EB8520820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BC176B026B; Mon, 10 Jun 2019 17:20:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36CEE6B026C; Mon, 10 Jun 2019 17:20:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 282936B026D; Mon, 10 Jun 2019 17:20:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01B216B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 17:20:36 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 21so7666545pgl.5
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 14:20:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gk2LT6fcQsSzPtvSDO++ABbQbp8Uy6r4UjS6ey/0Juc=;
        b=gS0SxocCoAfRYUkRhYgJ7M1OwHJVFE30BKQicpef2SuxNdwl6CdNXrFO1Yc4ZoIhi8
         ulOyC6XgzkNheXhwBROe8jYp+2a50K8lVPMjOC/vV0i6NCoKfqh52BlYePTRlWpTcXa+
         alpxEb3KL/5L+dgT6tWveRlV62LxKSXHYbXn2XIxDpWS1fcdOYwBJtaptHUV4wFphLOq
         Shxcibn+66iavNhg+eScw/u7y0h/p438Khu1UAlsuLX/hNTkjPaTd5kgeaI9RsqR5eZl
         rMfgkjhXi+7UTRppvsI10jzFQWwCKYdiWTM867R5TKM8ZkNzhGDI1GUrRxc3SJH60DKU
         6Iig==
X-Gm-Message-State: APjAAAUxNWWgQ8OunY6pvCkSFyOzP304giIjrrlT55aM0KFySTzfQ3Dd
	Piwa3/21yMRCQ91Gl8q696iX9/XKPahsTmDNr7ptlyNT7pGCjnIh7wBRlyCQdNwnbjJM9/XdhJ9
	+MJ2IeOwFv8AyennlDt8lNwklCSu02bRhBy7ZjePo/NvX9s/brBmvxD+cGV+AjtvJYQ==
X-Received: by 2002:a65:534b:: with SMTP id w11mr17648731pgr.210.1560201635459;
        Mon, 10 Jun 2019 14:20:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWtM/LW/dqXKnKctYww/lXx+VUb+NkEQFdZVuZPnWs+ZlgGJEODw0VJR22ptZSMjeBbt5m
X-Received: by 2002:a65:534b:: with SMTP id w11mr17648688pgr.210.1560201634808;
        Mon, 10 Jun 2019 14:20:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560201634; cv=none;
        d=google.com; s=arc-20160816;
        b=QIZdeSX1NU59eCWXmV4NKz69lALcGCYYYa5m1nq5Y5LhTvRpTDQQMtOdVOJouEvqf5
         6VXxwsz/itiG+K5LhjM9sqd949A/Me343O5ERhFemfow+UAIkHuMZWxpUm6LH2g/waU4
         w1+fTHBENxS5kQA/seA5axpcOH2QEAppxv29QedtiMaVvOw1fsCy2vX9jZJ5R//wDUdF
         oaU+wCiwfQlX36V7BnXs8I3rYpBHAh5Qq+bKyp0sFevP98Aet6KZWyL7jG5wOeh8JYrq
         iNZCjeUFTE3WNDZyWyN78nppvJU4t1TZRu5f6iogPqs3KB6fRDokFDWaoAADQQlFcIsw
         p73A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gk2LT6fcQsSzPtvSDO++ABbQbp8Uy6r4UjS6ey/0Juc=;
        b=KuRS/VTxL+QjHiNtwbOrJochIb0/NnEzABHmRYEhTqADzjbNLq3z6mEphzHPlRxQd1
         kVCBBAeFZdD+t6nPIRwDnQcWoo5ZQ19BQL8kUGlPyxcg3ss92Wq7UW6vxQqhycQth7kx
         488bp8/6CxA49KDFCtA3a4HUaw/h1O0XrEAgM4DcmyJ+LyfyLFrR6263I/wZG9HfVarn
         XlfdMGD92rGGHy1UyzQR+DJQVVTYubT9Tfnns9t8c1MXXhXImssnihfI/ijHBC66sO6r
         tk8Ci4IZk/K35Zxvb3b4SMlu+Mr4IoeeZR6R78w+jQjDa5MKRxSlpBe4HO65EWy3hIA7
         QwJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=K33EzM6D;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e19si496734pjp.49.2019.06.10.14.20.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 14:20:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=K33EzM6D;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 253C220859;
	Mon, 10 Jun 2019 21:20:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560201634;
	bh=gk2LT6fcQsSzPtvSDO++ABbQbp8Uy6r4UjS6ey/0Juc=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=K33EzM6D4Va30ZI5NAiOD9fA+ukRykQXFJG5QhB6faCgv/G+xtgEoePHQSqT5UjMf
	 Bivmju9CUBeJZRonOrZqoGsgPv0BZspRU37kfy3jf/Fs2eucmqTIhI2BCqIwrogQjH
	 ZNVIH2JyUj2bBFOcXqonoxSslpKMrOvFcjoAwiYE=
Date: Mon, 10 Jun 2019 14:20:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mike Kravetz
 <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, "Chen, Jerry T"
 <jerry.t.chen@intel.com>, "Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 1/2] mm: soft-offline: return -EBUSY if
 set_hwpoison_free_buddy_page() fails
Message-Id: <20190610142033.6096a8ec73d4bf40b2612fb5@linux-foundation.org>
In-Reply-To: <1560154686-18497-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1560154686-18497-2-git-send-email-n-horiguchi@ah.jp.nec.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 Jun 2019 17:18:05 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> The pass/fail of soft offline should be judged by checking whether the
> raw error page was finally contained or not (i.e. the result of
> set_hwpoison_free_buddy_page()), but current code do not work like that.
> So this patch is suggesting to fix it.

Please describe the user-visible runtime effects of this change?


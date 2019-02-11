Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC416C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:12:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B198218D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:12:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="knF1plx4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B198218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F29FE8E00DA; Mon, 11 Feb 2019 07:12:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED7578E00C3; Mon, 11 Feb 2019 07:12:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC71D8E00DA; Mon, 11 Feb 2019 07:12:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5188E00C3
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:12:12 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id e68so9233303plb.3
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 04:12:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BPtXQOxeYch/V0X+MBJp9wTl973Cc6vheZfDDJ3vJ1M=;
        b=ljcUzoyolR+Ty7EPx2+po3noajTjLL7e6YMsc60k/hqAsIzLWw42wpi7PF5gQeEyKN
         J3UGiRVnkygSSD+2RaveToispiJjJEL9dAUQpoKOvTsEMo2CyW18rnrCyhY12Uk9JVVh
         T7HYIlLkIQckDnXPMJi16W340FdRRvjUn1M91ZWIwM82gQfuYz455kSOSwUeR3gqHeN8
         fV8iJSq9/JF9BhsMyXl+2IB3vmAzP/jOU1gI6iDaGTPWuwBnIN0wgqc0Uwp7dBojrwpv
         ROVKIOLr5AwD9Uf6yj2fL8VA6DQXXixIvGVuCPeWHb+XdM9V0SOFe1UVQSMEYN32I6Le
         g13w==
X-Gm-Message-State: AHQUAuYvSsfiQWMg8aHqZ5KmPdfp5NKpPw8oujO6wz3+S74petutD2Dr
	AUbmGjoMcREe2kKdyfu2emUrR2NuAPtIjXNthXD6jPx+orY1mhfzt4IPPKDc4Yn52wxJQhITZpx
	PdIph4YsksHHF8cFsdexLVIJCaQeGgAvfUz6OsYrh1wsCzZPrY20ps916dKzAiwskWg==
X-Received: by 2002:a63:730c:: with SMTP id o12mr23696046pgc.270.1549887132183;
        Mon, 11 Feb 2019 04:12:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbYarkp7O1EqTDnXdmirigPqX4uepTdWTM8JW5DyrDtGSuKBoq6qaGU8twPYEGTYkwdVnh1
X-Received: by 2002:a63:730c:: with SMTP id o12mr23696013pgc.270.1549887131463;
        Mon, 11 Feb 2019 04:12:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549887131; cv=none;
        d=google.com; s=arc-20160816;
        b=BHOUya4UcnGITRdQ1y8h4+lJTN8IKvoXgAYJ9Xrtbj7uHYgzk113RToqPVYzaV7Jml
         YYmQy+W/LtEXcn9TqslDBu88q5vTE8hPhQLqhVYBCSQrfQKkgx4vcGSmYJFGyTHSh26y
         17XfNWAr6FN9uVZWNnN2xhIR1WoAJ0x0jm1zNnYHKBrR6UX7BCDTYBCj58qp4wr5gxKB
         2m6VRJ3SgnLkbCgDt6W6NfG6fPVRNPylXFwPMnjToyd/HWPdPcsiFQQLYcf+9JkgyEmM
         dDF1kMEpt6foUXEKVjM0lhTYt7f1FwiP1pwTZN4gJLzu3T0HrlyGq7vaGbN38rIgaDZN
         mHHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=BPtXQOxeYch/V0X+MBJp9wTl973Cc6vheZfDDJ3vJ1M=;
        b=qR8BGJD+6h1yvXNaSI5E31d+c3jTdDWlg2nrWtjUt+kvvy/ih7KU5f9BH4qFPR+1on
         EuV+zPAvlGTPlNvzmkd8rXur+mhcfk5LgNmXIWmmeDt/tEC1umaoIEL230zO318Oqkpf
         V9DCr+Kw9AbzXEjRa3NrDyamdtQ/rQjKVd9mg4W5va/+dCZhXYNXgB7OwiEyuKhxvqPO
         5jd6IGZXy3w1TDokpwvyQ9xcQ7XkbwRP1A4vSfhSrwEB+2Q0YCYg/ykHCHdPXvZm8k05
         LTfl+o8mIDjGiNhcwT7ARkYlPBNnko2nNQpsqrN3VAAM0gwK9LvxM7l84gOnUvJzHQl0
         GvNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=knF1plx4;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m6si9472356pll.86.2019.02.11.04.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 04:12:11 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=knF1plx4;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=BPtXQOxeYch/V0X+MBJp9wTl973Cc6vheZfDDJ3vJ1M=; b=knF1plx4j7WuqTz9tOcA7myib
	6p3FyKk+tbMpsSd/mVBx2nyHUziOgR2nxHufUUq8xgF+i23LnegLWIDZBDw1yID6TccRsHBgX098r
	wpvnaFbVc5Jx54K+xqAypmZG4OhLOuK8oESV01holg8Wu3tNMT9x/bkFZAdkNo9d9rj3TjoYx99ad
	bdmsboI8goqhAoKeAS4SiMw4oY0phQ/PE0ewAYxD92Jpub+1VDkRidQfYis9w8vdBuaSVSIqez5Iu
	PjV5o4hOtyDvZ9lFXKTqXdSyc8CDfuqmMc3OuNi0yZYqrwTEOR+TRvedM96Hx+8JavPwlOe10bzwa
	V9vQRBwBQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtARU-00075I-CL; Mon, 11 Feb 2019 12:12:08 +0000
Date: Mon, 11 Feb 2019 04:12:08 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Tariq Toukan <tariqt@mellanox.com>
Cc: Ilias Apalodimas <ilias.apalodimas@linaro.org>,
	David Miller <davem@davemloft.net>,
	"brouer@redhat.com" <brouer@redhat.com>,
	"toke@redhat.com" <toke@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Message-ID: <20190211121208.GB12668@bombadil.infradead.org>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
 <20190207150745.GW21860@bombadil.infradead.org>
 <20190207152034.GA3295@apalos>
 <20190207.132519.1698007650891404763.davem@davemloft.net>
 <20190207213400.GA21860@bombadil.infradead.org>
 <20190207214237.GA10676@Iliass-MBP.lan>
 <bfd83487-7073-18c8-6d89-e50fe9a83313@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bfd83487-7073-18c8-6d89-e50fe9a83313@mellanox.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 08:53:19AM +0000, Tariq Toukan wrote:
> It's great to use the struct page to store its dma mapping, but I am 
> worried about extensibility.
> page_pool is evolving, and it would need several more per-page fields. 
> One of them would be pageref_bias, a planned optimization to reduce the 
> number of the costly atomic pageref operations (and replace existing 
> code in several drivers).

There's space for five words (20 or 40 bytes on 32/64 bit).


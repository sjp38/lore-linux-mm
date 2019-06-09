Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50C87C468BD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 17:09:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1834420652
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 17:09:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iRanUUu1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1834420652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FEBB6B026C; Sun,  9 Jun 2019 13:09:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 860F56B026D; Sun,  9 Jun 2019 13:09:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B41F6B026E; Sun,  9 Jun 2019 13:09:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id F3D016B026C
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 13:09:32 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id u26so1382180lfq.8
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 10:09:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=LznUc87kOzY43gG7GqM3uuB+dRBgbcnhswA/OnlhqSI=;
        b=qAIEEVv1lb1b/cxsOwyKjTX5IaMgc9auF2BCp3Xx4wfG4RKUiVy4F6yOpk3rGYUZ0Z
         PrIx/wSKMDyvue+m19w71ywQHTTT/zvHucSLb/zhd3jMTdDhNVUPGSZb3JaXuuPB5FeX
         Slcl5+PnsWHKz6wcN2Nj2qp2DXJbE/U/1g+D8neFEkpx6WD8VMk7zTHHvV466kTjeYdF
         fxg+A1wiTFbTQtq2JmIZwispg4pDuJyhL4U2eInvlsTU+hpElE/JVhV7WFO4hJMBDk1M
         10ykgUrq1ms9fcMCqq/sgpXy7GRyCqQLL8KcqaloHBHSxBodaArbIjQTazO9/FcLI0se
         K3EQ==
X-Gm-Message-State: APjAAAWeIIO4PKyOnfAPJzI8CS1HwWy4Dc4hajRdMKVZuIROOmdjM8Gc
	P4uDBoiC/7IUW/ueBYyRd2Lq1ECrqKPTuWN9apENTC78XTwNyVHEXF7fkRTLhgRGheqPpbTJU0K
	yRmtulKp/35gc7EknBPgX+ZUsrgdmnFVheBjY4wXVK94b7LIicegvSfZLTtDPjPjr/g==
X-Received: by 2002:a19:9e53:: with SMTP id h80mr31587659lfe.77.1560100172206;
        Sun, 09 Jun 2019 10:09:32 -0700 (PDT)
X-Received: by 2002:a19:9e53:: with SMTP id h80mr31587649lfe.77.1560100171466;
        Sun, 09 Jun 2019 10:09:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560100171; cv=none;
        d=google.com; s=arc-20160816;
        b=TC8dni4A0QwJzhnxbG/PR2i2xs+VQqkfwGeKScUPW/8AJh0YQr5nM+lST8mSgomVRN
         K8bxyEWGNLRoyGnlGXkqH1+LnPczsqt6+d/kd78bciQqXkfX8yg5qKxLWZH/swYvOsOr
         vcGENEGTSH9KmF+5lOCYPJZhcdCzqA6na9YYNIzrdoM7nRVg9rZilReabV/3PNGx3Nhg
         ECv/tzTy0/P1ezAhuKrytfGC+MEvDj33DN3fWm2bg+9wdmyIE79EjS8AwBbceCjJv4iW
         m8aV07VxZ5CLLanEq78bA1h4KwvFAcjHaOJK26vdokcCQJLXQe0OG6LQl2RURxVhQOFz
         Bjtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=LznUc87kOzY43gG7GqM3uuB+dRBgbcnhswA/OnlhqSI=;
        b=Affn//4WMlFkdEhd8FTqzN+vlJ9xKxJ+LT1cNUlRfQDlqM2vt1Bd7hpezoGIAgnA1r
         AlGI6vpWU5vNzPcSDAMqIIJhOoAICX0SA5HrZnWNc+4vCScy30wd1mkg6qeJYUsefhu1
         To1PAxoXiSnkTUEzO0LNxetGl8hcchwnXTdsUGkdchUlZayps0i7ZHtZKc/UbxvFWQe9
         hybodV1a7J2b1InDYDNHlbN2baNP4TF3Ne35Q22KpN1XIPSR5PRMheCefesu5Ng7M0QX
         pYN4pdW4BaZXtfG1hrjsAz3fY4AIwgc25UHYxX2vxu3ooV/uhaeBy/12dlLsZOGvkdg+
         h2pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iRanUUu1;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h9sor3745471ljg.20.2019.06.09.10.09.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 10:09:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iRanUUu1;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=LznUc87kOzY43gG7GqM3uuB+dRBgbcnhswA/OnlhqSI=;
        b=iRanUUu1JtHll99gtTKBlOGAMCDt8WvFcIqAZrrJoVIxcg56HvmrRG2hEUVZqosEjY
         Oo/YhOn8KaZV9XTNdFolb091lW/+VrIJnibQnj14x2yT0UPHDUY9fUAS8dH0V29tW1xf
         4O7Dxvd4my18SNZvsB/sjKMXcE6cuvl8yNyVGZ7mtOyIm49EjP9YQDirCIdYKf0Np0Pg
         MAaGRfC/jvONh+OhXxtd+P8/856HGdn3/Rdjn3LcGBLXLtwRnF2kScbn9d0+BeW8603f
         tWAzG7rkKyEwSwXhJTmaL6qfX27aB65/m9HS9p6eTNEmC4sY6bDEK9zVR+klP5E/Vaq4
         jPfQ==
X-Google-Smtp-Source: APXvYqxBPS20PyWYhWunBvHAxE3Ys+hxIXMtjHYOBfOTkjSdU2FCtQMlvCeRqA75p0u3fD1jWFjOTA==
X-Received: by 2002:a2e:8195:: with SMTP id e21mr12057526ljg.62.1560100171209;
        Sun, 09 Jun 2019 10:09:31 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id u18sm396497ljj.32.2019.06.09.10.09.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 09 Jun 2019 10:09:30 -0700 (PDT)
Date: Sun, 9 Jun 2019 20:09:28 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v6 09/10] mm: stop setting page->mem_cgroup pointer for
 slab pages
Message-ID: <20190609170928.wetyjpueslcj3qft@esperanza>
References: <20190605024454.1393507-1-guro@fb.com>
 <20190605024454.1393507-10-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605024454.1393507-10-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 07:44:53PM -0700, Roman Gushchin wrote:
> Every slab page charged to a non-root memory cgroup has a pointer
> to the memory cgroup and holds a reference to it, which protects
> a non-empty memory cgroup from being released. At the same time
> the page has a pointer to the corresponding kmem_cache, and also
> hold a reference to the kmem_cache. And kmem_cache by itself
> holds a reference to the cgroup.
> 
> So there is clearly some redundancy, which allows to stop setting
> the page->mem_cgroup pointer and rely on getting memcg pointer
> indirectly via kmem_cache. Further it will allow to change this
> pointer easier, without a need to go over all charged pages.
> 
> So let's stop setting page->mem_cgroup pointer for slab pages,
> and stop using the css refcounter directly for protecting
> the memory cgroup from going away. Instead rely on kmem_cache
> as an intermediate object.
> 
> Make sure that vmstats and shrinker lists are working as previously,
> as well as /proc/kpagecgroup interface.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>


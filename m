Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1D85C74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:21:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B9DC214AF
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:21:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="r54oOfo9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B9DC214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36DBE8E0084; Wed, 10 Jul 2019 14:21:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31D2A8E0032; Wed, 10 Jul 2019 14:21:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20D9E8E0084; Wed, 10 Jul 2019 14:21:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFC268E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 14:21:12 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d3so1943650pgc.9
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 11:21:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fnGBpm29e8ih0nVcemzSumdnrI3YNjI1abxR9imHsCE=;
        b=nkmHeWZOsNDZPgSC5a5NL48RwxPM+qLWkehLrOYUfAA7HtEO5DjXAddR+p1wnd32lr
         vIxZNHZpApa8M50oVMJ40h1tiF6g8Mzl4G2/oZH90hm2nq6jAI8uY8eZVKuj5SrHwk/Y
         p4F7fNc8cZ93HcSXOOqA6iU5tSiNx+DXHSEh0295p8gFyROx9GPu98p0cVwrujpZvpEF
         4hCIZvwH3CzZNF7PI3WLhXFH4xG1m9eptbW1qaniYaV/HnwGUH7lCNW7IfXLAu2QMF6U
         LENyT3iblb9BRKOX5DMNxk+0PZ7Kb418jNXyC3IVH38SdFDn/Gh+W+iYs2kDXT+8Lrgh
         mRag==
X-Gm-Message-State: APjAAAVwP7MuCko/7jfDRcuybhuY69/26OPGG0JdX6x62fOSO5id3Qa1
	A5x2crHYsR5GeuEvGg8gtF6X+aRJU21IEXB6/AwDKiX1VU/KBgqAqbvTaZojExm1YGCfXzWg2xE
	Ws8NOgEM2jVptTyMKZRePox8loM5l84f3LoeIqNevYDvrLVRwE5C/UE3C9xNvknRjfA==
X-Received: by 2002:a17:90a:d151:: with SMTP id t17mr8495546pjw.60.1562782872472;
        Wed, 10 Jul 2019 11:21:12 -0700 (PDT)
X-Received: by 2002:a17:90a:d151:: with SMTP id t17mr8495483pjw.60.1562782871720;
        Wed, 10 Jul 2019 11:21:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562782871; cv=none;
        d=google.com; s=arc-20160816;
        b=IGUNv6FaF32Z57t7OnOoRdfHYkzfbaGVk0Pdy2QJyrZfeRYua8tJ38GffEGpg4Tg4e
         kedP3y+5FCaD7eq3taVFTUK/xKz6Zmze5YhGfHYs/U3/DKgTWtwSIAJkfuh5IiSy7NJ9
         Txt6zIQgmgaoFbzXOtAkQdIcNk7+paPE6HuKkIqFYAZxBJUSO/351dwNUoz5wW/k1Elh
         4akd6D8W7kW2wYIEExqlMfnlmYoeYKnNXyih+/7XQ9IS8UrBPDpIR/sHrAkxBD6FgGV9
         1f6/4trHhGlUhyVlhTwIDV2Fjk1JEtaIkTAsQD7Hq7N1L7dK2vTuYezOqKWwSl7wQKgQ
         8Eiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fnGBpm29e8ih0nVcemzSumdnrI3YNjI1abxR9imHsCE=;
        b=WpFnuOjzUiD9GUWND/2iUxfO2JfIh0uCoit1vURA9NyznGLJHBsuCO8cBPP2Ivff/C
         HsKxOO6kU2kdDEd7gG1q2X2Y9siqPL6OtTTiU0eP6Zwqk+5RkrWxY9ZHp2tMjOoXhPz/
         hHv7t9s4OA7txp0sb+R9Jg3DHKS+AtLV4Pqa7dcP8pTQF6l4/xAoeEor1yzLiGj1rRfK
         PWbm38myKkDJvfSL5/edfv6RVL/F+Pk6WidoxSrMlE/454MqPn+RZV1bv7qL17JXd2Lc
         gLYhwCq3ZYXuyd7ixB/K1MEJfTqk46q0NA0/hgtoxMIeQthmG0l8XMHhQSGQqAnOJMU2
         t89g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=r54oOfo9;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o11sor2669385plk.18.2019.07.10.11.21.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 11:21:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=r54oOfo9;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fnGBpm29e8ih0nVcemzSumdnrI3YNjI1abxR9imHsCE=;
        b=r54oOfo9tCGgPU7nLvxeuwlcmdrm1W6iXQBTBZuQX3uMd5MEButIOxEC8ZsooBrS22
         XDo3wfladVbiIrIEHAd1Nm+DPdJFk/HTfy0vfc7vqlOmJoQWsAtsV9lgjDhoLXS7165x
         sya+OrBKZmq7S45Xj2EiJugybWH3jnJvSJsVvyUDD6HskfqZNxn78dEhQd3q/VfgptTd
         kNFdqMeSAXscKx3XhFpoKqqrx9qoo/xTN+hEJ+//orXsW7lcODdi6oOkp/sMhNJ7f3DN
         hdJ6f1X/S+eu/F9g8mTz3eA1OsGy9CUSqKRZWYDHeSs+cXWv8sadpOreFTMS07aDYZND
         7Rdg==
X-Google-Smtp-Source: APXvYqxB3CQ6to2JGHiSbwc0t9tlBi+Ho6PWoIO2Ce1gSNPx5pyEn4b7NBFexyxmsIzvyOnXSOYzfQ==
X-Received: by 2002:a17:902:b20c:: with SMTP id t12mr40667176plr.285.1562782866693;
        Wed, 10 Jul 2019 11:21:06 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:5b9d])
        by smtp.gmail.com with ESMTPSA id i15sm2855950pfd.160.2019.07.10.11.21.05
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 11:21:05 -0700 (PDT)
Date: Wed, 10 Jul 2019 14:21:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	hdanton@sina.com
Subject: Re: [PATCH v9 4/6] khugepaged: rename collapse_shmem() and
 khugepaged_scan_shmem()
Message-ID: <20190710182104.GE11197@cmpxchg.org>
References: <20190625001246.685563-1-songliubraving@fb.com>
 <20190625001246.685563-5-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625001246.685563-5-songliubraving@fb.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 05:12:44PM -0700, Song Liu wrote:
> Next patch will add khugepaged support of non-shmem files. This patch
> renames these two functions to reflect the new functionality:
> 
>     collapse_shmem()        =>  collapse_file()
>     khugepaged_scan_shmem() =>  khugepaged_scan_file()
> 
> Signed-off-by: Song Liu <songliubraving@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>


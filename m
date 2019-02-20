Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F053AC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:10:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8A1220C01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:10:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8A1220C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40C118E000C; Wed, 20 Feb 2019 07:10:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BA498E0002; Wed, 20 Feb 2019 07:10:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25DA28E000C; Wed, 20 Feb 2019 07:10:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D02598E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 07:10:22 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id a21so8732277eda.3
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 04:10:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TRVIr/34CoaA+vI61Sv9WDyhWA1WE0yjWzyS05PQWmE=;
        b=Ls5CH3k6IgFC03J/MT7RPswS2T3bRMd+2shPZLWpdHx6uVfR0Kh52Xhfg02gNF4HlQ
         Y/OGSEzl9svYwt9Sk/BfUJH06QnXjj2r4cP2DHbRSbV5DjBWloF917oiHQURknpKCVNd
         HYxvc8KlIKWqO1up8qdJzR2dLoI8D4TQkVQ/ftWnb1H5Tj7yWm2KYCuPTol2OZf5RUPt
         UgwyEixxgdZW8iaB2u2mr8y/OZoyDgzWB1CTJguAcnwGLIYGuuK2YcjVNfxc8BoE49xa
         RB4RYNfejea1Md0Dcgbsjamz5kJcn3UFFBL35lfpiN78MaMft3rOrgRzNhNi67Q3AlqI
         QWXA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYcC4DXiZyJwRYBvOulNzWeSs0MERxHYHFlwhOzUPKmn0QtYgKV
	U5gMOLfLgLIC1uyfuUiGn94Dpz3abuSDi932V48H+d1u1RiyroW7YtVjS/U3mmHI4kfRffAAQOH
	MLI1Ql9902ABkq5rxEMxO0ResVpD+qzWYI4XkmwLt0GLjFCBOzepKXo4uaMN1DBo=
X-Received: by 2002:a17:906:1ec5:: with SMTP id m5mr22267084ejj.159.1550664622383;
        Wed, 20 Feb 2019 04:10:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaUd49speO1iTUY20ZtuR6ailvc0amYiCwxXpCiHSOhzv2nj7C3UJGkgO6P6YZVV5v8lCme
X-Received: by 2002:a17:906:1ec5:: with SMTP id m5mr22267029ejj.159.1550664621354;
        Wed, 20 Feb 2019 04:10:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550664621; cv=none;
        d=google.com; s=arc-20160816;
        b=Pr5htqyo4LYbWCzM2USCiqW6aPDIYWTmDvEh3jUG8JiphOGnf05drhZfbeh1yXaU5B
         oA9ipNEzjPl4kyMjvPuCHnTSNrj9L/k3pOb2XKaLXsww7VfS2YeDKhNGJSUpKBpXmyOA
         RzHISs1ONWeu+ch+7Tgx8GLfnCXjj4zl1o2Eg3R8pzekpqZB+Yuxp7KlxFsdtbikr2UN
         W+MDi26g/VbBXxiQwNcYN4YctbrPtmz/iAiA0xWdXlQmfnMbdSjHNCJthWxq+Ysk+6aJ
         I+DSs1upugXXCXV9D/jxW4807S6LmlYShZZdPjxmhU6bjrmj8JXt0MRqzEZ3jMRJbe+x
         t0iQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TRVIr/34CoaA+vI61Sv9WDyhWA1WE0yjWzyS05PQWmE=;
        b=Bv2XF5U+oljJBrL6YSi3c6W+u/87ApJhkAWVFlbBDny5pNBXohDjxBoX1gsV1i8u09
         DO5XrHhBYdbC8v9yob23NtSlWljgHHgzx4PzmHO2BuvwNosPDnM8vb7xiOYI1QLs+6MW
         9GfothLwpyEG/WXaj3Xi3Wj0cxJs/uAKThrNcb21xzBtaODYrDJeofnTEtrCFRj0Z3lU
         2qWeM0pnQzTg1DFTZ3WenFjqIrrhFgtBNVy6Vk9XP8zuLCiA+wm7qWJXLrniXCBTnaTW
         E9xDIBRqUES5AEe5mtGcZ+RhquyJqfwd1vnNbWTiOfH3Il/e08RLRviuQ20i4n2Ea2q9
         3lyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g18si64006edh.385.2019.02.20.04.10.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 04:10:21 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C39D0ACC8;
	Wed, 20 Feb 2019 12:10:20 +0000 (UTC)
Date: Wed, 20 Feb 2019 13:10:16 +0100
From: Michal Hocko <mhocko@kernel.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
	linux-fsdevel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC ][LSF/MM ATTEND] Read-only Mapping of Program Text
 using Large THP Pages
Message-ID: <20190220121016.GZ4525@dhcp22.suse.cz>
References: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 20-02-19 04:17:13, William Kucharski wrote:
> For the past year or so I have been working on further developing my original
> prototype support of mapping read-only program text using large THP pages.

Song Liu has already proposed THP on FS topic already [1]

[1] http://lkml.kernel.org/r/77A00946-D70D-469D-963D-4C4EA20AE4FA@fb.com
and I assume this is essentially leading to the same discussion, right?
So we can merge this requests.
-- 
Michal Hocko
SUSE Labs


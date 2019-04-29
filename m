Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34A4FC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:41:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E51AB2067D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:41:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E51AB2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95D2C6B0008; Mon, 29 Apr 2019 17:41:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E6806B000E; Mon, 29 Apr 2019 17:41:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D5A96B0010; Mon, 29 Apr 2019 17:41:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 409676B0008
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 17:41:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id j9so5416550eds.17
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 14:41:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OolbsuD69p6z342Cnmfm6Qi8m/8Hd/bFVu5CFz0wgGE=;
        b=EhRecmEXsR4fCw47s2Kakb58070RAE+9KV/6M7PbaSxn58GYif+sxOrfSfMypK99eM
         8rvMtpEx88pw55nkPDz5OKPqnN3zy2a8dfNmsBxyTp5IL8bJJR/U28hRXBIF3aODwTcg
         zV+71ZRRFasmGDgsRCseVYKGHxMF+Tci8MT9JAyF66yYbFSbcNBF38cL0zU/GftrHSNp
         ELdBk4p9+r/dBGXuvu7IqKT4KeKlTJl7drtn09JUFADagJlPmzM3sWEG4gO+RdNvTgAh
         gPNeLX/TlpB3ul1iQDhUFHfpCryLtNVeaw1fGDqg7iqcOyuQeS+Eg4SwUPo+JdKpDL1H
         /mHQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWcV7bnzgR5QjSYryGsUQ8scgbbq1UN0PZIbp5JAojpV7Z5z+hL
	OWT2nMQcSvmgmQJo7tfXOY3rIK1PcrbrYV1kTdYdi653jZFWBjjjpRzbstPsc33QXAKcRkZjkrB
	ULLKqdZr/dRRJDkHzKvuXzj5hp2E/CSADJBpJPFgrI7JW5i+Rh4sdZTyLAgV7srg=
X-Received: by 2002:aa7:d7c7:: with SMTP id e7mr38997885eds.108.1556574087833;
        Mon, 29 Apr 2019 14:41:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz68CvVLnM61FJdlz1eQiTNE9cpQnhbwX0xbwGuIvUo0e17d1A6hM9Vr5TPzALEfEvm9EpP
X-Received: by 2002:aa7:d7c7:: with SMTP id e7mr38997863eds.108.1556574087173;
        Mon, 29 Apr 2019 14:41:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556574087; cv=none;
        d=google.com; s=arc-20160816;
        b=zttpP2wJBnRSozgRXIKz+PmR+piwSnJ2mY7hcdckGhJTgf5huOtryYROlM9Jm1o+Qc
         vhGlKRvPofrhImw6sonKzguTwARiI7bbZLioQ/CUI0uNiSKiBfEqiLCZCjwvIC92t4no
         AFPsxOTPg99KXXzfjK3kpd8DKL36HXDnkaeYw0Jpb0Ptk2uqgvbhSblYHvOHZeNfiP76
         JKbGr9FwoC8MZuc/0dkYOCeGQBvEsnvS8uySbr4kzqNI41xFonyEUqhZ/vw5YAJt/P6h
         0ZMZFx93xf4L7B9sKGpCJO6/sy2yLOo6szylC23k2XPQ9I6rp9snYNczirb84/2Y9JI5
         Vv1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OolbsuD69p6z342Cnmfm6Qi8m/8Hd/bFVu5CFz0wgGE=;
        b=Jrx7CoxRAiDVC4ra9hIY43elMahnwVjeVaKaFeL77tLZj14aPZhv5gpjT59ZoXIABV
         1LU+umuh7uWTnQeL/seFTtPphKDRS2r6+kSWP4RODeU2t3PyI4iw55/93XN0N/DFFxRY
         GVloUbRBJFwaArkgBVBb9it4MvKiZvDMdf7Z7zot4XMt/UEn2NhmGbFwTY7uwB7ediDN
         QsADP0BQnEnmDaRCKFpZyfDV8Hbh7rXMfziNqx6XM34w/f9qFNadd1GBdcah/GSNGXVJ
         Yhq0MMRPlVKiK8ytedbO1u+XjF67ZmihK6JP5XPtQWHMcPN/ar8jwsEk+JdEXLvGYkrc
         owzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e19si1293051eje.133.2019.04.29.14.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 14:41:27 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8EB1BABD7;
	Mon, 29 Apr 2019 21:41:26 +0000 (UTC)
Date: Mon, 29 Apr 2019 17:41:23 -0400
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Jan Kara <jack@suse.cz>,
	Amir Goldstein <amir73il@gmail.com>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/2] memcg, fsnotify: no oom-kill for remote memcg
 charging
Message-ID: <20190429214123.GA3715@dhcp22.suse.cz>
References: <20190429171332.152992-1-shakeelb@google.com>
 <20190429171332.152992-2-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429171332.152992-2-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-04-19 10:13:32, Shakeel Butt wrote:
[...]
>  	/*
>  	 * For queues with unlimited length lost events are not expected and
>  	 * can possibly have security implications. Avoid losing events when
>  	 * memory is short.
> +	 *
> +	 * Note: __GFP_NOFAIL takes precedence over __GFP_RETRY_MAYFAIL.
>  	 */

No, I there is no rule like that. Combining the two is undefined
currently and I do not think we want to legitimize it. What does it even
mean?
-- 
Michal Hocko
SUSE Labs


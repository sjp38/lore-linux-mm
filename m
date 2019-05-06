Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50089C04AAB
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 14:57:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDB172054F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 14:57:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="x3BFXGD8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDB172054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5924A6B0007; Mon,  6 May 2019 10:57:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51AC86B0008; Mon,  6 May 2019 10:57:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3958F6B000A; Mon,  6 May 2019 10:57:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id F1F126B0007
	for <linux-mm@kvack.org>; Mon,  6 May 2019 10:57:33 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b8so7250152pls.22
        for <linux-mm@kvack.org>; Mon, 06 May 2019 07:57:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KsZcNzF1hybdUscCtnXpBh/F254onDMylJHf8yLDCZI=;
        b=DwD6TtRfsEKuCECcN/mGlbw5P+MT3aCR2JfYX4RFU2xMtgLiOaHOaOwlr8H0U59cl9
         3A7A96/o3c92gVpAIf+XNsU7iecNtC6XmmZW0XLwxk/F6wYqIRUhXS09y3JSYpSsCVcS
         IH2d8X8h6npq1BF2/ADAfW9NRdjs2jpMbi1LeFKckqmh2+k42/kcUqxGfDDcrwW03/Yv
         Iiq9wi48gIRg29eguigCaCjW3GV14wABHzQMZSBOAKzfunw1FNkS+q3xGs/JJMrT/sSh
         mWcyJksc/GM85zNMQr26lcJX3cSMIQI7m66CRpcwYunIbXEpuRqtH3x2mYV9NdjptqOh
         IDUA==
X-Gm-Message-State: APjAAAWFDUA95XBBiv8A/c8AqjRZqLI8KDwPTfLV5pPeQ4p6PcB+Incv
	zswhjIw1KTi2yJkW/SRYE8fOiWec80gMkmi9blGjWQ75gZ+IpjpLDSpVh0Rt8XYPHgaLJuLuHH6
	XFAZgi/jATX795ULHmnBogmAjcbJqpWg/UNUGpFsfuyj1JqB2BUM9K7JaX0nKOU/OrA==
X-Received: by 2002:aa7:82cb:: with SMTP id f11mr34897242pfn.0.1557154653518;
        Mon, 06 May 2019 07:57:33 -0700 (PDT)
X-Received: by 2002:aa7:82cb:: with SMTP id f11mr34897171pfn.0.1557154652779;
        Mon, 06 May 2019 07:57:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557154652; cv=none;
        d=google.com; s=arc-20160816;
        b=HF6PtD3jCtaBxdGEOSFHzlLKNPEtShQPlBC82hDlhtAvQ6KVT+qaCdSAOdCKOZGdDI
         hTtCnSr4Mnhlbohdn6taGSk+FCapFqw/VY5v1crwjSG3ZvIo1EF0CxAgPUC76M63btKf
         Bo+WHN4so7lJ1amk63SztbaWq5ZGi5+WO2I9R/w6bw29o0U/ifKlkXzvf+Ni7gcXIyt/
         sDx0ZhlU5dFkXOuqlg1YeqZlnnbqskjmvkJoEiul/R7SKQptJw0uQfDpMK30+wm8wI2T
         5CHnKvgeFx3uni4fucIJIsOksoqvNuvf4O5J6lNOh8iit934DoImxCK+jaM6b/DNClaY
         +avw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KsZcNzF1hybdUscCtnXpBh/F254onDMylJHf8yLDCZI=;
        b=FhxrLmI9/vQx59RDk5VxEMf6MO0IlSCEVPhTdll89KHzIUq+k42G7dmhLRnALQVfFQ
         WAvaDreWfn/W7kr4NQBcI4KQDIWEN7N2DC+1pA5khPsNK7gXCnzkK3UR1Uf6oTsSOGck
         oSuZgtHNMiNyBn3gF8xCzFDiaWGVyqUheS91s2/Grm6XmnC6JP0A42EdJmgRS7IotckD
         YoZsaKCQEgZmX0G0GEtvb+B4Xh2i5HGexEs3YwktjcmL2lscpn/YO0Iyqrnp/y9uQhWo
         8RwmkvMZ8L6zQAr2G8wljXQgDl8LBW5oYt2cutKb5o1Y5CxI4u3cMKDwLWGiurIiExMu
         ZlgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=x3BFXGD8;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o3sor12331276plk.31.2019.05.06.07.57.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 07:57:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=x3BFXGD8;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=KsZcNzF1hybdUscCtnXpBh/F254onDMylJHf8yLDCZI=;
        b=x3BFXGD8/emXf5QlCrkujCa+PcJkvQN9xszX7tdTYH90aT3XTCMaOe3K68c7JRmL4N
         PaynnQ0d5Kz8wipUcBEIe//4NdtuUtittkvJr70GCPT/WuyV9Vz8AQzWngVc1rn5CD90
         6A8L+TWxtZbQBdL72kK4/oLteDbFe3ZokokuKMv2CEt8vE2RO3TsNkEREaF6nci78oJJ
         z813KcEivWw1mvOwB3+/VpVuBuNbM9UAD8rTf0VabAJA/WouLrSW+lPFFpurm+JAikXS
         JlkpmQNX9dj3NaGzoaHKyLEWOUFzv1f28csn/BCkETIoKCEIESbq3cbFLbU4Yfwuw9km
         uW0Q==
X-Google-Smtp-Source: APXvYqzsy76OdF+u7Stt+xa2A/2at4+7p58pfgr6xCJ0xlI8R//reK/oe8DtCKgvE1sPge7KpRGisQ==
X-Received: by 2002:a17:902:2825:: with SMTP id e34mr33208399plb.264.1557154649848;
        Mon, 06 May 2019 07:57:29 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::3:32a0])
        by smtp.gmail.com with ESMTPSA id b77sm23821195pfj.99.2019.05.06.07.57.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 07:57:28 -0700 (PDT)
Date: Mon, 6 May 2019 10:57:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>,
	Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [[repost]RFC PATCH] mm/workingset : judge file page activity via
 timestamp
Message-ID: <20190506145727.GA11505@cmpxchg.org>
References: <1556437474-25319-1-git-send-email-huangzhaoyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1556437474-25319-1-git-send-email-huangzhaoyang@gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 28, 2019 at 03:44:34PM +0800, Zhaoyang Huang wrote:
> From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> 
> this patch introduce timestamp into workingset's entry and judge if the page is
> active or inactive via active_file/refault_ratio instead of refault distance.
> 
> The original thought is coming from the logs we got from trace_printk in this
> patch, we can find about 1/5 of the file pages' refault are under the
> scenario[1],which will be counted as inactive as they have a long refault distance
> in between access. However, we can also know from the time information that the
> page refault quickly as comparing to the average refault time which is calculated
> by the number of active file and refault ratio. We want to save these kinds of
> pages from evicted earlier as it used to be via setting it to ACTIVE instead.
> The refault ratio is the value which can reflect lru's average file access
> frequency in the past and provide the judge criteria for page's activation.
> 
> The patch is tested on an android system and reduce 30% of page faults, while
> 60% of the pages remain the original status as (refault_distance < active_file)
> indicates. Pages status got from ftrace during the test can refer to [2].
> 
> [1]
> system_server workingset_refault: WKST_ACT[0]:rft_dis 265976, act_file 34268 rft_ratio 3047 rft_time 0 avg_rft_time 11 refault 295592 eviction 29616 secs 97 pre_secs 97
> HwBinder:922  workingset_refault: WKST_ACT[0]:rft_dis 264478, act_file 35037 rft_ratio 3070 rft_time 2 avg_rft_time 11 refault 310078 eviction 45600 secs 101 pre_secs 99
> 
> [2]
> WKST_ACT[0]:   original--INACTIVE  commit--ACTIVE
> WKST_ACT[1]:   original--ACTIVE    commit--ACTIVE
> WKST_INACT[0]: original--INACTIVE  commit--INACTIVE
> WKST_INACT[1]: original--ACTIVE    commit--INACTIVE
> 
> Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>

Nacked-by: Johannes Weiner <hannes@cmpxchg.org>

You haven't addressed any of the questions raised during previous
submissions.


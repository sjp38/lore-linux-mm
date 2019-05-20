Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F11BC04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 09:28:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AB3420675
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 09:28:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AB3420675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E76EB6B0007; Mon, 20 May 2019 05:28:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4D5B6B0008; Mon, 20 May 2019 05:28:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D16256B000A; Mon, 20 May 2019 05:28:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 847166B0007
	for <linux-mm@kvack.org>; Mon, 20 May 2019 05:28:04 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r5so24183877edd.21
        for <linux-mm@kvack.org>; Mon, 20 May 2019 02:28:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LKR0MAyifomRJ/xjcwcaHNaLMMDx4Qc655jA2gOR6j8=;
        b=LJYqsb5ysi6WXCTPBfoJmqU5H5FO5P8Y6B1/2/hOxM5yD6BAbYmPkIw13hI60X41u8
         aKoYQFxzIj6EnDmB2LKWiUqpjo1YhwLxaPcAkCNdRbNpHkmqQeyReKU2VlxGm158f3/R
         VnCSe3JzYUS0EULJ3x2iiHxewNH/KQ2hTU5dirS1xyncXfzEHR9nAV4mmgx/AIHHnY/A
         1fRZ5B6LvluhTY8RCNK6Wi/m80s1IVpvsKdTo9A5Se6RqAqItha9JXDwHY7/1Cdeyv4l
         IfR0hS+5UUwDeqetpzEfBplBEoCwcGhpsFxIZP4Hap9dYBIQ63jqd1WrnSB8DZMzK/Ce
         XvLw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXzCsWw5jhyaj/X5bVIvExtHk5vKkPzkgLQAx7RR+y6Oua27zAL
	5Su55bUf1bg8Dln60+KO6nyN0qp05pPaYVD4NfxKJgdvhr5bpqtn1CaoFhwLSV1bRPYiQJK80J5
	esdn2tpKv1ivQZSlOUjO4/REaExlFaza+P+K/E1UCPA23Ad78UvzLE+B7Esj3aLk=
X-Received: by 2002:a50:9818:: with SMTP id g24mr56173988edb.35.1558344484106;
        Mon, 20 May 2019 02:28:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLy7Az3FOu65OkFqyTWee3gBBwJU/LLA2pek5J5fphyQoXenXuGwcymT9599HIe9z4fJsz
X-Received: by 2002:a50:9818:: with SMTP id g24mr56173938edb.35.1558344483389;
        Mon, 20 May 2019 02:28:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558344483; cv=none;
        d=google.com; s=arc-20160816;
        b=0O39qVMRBg9c6QJLN/AcsAPX4nAWqwPd+IRLtf3f1frfpUDl8Zhujr2w2wGP7LlnGn
         gjUNGV94yxGmz/zEdibARtFCSXs7f7/h9/TaRxrI2OSLFd6lVnR9wy2fvJ5yzMc+fXyy
         v+veMu+02zAyh9kTEz59ubqU4fX+O+j/H6ir2SL6N/RSLjxmbToLLifUAE3Fnq49s2PL
         QnRpHa4oh1nMB/lsZ8B/PS5zxpKLgf0qWVsr/99ljFQ2y1BlxuOIhgT+9ZD4qndrJyrB
         nunb6U8FU/sBFOz01fqJgKex1Yhbq9Pz9AR2QzYEdyamDXOIbyYTjic069ZSMcdlHkEN
         owGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LKR0MAyifomRJ/xjcwcaHNaLMMDx4Qc655jA2gOR6j8=;
        b=EpilD2VSGi3wF3IKX791AgWjhG2xUHteDrNKAO8V0C5ZLCdotl5kNBwnNbB7LHPxJs
         8in/1QoO1g/mXTHW1ZKY1jyp39bRf3gsSyXrqSEUscdreRdKoF+H+b1f0eA9yA4fecBK
         1Sg5RUBTEGVUsRL3xLrHyEkQ6aBisQ8xUlBgqk0muOANFtatSMaIDcxsYvh7Bw/uoL42
         hBKTWRwYJdQ5RQSX/jcIjRxzHfLvSI58eMaZc7tFZm7BhnnwUqc+Wri2hPsbnTIpIe2+
         At+EK2lZuWt3EvyFtNxwdvg8BBjkxHTCWL/HI5V4F7+Gwzsly2wGbm9WI5Hou+c27P/+
         /iBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g23si1494529edy.279.2019.05.20.02.28.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 02:28:03 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AAA62ABD7;
	Mon, 20 May 2019 09:28:02 +0000 (UTC)
Date: Mon, 20 May 2019 11:28:01 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190520092801.GA6836@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-8-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-8-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[cc linux-api]

On Mon 20-05-19 12:52:54, Minchan Kim wrote:
> System could have much faster swap device like zRAM. In that case, swapping
> is extremely cheaper than file-IO on the low-end storage.
> In this configuration, userspace could handle different strategy for each
> kinds of vma. IOW, they want to reclaim anonymous pages by MADV_COLD
> while it keeps file-backed pages in inactive LRU by MADV_COOL because
> file IO is more expensive in this case so want to keep them in memory
> until memory pressure happens.
> 
> To support such strategy easier, this patch introduces
> MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER options in madvise(2) like
> that /proc/<pid>/clear_refs already has supported same filters.
> They are filters could be Ored with other existing hints using top two bits
> of (int behavior).

madvise operates on top of ranges and it is quite trivial to do the
filtering from the userspace so why do we need any additional filtering?

> Once either of them is set, the hint could affect only the interested vma
> either anonymous or file-backed.
> 
> With that, user could call a process_madvise syscall simply with a entire
> range(0x0 - 0xFFFFFFFFFFFFFFFF) but either of MADV_ANONYMOUS_FILTER and
> MADV_FILE_FILTER so there is no need to call the syscall range by range.

OK, so here is the reason you want that. The immediate question is why
cannot the monitor do the filtering from the userspace. Slightly more
work, all right, but less of an API to expose and that itself is a
strong argument against.

> * from v1r2
>   * use consistent check with clear_refs to identify anon/file vma - surenb
> 
> * from v1r1
>   * use naming "filter" for new madvise option - dancol
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  include/uapi/asm-generic/mman-common.h |  5 +++++
>  mm/madvise.c                           | 14 ++++++++++++++
>  2 files changed, 19 insertions(+)
> 
> diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> index b8e230de84a6..be59a1b90284 100644
> --- a/include/uapi/asm-generic/mman-common.h
> +++ b/include/uapi/asm-generic/mman-common.h
> @@ -66,6 +66,11 @@
>  #define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
>  #define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
>  
> +#define MADV_BEHAVIOR_MASK (~(MADV_ANONYMOUS_FILTER|MADV_FILE_FILTER))
> +
> +#define MADV_ANONYMOUS_FILTER	(1<<31)	/* works for only anonymous vma */
> +#define MADV_FILE_FILTER	(1<<30)	/* works for only file-backed vma */
> +
>  /* compatibility flags */
>  #define MAP_FILE	0
>  
> diff --git a/mm/madvise.c b/mm/madvise.c
> index f4f569dac2bd..116131243540 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -1002,7 +1002,15 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
>  	int write;
>  	size_t len;
>  	struct blk_plug plug;
> +	bool anon_only, file_only;
>  
> +	anon_only = behavior & MADV_ANONYMOUS_FILTER;
> +	file_only = behavior & MADV_FILE_FILTER;
> +
> +	if (anon_only && file_only)
> +		return error;
> +
> +	behavior = behavior & MADV_BEHAVIOR_MASK;
>  	if (!madvise_behavior_valid(behavior))
>  		return error;
>  
> @@ -1067,12 +1075,18 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
>  		if (end < tmp)
>  			tmp = end;
>  
> +		if (anon_only && vma->vm_file)
> +			goto next;
> +		if (file_only && !vma->vm_file)
> +			goto next;
> +
>  		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
>  		error = madvise_vma(tsk, vma, &prev, start, tmp,
>  					behavior, &pages);
>  		if (error)
>  			goto out;
>  		*nr_pages += pages;
> +next:
>  		start = tmp;
>  		if (prev && start < prev->vm_end)
>  			start = prev->vm_end;
> -- 
> 2.21.0.1020.gf2820cf01a-goog
> 

-- 
Michal Hocko
SUSE Labs


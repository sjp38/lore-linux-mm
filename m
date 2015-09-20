Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 713686B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 06:58:31 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so81442722wic.0
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 03:58:31 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id gc4si10059612wib.85.2015.09.20.03.58.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Sep 2015 03:58:30 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so77656083wic.0
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 03:58:30 -0700 (PDT)
Date: Sun, 20 Sep 2015 12:58:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Message-ID: <20150920105828.GB20562@dhcp22.suse.cz>
References: <1442480955-7297-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1442480955-7297-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442480955-7297-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, David Rientjes <rientjes@google.com>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu 17-09-15 09:09:31, Naoya Horiguchi wrote:
> Currently there's no easy way to get per-process usage of hugetlb pages, which
> is inconvenient because userspace applications which use hugetlb typically want
> to control their processes on the basis of how much memory (including hugetlb)
> they use. So this patch simply provides easy access to the info via
> /proc/PID/status.

Thank you for making this much more lightweight. If we ever have a
request for a per-size breakdown we can add HugetlbPages-$size: value kB

> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Joern Engel <joern@logfs.org>
> Acked-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Just a small nit-pick, feel free to ignore if this was really intended:

[...]
> +static inline void hugetlb_count_add(long l, struct mm_struct *mm)
> +{
> +	atomic_long_add(l, &mm->hugetlb_usage);
> +}
> +
> +static inline void hugetlb_count_sub(long l, struct mm_struct *mm)
> +{
> +	atomic_long_sub(l, &mm->hugetlb_usage);
> +}

I can see why you didn't use dec_mm_counter but the ordering could be
same. Other functions which handle counters follow the same template
(target, counter/count).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

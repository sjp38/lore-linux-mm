Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 240B26B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 10:45:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y128so6160019pfg.5
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 07:45:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o187si779023pga.831.2017.10.20.07.44.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 07:44:57 -0700 (PDT)
Date: Fri, 20 Oct 2017 07:44:51 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 4/4] lockdep: Assign a lock_class per gendisk used for
 wait_for_completion()
Message-ID: <20171020144451.GA16793@infradead.org>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
 <1508396607-25362-1-git-send-email-byungchul.park@lge.com>
 <1508396607-25362-5-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508396607-25362-5-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

The Subject prefix for this should be "block:".

> @@ -945,7 +945,7 @@ int submit_bio_wait(struct bio *bio)
>  {
>  	struct submit_bio_ret ret;
>  
> -	init_completion(&ret.event);
> +	init_completion_with_map(&ret.event, &bio->bi_disk->lockdep_map);

FYI, I have an outstanding patch to simplify this a lot, which
switches this to DECLARE_COMPLETION_ONSTACK.  I can delay this or let
you pick it up with your series, but we'll need a variant of
DECLARE_COMPLETION_ONSTACK with the lockdep annotations.

Patch below for reference:

---

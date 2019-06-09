Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27787C468BD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 12:10:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7DED20840
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 12:10:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nRmn0YNw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7DED20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B1B46B0005; Sun,  9 Jun 2019 08:10:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 261F76B0006; Sun,  9 Jun 2019 08:10:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1511A6B0007; Sun,  9 Jun 2019 08:10:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id A57F36B0005
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 08:10:57 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id a25so1343534lfl.0
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 05:10:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=MGnWlXcEZlsDllQ1p+dLiYMxOQG545jMz4NgSBC9Y94=;
        b=JGU0b/hv5mHd38T+IxNc4yHUx39MJQTVgpaFl4ar5ujKja9Afg1kL3pz755Lajtj02
         50ASiUrRD5vk56yqtO5kpUQL2bqWc/RNyU8ChhsiZuANX7KZCHhR532650pUn3PHTcWv
         wL5NMDbIr/ypOWdEvb2YkYAChFCMg3a+aNVXQY6lLzGVrDP1CAHjLjaCbi2o/BaTilbI
         /yb4oHklk7eUqtMag3r1p56kL6KEjfKr9x3S4rZGeEXBjCZdWAaHArKYyc5FW9oATMNj
         prJra5vxkWk3ImQybTcXBm4dO1X/mtAho9Oyd6dLqE2oHKNvaxItZ4R0YRksmV+x1R0b
         ggXg==
X-Gm-Message-State: APjAAAXCGsP5LII25RVohG7j16xhxGBQa/CowdcYRHOOH6/q0R9OmaTl
	hW/pH1GpThwhtuPGdjYoodwoypAmVUWNYhxKyg+YVeNH33NwZt2bcnt6hs3g0oBhG8O4/L4xAG9
	rXQs/iHMbmQ2b7zDWiYq5y1Y+bqt0XJ1vVvPl6ZQs1Cl/d4npZTRuki2KAjenbDEujQ==
X-Received: by 2002:ac2:43cf:: with SMTP id u15mr31217241lfl.188.1560082256988;
        Sun, 09 Jun 2019 05:10:56 -0700 (PDT)
X-Received: by 2002:ac2:43cf:: with SMTP id u15mr31217191lfl.188.1560082255587;
        Sun, 09 Jun 2019 05:10:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560082255; cv=none;
        d=google.com; s=arc-20160816;
        b=ivScojz4PUYv4YxSOgUZ9K7/d8r9vEo+qBrz9OD8L2pegI9EkNuo/LYchPrcjli2nJ
         Jwfm3CEIC/Swk/1vUkIk1AMIyVYMwKN1/Rf+l0l1PkBBD3a7PcUcufZnD+U8ic+w4LpW
         EYQTJ2gDI+ZoeXdYE7B40zIYtyK69N9YUdz/qKGnAXKx/zdyyWuNog/UAxSMBffqPQdi
         ai+49DZFtIhEZdsQaKbjw43VHBuBIPetO6J14TVxY1Qf6FBS/uBXiIT4Fs1L76kRKC2W
         xn90p575HJcxz8svGZioUaxiuDxilgj2Kj1RlCgALBqoL3EI1gUhEZhvB+dMJ49OYyGE
         SWyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=MGnWlXcEZlsDllQ1p+dLiYMxOQG545jMz4NgSBC9Y94=;
        b=N2OpoFGX82t8fLcXL6J6BWlgNE0XEBZPrZuei6ELV0JRy3UsraeSudsXFo8DSdXMaR
         rvn6f+X5HsruCDXZ3j29IvIxeDFSoLrLctmJcbbzz9zkk8JPVbaUPEV0/hrkKC+SzpJA
         kUgNd15rph+mjEfl860qIWf7ApRleTpYrBiH2g/yafISP8ZgM1Hibn/+wVkYfb2l8Tjg
         4cuw6iWGa2MgSTD9kicbu8I84RE9Q7pyuinNXN/u0qFVTT7uNWBnras/Ptnc32MtFpPv
         uTH5S1t9BjJWm6EPnfu4Uy3pvT6hwSAzNBDqSMNJkDHJ3D/q6jU+Eoo/aQiSJobU3pAL
         jPxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nRmn0YNw;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p13sor3496197lja.38.2019.06.09.05.10.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 05:10:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nRmn0YNw;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=MGnWlXcEZlsDllQ1p+dLiYMxOQG545jMz4NgSBC9Y94=;
        b=nRmn0YNw8W+QR/WXpFQLQvxWieu7tL/WNi0q3+UMLXv1nXW9gwzTkCv8SY1aRpJeat
         ilJLCQYmFDEiyA3lldq0wUtt9f85fPZGz+jdQ/hHsk01cnqc6AUXcRN1GNDaWLJV14jX
         ngoF5Y2eJ4ywcfSSrZxnYcfyh8zCFxI53rHruVBiZnb1KSQtkRgLJIGZ6DOctY72Hm8S
         5TbducFcWoCXLn2GTEd21oqtCp0N4r2+WEB+zmjhox+Yi53x81DvSYRbVf4NWSZqbe/P
         0aiDUGPE3KavdxykFJkQrksAtAEmmw5rxLRm30FYIRBidXHsQ1OR0t18qhaGuetsxAZY
         TQNg==
X-Google-Smtp-Source: APXvYqyrmwbev/kM38jFwPiKr2yUx7kn6QEzpscG18zuD1wOeoyI47i1pIxOyWt6Uu8NLD0OnZFBrg==
X-Received: by 2002:a2e:9692:: with SMTP id q18mr34382352lji.89.1560082255174;
        Sun, 09 Jun 2019 05:10:55 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id t3sm1423097lfk.59.2019.06.09.05.10.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 09 Jun 2019 05:10:54 -0700 (PDT)
Date: Sun, 9 Jun 2019 15:10:52 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v6 01/10] mm: add missing smp read barrier on getting
 memcg kmem_cache pointer
Message-ID: <20190609121052.kge3w3hv3t5u5bb3@esperanza>
References: <20190605024454.1393507-1-guro@fb.com>
 <20190605024454.1393507-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605024454.1393507-2-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 07:44:45PM -0700, Roman Gushchin wrote:
> Johannes noticed that reading the memcg kmem_cache pointer in
> cache_from_memcg_idx() is performed using READ_ONCE() macro,
> which doesn't implement a SMP barrier, which is required
> by the logic.
> 
> Add a proper smp_rmb() to be paired with smp_wmb() in
> memcg_create_kmem_cache().
> 
> The same applies to memcg_create_kmem_cache() itself,
> which reads the same value without barriers and READ_ONCE().
> 
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> ---
>  mm/slab.h        | 1 +
>  mm/slab_common.c | 3 ++-
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/slab.h b/mm/slab.h
> index 739099af6cbb..1176b61bb8fc 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -260,6 +260,7 @@ cache_from_memcg_idx(struct kmem_cache *s, int idx)
>  	 * memcg_caches issues a write barrier to match this (see
>  	 * memcg_create_kmem_cache()).
>  	 */
> +	smp_rmb();
>  	cachep = READ_ONCE(arr->entries[idx]);

Hmm, we used to have lockless_dereference() here, but it was replaced
with READ_ONCE some time ago. The commit message claims that READ_ONCE
has an implicit read barrier in it.

commit 506458efaf153c1ea480591c5602a5a3ba5a3b76
Author: Will Deacon <will.deacon@arm.com>
Date:   Tue Oct 24 11:22:48 2017 +0100

    locking/barriers: Convert users of lockless_dereference() to READ_ONCE()

    READ_ONCE() now has an implicit smp_read_barrier_depends() call, so it
    can be used instead of lockless_dereference() without any change in
    semantics.

    Signed-off-by: Will Deacon <will.deacon@arm.com>
    Cc: Linus Torvalds <torvalds@linux-foundation.org>
    Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
    Cc: Peter Zijlstra <peterz@infradead.org>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Link: http://lkml.kernel.org/r/1508840570-22169-4-git-send-email-will.deacon@arm.com
    Signed-off-by: Ingo Molnar <mingo@kernel.org>

commit 76ebbe78f7390aee075a7f3768af197ded1bdfbb
Author: Will Deacon <will.deacon@arm.com>
Date:   Tue Oct 24 11:22:47 2017 +0100

    locking/barriers: Add implicit smp_read_barrier_depends() to READ_ONCE()

    In preparation for the removal of lockless_dereference(), which is the
    same as READ_ONCE() on all architectures other than Alpha, add an
    implicit smp_read_barrier_depends() to READ_ONCE() so that it can be
    used to head dependency chains on all architectures.

    Signed-off-by: Will Deacon <will.deacon@arm.com>
    Cc: Linus Torvalds <torvalds@linux-foundation.org>
    Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
    Cc: Peter Zijlstra <peterz@infradead.org>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Link: http://lkml.kernel.org/r/1508840570-22169-3-git-send-email-will.deacon@arm.com
    Signed-off-by: Ingo Molnar <mingo@kernel.org>


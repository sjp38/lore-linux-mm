Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54F60C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 22:28:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 221FF204EC
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 22:28:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 221FF204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B75A18E0003; Wed, 31 Jul 2019 18:28:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B26488E0001; Wed, 31 Jul 2019 18:28:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9ED8A8E0003; Wed, 31 Jul 2019 18:28:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1438E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 18:28:00 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j22so44154630pfe.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 15:28:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nwcJ3sQwPY3LTO7gF5g6MU8bAtfGsVtclFQFC0wg+HA=;
        b=ZqbiZ0SYKj7NJQDc2dIbwaOxA4Zh6K5ed77hInpdJtwQvkZS+ZoSOvI5Ft6u8ajLEH
         SFctY1oVbwPLpQXDMpdF6Hvo1ETt0ho3d/WOc21v9nBlhWrquWXtLtKgAVBcCN5NrV/P
         dVLkBcIJ1+JTpnOwN5d1I9EislxsN9IfQgrx4xXWhMhqprAM9oltfEmAwloknccZonzc
         qLcR19a2W+YGyRi3QdiRw1Z4iNY6KEtHMj9WcRFdtIO0MxxlInyuf95rEJBKBJ8UIC5V
         nvtd3oTvxiFLmqYrr7KgzbHKExHF3kBuIoRUYSLUKNBrmaek0X7DUGHh/y83kB+zlQCW
         6DGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUMAgzmLh75e+clw8wnL7EJJeL+7xuBu9EBMbaSKvyluNCGR9DB
	DBCvT27DGjkE8CLPvkwvki2v5v4duh+PRZri46/WRTmzlZ0mnpH2Vo95lzDv60XTMK3f3hD8X+Z
	egv2uQ30Gf/CIQ+dKGu8GvkoXaJvHM1aKdZSvtHDgNlFr9ZMCWb6yZs3ggJPk76Mk8w==
X-Received: by 2002:a17:902:7887:: with SMTP id q7mr4576509pll.129.1564612080098;
        Wed, 31 Jul 2019 15:28:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyXqWnZsuHLj+iOawkeG/q+79dW1bP/+vemJoIVXvc+XcURvy9w8AfQw+oe2a/NaVx72T2
X-Received: by 2002:a17:902:7887:: with SMTP id q7mr4576455pll.129.1564612079305;
        Wed, 31 Jul 2019 15:27:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564612079; cv=none;
        d=google.com; s=arc-20160816;
        b=SzEhPOhEQCmhZJixsxoNvYM8AIsDc62kN/k2kGya9z7zh1Hw9E26ZWurmihGnkmXQV
         brJYyWytFKnAqugZoS02sNrkKqpd13jt3AXuLmBOk1fsNWz4cPWhkWf8okB4kVgbI9pq
         NpEmmkD345LmKMCnSrRwLqFFwl7GlyjwfJebHmvehW/UV3PDePlzumYJaIIBPhNJuTbH
         +XxyJNr8IeY/PGbRniBfcxEZUTjyNzpYxd6TY8cgesCfBVi9/l0Sb4hTPbfycJOHypP4
         ULEYtfmxbn2dtRudjCbLHT8f0XCY6WpCr2/bW76LhdKKEjd0Wr8JfBagtspwEm+wRyw/
         hxYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=nwcJ3sQwPY3LTO7gF5g6MU8bAtfGsVtclFQFC0wg+HA=;
        b=Bco9VxGD8b2UbbDz4qCiJpBsnsKJYBp1uqXrTeRzY1XGR5T+TTSg1jxKDRx7jV+fHe
         P0u8LRRpO6hwolVYzHDx4OJlpOs3JvgHwfq3Wchh57ef/ihqywxv4OpuEjSBWDWjxQpx
         q1PWpl0I3sZQAFnos36+c3OL8JhYmxn8dmtYA8vsy96rur8hwe5JvLqNtRzUhIq+NEoG
         ER0Q4YzEAWXBWPO7DtCUaw2oHpcEOEWfQkfeB5BT2QqvN0OS6XcGTomxNMMEu3qIUDr1
         S2Fj2WL9ZqmWzILdKlPTovsNr1ejAStlKsvle058beNtWMV/FIi0y8h+DBjJ9YpmTu/s
         hudA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h185si30657283pge.199.2019.07.31.15.27.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 15:27:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from X1 (unknown [76.191.170.112])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id BBC45416B;
	Wed, 31 Jul 2019 22:27:55 +0000 (UTC)
Date: Wed, 31 Jul 2019 15:27:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com,
 Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] fork: Improve error message for corrupted page tables
Message-Id: <20190731152753.b17d9c4418f4bf6815a27ad8@linux-foundation.org>
In-Reply-To: <20190730221820.7738-1-sai.praneeth.prakhya@intel.com>
References: <20190730221820.7738-1-sai.praneeth.prakhya@intel.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jul 2019 15:18:20 -0700 Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com> wrote:

> When a user process exits, the kernel cleans up the mm_struct of the user
> process and during cleanup, check_mm() checks the page tables of the user
> process for corruption (E.g: unexpected page flags set/cleared). For
> corrupted page tables, the error message printed by check_mm() isn't very
> clear as it prints the loop index instead of page table type (E.g: Resident
> file mapping pages vs Resident shared memory pages). Hence, improve the
> error message so that it's more informative.
> 
> Without patch:
> --------------
> [  204.836425] mm/pgtable-generic.c:29: bad p4d 0000000089eb4e92(800000025f941467)
> [  204.836544] BUG: Bad rss-counter state mm:00000000f75895ea idx:0 val:2
> [  204.836615] BUG: Bad rss-counter state mm:00000000f75895ea idx:1 val:5
> [  204.836685] BUG: non-zero pgtables_bytes on freeing mm: 20480
> 
> With patch:
> -----------
> [   69.815453] mm/pgtable-generic.c:29: bad p4d 0000000084653642(800000025ca37467)
> [   69.815872] BUG: Bad rss-counter state mm:00000000014a6c03 type:MM_FILEPAGES val:2
> [   69.815962] BUG: Bad rss-counter state mm:00000000014a6c03 type:MM_ANONPAGES val:5
> [   69.816050] BUG: non-zero pgtables_bytes on freeing mm: 20480

Seems useful.

> --- a/include/linux/mm_types_task.h
> +++ b/include/linux/mm_types_task.h
> @@ -44,6 +44,13 @@ enum {
>  	NR_MM_COUNTERS
>  };
>  
> +static const char * const resident_page_types[NR_MM_COUNTERS] = {
> +	"MM_FILEPAGES",
> +	"MM_ANONPAGES",
> +	"MM_SWAPENTS",
> +	"MM_SHMEMPAGES",
> +};

But please let's not put this in a header file.  We're asking the
compiler to put a copy of all of this into every compilation unit which
includes the header.  Presumably the compiler is smart enough not to
do that, but it's not good practice.


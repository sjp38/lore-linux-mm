Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8EAF68E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 17:15:12 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i68-v6so8297829pfb.9
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 14:15:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h69-v6si5435268pge.13.2018.09.28.14.15.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 14:15:11 -0700 (PDT)
Date: Fri, 28 Sep 2018 14:15:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Fix int overflow in callers of do_shrink_slab()
Message-Id: <20180928141509.fd8f8ac8c0ea61f0cb79d494@linux-foundation.org>
In-Reply-To: <153813407177.17544.14888305435570723973.stgit@localhost.localdomain>
References: <153813407177.17544.14888305435570723973.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: gorcunov@openvz.org, mhocko@suse.com, aryabinin@virtuozzo.com, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 28 Sep 2018 14:28:32 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> do_shrink_slab() returns unsigned long value, and
> the placing into int variable cuts high bytes off.
> Then we compare ret and 0xfffffffe (since SHRINK_EMPTY
> is converted to ret type).
> 
> Thus, big number of objects returned by do_shrink_slab()
> may be interpreted as SHRINK_EMPTY, if low bytes of
> their value are equal to 0xfffffffe. Fix that
> by declaration ret as unsigned long in these functions.

Sigh.  How many times has this happened.

> Reported-by: Cyrill Gorcunov <gorcunov@openvz.org>

What did he report?  Was it code inspection?  Did the kernel explode? 
etcetera.  I'm thinking that the fix should be backported but to
determine that, we need to understand the end-user runtime effects, as
always.  Please.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EEED6B029F
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 09:46:51 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id w5-v6so9015420qto.18
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 06:46:51 -0700 (PDT)
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTPS id w16-v6si3403762qts.169.2018.10.25.06.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Oct 2018 06:46:50 -0700 (PDT)
Date: Thu, 25 Oct 2018 13:46:49 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm, slub: not retrieve cpu_slub again in
 new_slab_objects()
In-Reply-To: <20181025094437.18951-1-richard.weiyang@gmail.com>
Message-ID: <01000166ab7a489c-a877d05e-957c-45b1-8b62-9ede88db40a3-000000@email.amazonses.com>
References: <20181025094437.18951-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, 25 Oct 2018, Wei Yang wrote:

> In current code, the following context always meets:
>
>   local_irq_save/disable()
>     ___slab_alloc()
>       new_slab_objects()
>   local_irq_restore/enable()
>
> This context ensures cpu will continue running until it finish this job
> before yield its control, which means the cpu_slab retrieved in
> new_slab_objects() is the same as passed in.

Interrupts can be switched on in new_slab() since it goes to the page
allocator. See allocate_slab().

This means that the percpu slab may change.

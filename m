Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6606B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 19:54:06 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so172796302pac.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 16:54:06 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id pt7si19328964pdb.96.2015.03.22.16.54.05
        for <linux-mm@kvack.org>;
        Sun, 22 Mar 2015 16:54:05 -0700 (PDT)
Date: Sun, 22 Mar 2015 19:54:03 -0400 (EDT)
Message-Id: <20150322.195403.1653355516554747742.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <550F51D5.2010804@oracle.com>
References: <CA+55aFwEq09vwnxPEYr67O7nuOEN9_n-uJKX11qSbuBNGJVghg@mail.gmail.com>
	<20150322.182311.109269221031797359.davem@davemloft.net>
	<550F51D5.2010804@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david.ahern@oracle.com
Cc: torvalds@linux-foundation.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bpicco@meloft.net

From: David Ahern <david.ahern@oracle.com>
Date: Sun, 22 Mar 2015 17:35:49 -0600

> I don't know if you caught Bob's message; he has a hack to bypass
> memcpy and memmove in mm/slab.c use a for loop to move entries. With
> the hack he is not seeing the problem.
> 
> This is the hack:
> 
> +static void move_entries(void *dest, void *src, int nr)
> +{
> +       unsigned long *dp = dest;
> +       unsigned long *sp = src;
> +
> +       for (; nr; nr--, dp++, sp++)
> +               *dp = *sp;
> +}
> +
> 
> and then replace the mempy and memmove calls in transfer_objects,
> cache_flusharray and drain_array to use move_entries.
> 
> I just put it on 4.0.0-rc4 and ditto -- problem goes away, so it
> clearly suggests the memcpy or memmove are the root cause.

Thanks, didn't notice that.

So, something is amuck.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

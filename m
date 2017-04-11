Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBB496B039F
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 12:17:45 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id d203so4174651iof.20
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 09:17:45 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [69.252.207.43])
        by mx.google.com with ESMTPS id m188si2381377itd.54.2017.04.11.09.17.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 09:17:45 -0700 (PDT)
Date: Tue, 11 Apr 2017 11:16:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Add additional consistency check
In-Reply-To: <20170411141956.GP6729@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org>
References: <20170404113022.GC15490@dhcp22.suse.cz> <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org> <20170404151600.GN15132@dhcp22.suse.cz> <alpine.DEB.2.20.1704041412050.27424@east.gentwo.org> <20170404194220.GT15132@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041457030.28085@east.gentwo.org> <20170404201334.GV15132@dhcp22.suse.cz> <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com> <20170411134618.GN6729@dhcp22.suse.cz> <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com>
 <20170411141956.GP6729@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 11 Apr 2017, Michal Hocko wrote:

>  static inline void *index_to_obj(struct kmem_cache *cache, struct page *page,
> @@ -3813,14 +3818,18 @@ void kfree(const void *objp)
>  {
>  	struct kmem_cache *c;
>  	unsigned long flags;
> +	struct page *page;
>
>  	trace_kfree(_RET_IP_, objp);
>
>  	if (unlikely(ZERO_OR_NULL_PTR(objp)))
>  		return;
> +	page = virt_to_head_page(obj);
> +	if (CHECK_DATA_CORRUPTION(!PageSlab(page)))

There is a flag SLAB_DEBUG_OBJECTS that is available for this check.
Consistency checks are configuraable in the slab allocator.

Mentioned that before and got this lecture about data consistency checks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

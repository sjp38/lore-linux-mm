Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0661D6B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 12:03:14 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id a3so8313551itg.7
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 09:03:14 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id i190si5419346itg.13.2017.12.21.09.03.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 09:03:06 -0800 (PST)
Date: Thu, 21 Dec 2017 11:03:05 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 5/8] mm: Introduce _slub_counter_t
In-Reply-To: <20171220161923.GB1840@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1712211057310.22093@nuc-kabylake>
References: <20171216164425.8703-1-willy@infradead.org> <20171216164425.8703-6-willy@infradead.org> <20171219080731.GB2787@dhcp22.suse.cz> <20171219124605.GA13680@bombadil.infradead.org> <20171219130159.GT2787@dhcp22.suse.cz>
 <20171220161923.GB1840@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Wed, 20 Dec 2017, Matthew Wilcox wrote:

> slub wants to atomically update both freelist and its counters, so it has
> 96 bits of information to update atomically (on 64 bit), or 64 bits on
> 32-bit machines.  We don't have a 96-bit atomic-cmpxchg, but we do have
> a 128-bit atomic-cmpxchg on some architectures.  So _if_ we're going
> to use cmpxchg_double(), then we need counters to be an unsigned long.
> If we're not then counters needs to be an unsigned int so it doesn't
> overlap with _refcount, which is not going to be protected by slab_lock.

Almost correct. slab_lock is not used when double word cmpxchg is
available on the architecture.

> Now I look at it some more though, I wonder if it would hurt for counters
> to always be unsigned long.  There is no problem on 32-bit as long and int
> are the same size.  So on 64-bit, the cmpxchg_double path stays as it is.
> There would then be the extra miniscule risk that __cmpxchg_double_slab()
> fails due to a spurious _refcount modification due to an RCU-protected
> pagecache lookup.  And there are a few places that would be a 64-bit
> load rather than a 32-bit load.

Sounds good to me.

> I think if I were doing slub, I'd put in 'unsigned int counters_32'
> and 'unsigned long counters_64'.  set_page_slub_counters() would then
> become simply:
>
> 	page->counters_32 = counters_new;

If counters is always the native word size then we would not need the 32
and 64 bit variants.

Counters could always be unsigned long



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD016B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 19:47:00 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so6022044pdj.22
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 16:47:00 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id pi8si10279208pac.117.2013.12.16.16.46.56
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 16:46:57 -0800 (PST)
Message-ID: <52AF9EB9.7080606@sr71.net>
Date: Mon, 16 Dec 2013 16:45:45 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/7] re-shrink 'struct page' when SLUB is on.
References: <20131213235903.8236C539@viggo.jf.intel.com> <20131216160128.aa1f1eb8039f5eee578cf560@linux-foundation.org>
In-Reply-To: <20131216160128.aa1f1eb8039f5eee578cf560@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, Christoph Lameter <cl@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Pekka Enberg <penberg@kernel.org>

On 12/16/2013 04:01 PM, Andrew Morton wrote:
> On Fri, 13 Dec 2013 15:59:03 -0800 Dave Hansen <dave@sr71.net> wrote:
>> SLUB depends on a 16-byte cmpxchg for an optimization.  For the
>> purposes of this series, I'm assuming that it is a very important
>> optimization that we desperately need to keep around.
> 
> What if we don't do that.

I'll do some testing and see if I can coax out any delta from the
optimization myself.  Christoph went to a lot of trouble to put this
together, so I assumed that he had a really good reason, although the
changelogs don't really mention any.

I honestly can't imagine that a cmpxchg16 is going to be *THAT* much
cheaper than a per-page spinlock.  The contended case of the cmpxchg is
way more expensive than spinlock contention for sure.

fc9bb8c768's commit message says:
>     The doublewords must be properly aligned for cmpxchg_double to work.
>     Sadly this increases the size of page struct by one word on some architectures.
>     But as a resultpage structs are now cacheline aligned on x86_64.

I'm not sure what aligning them buys us though.  I think I just
demonstrated that cache footprint is *way* more important than alignment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

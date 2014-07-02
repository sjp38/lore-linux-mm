Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8146B0038
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 14:24:19 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so12923377pab.18
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 11:24:19 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id cd2si30939522pbb.90.2014.07.02.11.24.16
        for <linux-mm@kvack.org>;
        Wed, 02 Jul 2014 11:24:17 -0700 (PDT)
Message-ID: <53B44E4E.6020706@sr71.net>
Date: Wed, 02 Jul 2014 11:24:14 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] x86: mm: set TLB flush tunable to sane value (33)
References: <20140701164845.8D1A5702@viggo.jf.intel.com> <20140701164856.3020D644@viggo.jf.intel.com> <53B44C9A.9070808@nellans.org>
In-Reply-To: <53B44C9A.9070808@nellans.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Nellans <david@nellans.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "x86@kernel.org" <x86@kernel.org>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "mgorman@suse.de" <mgorman@suse.de>

On 07/02/2014 11:16 AM, David Nellans wrote:
> Intuition here is that invalidate caused refills will almost always
> be serviced from the L2 or better since we've recently walked to
> modify the page needing flush and thus pre-warmed the caches for any
> refill? Or is this an artifact of the flush/refill test setup?

There are lots of caches in place, not just the CPU's normal L1/2/3
memory caches.  See "4.10.3 Paging-Structure Caches" in the Intel SDM.
I _believe_ TLB misses can be serviced from these caches and their
purpose is to avoid going out to memory (or the memory caches).

So I think the effect that we're seeing is from _all_ of the caches,
plus prefetching.  If you start a prefetch for a TLB miss before you
actually start to run the instruction needing the TLB entry, you will
pay less than the entire cost of going out to memory (or the memory caches).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

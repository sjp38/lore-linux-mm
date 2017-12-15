Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0DE6B0069
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:22:35 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a74so8538300pfg.20
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 11:22:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 33si5164000plv.465.2017.12.15.11.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 11:22:34 -0800 (PST)
Date: Fri, 15 Dec 2017 11:22:03 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
Message-ID: <20171215192203.GC27160@bombadil.infradead.org>
References: <5A311C5E.7000304@intel.com>
 <201712132316.EJJ57332.MFOSJHOFFVLtQO@I-love.SAKURA.ne.jp>
 <5A31F445.6070504@intel.com>
 <201712150129.BFC35949.FFtFOLSOJOQHVM@I-love.SAKURA.ne.jp>
 <20171214181219.GA26124@bombadil.infradead.org>
 <201712160121.BEJ26052.HOFFOOQFMLtSVJ@I-love.SAKURA.ne.jp>
 <20171215184915.GB27160@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171215184915.GB27160@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On Fri, Dec 15, 2017 at 10:49:15AM -0800, Matthew Wilcox wrote:
> Here's the API I'm looking at right now.  The user need take no lock;
> the locking (spinlock) is handled internally to the implementation.

I looked at the API some more and found some flaws:
 - how does xbit_alloc communicate back which bit it allocated?
 - What if xbit_find_set() is called on a completely empty array with
   a range of 0, ULONG_MAX -- there's no invalid number to return.
 - xbit_clear() can't return an error.  Neither can xbit_zero().
 - Need to add __must_check to various return values to discourage sloppy
   programming

So I modify the proposed API we compete with thusly:

bool xbit_test(struct xbitmap *, unsigned long bit);
int __must_check xbit_set(struct xbitmap *, unsigned long bit, gfp_t);
void xbit_clear(struct xbitmap *, unsigned long bit);
int __must_check xbit_alloc(struct xbitmap *, unsigned long *bit, gfp_t);

int __must_check xbit_fill(struct xbitmap *, unsigned long start,
                        unsigned long nbits, gfp_t);
void xbit_zero(struct xbitmap *, unsigned long start, unsigned long nbits);
int __must_check xbit_alloc_range(struct xbitmap *, unsigned long *bit,
                        unsigned long nbits, gfp_t);

bool xbit_find_clear(struct xbitmap *, unsigned long *start, unsigned long max);
bool xbit_find_set(struct xbitmap *, unsigned long *start, unsigned long max);

(I'm a little sceptical about the API accepting 'max' for the find
functions and 'nbits' in the fill/zero/alloc_range functions, but I think
that matches how people want to use it, and it matches how bitmap.h works)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

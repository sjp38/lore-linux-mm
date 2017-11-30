Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B48016B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 08:40:51 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 81so5919143iof.4
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 05:40:51 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 65si3899296iti.86.2017.11.30.05.40.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 05:40:50 -0800 (PST)
Subject: Re: [PATCH v18 05/10] xbitmap: add more operations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
	<1511963726-34070-6-git-send-email-wei.w.wang@intel.com>
	<201711301934.CDC21800.FSLtJFFOOVQHMO@I-love.SAKURA.ne.jp>
In-Reply-To: <201711301934.CDC21800.FSLtJFFOOVQHMO@I-love.SAKURA.ne.jp>
Message-Id: <201711302235.FAJ57385.OFJHOVQOFtMSFL@I-love.SAKURA.ne.jp>
Date: Thu, 30 Nov 2017 22:35:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Tetsuo Handa wrote:
> > +
> > +			if (ebit >= BITS_PER_LONG)
> > +				continue;
> 
> (I don't understand how radix tree works, but generally this patchset looks fuzzy
> to me about boundary cases. Thus, I want to confirm that this is not an overlook.)
> Why is making "ebit >= BITS_PER_LONG" (e.g. start == 62) case a no-op correct?
> Aren't there bits which should have been cleared in this case?

According to xb_set_bit(), it seems to me that we are trying to avoid memory allocation
for "struct ida_bitmap" when all set bits within a 1024-bits bitmap reside in the first
61 bits.

But does such saving help? Is there characteristic bias that majority of set bits resides
in the first 61 bits, for "bit" is "unsigned long" which holds a page number (isn't it)?
If no such bias, wouldn't eliminating radix_tree_exception() case and always storing
"struct ida_bitmap" simplifies the code (and make the processing faster)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

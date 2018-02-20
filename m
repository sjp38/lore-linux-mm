Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 13FB16B0005
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:59:35 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 30so8471891wrw.6
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:59:35 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 202si785530wms.81.2018.02.20.08.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 08:59:32 -0800 (PST)
Subject: Re: [PATCH 2/6] genalloc: selftest
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
 <20180212165301.17933-3-igor.stoppa@huawei.com>
 <CAGXu5jJNERp-yni1jdqJRYJ82xrP7=_O1vkxG1sJ-b8CxudP9g@mail.gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <f33112e4-608f-ae8c-bf88-80ef83b61398@huawei.com>
Date: Tue, 20 Feb 2018 18:59:05 +0200
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJNERp-yni1jdqJRYJ82xrP7=_O1vkxG1sJ-b8CxudP9g@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph
 Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>



On 13/02/18 01:50, Kees Cook wrote:
> On Mon, Feb 12, 2018 at 8:52 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:

[...]

>>  lib/genalloc-selftest.c           | 400 ++++++++++++++++++++++++++++++++++++++
> 
> Nit: make this test_genalloc.c instead.

ok

[...]

>> +       genalloc_selftest();
> 
> I wonder if it's possible to make this module-loadable instead? That
> way it could be built and tested separately.

In my case modules are not an option.
Of course it could be still built in, but what is the real gain?

[...]

>> +config GENERIC_ALLOCATOR_SELFTEST
> 
> Like the other lib/test_*.c targets, I'd call this TEST_GENERIC_ALLOCATOR.

ok

[...]

>> +       BUG_ON(compare_bitmaps(pool, action->pattern));
> 
> There's been a lot recently on BUG vs WARN. It does seem crazy to not
> BUG for an allocator selftest, but if we can avoid it, we should.

If this fails, I would expect that memory corruption is almost guaranteed.
Do we really want to allow the boot to continue, possibly mounting a
filesystem, only to corrupt it? It seems very dangerous.

> Also, I wonder if it might make sense to split this series up a little
> more, as in:
> 
> 1/n: add genalloc selftest
> 2/n: update bitmaps
> 3/n: add/change bitmap tests to selftest
> 
> Maybe I'm over-thinking it, but the great thing about this self test
> is that it's checking much more than just the bitmap changes you're
> making, and that can be used to "prove" that genalloc continues to
> work after the changes (i.e. the selftest passes before the changes,
> and after, rather than just after).

If I really have to ... but to me the evidence that the changes to the
bitmaps do really work is already provided by the bitmap patch itself.

Since the patch doesn't remove the parameter indicating the space to be
freed, it can actually compare what the kernel passes to it vs. what it
thinks the space should be.

If the values were different, it would complain, but it doesn't ...
Isn't that even stronger evidence that the bitmap changes work as expected?


(eventually the parameter can be removed, but I intentionally left it,
for facilitating the merge)

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

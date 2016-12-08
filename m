Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5FB6B0253
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 08:00:29 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id j49so287776081qta.1
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 05:00:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q37si17184078qte.225.2016.12.08.05.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 05:00:28 -0800 (PST)
Subject: Re: [RFC PATCH] mm: introduce kv[mz]alloc helpers
References: <20161208103300.23217-1-mhocko@kernel.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <86cabb7a-1756-4d12-7ba4-776f66f6bb86@redhat.com>
Date: Thu, 8 Dec 2016 14:00:20 +0100
MIME-Version: 1.0
In-Reply-To: <20161208103300.23217-1-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, kvm@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org

Am 08.12.2016 um 11:33 schrieb Michal Hocko:
> From: Michal Hocko <mhocko@suse.com>
>
> Using kmalloc with the vmalloc fallback for larger allocations is a
> common pattern in the kernel code. Yet we do not have any common helper
> for that and so users have invented their own helpers. Some of them are
> really creative when doing so. Let's just add kv[mz]alloc and make sure
> it is implemented properly. This implementation makes sure to not make
> a large memory pressure for > PAGE_SZE requests (__GFP_NORETRY) and also
> to not warn about allocation failures. This also rules out the OOM
> killer as the vmalloc is a more approapriate fallback than a disruptive
> user visible action.
>
> This patch also changes some existing users and removes helpers which
> are specific for them. In some cases this is not possible (e.g.
> ext4_kvmalloc, libcfs_kvzalloc, __aa_kvmalloc) because those seems to be
> broken and require GFP_NO{FS,IO} context which is not vmalloc compatible
> in general (note that the page table allocation is GFP_KERNEL). Those
> need to be fixed separately.
>
> apparmor has already claimed kv[mz]alloc so remove those and use
> __aa_kvmalloc instead to prevent from the naming clashes.
>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Mike Snitzer <snitzer@redhat.com>
> Cc: dm-devel@redhat.com
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: "Theodore Ts'o" <tytso@mit.edu>
> Cc: kvm@vger.kernel.org
> Cc: linux-ext4@vger.kernel.org
> Cc: linux-f2fs-devel@lists.sourceforge.net
> Cc: linux-security-module@vger.kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>

I remember yet another similar user in arch/s390/kvm/kvm-s390.c
-> kvm_s390_set_skeys()

...
keys = kmalloc_array(args->count, sizeof(uint8_t),
                      GFP_KERNEL | __GFP_NOWARN);
if (!keys)
         vmalloc(sizeof(uint8_t) * args->count);
...

would kvmalloc_array make sense? (it would even make the code here
less error prone and better to read)

-- 

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

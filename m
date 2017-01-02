Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id EAEFE6B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 10:55:46 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id n68so415479720itn.4
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 07:55:46 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0217.hostedemail.com. [216.40.44.217])
        by mx.google.com with ESMTPS id f127si24947406ite.15.2017.01.02.07.55.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jan 2017 07:55:27 -0800 (PST)
Message-ID: <1483372522.1955.20.camel@perches.com>
Subject: Re: [PATCH] mm: introduce kv[mz]alloc helpers
From: Joe Perches <joe@perches.com>
Date: Mon, 02 Jan 2017 07:55:22 -0800
In-Reply-To: <20170102133700.1734-1-mhocko@kernel.org>
References: <20170102133700.1734-1-mhocko@kernel.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, linux-ext4@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael
 S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@dilger.ca>

On Mon, 2017-01-02 at 14:37 +0100, Michal Hocko wrote:
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

I have no real objection but perhaps this would
be better done as 3 or more patches

o rename apparmor uses
o introduce generic
o conversions to generic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

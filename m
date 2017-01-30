Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B95FA6B0272
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 11:14:26 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r18so9979798wmd.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 08:14:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si13927029wmd.88.2017.01.30.08.14.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 08:14:25 -0800 (PST)
Subject: Re: [PATCH 5/9] treewide: use kv[mz]alloc* rather than opencoded
 variants
References: <20170130094940.13546-1-mhocko@kernel.org>
 <20170130094940.13546-6-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9793f9d3-4ef1-aad0-b38f-d8760e536ff9@suse.cz>
Date: Mon, 30 Jan 2017 17:14:21 +0100
MIME-Version: 1.0
In-Reply-To: <20170130094940.13546-6-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Yishai Hadas <yishaih@mellanox.com>, Oleg Drokin <oleg.drokin@intel.com>, "Yan, Zheng" <zyan@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org

On 01/30/2017 10:49 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> There are many code paths opencoding kvmalloc. Let's use the helper
> instead. The main difference to kvmalloc is that those users are usually
> not considering all the aspects of the memory allocator. E.g. allocation
> requests <= 32kB (with 4kB pages) are basically never failing and invoke
> OOM killer to satisfy the allocation. This sounds too disruptive for
> something that has a reasonable fallback - the vmalloc. On the other
> hand those requests might fallback to vmalloc even when the memory
> allocator would succeed after several more reclaim/compaction attempts
> previously. There is no guarantee something like that happens though.
>
> This patch converts many of those places to kv[mz]alloc* helpers because
> they are more conservative.
>
> Changes since v1
> - add kvmalloc_array - this might silently fix some overflow issues
>   because most users simply didn't check the overflow for the vmalloc
>   fallback.
>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Anton Vorontsov <anton@enomsg.org>
> Cc: Colin Cross <ccross@android.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Ben Skeggs <bskeggs@redhat.com>
> Cc: Kent Overstreet <kent.overstreet@gmail.com>
> Cc: Santosh Raspatur <santosh@chelsio.com>
> Cc: Hariprasad S <hariprasad@chelsio.com>
> Cc: Yishai Hadas <yishaih@mellanox.com>
> Cc: Oleg Drokin <oleg.drokin@intel.com>
> Cc: "Yan, Zheng" <zyan@redhat.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: netdev@vger.kernel.org
> Acked-by: Andreas Dilger <andreas.dilger@intel.com> # Lustre
> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com> # Xen bits
> Acked-by: Christian Borntraeger <borntraeger@de.ibm.com> # KVM/s390
> Acked-by: Dan Williams <dan.j.williams@intel.com> # nvdim
> Acked-by: David Sterba <dsterba@suse.com> # btrfs
> Acked-by: Ilya Dryomov <idryomov@gmail.com> # Ceph
> Acked-by: Tariq Toukan <tariqt@mellanox.com> # mlx4
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

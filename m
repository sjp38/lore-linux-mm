Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id CC2C26B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 07:16:25 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l68so32142100wml.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 04:16:25 -0800 (PST)
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com. [195.75.94.102])
        by mx.google.com with ESMTPS id v71si10103274wmd.18.2016.03.03.04.16.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 04:16:24 -0800 (PST)
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cornelia.huck@de.ibm.com>;
	Thu, 3 Mar 2016 12:16:23 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id A0F4C1B08070
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 12:16:43 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u23CGKf961145230
	for <linux-mm@kvack.org>; Thu, 3 Mar 2016 12:16:20 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u23CGJbX016424
	for <linux-mm@kvack.org>; Thu, 3 Mar 2016 07:16:20 -0500
Date: Thu, 3 Mar 2016 13:16:16 +0100
From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [RFC qemu 4/4] migration: filter out guest's free pages in ram
 bulk stage
Message-ID: <20160303131616.753f1de5.cornelia.huck@de.ibm.com>
In-Reply-To: <1457001868-15949-5-git-send-email-liang.z.li@intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
	<1457001868-15949-5-git-send-email-liang.z.li@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: quintela@redhat.com, amit.shah@redhat.com, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, mst@redhat.com, akpm@linux-foundation.org, pbonzini@redhat.com, rth@twiddle.net, ehabkost@redhat.com, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, dgilbert@redhat.com

On Thu,  3 Mar 2016 18:44:28 +0800
Liang Li <liang.z.li@intel.com> wrote:

> Get the free pages information through virtio and filter out the free
> pages in the ram bulk stage. This can significantly reduce the total
> live migration time as well as network traffic.
> 
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> ---
>  migration/ram.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 46 insertions(+), 6 deletions(-)
> 

> @@ -1945,6 +1971,20 @@ static int ram_save_setup(QEMUFile *f, void *opaque)
>                                              DIRTY_MEMORY_MIGRATION);
>      }
>      memory_global_dirty_log_start();
> +
> +    if (balloon_free_pages_support() &&
> +        balloon_get_free_pages(migration_bitmap_rcu->free_pages_bmap,
> +                               &free_pages_count) == 0) {
> +        qemu_mutex_unlock_iothread();
> +        while (balloon_get_free_pages(migration_bitmap_rcu->free_pages_bmap,
> +                                      &free_pages_count) == 0) {
> +            usleep(1000);
> +        }
> +        qemu_mutex_lock_iothread();
> +
> +        filter_out_guest_free_pages(migration_bitmap_rcu->free_pages_bmap);

A general comment: Using the ballooner to get information about pages
that can be filtered out is too limited (there may be other ways to do
this; we might be able to use cmma on s390, for example), and I don't
like hardcoding to a specific method.

What about the reverse approach: Code may register a handler that
populates the free_pages_bitmap which is called during this stage?

<I like the idea of filtering in general, but I haven't looked at the
code yet>

> +    }
> +
>      migration_bitmap_sync();
>      qemu_mutex_unlock_ramlist();
>      qemu_mutex_unlock_iothread();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

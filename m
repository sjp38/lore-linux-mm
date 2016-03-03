Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 55DFA6B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 07:45:27 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id w104so15606207qge.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 04:45:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g188si40959424qkb.10.2016.03.03.04.45.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 04:45:26 -0800 (PST)
Date: Thu, 3 Mar 2016 12:45:20 +0000
From: "Daniel P. Berrange" <berrange@redhat.com>
Subject: Re: [Qemu-devel] [RFC qemu 4/4] migration: filter out guest's free
 pages in ram bulk stage
Message-ID: <20160303124520.GE32270@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange@redhat.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <1457001868-15949-5-git-send-email-liang.z.li@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1457001868-15949-5-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: quintela@redhat.com, amit.shah@redhat.com, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, ehabkost@redhat.com, kvm@vger.kernel.org, mst@redhat.com, dgilbert@redhat.com, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, pbonzini@redhat.com, akpm@linux-foundation.org, rth@twiddle.net

On Thu, Mar 03, 2016 at 06:44:28PM +0800, Liang Li wrote:
> Get the free pages information through virtio and filter out the free
> pages in the ram bulk stage. This can significantly reduce the total
> live migration time as well as network traffic.
> 
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> ---
>  migration/ram.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 46 insertions(+), 6 deletions(-)

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
> +    }

IIUC, this code is synchronous wrt to the guest OS balloon drive. ie it
is asking the geust for free pages and waiting for a response. If the
guest OS has crashed this is going to mean QEMU waits forever and thus
migration won't complete. Similarly you need to consider that the guest
OS may be malicious and simply never respond.

So if the migration code is going to use the guest balloon driver to get
info about free pages it has to be done in an asynchronous manner so that
migration can never be stalled by a slow/crashed/malicious guest driver.

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

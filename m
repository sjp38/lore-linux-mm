Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id A9C9D6B0033
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 20:24:07 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id r11so929974ote.20
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 17:24:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f69si168851oib.69.2017.11.28.17.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 17:24:06 -0800 (PST)
Date: Wed, 29 Nov 2017 03:24:02 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3] virtio_balloon: include disk/file caches memory
 statistics
Message-ID: <20171129032348-mutt-send-email-mst@kernel.org>
References: <2e8c12f5242bcf755a33ee3a0e9ef94339d1808c.1510487579.git.tgolembi@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2e8c12f5242bcf755a33ee3a0e9ef94339d1808c.1510487579.git.tgolembi@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?VG9tw6HFoSBHb2xlbWJpb3Zza8O9?= <tgolembi@redhat.com>
Cc: linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, virtualization@lists.linux-foundation.org, Huang Ying <ying.huang@intel.com>, Gal Hammer <ghammer@redhat.com>, Jason Wang <jasowang@redhat.com>, Amnon Ilan <ailan@redhat.com>, Wei Wang <wei.w.wang@intel.com>, Shaohua Li <shli@fb.com>, Rik van Riel <riel@redhat.com>

On Sun, Nov 12, 2017 at 01:05:38PM +0100, TomA!A! GolembiovskA 1/2  wrote:
> Add a new field VIRTIO_BALLOON_S_CACHES to virtio_balloon memory
> statistics protocol. The value represents all disk/file caches.
> 
> In this case it corresponds to the sum of values
> Buffers+Cached+SwapCached from /proc/meminfo.
> 
> Signed-off-by: TomA!A! GolembiovskA 1/2  <tgolembi@redhat.com>


I parked this on vhost branch, part of linux next.

> ---
>  drivers/virtio/virtio_balloon.c     | 4 ++++
>  include/uapi/linux/virtio_balloon.h | 3 ++-
>  2 files changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index f0b3a0b9d42f..d2bd13bbaf9f 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -244,11 +244,13 @@ static unsigned int update_balloon_stats(struct virtio_balloon *vb)
>  	struct sysinfo i;
>  	unsigned int idx = 0;
>  	long available;
> +	unsigned long caches;
>  
>  	all_vm_events(events);
>  	si_meminfo(&i);
>  
>  	available = si_mem_available();
> +	caches = global_node_page_state(NR_FILE_PAGES);
>  
>  #ifdef CONFIG_VM_EVENT_COUNTERS
>  	update_stat(vb, idx++, VIRTIO_BALLOON_S_SWAP_IN,
> @@ -264,6 +266,8 @@ static unsigned int update_balloon_stats(struct virtio_balloon *vb)
>  				pages_to_bytes(i.totalram));
>  	update_stat(vb, idx++, VIRTIO_BALLOON_S_AVAIL,
>  				pages_to_bytes(available));
> +	update_stat(vb, idx++, VIRTIO_BALLOON_S_CACHES,
> +				pages_to_bytes(caches));
>  
>  	return idx;
>  }
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 343d7ddefe04..4e8b8304b793 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -52,7 +52,8 @@ struct virtio_balloon_config {
>  #define VIRTIO_BALLOON_S_MEMFREE  4   /* Total amount of free memory */
>  #define VIRTIO_BALLOON_S_MEMTOT   5   /* Total amount of memory */
>  #define VIRTIO_BALLOON_S_AVAIL    6   /* Available memory as in /proc */
> -#define VIRTIO_BALLOON_S_NR       7
> +#define VIRTIO_BALLOON_S_CACHES   7   /* Disk caches */
> +#define VIRTIO_BALLOON_S_NR       8
>  
>  /*
>   * Memory statistics structure.
> -- 
> 2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

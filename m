Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8D5A6B0033
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 12:01:19 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 97so3516455wrb.1
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 09:01:19 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i48sor926327wrf.19.2017.09.20.09.01.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 09:01:18 -0700 (PDT)
Date: Wed, 20 Sep 2017 18:01:13 +0200
From: =?UTF-8?B?VG9tw6HFoSBHb2xlbWJpb3Zza8O9?= <tgolembi@redhat.com>
Subject: Re: [PATCH] virtio_balloon: include buffers and chached memory
 statistics
Message-ID: <20170920180113.73b76041@fiorina>
In-Reply-To: <0bc0c49663fafdf3b03844fe048cac3216d88c5b.1505922364.git.tgolembi@redhat.com>
References: <0bc0c49663fafdf3b03844fe048cac3216d88c5b.1505922364.git.tgolembi@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
Cc: Wei Wang <wei.w.wang@intel.com>, Shaohua Li <shli@fb.com>, Huang Ying <ying.huang@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>

On Wed, 20 Sep 2017 17:48:36 +0200
Tom=C3=A1=C5=A1 Golembiovsk=C3=BD <tgolembi@redhat.com> wrote:

> Add a new fields, VIRTIO_BALLOON_S_BUFFERS and VIRTIO_BALLOON_S_CACHED,
> to virtio_balloon memory statistics protocol. The values correspond to
> 'Buffers' and 'Cached' in /proc/meminfo.
>=20
> To be able to compute the value of 'Cached' memory it is necessary to
> export total_swapcache_pages() to modules.
>=20
> Signed-off-by: Tom=C3=A1=C5=A1 Golembiovsk=C3=BD <tgolembi@redhat.com>
> ---
>  drivers/virtio/virtio_balloon.c     | 11 +++++++++++
>  include/uapi/linux/virtio_balloon.h |  4 +++-
>  mm/swap_state.c                     |  1 +
>  3 files changed, 15 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_ball=
oon.c
> index f0b3a0b9d42f..c2558ec47a62 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -244,12 +244,19 @@ static unsigned int update_balloon_stats(struct vir=
tio_balloon *vb)
>  	struct sysinfo i;
>  	unsigned int idx =3D 0;
>  	long available;
> +	long cached;
> =20
>  	all_vm_events(events);
>  	si_meminfo(&i);
> =20
>  	available =3D si_mem_available();
> =20
> +	cached =3D global_node_page_state(NR_FILE_PAGES) -
> +			total_swapcache_pages() - i.bufferram;
> +	if (cached < 0)
> +		cached =3D 0;
> +
> +
>  #ifdef CONFIG_VM_EVENT_COUNTERS
>  	update_stat(vb, idx++, VIRTIO_BALLOON_S_SWAP_IN,
>  				pages_to_bytes(events[PSWPIN]));
> @@ -264,6 +271,10 @@ static unsigned int update_balloon_stats(struct virt=
io_balloon *vb)
>  				pages_to_bytes(i.totalram));
>  	update_stat(vb, idx++, VIRTIO_BALLOON_S_AVAIL,
>  				pages_to_bytes(available));
> +	update_stat(vb, idx++, VIRTIO_BALLOON_S_BUFFERS,
> +				pages_to_bytes(i.bufferram));
> +	update_stat(vb, idx++, VIRTIO_BALLOON_S_CACHED,
> +				pages_to_bytes(cached));
> =20
>  	return idx;
>  }
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/vir=
tio_balloon.h
> index 343d7ddefe04..119224c34389 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -52,7 +52,9 @@ struct virtio_balloon_config {
>  #define VIRTIO_BALLOON_S_MEMFREE  4   /* Total amount of free memory */
>  #define VIRTIO_BALLOON_S_MEMTOT   5   /* Total amount of memory */
>  #define VIRTIO_BALLOON_S_AVAIL    6   /* Available memory as in /proc */
> -#define VIRTIO_BALLOON_S_NR       7
> +#define VIRTIO_BALLOON_S_BUFFERS  7   /* Bufferes memory as in /proc */

I've just noticed I have a typo in the comment: 'Bufferes' should be
'Buffers'.

> +#define VIRTIO_BALLOON_S_CACHED   8   /* Cached memory as in /proc */
> +#define VIRTIO_BALLOON_S_NR       9
> =20
>  /*
>   * Memory statistics structure.
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 71ce2d1ccbf7..f3a4ff7d6c52 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -95,6 +95,7 @@ unsigned long total_swapcache_pages(void)
>  	rcu_read_unlock();
>  	return ret;
>  }
> +EXPORT_SYMBOL_GPL(total_swapcache_pages);
> =20
>  static atomic_t swapin_readahead_hits =3D ATOMIC_INIT(4);
> =20
> --=20
> 2.14.1
>=20


--=20
Tom=C3=A1=C5=A1 Golembiovsk=C3=BD <tgolembi@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

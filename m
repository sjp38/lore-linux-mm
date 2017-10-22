Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 219296B0038
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 14:06:11 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 4so4080651wrt.8
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 11:06:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f19sor1957090wre.78.2017.10.22.11.06.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Oct 2017 11:06:08 -0700 (PDT)
Date: Sun, 22 Oct 2017 20:05:57 +0200
From: =?UTF-8?B?VG9tw6HFoSBHb2xlbWJpb3Zza8O9?= <tgolembi@redhat.com>
Subject: Re: [PATCH v2 1/1] virtio_balloon: include buffers and cached
 memory statistics
Message-ID: <20171022200557.02558e37@fiorina>
In-Reply-To: <20171019160405-mutt-send-email-mst@kernel.org>
References: <cover.1505998455.git.tgolembi@redhat.com>
	<b13f11c03ed394bd8ad367dc90996ed134ea98da.1505998455.git.tgolembi@redhat.com>
	<20171019160405-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org, Wei Wang <wei.w.wang@intel.com>, Shaohua Li <shli@fb.com>, Huang Ying <ying.huang@intel.com>, Jason Wang <jasowang@redhat.com>

On Thu, 19 Oct 2017 16:12:20 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Thu, Sep 21, 2017 at 02:55:41PM +0200, Tom=C3=A1=C5=A1 Golembiovsk=C3=
=BD wrote:
> > Add a new fields, VIRTIO_BALLOON_S_BUFFERS and VIRTIO_BALLOON_S_CACHED,
> > to virtio_balloon memory statistics protocol. The values correspond to
> > 'Buffers' and 'Cached' in /proc/meminfo.
> >=20
> > To be able to compute the value of 'Cached' memory it is necessary to
> > export total_swapcache_pages() to modules.
> >=20
> > Signed-off-by: Tom=C3=A1=C5=A1 Golembiovsk=C3=BD <tgolembi@redhat.com>
>=20
> Does 'Buffers' actually make sense? It's a temporary storage -
> wouldn't it be significantly out of date by the time
> host receives it?

That would be best answered by somebody from kernel. But my personal
opinion is that it would not be out of date. The amount of memory
dedicated to Buffers does not seem to fluctuate too much.

    Tomas


> > ---
> >  drivers/virtio/virtio_balloon.c     | 11 +++++++++++
> >  include/uapi/linux/virtio_balloon.h |  4 +++-
> >  mm/swap_state.c                     |  1 +
> >  3 files changed, 15 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_ba=
lloon.c
> > index f0b3a0b9d42f..c2558ec47a62 100644
> > --- a/drivers/virtio/virtio_balloon.c
> > +++ b/drivers/virtio/virtio_balloon.c
> > @@ -244,12 +244,19 @@ static unsigned int update_balloon_stats(struct v=
irtio_balloon *vb)
> >  	struct sysinfo i;
> >  	unsigned int idx =3D 0;
> >  	long available;
> > +	long cached;
> > =20
> >  	all_vm_events(events);
> >  	si_meminfo(&i);
> > =20
> >  	available =3D si_mem_available();
> > =20
> > +	cached =3D global_node_page_state(NR_FILE_PAGES) -
> > +			total_swapcache_pages() - i.bufferram;
> > +	if (cached < 0)
> > +		cached =3D 0;
> > +
> > +
> >  #ifdef CONFIG_VM_EVENT_COUNTERS
> >  	update_stat(vb, idx++, VIRTIO_BALLOON_S_SWAP_IN,
> >  				pages_to_bytes(events[PSWPIN]));
> > @@ -264,6 +271,10 @@ static unsigned int update_balloon_stats(struct vi=
rtio_balloon *vb)
> >  				pages_to_bytes(i.totalram));
> >  	update_stat(vb, idx++, VIRTIO_BALLOON_S_AVAIL,
> >  				pages_to_bytes(available));
> > +	update_stat(vb, idx++, VIRTIO_BALLOON_S_BUFFERS,
> > +				pages_to_bytes(i.bufferram));
> > +	update_stat(vb, idx++, VIRTIO_BALLOON_S_CACHED,
> > +				pages_to_bytes(cached));
> > =20
> >  	return idx;
> >  }
> > diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/v=
irtio_balloon.h
> > index 343d7ddefe04..d5dc8a56a497 100644
> > --- a/include/uapi/linux/virtio_balloon.h
> > +++ b/include/uapi/linux/virtio_balloon.h
> > @@ -52,7 +52,9 @@ struct virtio_balloon_config {
> >  #define VIRTIO_BALLOON_S_MEMFREE  4   /* Total amount of free memory */
> >  #define VIRTIO_BALLOON_S_MEMTOT   5   /* Total amount of memory */
> >  #define VIRTIO_BALLOON_S_AVAIL    6   /* Available memory as in /proc =
*/
> > -#define VIRTIO_BALLOON_S_NR       7
> > +#define VIRTIO_BALLOON_S_BUFFERS  7   /* Buffers memory as in /proc */
> > +#define VIRTIO_BALLOON_S_CACHED   8   /* Cached memory as in /proc */
> > +#define VIRTIO_BALLOON_S_NR       9
> > =20
> >  /*
> >   * Memory statistics structure.
> > diff --git a/mm/swap_state.c b/mm/swap_state.c
> > index 71ce2d1ccbf7..f3a4ff7d6c52 100644
> > --- a/mm/swap_state.c
> > +++ b/mm/swap_state.c
> > @@ -95,6 +95,7 @@ unsigned long total_swapcache_pages(void)
> >  	rcu_read_unlock();
> >  	return ret;
> >  }
> > +EXPORT_SYMBOL_GPL(total_swapcache_pages);
> > =20
> >  static atomic_t swapin_readahead_hits =3D ATOMIC_INIT(4);
>=20
> Need an ack from MM crowd on that.
>=20
> > --=20
> > 2.14.1


--=20
Tom=C3=A1=C5=A1 Golembiovsk=C3=BD <tgolembi@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

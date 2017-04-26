Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF4C76B0038
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 07:03:40 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y4so34899720pge.16
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 04:03:40 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id i190si23623536pge.262.2017.04.26.04.03.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 04:03:38 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [virtio-dev] Re: [PATCH v9 2/5] virtio-balloon:
 VIRTIO_BALLOON_F_BALLOON_CHUNKS
Date: Wed, 26 Apr 2017 11:03:34 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7391F6DCD@shsmsx102.ccr.corp.intel.com>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
 <1492076108-117229-3-git-send-email-wei.w.wang@intel.com>
 <20170413184040-mutt-send-email-mst@kernel.org> <58F08A60.2020407@intel.com>
 <20170415000934-mutt-send-email-mst@kernel.org> <58F43801.7060004@intel.com>
In-Reply-To: <58F43801.7060004@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>

Hi Michael, could you please give some feedback?

On Monday, April 17, 2017 11:35 AM, Wei Wang wrote:
> On 04/15/2017 05:38 AM, Michael S. Tsirkin wrote:
> > On Fri, Apr 14, 2017 at 04:37:52PM +0800, Wei Wang wrote:
> >> On 04/14/2017 12:34 AM, Michael S. Tsirkin wrote:
> >>> On Thu, Apr 13, 2017 at 05:35:05PM +0800, Wei Wang wrote:
> >>>
> >>> So we don't need the bitmap to talk to host, it is just a data
> >>> structure we chose to maintain lists of pages, right?
> >> Right. bitmap is the way to gather pages to chunk.
> >> It's only needed in the balloon page case.
> >> For the unused page case, we don't need it, since the free page
> >> blocks are already chunks.
> >>
> >>> OK as far as it goes but you need much better isolation for it.
> >>> Build a data structure with APIs such as _init, _cleanup, _add,
> >>> _clear, _find_first, _find_next.
> >>> Completely unrelated to pages, it just maintains bits.
> >>> Then use it here.
> >>>
> >>>
> >>>>    static int oom_pages =3D OOM_VBALLOON_DEFAULT_PAGES;
> >>>>    module_param(oom_pages, int, S_IRUSR | S_IWUSR);
> >>>>    MODULE_PARM_DESC(oom_pages, "pages to free on OOM"); @@ -50,6
> >>>> +54,10 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
> >>>>    static struct vfsmount *balloon_mnt;
> >>>>    #endif
> >>>> +/* Types of pages to chunk */
> >>>> +#define PAGE_CHUNK_TYPE_BALLOON 0
> >>>> +
> >>> Doesn't look like you are ever adding more types in this patchset.
> >>> Pls keep code simple, generalize it later.
> >>>
> >> "#define PAGE_CHUNK_TYPE_UNUSED 1" is added in another patch.
> > I would say add the extra code there too. Or maybe we can avoid adding
> > it altogether.
>=20
> I'm trying to have the two features( i.e. "balloon pages" and "unused pag=
es")
> decoupled while trying to use common functions to deal with the commonali=
ties.
> That's the reason to define the above macro.
> Without the macro, we will need to have separate functions, for example,
> instead of one "add_one_chunk()", we need to have
> add_one_balloon_page_chunk() and add_one_unused_page_chunk(), and some
> of the implementations will be kind of duplicate in the two functions.
> Probably we can add it when the second feature comes to the code.
>=20
> >
> >> Types of page to chunk are treated differently. Different types of
> >> page chunks are sent to the host via different protocols.
> >>
> >> 1) PAGE_CHUNK_TYPE_BALLOON: Ballooned (i.e. inflated/deflated) pages
> >> to chunk.  For the ballooned type, it uses the basic chunk msg format:
> >>
> >> virtio_balloon_page_chunk_hdr +
> >> virtio_balloon_page_chunk * MAX_PAGE_CHUNKS
> >>
> >> 2) PAGE_CHUNK_TYPE_UNUSED: unused pages to chunk. It uses this miscq
> >> msg
> >> format:
> >> miscq_hdr +
> >> virtio_balloon_page_chunk_hdr +
> >> virtio_balloon_page_chunk * MAX_PAGE_CHUNKS
> >>
> >> The chunk msg is actually the payload of the miscq msg.
> >>
> >>
> > So just combine the two message formats and then it'll all be easier?
> >
>=20
> Yes, it'll be simple with only one msg format. But the problem I see here=
 is that
> miscq hdr is something necessary for the "unused page"
> usage, but not needed by the "balloon page" usage. To be more precise, st=
ruct
> virtio_balloon_miscq_hdr {
>   __le16 cmd;
>   __le16 flags;
> };
> 'cmd' specifies  the command from the miscq (I envision that miscq will b=
e
> further used to handle other possible miscellaneous requests either from =
the
> host or to the host), so 'cmd' is necessary for the miscq. But the inflat=
eq is
> exclusively used for inflating pages, so adding a command to it would be
> redundant and look a little bewildered there.
> 'flags': We currently use bit 0 of flags to indicate the completion ofa c=
ommand,
> this is also useful in the "unused page" usage, and not needed by the "ba=
lloon
> page" usage.
> >>>> +#define MAX_PAGE_CHUNKS 4096
> >>> This is an order-4 allocation. I'd make it 4095 and then it's an
> >>> order-3 one.
> >> Sounds good, thanks.
> >> I think it would be better to make it 4090. Leave some space for the
> >> hdr as well.
> > And miscq hdr. In fact just let compiler do the math - something like:
> > (8 * PAGE_SIZE - sizeof(hdr)) / sizeof(chunk)
> Agree, thanks.
>=20
> >
> > I skimmed explanation of algorithms below but please make sure code
> > speaks for itself and add comments inline to document it.
> > Whenever you answered me inline this is where you want to try to make
> > code clearer and add comments.
> >
> > Also, pls find ways to abstract the data structure so we don't need to
> > deal with its internals all over the code.
> >
> >
> > ....
> >
> >>>>    {
> >>>>    	struct scatterlist sg;
> >>>> +	struct virtio_balloon_page_chunk_hdr *hdr;
> >>>> +	void *buf;
> >>>>    	unsigned int len;
> >>>> -	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
> >>>> +	switch (type) {
> >>>> +	case PAGE_CHUNK_TYPE_BALLOON:
> >>>> +		hdr =3D vb->balloon_page_chunk_hdr;
> >>>> +		len =3D 0;
> >>>> +		break;
> >>>> +	default:
> >>>> +		dev_warn(&vb->vdev->dev, "%s: chunk %d of unknown
> pages\n",
> >>>> +			 __func__, type);
> >>>> +		return;
> >>>> +	}
> >>>> -	/* We should always be able to add one buffer to an empty queue. *=
/
> >>>> -	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> >>>> -	virtqueue_kick(vq);
> >>>> +	buf =3D (void *)hdr - len;
> >>> Moving back to before the header? How can this make sense?
> >>> It works fine since len is 0, so just buf =3D hdr.
> >>>
> >> For the unused page chunk case, it follows its own protocol:
> >> miscq_hdr + payload(chunk msg).
> >>   "buf =3D (void *)hdr - len" moves the buf pointer to the miscq_hdr,
> >> to send the entire miscq msg.
> > Well just pass the correct pointer in.
> >
> OK. The miscq msg is
> {
> miscq_hdr;
> chunk_msg;
> }
>=20
> We can probably change the code like this:
>=20
> #define CHUNK_TO_MISCQ_MSG(chunk) (chunk - sizeof(struct
> virtio_balloon_miscq_hdr))
>=20
> switch (type) {
>          case PAGE_CHUNK_TYPE_BALLOON:
>                  msg_buf =3D vb->balloon_page_chunk_hdr;
>                  msg_len =3D sizeof(struct virtio_balloon_page_chunk_hdr)=
 +
>                      nr_chunks * sizeof(struct virtio_balloon_page_chunk_=
entry);
>                  break;
>          case PAGE_CHUNK_TYPE_UNUSED:
>                  msg_buf =3D CHUNK_TO_MISCQ_MSG(vb->unused_page_chunk_hdr=
);
>                  msg_len =3D sizeof(struct virtio_balloon_miscq_hdr) + si=
zeof(struct
> virtio_balloon_page_chunk_hdr) +
>                      nr_chunks * sizeof(struct virtio_balloon_page_chunk_=
entry);
>                  break;
>          default:
>                  dev_warn(&vb->vdev->dev, "%s: chunk %d of unknown pages\=
n",
>                           __func__, type);
>                  return;
>          }
>=20
>=20
>=20
> >> Please check the patch for implementing the unused page chunk, it
> >> will be clear. If necessary, I can put "buf =3D (void *)hdr - len" fro=
m
> >> that patch.
> > Exactly. And all this pointer math is very messy. Please look for ways
> > to clean it. It's generally easy to fill structures:
> >
> > struct foo *foo =3D kmalloc(..., sizeof(*foo) + n * sizeof(foo->a[0]));
> > for (i =3D 0; i < n; ++i)
> > 	foo->a[i] =3D b;
> >
> > this is the kind of code that's easy to understand and it's obvious
> > there are no overflows and no info leaks here.
> >
> OK, will take your suggestion:
>=20
> struct virtio_balloon_page_chunk {
> 	struct virtio_balloon_page_chunk_hdr hdr;
> 	struct virtio_balloon_page_chunk_entry entries[]; };
>=20
>=20
> >>>> +	len +=3D sizeof(struct virtio_balloon_page_chunk_hdr);
> >>>> +	len +=3D hdr->chunks * sizeof(struct virtio_balloon_page_chunk);
> >>>> +	sg_init_table(&sg, 1);
> >>>> +	sg_set_buf(&sg, buf, len);
> >>>> +	if (!virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL)) {
> >>>> +		virtqueue_kick(vq);
> >>>> +		if (busy_wait)
> >>>> +			while (!virtqueue_get_buf(vq, &len) &&
> >>>> +			       !virtqueue_is_broken(vq))
> >>>> +				cpu_relax();
> >>>> +		else
> >>>> +			wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> >>>> +		hdr->chunks =3D 0;
> >>> Why zero it here after device used it? Better to zero before use.
> >> hdr->chunks tells the host how many chunks are there in the payload.
> >> After the device use it, it is ready to zero it.
> > It's rather confusing. Try to pass # of chunks around in some other
> > way.
>=20
> Not sure if this was explained clearly - we just let the chunk msg hdr in=
dicates
> the # of chunks in the payload. I think this should be a pretty normal us=
age, like
> the network UDP hdr, which uses a length field to indicate the packet len=
gth.
>=20
> >>>> +	}
> >>>> +}
> >>>> +
> >>>> +static void add_one_chunk(struct virtio_balloon *vb, struct virtque=
ue *vq,
> >>>> +			  int type, u64 base, u64 size)
> >>> what are the units here? Looks like it's in 4kbyte units?
> >> what is the "unit" you referred to?
> >> This is the function to add one chunk, base pfn and size of the chunk
> >> are supplied to the function.
> >>
> > Are both size and base in bytes then?
> > But you do not send them to host as is, you shift them for some reason
> > before sending them to host.
> >
> Not in bytes actually. base is a base pfn, which is the starting address =
of the
> continuous pfns. Size is the chunk size, which is the number of continuou=
s pfns.
>=20
> They are shifted based on the chunk format we agreed before:
>=20
> --------------------------------------------------------
> |                 Base (52 bit)        | Rsvd (12 bit) |
> --------------------------------------------------------
> --------------------------------------------------------
> |                 Size (52 bit)        | Rsvd (12 bit) |
> --------------------------------------------------------
>=20
>=20
> Here, the pfn will be the balloon page pfn (4KB).In this way, the host do=
esn't
> need to know PAGE_SIZE of the guest.
>=20
>=20
>=20
> >>>> +			if (zero >=3D end)
> >>>> +				chunk_size =3D end - one;
> >>>> +			else
> >>>> +				chunk_size =3D zero - one;
> >>>> +
> >>>> +			if (chunk_size)
> >>>> +				add_one_chunk(vb, vq,
> PAGE_CHUNK_TYPE_BALLOON,
> >>>> +					      pfn_start + one, chunk_size);
> >>> Still not so what does a bit refer to? page or 4kbytes?
> >>> I think it should be a page.
> >> A bit in the bitmap corresponds to a pfn of a balloon page(4KB).
> > That's a waste on systems with large page sizes, and it does not look
> > like you handle that case correctly.
>=20
> OK, I will change the bitmap to be PAGE_SIZE based here, instead of
> BALLOON_PAGE_SIZE based. When convert them into chunks, making it based
> on BALLOON_PAGE_SIZE.
>=20
>=20
> Best,
> Wei
>=20
>=20
> ---------------------------------------------------------------------
> To unsubscribe, e-mail: virtio-dev-unsubscribe@lists.oasis-open.org
> For additional commands, e-mail: virtio-dev-help@lists.oasis-open.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

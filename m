Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57CFA6B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 07:30:01 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id l73so13969754qke.9
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 04:30:01 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p53si888778qtf.357.2018.02.14.04.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 04:30:00 -0800 (PST)
Date: Wed, 14 Feb 2018 13:29:50 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: WARNING in kvmalloc_node
Message-ID: <20180214132950.2d06e612@redhat.com>
In-Reply-To: <dcbb4ead-2a76-310c-69dc-4f253e711fe9@iogearbox.net>
References: <001a1144c4ca5dc9d6056520c7b7@google.com>
	<20180214025533.GA28811@bombadil.infradead.org>
	<20180214084308.GX3443@dhcp22.suse.cz>
	<f3fda93e-b223-3c94-3213-43cad4346716@iogearbox.net>
	<24351362-a099-3317-2b96-8cdc6835eb1e@redhat.com>
	<20180214115119.GA3443@dhcp22.suse.cz>
	<62489a86-b578-b075-3ada-c2f5baf5b787@redhat.com>
	<dcbb4ead-2a76-310c-69dc-4f253e711fe9@iogearbox.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jason Wang <jasowang@redhat.com>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, syzbot <syzbot+1a240cdb1f4cc88819df@syzkaller.appspotmail.com>, akpm@linux-foundation.org, dhowells@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, rppt@linux.vnet.ibm.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, viro@zeniv.linux.org.uk, Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, brouer@redhat.com

On Wed, 14 Feb 2018 13:17:18 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 02/14/2018 01:02 PM, Jason Wang wrote:
> > On 2018=E5=B9=B402=E6=9C=8814=E6=97=A5 19:51, Michal Hocko wrote: =20
> >> On Wed 14-02-18 19:47:30, Jason Wang wrote: =20
> >>> On 2018=E5=B9=B402=E6=9C=8814=E6=97=A5 17:28, Daniel Borkmann wrote: =
=20
> >>>> [ +Jason, +Jesper ]
> >>>>
> >>>> On 02/14/2018 09:43 AM, Michal Hocko wrote: =20
> >>>>> On Tue 13-02-18 18:55:33, Matthew Wilcox wrote: =20
> >>>>>> On Tue, Feb 13, 2018 at 03:59:01PM -0800, syzbot wrote: =20
> >>>>> [...] =20
> >>>>>>> =C2=A0=C2=A0 kvmalloc include/linux/mm.h:541 [inline]
> >>>>>>> =C2=A0=C2=A0 kvmalloc_array include/linux/mm.h:557 [inline]
> >>>>>>> =C2=A0=C2=A0 __ptr_ring_init_queue_alloc include/linux/ptr_ring.h=
:474 [inline]
> >>>>>>> =C2=A0=C2=A0 ptr_ring_init include/linux/ptr_ring.h:492 [inline]
> >>>>>>> =C2=A0=C2=A0 __cpu_map_entry_alloc kernel/bpf/cpumap.c:359 [inlin=
e]
> >>>>>>> =C2=A0=C2=A0 cpu_map_update_elem+0x3c3/0x8e0 kernel/bpf/cpumap.c:=
490
> >>>>>>> =C2=A0=C2=A0 map_update_elem kernel/bpf/syscall.c:698 [inline] =20
> >>>>>> Blame the BPF people, not the MM people ;-) =20
> >>>> Heh, not really. ;-)
> >>>> =20
> >>>>> Yes. kvmalloc (the vmalloc part) doesn't support GFP_ATOMIC semanti=
c. =20
> >>>> Agree, that doesn't work.
> >>>>
> >>>> Bug was added in commit 0bf7800f1799 ("ptr_ring: try vmalloc() when =
kmalloc() fails").
> >>>>
> >>>> Jason, please take a look at fixing this, thanks! =20
> >>> It looks to me the only solution is to revert that commit. =20
> >> Do you really need this to be GFP_ATOMIC? I can see some callers are
> >> under RCU read lock but can we perhaps do the allocation outside of th=
is
> >> section? =20
> >=20
> > If I understand the code correctly, the code would be called by XDP pro=
gram (usually run inside a bh) which makes it hard to do this.
> >=20
> > Rethink of this, we can probably test gfp and not call kvmalloc if GFP_=
ATOMIC is set in __ptr_ring_init_queue_alloc(). =20
>=20
> That would be one option indeed (probably useful in any case to make the =
API
> more robust). Another one is to just not use GFP_ATOMIC in cpumap. Lookin=
g at
> it, update can neither be called out of a BPF prog since prevented by ver=
ifier
> nor under RCU reader side when updating this type of map from syscall pat=
h.
> Jesper, any concrete reason we still need GFP_ATOMIC here?

Allocations in cpumap (related to ptr_ring) should only be possible to
be initiated through userspace via bpf-syscall. Thus, there isn't any
reason for GFP_ATOMIC here.

--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

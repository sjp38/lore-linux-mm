Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9A56B0038
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 23:09:37 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id a103so213142678ioj.8
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 20:09:37 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id n2si6207959itd.31.2017.04.25.20.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 20:09:36 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
Date: Wed, 26 Apr 2017 02:34:11 +0000
Message-ID: <20170426023410.GA11619@hori1.linux.bs1.fc.nec.co.jp>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493171698.4828.1.camel@gmail.com>
In-Reply-To: <1493171698.4828.1.camel@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <AA6073450FC3D942A18E60B9CEAC9C60@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, Apr 26, 2017 at 11:54:58AM +1000, Balbir Singh wrote:
> On Tue, 2017-04-25 at 16:27 +0200, Laurent Dufour wrote:
> > When page are poisoned, they should be uncharged from the root memory
> > cgroup.
> >=20
> > This is required to avoid a BUG raised when the page is onlined back:
> > BUG: Bad page state in process mem-on-off-test  pfn:7ae3b
> > page:f000000001eb8ec0 count:0 mapcount:0 mapping:          (null)
> > index:0x1
> > flags: 0x3ffff800200000(hwpoison)
> > raw: 003ffff800200000 0000000000000000 0000000000000001
> > 00000000ffffffff
> > raw: 5deadbeef0000100 5deadbeef0000200 0000000000000000
> > c0000007fe055800
> > page dumped because: page still charged to cgroup
> > page->mem_cgroup:c0000007fe055800
> > Modules linked in: pseries_rng rng_core vmx_crypto virtio_balloon
> > ip_tables x_tables autofs4 virtio_blk virtio_net virtio_pci
> > virtio_ring virtio
> > CPU: 34 PID: 5946 Comm: mem-on-off-test Tainted: G    B 4.11.0-rc7-hwp
> > Call Trace:
> > [c0000007e4a737f0] [c000000000958e8c] dump_stack+0xb0/0xf0
> > (unreliable)
> > [c0000007e4a73830] [c00000000021588c] bad_page+0x11c/0x190
> > [c0000007e4a738c0] [c00000000021757c] free_pcppages_bulk+0x46c/0x600
> > [c0000007e4a73990] [c00000000021924c] free_hot_cold_page+0x2ec/0x320
> > [c0000007e4a739e0] [c0000000002a6440] generic_online_page+0x50/0x70
> > [c0000007e4a73a10] [c0000000002a6184] online_pages_range+0x94/0xe0
> > [c0000007e4a73a70] [c00000000005a2b0] walk_system_ram_range+0xe0/0x120
> > [c0000007e4a73ac0] [c0000000002cce44] online_pages+0x2b4/0x6b0
> > [c0000007e4a73b60] [c000000000600558] memory_subsys_online+0x218/0x270
> > [c0000007e4a73bf0] [c0000000005dec84] device_online+0xb4/0x110
> > [c0000007e4a73c30] [c000000000600f00] store_mem_state+0xc0/0x190
> > [c0000007e4a73c70] [c0000000005da1d4] dev_attr_store+0x34/0x60
> > [c0000007e4a73c90] [c000000000377c70] sysfs_kf_write+0x60/0xa0
> > [c0000007e4a73cb0] [c0000000003769fc] kernfs_fop_write+0x16c/0x240
> > [c0000007e4a73d00] [c0000000002d1b0c] __vfs_write+0x3c/0x1b0
> > [c0000007e4a73d90] [c0000000002d34dc] vfs_write+0xcc/0x230
> > [c0000007e4a73de0] [c0000000002d50e0] SyS_write+0x60/0x110
> > [c0000007e4a73e30] [c00000000000b760] system_call+0x38/0xfc
> >=20
> > Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> > ---
> >  mm/memory-failure.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >=20
> > diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> > index 27f7210e7fab..22bd22eb25cb 100644
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -529,6 +529,9 @@ static const char * const action_page_types[] =3D {
> >   */
> >  static int delete_from_lru_cache(struct page *p)
> >  {
> > +	if (memcg_kmem_enabled())
> > +		memcg_kmem_uncharge(p, 0);
> > +
>=20
> The changelog is not quite clear, so we are uncharging a page using
> memcg_kmem_uncharge for a page in swap cache/page cache?

Hi Balbir,

Yes, in the normal page lifecycle, uncharge is done in page free time.
But in memory error handling case, in-use pages (i.e. swap cache and page
cache) are removed from normal path and they don't pass page freeing code.
So I think that this change is to keep the consistent charging for such a c=
ase.

- Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

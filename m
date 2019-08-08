Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A526C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 13:01:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF0F62171F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 13:01:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF0F62171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E3016B0003; Thu,  8 Aug 2019 09:01:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 996206B0006; Thu,  8 Aug 2019 09:01:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 882AC6B0007; Thu,  8 Aug 2019 09:01:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 696806B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 09:01:12 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x7so85431489qtp.15
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 06:01:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=fnV0oCdYhAplPkUz9SWv6iMclTvrFuZOzdoojjboE3I=;
        b=kxV2uoTnYBS2FdiMyraAud6wzwl8MaZVjeTccF2LqHoX1l7fe4aN4E9u8FvV7f3py9
         2L5FTyn3lQIjfOwi81RnvYFDglQLcslwylBQ1fvL4NrjArP2RG/6mW1435fcdwkwwN/8
         fuHR6WPQ1iI4IGd418/BNY7i2RwbgbS/nx5+HYghI2aJRDEXFc5j5Ev7t9PRJVCxDIUK
         kxR/WAgIkr4SiXAIz745gxe6J0vsdLFM+OhIHSQ9rqivbxAy5PdohEhbG+hFrmPc1JDP
         qNtUdtw/FyrAB0ZysEls+3HQlCnLgcjRFJOA8gH3cHLr7zOoZBanW6SlYhPOSrzZxQYc
         Mzrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWTDmkCAK6+Dw3LyJ/PryVfoK//ZN7AST+gT9Xtl+MyjFS/gnhd
	kptWJYvrCNrtu3iyYB4yEwwAH0xbT9LOT1saIf1yfNf+7EKe52Mv0yqBud4lr4Wuw23xpBPEC14
	eEIsk6xf6BOiwPe3iAq50St4w8WijTBkuhohNPxKrin9k/LodY3SSkEk9LCXrxZlp3w==
X-Received: by 2002:a05:620a:1467:: with SMTP id j7mr8582515qkl.445.1565269272164;
        Thu, 08 Aug 2019 06:01:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmoV8gebPx/Unccn4T8FLGytmRsmxfvMlaRPFGyaENAXu4EomsJPhBWASEbT5IXnk2mzzd
X-Received: by 2002:a05:620a:1467:: with SMTP id j7mr8582452qkl.445.1565269271386;
        Thu, 08 Aug 2019 06:01:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565269271; cv=none;
        d=google.com; s=arc-20160816;
        b=YoMkoMMwcs/Fdy5q0qbgiJoTAjanVi2HMOl0XS1YtQIiPSQjf/+kshT6d0GiHE4wLD
         nc4jSfhFB6fwJWWU6tpL3QzZu2+Kf8pExhltEJM/aSfhola0qrJfCx78+g5jilBcecq6
         GaXR+21c/dWk0drwSUrHwoH+JRecc5iAHru5wY/uVHgtkNJ/wEF4qnDXAl5BqxKcp2X/
         3k+c3I8hnnRxsK7X1nR0V6KUfgKEQ7nN9VgtQfEjKn5qa3CQaF9YyP3jEllYuZTzwQc0
         TCA+566/0Jf40RAsOcJA81MRuCH+k/S5TEbJz90G6LKTM4Z1IC94B0At60L03lxOkV+U
         zk2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=fnV0oCdYhAplPkUz9SWv6iMclTvrFuZOzdoojjboE3I=;
        b=UO9XKTbBcwNas/S+H4RPBTN3LQMYLNAN1m2Sg2kAJ21Rmq1PhteHw71uUVKg832LDY
         ngtFEtj4NPOLZf+POCtdRbYOXgms9vKj5N4OWCYU8TH4CdiqP0F8FQjxpRjyzYiosgVx
         F4TinRhBU4ZXaPBsupmF6iLLeUaT3ZwSC7fUHHNLTMGl41YVBsxnr+RNgzcbyxQMcTxr
         AZc6gAG7qFxQBWDZiPDfCzoLW8VHoaSYJP9NwgIQ3y0lAdCPgW4q7e27e2xTxcNXM0Ee
         qO0vHXSbW2ZXgjeC7LyjvXEYWFf+77olzpyJHGTxaPQg+MGFXDWQB92RFV/W+TfNxeBX
         3sdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x47si57433545qtk.204.2019.08.08.06.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 06:01:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 73550315C00C;
	Thu,  8 Aug 2019 13:01:10 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5E6E9600C8;
	Thu,  8 Aug 2019 13:01:10 +0000 (UTC)
Received: from zmail21.collab.prod.int.phx2.redhat.com (zmail21.collab.prod.int.phx2.redhat.com [10.5.83.24])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id 4800124F2F;
	Thu,  8 Aug 2019 13:01:10 +0000 (UTC)
Date: Thu, 8 Aug 2019 09:01:09 -0400 (EDT)
From: Jason Wang <jasowang@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org, 
	linux-kernel@vger.kernel.org, 
	virtualization@lists.linux-foundation.org, linux-mm@kvack.org
Message-ID: <1514137898.7430705.1565269269504.JavaMail.zimbra@redhat.com>
In-Reply-To: <1000f8a3-19a9-0383-61e5-ba08ddc9fcba@redhat.com>
References: <20190807070617.23716-1-jasowang@redhat.com> <20190807070617.23716-8-jasowang@redhat.com> <20190807120738.GB1557@ziepe.ca> <ba5f375f-435a-91fd-7fca-bfab0915594b@redhat.com> <1000f8a3-19a9-0383-61e5-ba08ddc9fcba@redhat.com>
Subject: Re: [PATCH V4 7/9] vhost: do not use RCU to synchronize MMU
 notifier	with worker
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Originating-IP: [10.68.5.20, 10.4.195.1]
Thread-Topic: vhost: do not use RCU to synchronize MMU notifier with worker
Thread-Index: 8bG8pspTquXH/UvMW3K+XUgVgEyz4A==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 08 Aug 2019 13:01:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



----- Original Message -----
>=20
> On 2019/8/7 =E4=B8=8B=E5=8D=8810:02, Jason Wang wrote:
> >
> > On 2019/8/7 =E4=B8=8B=E5=8D=888:07, Jason Gunthorpe wrote:
> >> On Wed, Aug 07, 2019 at 03:06:15AM -0400, Jason Wang wrote:
> >>> We used to use RCU to synchronize MMU notifier with worker. This lead=
s
> >>> calling synchronize_rcu() in invalidate_range_start(). But on a busy
> >>> system, there would be many factors that may slow down the
> >>> synchronize_rcu() which makes it unsuitable to be called in MMU
> >>> notifier.
> >>>
> >>> So this patch switches use seqlock counter to track whether or not th=
e
> >>> map was used. The counter was increased when vq try to start or finis=
h
> >>> uses the map. This means, when it was even, we're sure there's no
> >>> readers and MMU notifier is synchronized. When it was odd, it means
> >>> there's a reader we need to wait it to be even again then we are
> >>> synchronized. Consider the read critical section is pretty small the
> >>> synchronization should be done very fast.
> >>>
> >>> Reported-by: Michael S. Tsirkin <mst@redhat.com>
> >>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel
> >>> virtual address")
> >>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> >>> =C2=A0 drivers/vhost/vhost.c | 141
> >>> ++++++++++++++++++++++++++----------------
> >>> =C2=A0 drivers/vhost/vhost.h |=C2=A0=C2=A0 7 ++-
> >>> =C2=A0 2 files changed, 90 insertions(+), 58 deletions(-)
> >>>
> >>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> >>> index cfc11f9ed9c9..57bfbb60d960 100644
> >>> +++ b/drivers/vhost/vhost.c
> >>> @@ -324,17 +324,16 @@ static void vhost_uninit_vq_maps(struct
> >>> vhost_virtqueue *vq)
> >>> =C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 spin_lock(&vq->mmu_lock);
> >>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for (i =3D 0; i < VHOST_NUM_ADDRS; i++=
) {
> >>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 map[i] =3D rcu_dereferenc=
e_protected(vq->maps[i],
> >>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 lockdep_is_held(&vq->mmu_lock));
> >>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 map[i] =3D vq->maps[i];
> >>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (map[i]) {
> >>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 vhost_set_map_dirty(vq, map[i], i);
> >>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 r=
cu_assign_pointer(vq->maps[i], NULL);
> >>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 v=
q->maps[i] =3D NULL;
> >>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
> >>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
> >>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 spin_unlock(&vq->mmu_lock);
> >>> =C2=A0 -=C2=A0=C2=A0=C2=A0 /* No need for synchronize_rcu() or kfree_=
rcu() since we are
> >>> -=C2=A0=C2=A0=C2=A0=C2=A0 * serialized with memory accessors (e.g vq =
mutex held).
> >>> +=C2=A0=C2=A0=C2=A0 /* No need for synchronization since we are seria=
lized with
> >>> +=C2=A0=C2=A0=C2=A0=C2=A0 * memory accessors (e.g vq mutex held).
> >>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 */
> >>> =C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for (i =3D 0; i < VHOST_NUM_ADD=
RS; i++)
> >>> @@ -362,6 +361,40 @@ static bool vhost_map_range_overlap(struct
> >>> vhost_uaddr *uaddr,
> >>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return !(end < uaddr->uaddr || start >=
 uaddr->uaddr - 1 +
> >>> uaddr->size);
> >>> =C2=A0 }
> >>> =C2=A0 +static void inline vhost_vq_access_map_begin(struct
> >>> vhost_virtqueue *vq)
> >>> +{
> >>> +=C2=A0=C2=A0=C2=A0 write_seqcount_begin(&vq->seq);
> >>> +}
> >>> +
> >>> +static void inline vhost_vq_access_map_end(struct vhost_virtqueue *v=
q)
> >>> +{
> >>> +=C2=A0=C2=A0=C2=A0 write_seqcount_end(&vq->seq);
> >>> +}
> >> The write side of a seqlock only provides write barriers. Access to
> >>
> >> =C2=A0=C2=A0=C2=A0=C2=A0map =3D vq->maps[VHOST_ADDR_USED];
> >>
> >> Still needs a read side barrier, and then I think this will be no
> >> better than a normal spinlock.
> >>
> >> It also doesn't seem like this algorithm even needs a seqlock, as this
> >> is just a one bit flag
> >
> >
> > Right, so then I tend to use spinlock first for correctness.
> >
> >
> >>
> >> atomic_set_bit(using map)
> >> smp_mb__after_atomic()
> >> .. maps [...]
> >> atomic_clear_bit(using map)
> >>
> >>
> >> map =3D NULL;
> >> smp_mb__before_atomic();
> >> while (atomic_read_bit(using map))
> >> =C2=A0=C2=A0=C2=A0 relax()
> >>
> >> Again, not clear this could be faster than a spinlock when the
> >> barriers are correct...
> >
>=20
> I've done some benchmark[1] on x86, and yes it looks even slower. It
> looks to me the atomic stuffs is not necessary, so in order to compare
> it better with spinlock. I tweak it a little bit through
> smp_load_acquire()/store_releaes() + mb() like:
>=20

Sorry the format is messed up:

The code should be something like:

static struct vhost_map *vhost_vq_access_map_begin(struct vhost_virtqueue *=
vq,
                                                   unsigned int type)
{
        ++vq->counter;
        /* Ensure map was read after incresing the counter. Paired
         * with smp_mb() in vhost_vq_sync_access().
         */
        smp_mb();
        return vq->maps[type];
}

static void inline vhost_vq_access_map_end(struct vhost_virtqueue *vq)
{
 =09/* Ensure all memory access through map was done before
         * reducing the counter. Paired with smp_load_acquire() in
         * vhost_vq_sync_access() */
        smp_store_release(&vq->counter, --vq->counter);
}

static void inline vhost_vq_sync_access(struct vhost_virtqueue *vq)
{
        /* Ensure new map value is visible before checking counter. */
        smp_mb();
        /* Ensure map was freed after reading counter value, paired
         * with smp_store_release() in vhost_vq_access_map_end().
         */
        while (smp_load_acquire(&vq->counter)) {
                if (need_resched())
                        schedule();
        }
}

And the benchmark result is:

         | base    | direct + atomic bitops | direct + spinlock() | direct =
+ counter + smp_mb() | direct + RCU     |
SMAP on  | 5.0Mpps | 5.0Mpps     (+0%)      | 5.7Mpps  =09(+14%)=09  | 5.9M=
pps  (+18%)=09        | 6.2Mpps  (+24%)  |
SMAP off | 7.0Mpps | 7.0Mpps     (+0%)      | 7.0Mpps   (+0%)     | 7.5Mpps=
  (+7%)=09        | 8.2Mpps  (+17%)  |


>=20
>=20
> base: normal copy_to_user()/copy_from_user() path.
> direct + atomic bitops: using direct mapping but synchronize through
> atomic bitops like you suggested above
> direct + spinlock(): using direct mapping but synchronize through spinloc=
ks
> direct + counter + smp_mb(): using direct mapping but synchronize
> through counter + smp_mb()
> direct + RCU: using direct mapping and synchronize through RCU (buggy
> and need to be addressed by this series)
>=20
>=20
> So smp_mb() + counter is fastest way. And spinlock can still show some
> improvement (+14%) in the case of SMAP, but no the case when SMAP is off.
>=20
> I don't have any objection to convert=C2=A0 to spinlock() but just want t=
o
> know if any case that the above smp_mb() + counter looks good to you?
>=20
> Thanks
>=20
>=20
> >
> > Yes, for next release we may want to use the idea from Michael like to
> > mitigate the impact of mb.
> >
> > https://lwn.net/Articles/775871/
> >
> > Thanks
> >
> >
> >>
> >> Jason
>=20
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization


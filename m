Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A43DC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:06:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B25720838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:06:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B25720838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5F7B8E0006; Thu,  1 Aug 2019 04:06:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0EBC8E0001; Thu,  1 Aug 2019 04:06:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD6BF8E0006; Thu,  1 Aug 2019 04:06:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 880668E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 04:06:17 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id o11so55352942qtq.10
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 01:06:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=DvO2Eb8H5BTiue/eDJeWbhfED2Iuf++zTwICzlfJpuU=;
        b=F0LB8KBkq9tfFVs4eOMkAhPmVjittPV7IRfHl457UQI+JwsyTymefD1XRB9y3zZO3C
         oGDamRz2IhQoQ2QGjdfoXTjHcNWTsTG97rxf9HmVx1L3XvOkvEWgEHyU3PvOH/dweoVe
         M/q3SB9AlDIM086nBpxYY+vHM2+A5EX+5NR26CDsHKjMd3NyxZc9i6ooG4v+IXawrKhx
         a9o0+f8Bq16EODkLXZp9aTiJ/weJEdxs+qbs9KMpmOK4WUVRb3n3UOUhxjcbzm2icGwr
         67Ph6vUB4xbHZgVjMVA0a09ai45jf/mzCId3o9+S7WP9lCbStdHqpnalCf8Di50PoXsS
         FEmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUcwNzHjpz6xApZXpTMnIJorJRyaJMNp7e2khuXKkKLAr69u4SN
	i3oOqo/iUFcNSzr2Vbs+Ws3W42o7nDzQiPvIrrnXkTRhdztcz7zIpzJQ74EQKGzE5f2Hzd4zcZ6
	r61AepNrI0vlA3oWRbkZry9oyjXUohymenKBwQxI7HQSQsMlZBNH3kmgev6r25AQLmA==
X-Received: by 2002:a37:7cf:: with SMTP id 198mr85189586qkh.450.1564646777260;
        Thu, 01 Aug 2019 01:06:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzkza2+KTkQ9KvSZIV5OXrzOL0omAKhhmPwO8fG3vgoZAS89EX3K5Du+Gc1RMfBvUz8lJK
X-Received: by 2002:a37:7cf:: with SMTP id 198mr85189502qkh.450.1564646775830;
        Thu, 01 Aug 2019 01:06:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564646775; cv=none;
        d=google.com; s=arc-20160816;
        b=vSW2/USexi//YFQpc89kDVzhlb1XyWuZQ3DWHN8hturN9opW/Vf5waJHuvVIIj1ttC
         x0UbmzdGPZheNI0D4GwRL3hgmVB8qPrtZohBbs8uWQ9uLuV+OrKpVlgllxpZaLSFwgiT
         I1I0NSW83B1EeqVNW+3qDWPqSJ8p/Le5bhbfiJ+f5hxZCVM7Vrtc411so+rjlmaS7pIv
         NkkEFFPQ4WbHCtaHP7jEB04J6twebwEQmo0oeZZXAYHeAgup41JYJ+827Yr2q8SJ905S
         U7L6puY3ZE00A9PTKAUdeOaPeZ09Tf8wGq8QMbQSJS5dNBtB984xpryO2iFnRX2OjzNZ
         Vr8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=DvO2Eb8H5BTiue/eDJeWbhfED2Iuf++zTwICzlfJpuU=;
        b=y6nXtNnHFf5Qu8M6fgeP6n7ym6FKEjkt3OemJORf6JzzZXRQ/SxIeZ7gAaPwBJRDA1
         2Wu1IcScDoWdcfHxPgIY3HqevrvLo2j+f1+eVKWNja8QRxYhWeehLnxzJVZxSDjHeVoR
         iSyQTwZPpwvBBoaLGS4yZfrNen0gJ+gI8NqVrb4Qt7lsCd0VBJkaFoAHHs8FuEMyjzHo
         UOc+UrjPCxOZN7tk8VAixhy3TNModtbPW1lfGrHtWdbex/SRBxVx4Ex9IidNtZjBikpE
         IQ91irINiFYoPY/9vW0S7c9bOeI6wH2eNLs3GLn3kgwxr3SSKxmnF6Ywc0KtBj9up+2O
         2+ow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c80si40296875qke.221.2019.08.01.01.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 01:06:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DD28D4627A;
	Thu,  1 Aug 2019 08:06:14 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CD7AC60BE0;
	Thu,  1 Aug 2019 08:06:14 +0000 (UTC)
Received: from zmail21.collab.prod.int.phx2.redhat.com (zmail21.collab.prod.int.phx2.redhat.com [10.5.83.24])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id AA76541F40;
	Thu,  1 Aug 2019 08:06:14 +0000 (UTC)
Date: Thu, 1 Aug 2019 04:06:13 -0400 (EDT)
From: Jason Wang <jasowang@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org, 
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, jgg@ziepe.ca, 
	"Paul E. McKenney" <paulmck@linux.ibm.com>
Message-ID: <130386548.6222676.1564646773879.JavaMail.zimbra@redhat.com>
In-Reply-To: <20190731132438-mutt-send-email-mst@kernel.org>
References: <20190731084655.7024-1-jasowang@redhat.com> <20190731084655.7024-8-jasowang@redhat.com> <20190731132438-mutt-send-email-mst@kernel.org>
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU
 notifier with worker
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Originating-IP: [10.68.5.20, 10.4.195.18]
Thread-Topic: vhost: do not use RCU to synchronize MMU notifier with worker
Thread-Index: JuCf0A1UiJx/OyE0t9VYmt7ftZGITg==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 01 Aug 2019 08:06:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/8/1 =E4=B8=8A=E5=8D=882:29, Michael S. Tsirkin wrote:
> On Wed, Jul 31, 2019 at 04:46:53AM -0400, Jason Wang wrote:
>> We used to use RCU to synchronize MMU notifier with worker. This leads
>> calling synchronize_rcu() in invalidate_range_start(). But on a busy
>> system, there would be many factors that may slow down the
>> synchronize_rcu() which makes it unsuitable to be called in MMU
>> notifier.
>>
>> A solution is SRCU but its overhead is obvious with the expensive full
>> memory barrier. Another choice is to use seqlock, but it doesn't
>> provide a synchronization method between readers and writers. The last
>> choice is to use vq mutex, but it need to deal with the worst case
>> that MMU notifier must be blocked and wait for the finish of swap in.
>>
>> So this patch switches use a counter to track whether or not the map
>> was used. The counter was increased when vq try to start or finish
>> uses the map. This means, when it was even, we're sure there's no
>> readers and MMU notifier is synchronized. When it was odd, it means
>> there's a reader we need to wait it to be even again then we are
>> synchronized. To avoid full memory barrier, store_release +
>> load_acquire on the counter is used.
>
> Unfortunately this needs a lot of review and testing, so this can't make
> rc2, and I don't think this is the kind of patch I can merge after rc3.
> Subtle memory barrier tricks like this can introduce new bugs while they
> are fixing old ones.

I admit the patch is tricky. Some questions:

- Do we must address the case of e.g swap in? If not, a simple
  vhost_work_flush() instead of synchronize_rcu() may work.
- Having some hard thought, I think we can use seqlock, it looks
  to me smp_wmb() is in write_segcount_begin() is sufficient, we don't
  care vq->map read before smp_wmb(), and for the other we all have
  good data devendency so smp_wmb() in the write_seqbegin_end() is
  sufficient.

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index db2c81cb1e90..6d9501303258 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -363,39 +363,29 @@ static bool vhost_map_range_overlap(struct vhost_uadd=
r *uaddr,
=20
 static void inline vhost_vq_access_map_begin(struct vhost_virtqueue *vq)
 {
-=09int ref =3D READ_ONCE(vq->ref);
-
-=09smp_store_release(&vq->ref, ref + 1);
-=09/* Make sure ref counter is visible before accessing the map */
-=09smp_load_acquire(&vq->ref);
+=09write_seqcount_begin(&vq->seq);
 }
=20
 static void inline vhost_vq_access_map_end(struct vhost_virtqueue *vq)
 {
-=09int ref =3D READ_ONCE(vq->ref);
-
-=09/* Make sure vq access is done before increasing ref counter */
-=09smp_store_release(&vq->ref, ref + 1);
+=09write_seqcount_end(&vq->seq);
 }
=20
 static void inline vhost_vq_sync_access(struct vhost_virtqueue *vq)
 {
-=09int ref;
+=09unsigned int ret;
=20
 =09/* Make sure map change was done before checking ref counter */
 =09smp_mb();
-
-=09ref =3D READ_ONCE(vq->ref);
-=09if (ref & 0x1) {
-=09=09/* When ref change, we are sure no reader can see
+=09ret =3D raw_read_seqcount(&vq->seq);
+=09if (ret & 0x1) {
+=09=09/* When seq changes, we are sure no reader can see
 =09=09 * previous map */
-=09=09while (READ_ONCE(vq->ref) =3D=3D ref) {
-=09=09=09set_current_state(TASK_RUNNING);
+=09=09while (raw_read_seqcount(&vq->seq) =3D=3D ret)
 =09=09=09schedule();
-=09=09}
 =09}
-=09/* Make sure ref counter was checked before any other
-=09 * operations that was dene on map. */
+=09/* Make sure seq was checked before any other operations that
+=09 * was dene on map. */
 =09smp_mb();
 }
=20
@@ -691,7 +681,7 @@ void vhost_dev_init(struct vhost_dev *dev,
 =09=09vq->indirect =3D NULL;
 =09=09vq->heads =3D NULL;
 =09=09vq->dev =3D dev;
-=09=09vq->ref =3D 0;
+=09=09seqcount_init(&vq->seq);
 =09=09mutex_init(&vq->mutex);
 =09=09spin_lock_init(&vq->mmu_lock);
 =09=09vhost_vq_reset(dev, vq);
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 3d10da0ae511..1a705e181a84 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -125,7 +125,7 @@ struct vhost_virtqueue {
 =09 */
 =09struct vhost_uaddr uaddrs[VHOST_NUM_ADDRS];
 #endif
-=09int ref;
+=09seqcount_t seq;
 =09const struct vhost_umem_node *meta_iotlb[VHOST_NUM_ADDRS];
=20
 =09struct file *kick;
--=20
2.18.1

>
>
>
>
>
>>
>> Consider the read critical section is pretty small the synchronization
>> should be done very fast.
>>
>> Note the patch lead about 3% PPS dropping.
>
> Sorry what do you mean by this last sentence? This degrades performance
> compared to what?

Compare to without this patch.

>
>>
>> Reported-by: Michael S. Tsirkin <mst@redhat.com>
>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual a=
ddress")
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  drivers/vhost/vhost.c | 145 ++++++++++++++++++++++++++----------------
>>  drivers/vhost/vhost.h |   7 +-
>>  2 files changed, 94 insertions(+), 58 deletions(-)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index cfc11f9ed9c9..db2c81cb1e90 100644
>> --- a/drivers/vhost/vhost.c
>> +++ b/drivers/vhost/vhost.c
>> @@ -324,17 +324,16 @@ static void vhost_uninit_vq_maps(struct vhost_virt=
queue *vq)
>> =20
>>  =09spin_lock(&vq->mmu_lock);
>>  =09for (i =3D 0; i < VHOST_NUM_ADDRS; i++) {
>> -=09=09map[i] =3D rcu_dereference_protected(vq->maps[i],
>> -=09=09=09=09  lockdep_is_held(&vq->mmu_lock));
>> +=09=09map[i] =3D vq->maps[i];
>>  =09=09if (map[i]) {
>>  =09=09=09vhost_set_map_dirty(vq, map[i], i);
>> -=09=09=09rcu_assign_pointer(vq->maps[i], NULL);
>> +=09=09=09vq->maps[i] =3D NULL;
>>  =09=09}
>>  =09}
>>  =09spin_unlock(&vq->mmu_lock);
>> =20
>> -=09/* No need for synchronize_rcu() or kfree_rcu() since we are
>> -=09 * serialized with memory accessors (e.g vq mutex held).
>> +=09/* No need for synchronization since we are serialized with
>> +=09 * memory accessors (e.g vq mutex held).
>>  =09 */
>> =20
>>  =09for (i =3D 0; i < VHOST_NUM_ADDRS; i++)
>> @@ -362,6 +361,44 @@ static bool vhost_map_range_overlap(struct vhost_ua=
ddr *uaddr,
>>  =09return !(end < uaddr->uaddr || start > uaddr->uaddr - 1 + uaddr->siz=
e);
>>  }
>> =20
>> +static void inline vhost_vq_access_map_begin(struct vhost_virtqueue *vq=
)
>> +{
>> +=09int ref =3D READ_ONCE(vq->ref);
>> +
>> +=09smp_store_release(&vq->ref, ref + 1);
>> +=09/* Make sure ref counter is visible before accessing the map */
>> +=09smp_load_acquire(&vq->ref);
>
> The map access is after this sequence, correct?

Yes.

>
> Just going by the rules in Documentation/memory-barriers.txt,
> I think that this pair will not order following accesses with ref store.
>
> Documentation/memory-barriers.txt says:
>
>
> +     In addition, a RELEASE+ACQUIRE
> +     pair is -not- guaranteed to act as a full memory barrier.
>
>
>
> The guarantee that is made is this:
> =09after
>      an ACQUIRE on a given variable, all memory accesses preceding any pr=
ior
>      RELEASE on that same variable are guaranteed to be visible.

Yes, but it's not clear about the order of ACQUIRE the same location
of previous RELEASE. And it only has a example like:

"
=09*A =3D a;
=09RELEASE M
=09ACQUIRE N
=09*B =3D b;

could occur as:

=09ACQUIRE N, STORE *B, STORE *A, RELEASE M
"

But it doesn't explain what happen when

*A =3D a
RELEASE M
ACQUIRE M
*B =3D b;

And tools/memory-model/Documentation said

"
First, when a lock-acquire reads from a lock-release, the LKMM
requires that every instruction po-before the lock-release must
execute before any instruction po-after the lock-acquire.
"

Is this a hint that I was correct?

>
>
> And if we also had the reverse rule we'd end up with a full barrier,
> won't we?
>
> Cc Paul in case I missed something here. And if I'm right,
> maybe we should call this out, adding
>
> =09"The opposite is not true: a prior RELEASE is not
> =09 guaranteed to be visible before memory accesses following
> =09 the subsequent ACQUIRE".

That kinds of violates the RELEASE?

"
     This also acts as a one-way permeable barrier.  It guarantees that all
     memory operations before the RELEASE operation will appear to happen
     before the RELEASE operation with respect to the other components of t=
he
"

>
>
>
>> +}
>> +
>> +static void inline vhost_vq_access_map_end(struct vhost_virtqueue *vq)
>> +{
>> +=09int ref =3D READ_ONCE(vq->ref);
>> +
>> +=09/* Make sure vq access is done before increasing ref counter */
>> +=09smp_store_release(&vq->ref, ref + 1);
>> +}
>> +
>> +static void inline vhost_vq_sync_access(struct vhost_virtqueue *vq)
>> +{
>> +=09int ref;
>> +
>> +=09/* Make sure map change was done before checking ref counter */
>> +=09smp_mb();
>> +
>> +=09ref =3D READ_ONCE(vq->ref);
>> +=09if (ref & 0x1) {
>
> Please document the even/odd trick here too, not just in the commit log.
>

Ok.

>> +=09=09/* When ref change,
>
> changes
>
>> we are sure no reader can see
>> +=09=09 * previous map */
>> +=09=09while (READ_ONCE(vq->ref) =3D=3D ref) {
>
>
> what is the below line in aid of?
>
>> +=09=09=09set_current_state(TASK_RUNNING);
>> +=09=09=09schedule();
>
>                         if (need_resched())
>                                 schedule();
>
> ?

Yes, better.

>
>> +=09=09}
>
> On an interruptible kernel, there's a risk here is that
> a task got preempted with an odd ref.
> So I suspect we'll have to disable preemption when we
> make ref odd.

I'm not sure I get, if the odd is not the original value we read,
we're sure it won't read the new map here I believe.

>
>
>> +=09}
>> +=09/* Make sure ref counter was checked before any other
>> +=09 * operations that was dene on map. */
>
> was dene -> were done?
>

Yes.

>> +=09smp_mb();
>> +}
>> +
>>  static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
>>  =09=09=09=09      int index,
>>  =09=09=09=09      unsigned long start,
>> @@ -376,16 +413,15 @@ static void vhost_invalidate_vq_start(struct vhost=
_virtqueue *vq,
>>  =09spin_lock(&vq->mmu_lock);
>>  =09++vq->invalidate_count;
>> =20
>> -=09map =3D rcu_dereference_protected(vq->maps[index],
>> -=09=09=09=09=09lockdep_is_held(&vq->mmu_lock));
>> +=09map =3D vq->maps[index];
>>  =09if (map) {
>>  =09=09vhost_set_map_dirty(vq, map, index);
>> -=09=09rcu_assign_pointer(vq->maps[index], NULL);
>> +=09=09vq->maps[index] =3D NULL;
>>  =09}
>>  =09spin_unlock(&vq->mmu_lock);
>> =20
>>  =09if (map) {
>> -=09=09synchronize_rcu();
>> +=09=09vhost_vq_sync_access(vq);
>>  =09=09vhost_map_unprefetch(map);
>>  =09}
>>  }
>> @@ -457,7 +493,7 @@ static void vhost_init_maps(struct vhost_dev *dev)
>>  =09for (i =3D 0; i < dev->nvqs; ++i) {
>>  =09=09vq =3D dev->vqs[i];
>>  =09=09for (j =3D 0; j < VHOST_NUM_ADDRS; j++)
>> -=09=09=09RCU_INIT_POINTER(vq->maps[j], NULL);
>> +=09=09=09vq->maps[j] =3D NULL;
>>  =09}
>>  }
>>  #endif
>> @@ -655,6 +691,7 @@ void vhost_dev_init(struct vhost_dev *dev,
>>  =09=09vq->indirect =3D NULL;
>>  =09=09vq->heads =3D NULL;
>>  =09=09vq->dev =3D dev;
>> +=09=09vq->ref =3D 0;
>>  =09=09mutex_init(&vq->mutex);
>>  =09=09spin_lock_init(&vq->mmu_lock);
>>  =09=09vhost_vq_reset(dev, vq);
>> @@ -921,7 +958,7 @@ static int vhost_map_prefetch(struct vhost_virtqueue=
 *vq,
>>  =09map->npages =3D npages;
>>  =09map->pages =3D pages;
>> =20
>> -=09rcu_assign_pointer(vq->maps[index], map);
>> +=09vq->maps[index] =3D map;
>>  =09/* No need for a synchronize_rcu(). This function should be
>>  =09 * called by dev->worker so we are serialized with all
>>  =09 * readers.
>> @@ -1216,18 +1253,18 @@ static inline int vhost_put_avail_event(struct v=
host_virtqueue *vq)
>>  =09struct vring_used *used;
>> =20
>>  =09if (!vq->iotlb) {
>> -=09=09rcu_read_lock();
>> +=09=09vhost_vq_access_map_begin(vq);
>> =20
>> -=09=09map =3D rcu_dereference(vq->maps[VHOST_ADDR_USED]);
>> +=09=09map =3D vq->maps[VHOST_ADDR_USED];
>>  =09=09if (likely(map)) {
>>  =09=09=09used =3D map->addr;
>>  =09=09=09*((__virtio16 *)&used->ring[vq->num]) =3D
>>  =09=09=09=09cpu_to_vhost16(vq, vq->avail_idx);
>> -=09=09=09rcu_read_unlock();
>> +=09=09=09vhost_vq_access_map_end(vq);
>>  =09=09=09return 0;
>>  =09=09}
>> =20
>> -=09=09rcu_read_unlock();
>> +=09=09vhost_vq_access_map_end(vq);
>>  =09}
>>  #endif
>> =20
>> @@ -1245,18 +1282,18 @@ static inline int vhost_put_used(struct vhost_vi=
rtqueue *vq,
>>  =09size_t size;
>> =20
>>  =09if (!vq->iotlb) {
>> -=09=09rcu_read_lock();
>> +=09=09vhost_vq_access_map_begin(vq);
>> =20
>> -=09=09map =3D rcu_dereference(vq->maps[VHOST_ADDR_USED]);
>> +=09=09map =3D vq->maps[VHOST_ADDR_USED];
>>  =09=09if (likely(map)) {
>>  =09=09=09used =3D map->addr;
>>  =09=09=09size =3D count * sizeof(*head);
>>  =09=09=09memcpy(used->ring + idx, head, size);
>> -=09=09=09rcu_read_unlock();
>> +=09=09=09vhost_vq_access_map_end(vq);
>>  =09=09=09return 0;
>>  =09=09}
>> =20
>> -=09=09rcu_read_unlock();
>> +=09=09vhost_vq_access_map_end(vq);
>>  =09}
>>  #endif
>> =20
>> @@ -1272,17 +1309,17 @@ static inline int vhost_put_used_flags(struct vh=
ost_virtqueue *vq)
>>  =09struct vring_used *used;
>> =20
>>  =09if (!vq->iotlb) {
>> -=09=09rcu_read_lock();
>> +=09=09vhost_vq_access_map_begin(vq);
>> =20
>> -=09=09map =3D rcu_dereference(vq->maps[VHOST_ADDR_USED]);
>> +=09=09map =3D vq->maps[VHOST_ADDR_USED];
>>  =09=09if (likely(map)) {
>>  =09=09=09used =3D map->addr;
>>  =09=09=09used->flags =3D cpu_to_vhost16(vq, vq->used_flags);
>> -=09=09=09rcu_read_unlock();
>> +=09=09=09vhost_vq_access_map_end(vq);
>>  =09=09=09return 0;
>>  =09=09}
>> =20
>> -=09=09rcu_read_unlock();
>> +=09=09vhost_vq_access_map_end(vq);
>>  =09}
>>  #endif
>> =20
>> @@ -1298,17 +1335,17 @@ static inline int vhost_put_used_idx(struct vhos=
t_virtqueue *vq)
>>  =09struct vring_used *used;
>> =20
>>  =09if (!vq->iotlb) {
>> -=09=09rcu_read_lock();
>> +=09=09vhost_vq_access_map_begin(vq);
>> =20
>> -=09=09map =3D rcu_dereference(vq->maps[VHOST_ADDR_USED]);
>> +=09=09map =3D vq->maps[VHOST_ADDR_USED];
>>  =09=09if (likely(map)) {
>>  =09=09=09used =3D map->addr;
>>  =09=09=09used->idx =3D cpu_to_vhost16(vq, vq->last_used_idx);
>> -=09=09=09rcu_read_unlock();
>> +=09=09=09vhost_vq_access_map_end(vq);
>>  =09=09=09return 0;
>>  =09=09}
>> =20
>> -=09=09rcu_read_unlock();
>> +=09=09vhost_vq_access_map_end(vq);
>>  =09}
>>  #endif
>> =20
>> @@ -1362,17 +1399,17 @@ static inline int vhost_get_avail_idx(struct vho=
st_virtqueue *vq,
>>  =09struct vring_avail *avail;
>> =20
>>  =09if (!vq->iotlb) {
>> -=09=09rcu_read_lock();
>> +=09=09vhost_vq_access_map_begin(vq);
>> =20
>> -=09=09map =3D rcu_dereference(vq->maps[VHOST_ADDR_AVAIL]);
>> +=09=09map =3D vq->maps[VHOST_ADDR_AVAIL];
>>  =09=09if (likely(map)) {
>>  =09=09=09avail =3D map->addr;
>>  =09=09=09*idx =3D avail->idx;
>> -=09=09=09rcu_read_unlock();
>> +=09=09=09vhost_vq_access_map_end(vq);
>>  =09=09=09return 0;
>>  =09=09}
>> =20
>> -=09=09rcu_read_unlock();
>> +=09=09vhost_vq_access_map_end(vq);
>>  =09}
>>  #endif
>> =20
>> @@ -1387,17 +1424,17 @@ static inline int vhost_get_avail_head(struct vh=
ost_virtqueue *vq,
>>  =09struct vring_avail *avail;
>> =20
>>  =09if (!vq->iotlb) {
>> -=09=09rcu_read_lock();
>> +=09=09vhost_vq_access_map_begin(vq);
>> =20
>> -=09=09map =3D rcu_dereference(vq->maps[VHOST_ADDR_AVAIL]);
>> +=09=09map =3D vq->maps[VHOST_ADDR_AVAIL];
>>  =09=09if (likely(map)) {
>>  =09=09=09avail =3D map->addr;
>>  =09=09=09*head =3D avail->ring[idx & (vq->num - 1)];
>> -=09=09=09rcu_read_unlock();
>> +=09=09=09vhost_vq_access_map_end(vq);
>>  =09=09=09return 0;
>>  =09=09}
>> =20
>> -=09=09rcu_read_unlock();
>> +=09=09vhost_vq_access_map_end(vq);
>>  =09}
>>  #endif
>> =20
>> @@ -1413,17 +1450,17 @@ static inline int vhost_get_avail_flags(struct v=
host_virtqueue *vq,
>>  =09struct vring_avail *avail;
>> =20
>>  =09if (!vq->iotlb) {
>> -=09=09rcu_read_lock();
>> +=09=09vhost_vq_access_map_begin(vq);
>> =20
>> -=09=09map =3D rcu_dereference(vq->maps[VHOST_ADDR_AVAIL]);
>> +=09=09map =3D vq->maps[VHOST_ADDR_AVAIL];
>>  =09=09if (likely(map)) {
>>  =09=09=09avail =3D map->addr;
>>  =09=09=09*flags =3D avail->flags;
>> -=09=09=09rcu_read_unlock();
>> +=09=09=09vhost_vq_access_map_end(vq);
>>  =09=09=09return 0;
>>  =09=09}
>> =20
>> -=09=09rcu_read_unlock();
>> +=09=09vhost_vq_access_map_end(vq);
>>  =09}
>>  #endif
>> =20
>> @@ -1438,15 +1475,15 @@ static inline int vhost_get_used_event(struct vh=
ost_virtqueue *vq,
>>  =09struct vring_avail *avail;
>> =20
>>  =09if (!vq->iotlb) {
>> -=09=09rcu_read_lock();
>> -=09=09map =3D rcu_dereference(vq->maps[VHOST_ADDR_AVAIL]);
>> +=09=09vhost_vq_access_map_begin(vq);
>> +=09=09map =3D vq->maps[VHOST_ADDR_AVAIL];
>>  =09=09if (likely(map)) {
>>  =09=09=09avail =3D map->addr;
>>  =09=09=09*event =3D (__virtio16)avail->ring[vq->num];
>> -=09=09=09rcu_read_unlock();
>> +=09=09=09vhost_vq_access_map_end(vq);
>>  =09=09=09return 0;
>>  =09=09}
>> -=09=09rcu_read_unlock();
>> +=09=09vhost_vq_access_map_end(vq);
>>  =09}
>>  #endif
>> =20
>> @@ -1461,17 +1498,17 @@ static inline int vhost_get_used_idx(struct vhos=
t_virtqueue *vq,
>>  =09struct vring_used *used;
>> =20
>>  =09if (!vq->iotlb) {
>> -=09=09rcu_read_lock();
>> +=09=09vhost_vq_access_map_begin(vq);
>> =20
>> -=09=09map =3D rcu_dereference(vq->maps[VHOST_ADDR_USED]);
>> +=09=09map =3D vq->maps[VHOST_ADDR_USED];
>>  =09=09if (likely(map)) {
>>  =09=09=09used =3D map->addr;
>>  =09=09=09*idx =3D used->idx;
>> -=09=09=09rcu_read_unlock();
>> +=09=09=09vhost_vq_access_map_end(vq);
>>  =09=09=09return 0;
>>  =09=09}
>> =20
>> -=09=09rcu_read_unlock();
>> +=09=09vhost_vq_access_map_end(vq);
>>  =09}
>>  #endif
>> =20
>> @@ -1486,17 +1523,17 @@ static inline int vhost_get_desc(struct vhost_vi=
rtqueue *vq,
>>  =09struct vring_desc *d;
>> =20
>>  =09if (!vq->iotlb) {
>> -=09=09rcu_read_lock();
>> +=09=09vhost_vq_access_map_begin(vq);
>> =20
>> -=09=09map =3D rcu_dereference(vq->maps[VHOST_ADDR_DESC]);
>> +=09=09map =3D vq->maps[VHOST_ADDR_DESC];
>>  =09=09if (likely(map)) {
>>  =09=09=09d =3D map->addr;
>>  =09=09=09*desc =3D *(d + idx);
>> -=09=09=09rcu_read_unlock();
>> +=09=09=09vhost_vq_access_map_end(vq);
>>  =09=09=09return 0;
>>  =09=09}
>> =20
>> -=09=09rcu_read_unlock();
>> +=09=09vhost_vq_access_map_end(vq);
>>  =09}
>>  #endif
>> =20
>> @@ -1843,13 +1880,11 @@ static bool iotlb_access_ok(struct vhost_virtque=
ue *vq,
>>  #if VHOST_ARCH_CAN_ACCEL_UACCESS
>>  static void vhost_vq_map_prefetch(struct vhost_virtqueue *vq)
>>  {
>> -=09struct vhost_map __rcu *map;
>> +=09struct vhost_map *map;
>>  =09int i;
>> =20
>>  =09for (i =3D 0; i < VHOST_NUM_ADDRS; i++) {
>> -=09=09rcu_read_lock();
>> -=09=09map =3D rcu_dereference(vq->maps[i]);
>> -=09=09rcu_read_unlock();
>> +=09=09map =3D vq->maps[i];
>>  =09=09if (unlikely(!map))
>>  =09=09=09vhost_map_prefetch(vq, i);
>>  =09}
>> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
>> index a9a2a93857d2..f9e9558a529d 100644
>> --- a/drivers/vhost/vhost.h
>> +++ b/drivers/vhost/vhost.h
>> @@ -115,16 +115,17 @@ struct vhost_virtqueue {
>>  #if VHOST_ARCH_CAN_ACCEL_UACCESS
>>  =09/* Read by memory accessors, modified by meta data
>>  =09 * prefetching, MMU notifier and vring ioctl().
>> -=09 * Synchonrized through mmu_lock (writers) and RCU (writers
>> -=09 * and readers).
>> +=09 * Synchonrized through mmu_lock (writers) and ref counters,
>> +=09 * see vhost_vq_access_map_begin()/vhost_vq_access_map_end().
>>  =09 */
>> -=09struct vhost_map __rcu *maps[VHOST_NUM_ADDRS];
>> +=09struct vhost_map *maps[VHOST_NUM_ADDRS];
>>  =09/* Read by MMU notifier, modified by vring ioctl(),
>>  =09 * synchronized through MMU notifier
>>  =09 * registering/unregistering.
>>  =09 */
>>  =09struct vhost_uaddr uaddrs[VHOST_NUM_ADDRS];
>>  #endif
>> +=09int ref;
>
> Is it important that this is signed? If not I'd do unsigned here:
> even though kernel does compile with 2s complement sign overflow,
> it seems cleaner not to depend on that.

Not a must, let me fix.

Thanks

>
>>  =09const struct vhost_umem_node *meta_iotlb[VHOST_NUM_ADDRS];
>> =20
>>  =09struct file *kick;
>> --=20
>> 2.18.1


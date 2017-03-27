Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0ACF96B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 10:11:09 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k188so67085061itd.11
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 07:11:09 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0055.outbound.protection.outlook.com. [104.47.38.55])
        by mx.google.com with ESMTPS id i5si770957iob.41.2017.03.27.07.11.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 27 Mar 2017 07:11:08 -0700 (PDT)
Subject: Re: [PATCH] mm: Remove pointless might_sleep() in remove_vm_area().
References: <1490352808-7187-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <59149d48-2a8e-d7c0-8009-1d0b3ea8290b@virtuozzo.com>
 <201703242140.CHJ64587.LFSFQOJOOMtFHV@I-love.SAKURA.ne.jp>
 <fe511b26-f2e5-0a0e-09cc-303d38d2ad05@virtuozzo.com>
 <20170324161732.GA23110@bombadil.infradead.org>
 <0eceef23-a20c-bca7-2153-b9b5baf1f1d8@virtuozzo.com>
From: Thomas Hellstrom <thellstrom@vmware.com>
Message-ID: <f1c0b9ec-c0c8-502c-c7f0-fe692c73ab04@vmware.com>
Date: Mon, 27 Mar 2017 16:10:45 +0200
MIME-Version: 1.0
In-Reply-To: <0eceef23-a20c-bca7-2153-b9b5baf1f1d8@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Matthew Wilcox <willy@infradead.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, hch@lst.de, jszhang@marvell.com, joelaf@google.com, chris@chris-wilson.co.uk, joaodias@google.com, tglx@linutronix.de, hpa@zytor.com, mingo@elte.hu, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>

On 03/27/2017 03:26 PM, Andrey Ryabinin wrote:
> [+CC drm folks, see the following threads:
> 	https://urldefense.proofpoint.com/v2/url?u=3Dhttp-3A__lkml.kernel.org_=
r_201703232349.BGB95898.QHLVFFOMtFOOJS-40I-2Dlove.SAKURA.ne.jp&d=3DDwIC-g=
&c=3DuilaK90D4TOVoH58JNXRgQ&r=3DwnSlgOCqfpNS4d02vP68_E9q2BNMCwfD2OZ_6dCFV=
QQ&m=3DiraTSVk5qLTsuZU7WSBk97YAYoGmC7W5zjR2wwDRVVk&s=3DbX-RtB9qE168yR2AjM=
RvRvln1Pn6r8fmNUDQydGWIdk&e=3D=20
> 	https://urldefense.proofpoint.com/v2/url?u=3Dhttp-3A__lkml.kernel.org_=
r_1490352808-2D7187-2D1-2Dgit-2Dsend-2Demail-2Dpenguin-2Dkernel-40I-2Dlov=
e.SAKURA.ne.jp&d=3DDwIC-g&c=3DuilaK90D4TOVoH58JNXRgQ&r=3DwnSlgOCqfpNS4d02=
vP68_E9q2BNMCwfD2OZ_6dCFVQQ&m=3DiraTSVk5qLTsuZU7WSBk97YAYoGmC7W5zjR2wwDRV=
Vk&s=3Djw45iN1ypIQrzl08wkan3QZkuU6Gu0riU4_PvZD8KXQ&e=3D=20
> ]
>
> On 03/24/2017 07:17 PM, Matthew Wilcox wrote:
>> On Fri, Mar 24, 2017 at 06:05:45PM +0300, Andrey Ryabinin wrote:
>>> Just fix the drm code. There is zero point in releasing memory under =
spinlock.
>> I disagree.  The spinlock has to be held while deleting from the hash
>> table.=20
> And what makes you think so?
>
> There are too places where spinlock held during drm_ht_remove();
>
> 1) The first one is an obvious crap in ttm_object_device_release():
>
> void ttm_object_device_release(struct ttm_object_device **p_tdev)
> {
> 	struct ttm_object_device *tdev =3D *p_tdev;
>
> 	*p_tdev =3D NULL;
>
> 	spin_lock(&tdev->object_lock);
> 	drm_ht_remove(&tdev->object_hash);
> 	spin_unlock(&tdev->object_lock);
>
> 	kfree(tdev);
> }
>
> Obviously this spin_lock has no use here and it can be removed. There s=
hould
> be no concurrent access to tdev at this point, because that would mean =
immediate
> use-afte-free.
>
> 2) The second case is in ttm_object_file_release() calls drm_ht_remove(=
) under tfile->lock
> And drm_ht_remove() does:
> void drm_ht_remove(struct drm_open_hash *ht)
> {
> 	if (ht->table) {
> 		kvfree(ht->table);
> 		ht->table =3D NULL;
> 	}
> }
>
> Let's assume that we have some other code accessing ht->table and racin=
g
> against ttm_object_file_release()->drm_ht_remove().
> This would mean that such code must do the following:
>   a) take spin_lock(&tfile->lock)
>   b) check ht->table for being non-NULL and only after that it can dere=
ference ht->table.
>
> But I don't see any code checking ht->table for NULL. So if race agains=
t drm_ht_remove()
> is possible, this code is already broken and this spin_lock doesn't sav=
e us from NULL-ptr
> deref.
>
> So, either we already protected from such scenarios (e.g. we are the on=
ly owners of tdev/tfile in
> ttm_object_device_release()/ttm_object_file_release()) or this code is =
already terribly
> broken. Anyways we can just move drm_ht_remove() out of spin_lock()/spi=
n_unlock() section.
>
> Did I miss anything?=20
>
>
>> Sure, we could change the API to return the object removed, and
>> then force the caller to free the object that was removed from the has=
h
>> table outside the lock it's holding, but that's a really inelegant API=
=2E
>>
> This won't be required if I'm right.
>
Actually, I've already sent out a patch for internal review to remove
the spinlocks around drm_ht_free().
They are both in destructors so it should be harmless in this particular
case. The reason the locks are there is to avoid upsetting static code
analyzers that think the hash table pointer should be protected because
it is elsewhere in the code.

However, while it is common that acquiring a resource (in this case
vmalloc space) might sleep,  Sleeping while releasing it ishould, IMO in
general be avoided if at all possible. It's quite common to take a lock
around kref_put() and if the destructor needs to sleep that requires
unlocking in it, leading to bad looking code that upsets static
analyzers and requires extra locking cycles.

In addition, if the vfree sleeping is triggered by waiting for a thread
currently blocked by, for example a memory allocation, which is blocked
by the kernel running shrinkers, which call vfree() then we're in a
deadlock situation.

So to summarize. Yes, the drm callers can be fixed up, but IMO requiring
vfree() to be non-atomic is IMO not a good idea if avoidable.

Thanks,

Thomas



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

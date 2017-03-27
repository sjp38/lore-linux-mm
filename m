Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 766EE6B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 09:24:45 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c67so30943645itg.23
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 06:24:45 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0091.outbound.protection.outlook.com. [104.47.1.91])
        by mx.google.com with ESMTPS id h68si594875itg.119.2017.03.27.06.24.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 27 Mar 2017 06:24:44 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: Re: [PATCH] mm: Remove pointless might_sleep() in remove_vm_area().
References: <1490352808-7187-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <59149d48-2a8e-d7c0-8009-1d0b3ea8290b@virtuozzo.com>
 <201703242140.CHJ64587.LFSFQOJOOMtFHV@I-love.SAKURA.ne.jp>
 <fe511b26-f2e5-0a0e-09cc-303d38d2ad05@virtuozzo.com>
 <20170324161732.GA23110@bombadil.infradead.org>
Message-ID: <0eceef23-a20c-bca7-2153-b9b5baf1f1d8@virtuozzo.com>
Date: Mon, 27 Mar 2017 16:26:02 +0300
MIME-Version: 1.0
In-Reply-To: <20170324161732.GA23110@bombadil.infradead.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, hch@lst.de, jszhang@marvell.com, joelaf@google.com, chris@chris-wilson.co.uk, joaodias@google.com, tglx@linutronix.de, hpa@zytor.com, mingo@elte.hu, Thomas Hellstrom <thellstrom@vmware.com>, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>

[+CC drm folks, see the following threads:
	http://lkml.kernel.org/r/201703232349.BGB95898.QHLVFFOMtFOOJS@I-love.SAKURA.ne.jp
	http://lkml.kernel.org/r/1490352808-7187-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
]

On 03/24/2017 07:17 PM, Matthew Wilcox wrote:
> On Fri, Mar 24, 2017 at 06:05:45PM +0300, Andrey Ryabinin wrote:
>> Just fix the drm code. There is zero point in releasing memory under spinlock.
> 
> I disagree.  The spinlock has to be held while deleting from the hash
> table. 

And what makes you think so?

There are too places where spinlock held during drm_ht_remove();

1) The first one is an obvious crap in ttm_object_device_release():

void ttm_object_device_release(struct ttm_object_device **p_tdev)
{
	struct ttm_object_device *tdev = *p_tdev;

	*p_tdev = NULL;

	spin_lock(&tdev->object_lock);
	drm_ht_remove(&tdev->object_hash);
	spin_unlock(&tdev->object_lock);

	kfree(tdev);
}

Obviously this spin_lock has no use here and it can be removed. There should
be no concurrent access to tdev at this point, because that would mean immediate
use-afte-free.

2) The second case is in ttm_object_file_release() calls drm_ht_remove() under tfile->lock
And drm_ht_remove() does:
void drm_ht_remove(struct drm_open_hash *ht)
{
	if (ht->table) {
		kvfree(ht->table);
		ht->table = NULL;
	}
}

Let's assume that we have some other code accessing ht->table and racing
against ttm_object_file_release()->drm_ht_remove().
This would mean that such code must do the following:
  a) take spin_lock(&tfile->lock)
  b) check ht->table for being non-NULL and only after that it can dereference ht->table.

But I don't see any code checking ht->table for NULL. So if race against drm_ht_remove()
is possible, this code is already broken and this spin_lock doesn't save us from NULL-ptr
deref.

So, either we already protected from such scenarios (e.g. we are the only owners of tdev/tfile in
ttm_object_device_release()/ttm_object_file_release()) or this code is already terribly
broken. Anyways we can just move drm_ht_remove() out of spin_lock()/spin_unlock() section.

Did I miss anything? 


> Sure, we could change the API to return the object removed, and
> then force the caller to free the object that was removed from the hash
> table outside the lock it's holding, but that's a really inelegant API.
> 

This won't be required if I'm right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

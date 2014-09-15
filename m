Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6323C6B0037
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 04:28:50 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id n3so3685647wiv.7
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 01:28:47 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id r8si8375850wiy.73.2014.09.15.01.28.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 01:28:43 -0700 (PDT)
Date: Mon, 15 Sep 2014 10:28:40 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] mm: dmapool: add/remove sysfs file outside of the pool
 lock
Message-ID: <20140915082840.GA14546@linutronix.de>
References: <1410463876-21265-1-git-send-email-bigeasy@linutronix.de>
 <20140912161317.f38c0d2c3b589aea94bdb870@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20140912161317.f38c0d2c3b589aea94bdb870@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

* Andrew Morton | 2014-09-12 16:13:17 [-0700]:

>On Thu, 11 Sep 2014 21:31:16 +0200 Sebastian Andrzej Siewior <bigeasy@linu=
tronix.de> wrote:
>
>> cat /sys/___/pools followed by removal the device leads to:
>>=20
>> |=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
>> |[ INFO: possible circular locking dependency detected ]
>> |3.17.0-rc4+ #1498 Not tainted
>> |-------------------------------------------------------
>> |rmmod/2505 is trying to acquire lock:
>> | (s_active#28){++++.+}, at: [<c017f754>] kernfs_remove_by_name_ns+0x3c/=
0x88
>> |
>> |but task is already holding lock:
>> | (pools_lock){+.+.+.}, at: [<c011494c>] dma_pool_destroy+0x18/0x17c
>> |
>> |which lock already depends on the new lock.
>>=20
>> The problem is the lock order of pools_lock and kernfs_mutex in
>> dma_pool_destroy() vs show_pools().
>
>Important details were omitted.  What's the call path whereby
>show_pools() is called under kernfs_mutex?

The complete lockdep output:

 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
 [ INFO: possible circular locking dependency detected ]
 3.17.0-rc4+ #1498 Not tainted
 -------------------------------------------------------
 rmmod/2505 is trying to acquire lock:
  (s_active#28){++++.+}, at: [<c017f754>] kernfs_remove_by_name_ns+0x3c/0x88
=20
 but task is already holding lock:
  (pools_lock){+.+.+.}, at: [<c011494c>] dma_pool_destroy+0x18/0x17c
=20
 which lock already depends on the new lock.
=20
=20
 the existing dependency chain (in reverse order) is:
=20
-> #1 (pools_lock){+.+.+.}:
        [<c0114ae8>] show_pools+0x30/0xf8
        [<c0313210>] dev_attr_show+0x1c/0x48
        [<c0180e84>] sysfs_kf_seq_show+0x88/0x10c
        [<c017f960>] kernfs_seq_show+0x24/0x28
        [<c013efc4>] seq_read+0x1b8/0x480
        [<c011e820>] vfs_read+0x8c/0x148
        [<c011ea10>] SyS_read+0x40/0x8c
        [<c000e960>] ret_fast_syscall+0x0/0x48
=20
-> #0 (s_active#28){++++.+}:
        [<c017e9ac>] __kernfs_remove+0x258/0x2ec
        [<c017f754>] kernfs_remove_by_name_ns+0x3c/0x88
        [<c0114a7c>] dma_pool_destroy+0x148/0x17c
        [<c03ad288>] hcd_buffer_destroy+0x20/0x34
        [<c03a4780>] usb_remove_hcd+0x110/0x1a4
        [<bf04e1a0>] musb_host_cleanup+0x24/0x38 [musb_hdrc]
        [<bf04964c>] musb_shutdown+0x1c/0x90 [musb_hdrc]
        [<bf049a78>] musb_remove+0x1c/0x58 [musb_hdrc]
        [<c031791c>] platform_drv_remove+0x18/0x1c
        [<c03160e0>] __device_release_driver+0x70/0xc4
        [<c0316154>] device_release_driver+0x20/0x2c
        [<c0315d24>] bus_remove_device+0xd8/0xf8
        [<c0313970>] device_del+0xf4/0x178
        [<c0317c84>] platform_device_del+0x14/0x9c
        [<c0317fdc>] platform_device_unregister+0xc/0x18
        [<bf06d180>] dsps_remove+0x14/0x34 [musb_dsps]
        [<c031791c>] platform_drv_remove+0x18/0x1c
        [<c03160e0>] __device_release_driver+0x70/0xc4
        [<c03168e8>] driver_detach+0xb4/0xb8
        [<c0315f68>] bus_remove_driver+0x4c/0x90
        [<c00aac54>] SyS_delete_module+0x114/0x178
        [<c000e960>] ret_fast_syscall+0x0/0x48
=20
 other info that might help us debug this:
  Possible unsafe locking scenario:
=20
        CPU0                    CPU1
        ----                    ----
   lock(pools_lock);
                                lock(s_active#28);
                                lock(pools_lock);
   lock(s_active#28);
=20
  *** DEADLOCK ***
=20
 4 locks held by rmmod/2505:
  #0:  (&dev->mutex){......}, at: [<c0316878>] driver_detach+0x44/0xb8
  #1:  (&dev->mutex){......}, at: [<c0316884>] driver_detach+0x50/0xb8
  #2:  (&dev->mutex){......}, at: [<c031614c>] device_release_driver+0x18/0=
x2c
  #3:  (pools_lock){+.+.+.}, at: [<c011494c>] dma_pool_destroy+0x18/0x17c
=20
 stack backtrace:
 CPU: 0 PID: 2505 Comm: rmmod Not tainted 3.17.0-rc4+ #1498
 [<c0015ae8>] (unwind_backtrace) from [<c0011cf4>] (show_stack+0x10/0x14)
 [<c0011cf4>] (show_stack) from [<c04f8b40>] (dump_stack+0x8c/0xc0)
 [<c04f8b40>] (dump_stack) from [<c04f5cc8>] (print_circular_bug+0x284/0x2d=
c)
 [<c04f5cc8>] (print_circular_bug) from [<c0079ebc>] (__lock_acquire+0x16a8=
/0x1c5c)
 [<c0079ebc>] (__lock_acquire) from [<c007a9c4>] (lock_acquire+0x98/0x118)
 [<c007a9c4>] (lock_acquire) from [<c017e9ac>] (__kernfs_remove+0x258/0x2ec)
 [<c017e9ac>] (__kernfs_remove) from [<c017f754>] (kernfs_remove_by_name_ns=
+0x3c/0x88)
 [<c017f754>] (kernfs_remove_by_name_ns) from [<c0114a7c>] (dma_pool_destro=
y+0x148/0x17c)
 [<c0114a7c>] (dma_pool_destroy) from [<c03ad288>] (hcd_buffer_destroy+0x20=
/0x34)
 [<c03ad288>] (hcd_buffer_destroy) from [<c03a4780>] (usb_remove_hcd+0x110/=
0x1a4)
 [<c03a4780>] (usb_remove_hcd) from [<bf04e1a0>] (musb_host_cleanup+0x24/0x=
38 [musb_hdrc])

>
>> This patch breaks out the creation of the sysfs file outside of the
>> pools_lock mutex.
>
>I think the patch adds races.  They're improbable, but they're there.
>
>> In theory we would have to create the link in the error path of
>> device_create_file() in case the dev->dma_pools list is not empty. In
>> reality I doubt that there will be a single device creating dma-pools in
>> parallel where it would matter.
>
>Maybe you're saying the same thing here, but the changelog lacks
>sufficient detail for me to tell because it doesn't explain *why* "we
>would have to create the link".

We drop the pools_lock while invoking device_create_file(). In other
thread (for the same device) another invocation of dma_pool_create() may
have occured. The caller won't invoke device_create_file() becase the
list is non-empty so it has been done. Now, the previous caller returns
=66rom device_create_file() with an error and for the cleanup it grabs the
pools_lock() to remove itself from the list and return NULL. Here, we
have the problem that after we remove ourself from the list and the list
is non-empty (like in the described case because dma_pool_create() has
been invoked twice from two threads in parallel) then we should invoke
device_create_file() because the second thread didn't as it expected the
first one to do so.

>> --- a/mm/dmapool.c
>> +++ b/mm/dmapool.c
>> @@ -132,6 +132,7 @@ struct dma_pool *dma_pool_create(const char *name, s=
truct device *dev,
>>  {
>>  	struct dma_pool *retval;
>>  	size_t allocation;
>> +	bool empty =3D false;
>> =20
>>  	if (align =3D=3D 0) {
>>  		align =3D 1;
>> @@ -173,14 +174,22 @@ struct dma_pool *dma_pool_create(const char *name,=
 struct device *dev,
>>  	INIT_LIST_HEAD(&retval->pools);
>> =20
>>  	mutex_lock(&pools_lock);
>> -	if (list_empty(&dev->dma_pools) &&
>> -	    device_create_file(dev, &dev_attr_pools)) {
>> -		kfree(retval);
>> -		return NULL;
>> -	} else
>> -		list_add(&retval->pools, &dev->dma_pools);
>> +	if (list_empty(&dev->dma_pools))
>> +		empty =3D true;
>> +	list_add(&retval->pools, &dev->dma_pools);
>>  	mutex_unlock(&pools_lock);
>> -
>> +	if (empty) {
>> +		int err;
>> +
>> +		err =3D device_create_file(dev, &dev_attr_pools);
>> +		if (err) {
>> +			mutex_lock(&pools_lock);
>> +			list_del(&retval->pools);
>> +			mutex_unlock(&pools_lock);
>> +			kfree(retval);
>> +			return NULL;
>> +		}
>> +	}
>>  	return retval;
>>  }
>>  EXPORT_SYMBOL(dma_pool_create);
>> @@ -251,11 +260,15 @@ static void pool_free_page(struct dma_pool *pool, =
struct dma_page *page)
>>   */
>>  void dma_pool_destroy(struct dma_pool *pool)
>>  {
>> +	bool empty =3D false;
>> +
>>  	mutex_lock(&pools_lock);
>>  	list_del(&pool->pools);
>>  	if (pool->dev && list_empty(&pool->dev->dma_pools))
>> -		device_remove_file(pool->dev, &dev_attr_pools);
>> +		empty =3D true;
>>  	mutex_unlock(&pools_lock);
>
>For example, if another process now runs dma_pool_create(), it will try
>to create the sysfs file and will presumably fail because it's already
>there.  Then when this process runs, the file gets removed again.  So
>we'll get a nasty warning from device_create_file() (I assume) and the
>dma_pool_create() call will fail.

Please note that this file is _per_ device. I wouldn't assume that you
create & destroy over and over again for a single device.
But I get your possible race here. So I could add a mutex across the
whole device create & destory path. Since this mutex won't protect the
list it won't be taken the show_pools() and lockdep won't complain.

>There's probably a similar race in the destroy()-interrupts-create()
>path but I'm lazy.
>
>> +	if (empty)
>> +		device_remove_file(pool->dev, &dev_attr_pools);
>> =20
>
>
>This problem is pretty ugly.
>
>It's a bit surprising that it hasn't happened elsewhere.  Perhaps this
>is because dmapool went and broke the sysfs rules and has multiple
>values in a single sysfs file.  This causes dmapool to walk a list
>under kernfs_lock and that list walk requires a lock.
>
>And it's too late to fix this by switching to one-value-per-file.  Ugh.
>Maybe there's some wizardly hack we can use in dma_pool_create() and
>dma_pool_destroy() to avoid the races.  Maybe use your patch as-is but
>add yet another mutex to serialise dma_pool_create() against
>dma_pool_destroy() so they can never run concurrently?  There may
>already be higher-level locking which ensures this so perhaps we can
>"fix" the races with suitable code comments.

There is nothing that ensures that dma_pool_destroy() and
dma_pool_create() are not invoked in parallel since those two are
directly used by device drivers. I think it is unlikely since you need a
second thread and this is usually done at device-init / device-exit
time. Saying unlikely does not make it impossible to happen so I add
another mutex around it=E2=80=A6

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

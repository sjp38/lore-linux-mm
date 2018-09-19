Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C95458E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 01:07:14 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 191-v6so1897415pgb.23
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 22:07:14 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z4-v6si19781058pgo.626.2018.09.18.22.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 22:07:13 -0700 (PDT)
Subject: Re: [LKP] [vfree, kvfree] a79ed8bfb2:
 BUG:sleeping_function_called_from_invalid_context_at_mm/util.c
References: <20180918085252.GR7632@shao2-debian>
 <7e19e4df-b1a6-29bd-9ae7-0266d50bef1d@virtuozzo.com>
From: Rong Chen <rong.a.chen@intel.com>
Message-ID: <7fa0dc06-25bb-9549-e501-042bfc22dd36@intel.com>
Date: Wed, 19 Sep 2018 13:07:28 +0800
MIME-Version: 1.0
In-Reply-To: <7e19e4df-b1a6-29bd-9ae7-0266d50bef1d@virtuozzo.com>
Content-Type: multipart/alternative;
 boundary="------------4034E5576A06A3A9F6D0C6BC"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, lkp@01.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>

This is a multi-part message in MIME format.
--------------4034E5576A06A3A9F6D0C6BC
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Tested-by: kernel test robot <rong.a.chen@intel.com>


On 09/18/2018 05:43 PM, Andrey Ryabinin wrote:
> On 09/18/2018 11:52 AM, kernel test robot wrote:
>
>> [    3.265372] BUG: sleeping function called from invalid context at mm/util.c:449
>> [    3.288552] in_atomic(): 0, irqs_disabled(): 0, pid: 142, name: rhashtable_thra
>> [    3.301548] INFO: lockdep is turned off.
>> [    3.302214] Preemption disabled at:
>> [    3.302221] [<c163e86f>] get_random_u32+0x4f/0x100
>> [    3.327556] CPU: 0 PID: 142 Comm: rhashtable_thra Tainted: G        W       T 4.19.0-rc3-00266-ga79ed8bf #656
>> [    3.328540] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
>> [    3.328540] Call Trace:
>> [    3.328540]  ? dump_stack+0x55/0x7b
>> [    3.328540]  ? get_random_u32+0x4f/0x100
>> [    3.328540]  ? ___might_sleep+0x11d/0x170
>> [    3.328540]  ? kvfree+0x61/0x70
>> [    3.328540]  ? bucket_table_free+0x18/0x80
>> [    3.328540]  ? bucket_table_alloc+0x79/0x160
>> [    3.328540]  ? rhashtable_insert_slow+0x25d/0x2d0
>> [    3.328540]  ? insert_retry+0x1df/0x320
>> [    3.328540]  ? threadfunc+0xa3/0x3fe
>> [    3.328540]  ? kzalloc+0x14/0x14
>> [    3.328540]  ? _raw_spin_unlock_irqrestore+0x30/0x50
>> [    3.328540]  ? kthread+0xd1/0x100
>> [    3.328540]  ? insert_retry+0x320/0x320
>> [    3.328540]  ? kthread_delayed_work_timer_fn+0x80/0x80
>> [    3.328540]  ? ret_from_fork+0x2e/0x38
>
> Seems like we need to drop might_sleep_if() from kvfree().
>
> 	rcu_read_lock()
> 		rhashtable_insert_rehash()
> 			new_tbl = bucket_table_alloc(ht, size, GFP_ATOMIC | __GFP_NOWARN);
> 				->kvmalloc();
>
> 		bucket_table_free(new_tbl);
> 			->kvfree()
> 	rcu_read_unlock()
>
> kvmalloc(..., GFP_ATOMIC) simply always kmalloc:
> 	if ((flags & GFP_KERNEL) != GFP_KERNEL)
> 		return kmalloc_node(size, flags, node);
>
> So in the above case, kvfree() always frees kmalloced memory -> and never calls vfree().
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>   mm/util.c | 2 --
>   1 file changed, 2 deletions(-)
>
> diff --git a/mm/util.c b/mm/util.c
> index 929ed1795bc1..7f1f165f46af 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -446,8 +446,6 @@ EXPORT_SYMBOL(kvmalloc_node);
>    */
>   void kvfree(const void *addr)
>   {
> -	might_sleep_if(!in_interrupt());
> -
>   	if (is_vmalloc_addr(addr))
>   		vfree(addr);
>   	else


--------------4034E5576A06A3A9F6D0C6BC
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p>Tested-by: kernel test robot <a class="moz-txt-link-rfc2396E"
        href="mailto:rong.a.chen@intel.com">&lt;rong.a.chen@intel.com&gt;</a>
      <br>
    </p>
    <br>
    <div class="moz-cite-prefix">On 09/18/2018 05:43 PM, Andrey Ryabinin
      wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:7e19e4df-b1a6-29bd-9ae7-0266d50bef1d@virtuozzo.com">
      <pre wrap="">On 09/18/2018 11:52 AM, kernel test robot wrote:

</pre>
      <blockquote type="cite">
        <pre wrap="">
[    3.265372] BUG: sleeping function called from invalid context at mm/util.c:449
[    3.288552] in_atomic(): 0, irqs_disabled(): 0, pid: 142, name: rhashtable_thra
[    3.301548] INFO: lockdep is turned off.
[    3.302214] Preemption disabled at:
[    3.302221] [&lt;c163e86f&gt;] get_random_u32+0x4f/0x100
[    3.327556] CPU: 0 PID: 142 Comm: rhashtable_thra Tainted: G        W       T 4.19.0-rc3-00266-ga79ed8bf #656
[    3.328540] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[    3.328540] Call Trace:
[    3.328540]  ? dump_stack+0x55/0x7b
[    3.328540]  ? get_random_u32+0x4f/0x100
[    3.328540]  ? ___might_sleep+0x11d/0x170
[    3.328540]  ? kvfree+0x61/0x70
[    3.328540]  ? bucket_table_free+0x18/0x80
[    3.328540]  ? bucket_table_alloc+0x79/0x160
[    3.328540]  ? rhashtable_insert_slow+0x25d/0x2d0
[    3.328540]  ? insert_retry+0x1df/0x320
[    3.328540]  ? threadfunc+0xa3/0x3fe
[    3.328540]  ? kzalloc+0x14/0x14
[    3.328540]  ? _raw_spin_unlock_irqrestore+0x30/0x50
[    3.328540]  ? kthread+0xd1/0x100
[    3.328540]  ? insert_retry+0x320/0x320
[    3.328540]  ? kthread_delayed_work_timer_fn+0x80/0x80
[    3.328540]  ? ret_from_fork+0x2e/0x38
</pre>
      </blockquote>
      <pre wrap="">

Seems like we need to drop might_sleep_if() from kvfree().

	rcu_read_lock()
		rhashtable_insert_rehash()
			new_tbl = bucket_table_alloc(ht, size, GFP_ATOMIC | __GFP_NOWARN);
				-&gt;kvmalloc();

		bucket_table_free(new_tbl);
			-&gt;kvfree()
	rcu_read_unlock()

kvmalloc(..., GFP_ATOMIC) simply always kmalloc:
	if ((flags &amp; GFP_KERNEL) != GFP_KERNEL)
		return kmalloc_node(size, flags, node);

So in the above case, kvfree() always frees kmalloced memory -&gt; and never calls vfree().

Signed-off-by: Andrey Ryabinin <a class="moz-txt-link-rfc2396E" href="mailto:aryabinin@virtuozzo.com">&lt;aryabinin@virtuozzo.com&gt;</a>
---
 mm/util.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index 929ed1795bc1..7f1f165f46af 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -446,8 +446,6 @@ EXPORT_SYMBOL(kvmalloc_node);
  */
 void kvfree(const void *addr)
 {
-	might_sleep_if(!in_interrupt());
-
 	if (is_vmalloc_addr(addr))
 		vfree(addr);
 	else
</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------4034E5576A06A3A9F6D0C6BC--

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 568ED5F0001
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 11:09:24 -0400 (EDT)
From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Date: Fri, 17 Apr 2009 16:07:38 +0100
Subject: RE: [RFC][PATCH v3 6/6] fix wrong get_user_pages usage in iovlock.c
Message-ID: <129600E5E5FB004392DDC3FB599660D792A39DCE@irsmsx504.ger.corp.intel.com>
References: <200904141656.14191.nickpiggin@yahoo.com.au>
 <20090414155719.C66B.A69D9226@jp.fujitsu.com>
 <20090415174658.AC4F.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090415174658.AC4F.A69D9226@jp.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "David S.
 Miller" <davem@davemloft.net>, "Leech, Christopher" <christopher.leech@intel.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>>> I would perhaps not fold gup_fast conversions into the same patch as
>>> the fix.
>>=20
>> OK. I'll fix.
>=20
> Done.
>=20
>=20
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Subject: [Untested][RFC][PATCH] fix wrong get_user_pages usage in iovlock=
.c
>=20
> 	down_read(mmap_sem)
> 	get_user_pages()
> 	up_read(mmap_sem)
>=20
> is fork unsafe.
> fix it.
>=20
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Maciej Sosnowski <maciej.sosnowski@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Chris Leech <christopher.leech@intel.com>
> Cc: netdev@vger.kernel.org
> ---
>  drivers/dma/iovlock.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> Index: b/drivers/dma/iovlock.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- a/drivers/dma/iovlock.c	2009-04-13 22:58:36.000000000 +0900
> +++ b/drivers/dma/iovlock.c	2009-04-14 20:27:16.000000000 +0900
> @@ -104,8 +104,6 @@ struct dma_pinned_list *dma_pin_iovec_pa
>  			0,	/* force */
>  			page_list->pages,
>  			NULL);
> -		up_read(&current->mm->mmap_sem);
> -
>  		if (ret !=3D page_list->nr_pages)
>  			goto unpin;
>=20
> @@ -127,6 +125,8 @@ void dma_unpin_iovec_pages(struct dma_pi
>  	if (!pinned_list)
>  		return;
>=20
> +	up_read(&current->mm->mmap_sem);
> +
>  	for (i =3D 0; i < pinned_list->nr_iovecs; i++) {
>  		struct dma_page_list *page_list =3D &pinned_list->page_list[i];
>  		for (j =3D 0; j < page_list->nr_pages; j++) {

I have tried it with net_dma and here is what I've got.

Regards,
Maciej
---

 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
 [ INFO: possible circular locking dependency detected ]
 2.6.30-rc2 #2
 -------------------------------------------------------
 iperf/10555 is trying to acquire lock:
  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff80450991>] sk_wait_data+0x90/0xc=
5

 but task is already holding lock:
  (&mm->mmap_sem){++++++}, at: [<ffffffff8043d0f6>] dma_pin_iovec_pages+0x1=
22/0x1a0
=20
 which lock already depends on the new lock.
=20
=20
 the existing dependency chain (in reverse order) is:
=20
 -> #1 (&mm->mmap_sem){++++++}:
        [<ffffffffffffffff>] 0xffffffffffffffff
=20
 -> #0 (sk_lock-AF_INET){+.+.+.}:
        [<ffffffffffffffff>] 0xffffffffffffffff
=20
 other info that might help us debug this:
=20
 1 lock held by iperf/10555:
  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8043d0f6>] dma_pin_iovec_page=
s+0x122/0x1a0
=20
 stack backtrace:
 Pid: 10555, comm: iperf Tainted: G        W  2.6.30-rc2 #2
 Call Trace:
  [<ffffffff8025b1dc>] ? print_circular_bug_tail+0xc0/0xc9
  [<ffffffff8025aa2b>] ? print_circular_bug_header+0xc8/0xcf
  [<ffffffff8025b984>] ? validate_chain+0x67d/0xc7c
  [<ffffffff8025c6e6>] ? __lock_acquire+0x763/0x7ec
  [<ffffffff8025c835>] ? lock_acquire+0xc6/0xea
  [<ffffffff80450991>] ? sk_wait_data+0x90/0xc5
  [<ffffffff8044ff01>] ? lock_sock_nested+0xee/0x100
  [<ffffffff80450991>] ? sk_wait_data+0x90/0xc5
  [<ffffffff80259b07>] ? mark_held_locks+0x43/0x5b
  [<ffffffff802403ee>] ? local_bh_enable_ip+0xc4/0xc7
  [<ffffffff80259c3c>] ? trace_hardirqs_on_caller+0x11d/0x148
  [<ffffffff80450991>] ? sk_wait_data+0x90/0xc5
  [<ffffffff8024ebb3>] ? autoremove_wake_function+0x0/0x2e
  [<ffffffff80488ad3>] ? tcp_recvmsg+0x3bf/0xa21
  [<ffffffff8044f601>] ? sock_common_recvmsg+0x30/0x45
  [<ffffffff8044d847>] ? sock_recvmsg+0xf0/0x10f
  [<ffffffff8024ebb3>] ? autoremove_wake_function+0x0/0x2e
  [<ffffffff8025c704>] ? __lock_acquire+0x781/0x7ec
  [<ffffffff802b553c>] ? fget_light+0xd5/0xdf
  [<ffffffff802b54b0>] ? fget_light+0x49/0xdf
  [<ffffffff8044e91b>] ? sys_recvfrom+0xbc/0x119
  [<ffffffff80259c3c>] ? trace_hardirqs_on_caller+0x11d/0x148
  [<ffffffff804e1a7f>] ? _spin_unlock_irq+0x24/0x27
  [<ffffffff802359ab>] ? finish_task_switch+0x7a/0xe4
  [<ffffffff80235967>] ? finish_task_switch+0x36/0xe4
  [<ffffffff804df188>] ? thread_return+0x3e/0x97
  [<ffffffff802718f7>] ? audit_syscall_entry+0x192/0x1bd
  [<ffffffff8020b96b>] ? system_call_fastpath+0x16/0x1b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DCD428E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 18:41:53 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r16so7222185pgr.15
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 15:41:53 -0800 (PST)
Received: from alln-iport-8.cisco.com (alln-iport-8.cisco.com. [173.37.142.95])
        by mx.google.com with ESMTPS id 37si2844737pgs.447.2019.01.17.15.41.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 15:41:52 -0800 (PST)
From: "Parvi Kaustubhi (pkaustub)" <pkaustub@cisco.com>
Subject: Re: [PATCH 5/6] drivers/IB,usnic: reduce scope of mmap_sem
Date: Thu, 17 Jan 2019 23:41:50 +0000
Message-ID: <ED26DFF4-3798-417E-85BD-53FB32F2BE3A@cisco.com>
References: <20190115181300.27547-1-dave@stgolabs.net>
 <20190115181300.27547-6-dave@stgolabs.net>
In-Reply-To: <20190115181300.27547-6-dave@stgolabs.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F62F45282BDCED4BA4DF5D2867569154@emea.cisco.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Doug Ledford <dledford@redhat.com>, "jgg@mellanox.com" <jgg@mellanox.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Christian Benvenuti (benve)" <benve@cisco.com>, "Nelson Escobar (neescoba)" <neescoba@cisco.com>, Davidlohr Bueso <dbueso@suse.de>

usnic driver was tested with this.

Acked-by: Parvi Kaustubhi <pkaustub@cisco.com>


> On Jan 15, 2019, at 10:12 AM, Davidlohr Bueso <dave@stgolabs.net> wrote:
>=20
> usnic_uiom_get_pages() uses gup_longterm() so we cannot really
> get rid of mmap_sem altogether in the driver, but we can get
> rid of some complexity that mmap_sem brings with only pinned_vm.
> We can get rid of the wq altogether as we no longer need to
> defer work to unpin pages as the counter is now atomic.
>=20
> Cc: benve@cisco.com
> Cc: neescoba@cisco.com
> Cc: pkaustub@cisco.com
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> ---
> drivers/infiniband/hw/usnic/usnic_ib_main.c |  2 --
> drivers/infiniband/hw/usnic/usnic_uiom.c    | 54 +++---------------------=
-----
> drivers/infiniband/hw/usnic/usnic_uiom.h    |  1 -
> 3 files changed, 4 insertions(+), 53 deletions(-)
>=20
> diff --git a/drivers/infiniband/hw/usnic/usnic_ib_main.c b/drivers/infini=
band/hw/usnic/usnic_ib_main.c
> index b2323a52a0dd..64bc4fda36bf 100644
> --- a/drivers/infiniband/hw/usnic/usnic_ib_main.c
> +++ b/drivers/infiniband/hw/usnic/usnic_ib_main.c
> @@ -691,7 +691,6 @@ static int __init usnic_ib_init(void)
> out_pci_unreg:
> 	pci_unregister_driver(&usnic_ib_pci_driver);
> out_umem_fini:
> -	usnic_uiom_fini();
>=20
> 	return err;
> }
> @@ -704,7 +703,6 @@ static void __exit usnic_ib_destroy(void)
> 	unregister_inetaddr_notifier(&usnic_ib_inetaddr_notifier);
> 	unregister_netdevice_notifier(&usnic_ib_netdevice_notifier);
> 	pci_unregister_driver(&usnic_ib_pci_driver);
> -	usnic_uiom_fini();
> }
>=20
> MODULE_DESCRIPTION("Cisco VIC (usNIC) Verbs Driver");
> diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniban=
d/hw/usnic/usnic_uiom.c
> index 22c40c432b9e..555d7bc93e72 100644
> --- a/drivers/infiniband/hw/usnic/usnic_uiom.c
> +++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
> @@ -47,8 +47,6 @@
> #include "usnic_uiom.h"
> #include "usnic_uiom_interval_tree.h"
>=20
> -static struct workqueue_struct *usnic_uiom_wq;
> -
> #define USNIC_UIOM_PAGE_CHUNK						\
> 	((PAGE_SIZE - offsetof(struct usnic_uiom_chunk, page_list))	/\
> 	((void *) &((struct usnic_uiom_chunk *) 0)->page_list[1] -	\
> @@ -129,7 +127,7 @@ static int usnic_uiom_get_pages(unsigned long addr, s=
ize_t size, int writable,
> 	uiomr->owning_mm =3D mm =3D current->mm;
> 	down_write(&mm->mmap_sem);
>=20
> -	locked =3D npages + atomic_long_read(&current->mm->pinned_vm);
> +	locked =3D atomic_long_add_return(npages, &current->mm->pinned_vm);
> 	lock_limit =3D rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>=20
> 	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
> @@ -185,12 +183,11 @@ static int usnic_uiom_get_pages(unsigned long addr,=
 size_t size, int writable,
> 	}
>=20
> out:
> -	if (ret < 0)
> +	if (ret < 0) {
> 		usnic_uiom_put_pages(chunk_list, 0);
> -	else {
> -		atomic_long_set(&mm->pinned_vm, locked);
> +		atomic_long_sub(npages, &current->mm->pinned_vm);
> +	} else
> 		mmgrab(uiomr->owning_mm);
> -	}
>=20
> 	up_write(&mm->mmap_sem);
> 	free_page((unsigned long) page_list);
> @@ -436,43 +433,12 @@ static inline size_t usnic_uiom_num_pages(struct us=
nic_uiom_reg *uiomr)
> 	return PAGE_ALIGN(uiomr->length + uiomr->offset) >> PAGE_SHIFT;
> }
>=20
> -static void usnic_uiom_release_defer(struct work_struct *work)
> -{
> -	struct usnic_uiom_reg *uiomr =3D
> -		container_of(work, struct usnic_uiom_reg, work);
> -
> -	down_write(&uiomr->owning_mm->mmap_sem);
> -	atomic_long_sub(usnic_uiom_num_pages(uiomr), &uiomr->owning_mm->pinned_=
vm);
> -	up_write(&uiomr->owning_mm->mmap_sem);
> -
> -	__usnic_uiom_release_tail(uiomr);
> -}
> -
> void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr,
> 			    struct ib_ucontext *context)
> {
> 	__usnic_uiom_reg_release(uiomr->pd, uiomr, 1);
>=20
> -	/*
> -	 * We may be called with the mm's mmap_sem already held.  This
> -	 * can happen when a userspace munmap() is the call that drops
> -	 * the last reference to our file and calls our release
> -	 * method.  If there are memory regions to destroy, we'll end
> -	 * up here and not be able to take the mmap_sem.  In that case
> -	 * we defer the vm_locked accounting to a workqueue.
> -	 */
> -	if (context->closing) {
> -		if (!down_write_trylock(&uiomr->owning_mm->mmap_sem)) {
> -			INIT_WORK(&uiomr->work, usnic_uiom_release_defer);
> -			queue_work(usnic_uiom_wq, &uiomr->work);
> -			return;
> -		}
> -	} else {
> -		down_write(&uiomr->owning_mm->mmap_sem);
> -	}
> 	atomic_long_sub(usnic_uiom_num_pages(uiomr), &uiomr->owning_mm->pinned_v=
m);
> -	up_write(&uiomr->owning_mm->mmap_sem);
> -
> 	__usnic_uiom_release_tail(uiomr);
> }
>=20
> @@ -601,17 +567,5 @@ int usnic_uiom_init(char *drv_name)
> 		return -EPERM;
> 	}
>=20
> -	usnic_uiom_wq =3D create_workqueue(drv_name);
> -	if (!usnic_uiom_wq) {
> -		usnic_err("Unable to alloc wq for drv %s\n", drv_name);
> -		return -ENOMEM;
> -	}
> -
> 	return 0;
> }
> -
> -void usnic_uiom_fini(void)
> -{
> -	flush_workqueue(usnic_uiom_wq);
> -	destroy_workqueue(usnic_uiom_wq);
> -}
> diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.h b/drivers/infiniban=
d/hw/usnic/usnic_uiom.h
> index b86a9731071b..c88cfa087e3a 100644
> --- a/drivers/infiniband/hw/usnic/usnic_uiom.h
> +++ b/drivers/infiniband/hw/usnic/usnic_uiom.h
> @@ -93,5 +93,4 @@ struct usnic_uiom_reg *usnic_uiom_reg_get(struct usnic_=
uiom_pd *pd,
> void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr,
> 			    struct ib_ucontext *ucontext);
> int usnic_uiom_init(char *drv_name);
> -void usnic_uiom_fini(void);
> #endif /* USNIC_UIOM_H_ */
> --=20
> 2.16.4
>=20

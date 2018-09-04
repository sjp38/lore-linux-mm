Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 153156B6C1A
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 02:37:17 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id w196-v6so2559778itb.4
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 23:37:17 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id u66-v6si12431080jad.5.2018.09.03.23.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Sep 2018 23:37:16 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [RFC][PATCH 1/5] [PATCH 1/5] kvm: register in task_struct
From: Nikita Leshenko <nikita.leshchenko@oracle.com>
In-Reply-To: <20180904004621.aqhemgpefwtq3kif@wfg-t540p.sh.intel.com>
Date: Tue, 4 Sep 2018 08:37:03 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <F0A5145C-E401-43E8-9FE9-56A4470CD13E@oracle.com>
References: <D3FBF73C-3C33-4F94-8BBB-CE6C70B81A70@oracle.com>
 <0ef9ccdc-3eae-f0b9-5304-8552cb94d166@de.ibm.com>
 <20180904002818.nq2ejxlsn4o34anl@wfg-t540p.sh.intel.com>
 <20180904004621.aqhemgpefwtq3kif@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, dongx.peng@intel.com, jingqi.liu@intel.com, eddie.dong@intel.com, dave.hansen@intel.com, ying.huang@intel.com, bgregg@netflix.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

On 4 Sep 2018, at 2:46, Fengguang Wu <fengguang.wu@intel.com> wrote:
>=20
> Here it goes:
>=20
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 99ce070e7dcb..27c5446f3deb 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -27,6 +27,7 @@ typedef int vm_fault_t;
> struct address_space;
> struct mem_cgroup;
> struct hmm;
> +struct kvm;
> /*
> * Each physical page in the system has a struct page associated with
> @@ -489,10 +490,19 @@ struct mm_struct {
> 	/* HMM needs to track a few things per mm */
> 	struct hmm *hmm;
> #endif
> +#if IS_ENABLED(CONFIG_KVM)
> +	struct kvm *kvm;
> +#endif
> } __randomize_layout;
> extern struct mm_struct init_mm;
> +#if IS_ENABLED(CONFIG_KVM)
> +static inline struct kvm *mm_kvm(struct mm_struct *mm) { return =
mm->kvm; }
> +#else
> +static inline struct kvm *mm_kvm(struct mm_struct *mm) { return NULL; =
}
> +#endif
> +
> static inline void mm_init_cpumask(struct mm_struct *mm)
> {
> #ifdef CONFIG_CPUMASK_OFFSTACK
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 0c483720de8d..dca6156a7b35 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -3892,7 +3892,7 @@ static void kvm_uevent_notify_change(unsigned =
int type, struct kvm *kvm)
> 	if (type =3D=3D KVM_EVENT_CREATE_VM) {
> 		add_uevent_var(env, "EVENT=3Dcreate");
> 		kvm->userspace_pid =3D task_pid_nr(current);
> -		current->kvm =3D kvm;
> +		current->mm->kvm =3D kvm;
I think you also need to reset kvm to NULL once the VM is
destroyed, otherwise it would point to dangling memory.

-Nikita
> 	} else if (type =3D=3D KVM_EVENT_DESTROY_VM) {
> 		add_uevent_var(env, "EVENT=3Ddestroy");
> 	}

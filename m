Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3341D8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 06:59:21 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id i3so20492316pfj.4
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 03:59:21 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id ay4si33767072plb.235.2018.12.27.03.59.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 03:59:19 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBRBruWi137854
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 06:59:18 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pmu2nqdms-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 06:59:18 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 27 Dec 2018 11:59:15 -0000
Subject: Re: [PATCH v37 0/3] Virtio-balloon: support free page reporting
From: Christian Borntraeger <borntraeger@de.ibm.com>
References: <1535333539-32420-1-git-send-email-wei.w.wang@intel.com>
 <0661b05a-d9d0-d374-44e8-2583463e94c2@de.ibm.com>
Date: Thu, 27 Dec 2018 12:59:04 +0100
In-Reply-To: <0661b05a-d9d0-d374-44e8-2583463e94c2@de.ibm.com>
Content-Language: en-US
Message-Id: <de167161-b586-6aee-d6a5-a90d47bbe1d4@de.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: Quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, dgilbert@redhat.com
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com, quintela@redhat.com, Halil Pasic <pasic@linux.ibm.com>, Cornelia Huck <cohuck@redhat.com>

On 27.12.2018 12:31, Christian Borntraeger wrote:
> This patch triggers random crashes in the guest kernel on s390 early duri=
ng boot.
> No migration and no setting of the balloon is involved.
>=20

Adding Conny and Halil,

As the QEMU provides no PAGE_HINT feature yet, this quick hack makes the
guest boot fine again:


diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloo=
n.c
index 728ecd1eea305..aa2e1864c5736 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -492,7 +492,7 @@ static int init_vqs(struct virtio_balloon *vb)
                callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] =3D NULL;
        }
=20
-       err =3D vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
+       err =3D vb->vdev->config->find_vqs(vb->vdev, 3, //VIRTIO_BALLOON_VQ=
_MAX,
                                         vqs, callbacks, names, NULL, NULL);
        if (err)
                return err;


To me it looks like that virtio_ccw_find_vqs will abort if any of the virtq=
ueues=20
that it is been asked for does not exist (including the earlier ones).


Christian

>=20
> On 27.08.2018 03:32, Wei Wang wrote:
>> The new feature, VIRTIO_BALLOON_F_FREE_PAGE_HINT, implemented by this
>> series enables the virtio-balloon driver to report hints of guest free
>> pages to host. It can be used to accelerate virtual machine (VM) live
>> migration. Here is an introduction of this usage:
>>
>> Live migration needs to transfer the VM's memory from the source machine
>> to the destination round by round. For the 1st round, all the VM's memory
>> is transferred. From the 2nd round, only the pieces of memory that were
>> written by the guest (after the 1st round) are transferred. One method
>> that is popularly used by the hypervisor to track which part of memory is
>> written is to have the hypervisor write-protect all the guest memory.
>>
>> This feature enables the optimization by skipping the transfer of guest
>> free pages during VM live migration. It is not concerned that the memory
>> pages are used after they are given to the hypervisor as a hint of the
>> free pages, because they will be tracked by the hypervisor and transferr=
ed
>> in the subsequent round if they are used and written.
>>
>> * Tests
>> 1 Test Environment
>>     Host: Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz
>>     Migration setup: migrate_set_speed 100G, migrate_set_downtime 400ms
>>
>> 2 Test Results (results are averaged over several repeated runs)
>>     2.1 Guest setup: 8G RAM, 4 vCPU
>>         2.1.1 Idle guest live migration time
>>             Optimization v.s. Legacy =3D 620ms vs 2970ms
>>             --> ~79% reduction
>>         2.1.2 Guest live migration with Linux compilation workload
>>           (i.e. make bzImage -j4) running
>>           1) Live Migration Time:
>>              Optimization v.s. Legacy =3D 2273ms v.s. 4502ms
>>              --> ~50% reduction
>>           2) Linux Compilation Time:
>>              Optimization v.s. Legacy =3D 8min42s v.s. 8min43s
>>              --> no obvious difference
>>
>>     2.2 Guest setup: 128G RAM, 4 vCPU
>>         2.2.1 Idle guest live migration time
>>             Optimization v.s. Legacy =3D 5294ms vs 41651ms
>>             --> ~87% reduction
>>         2.2.2 Guest live migration with Linux compilation workload
>>           1) Live Migration Time:
>>             Optimization v.s. Legacy =3D 8816ms v.s. 54201ms
>>             --> 84% reduction
>>           2) Linux Compilation Time:
>>              Optimization v.s. Legacy =3D 8min30s v.s. 8min36s
>>              --> no obvious difference
>>
>> ChangeLog:
>> v36->v37:
>>     - free the reported pages to mm when receives a DONE cmd from host.
>>       Please see patch 1's commit log for reasons. Please see patch 1's
>>       commit for detailed explanations.
>>
>> For ChangeLogs from v22 to v36, please reference
>> https://lkml.org/lkml/2018/7/20/199
>>
>> For ChangeLogs before v21, please reference
>> https://lwn.net/Articles/743660/
>>
>> Wei Wang (3):
>>   virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
>>   mm/page_poison: expose page_poisoning_enabled to kernel modules
>>   virtio-balloon: VIRTIO_BALLOON_F_PAGE_POISON
>>
>>  drivers/virtio/virtio_balloon.c     | 374 +++++++++++++++++++++++++++++=
+++----
>>  include/uapi/linux/virtio_balloon.h |   8 +
>>  mm/page_poison.c                    |   6 +
>>  3 files changed, 355 insertions(+), 33 deletions(-)
>>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1A36B0031
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 14:57:56 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id k15so6957056qaq.30
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 11:57:56 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1blp0183.outbound.protection.outlook.com. [207.46.163.183])
        by mx.google.com with ESMTPS id u7si22134561qab.34.2014.06.30.11.57.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 Jun 2014 11:57:55 -0700 (PDT)
From: "Lewycky, Andrew" <Andrew.Lewycky@amd.com>
Subject: RE: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
Date: Mon, 30 Jun 2014 18:57:48 +0000
Message-ID: <3725846D7614874B8367361CC6008D741645DFA0@storexdag01.amd.com>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
 <1403920822-14488-2-git-send-email-j.glisse@gmail.com>
 <019CCE693E457142B37B791721487FD91806B836@storexdag01.amd.com>
 <20140630154042.GD26537@8bytes.org> <20140630160604.GF1956@gmail.com>
 <20140630181623.GE26537@8bytes.org> <20140630183556.GB3280@gmail.com>
In-Reply-To: <20140630183556.GB3280@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>, Joerg Roedel <joro@8bytes.org>
Cc: "Gabbay, Oded" <Oded.Gabbay@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "hpa@zytor.com" <hpa@zytor.com>, "peterz@infraread.org" <peterz@infraread.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien
 Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>

> On Mon, Jun 30, 2014 at 08:16:23PM +0200, Joerg Roedel wrote:
> > On Mon, Jun 30, 2014 at 12:06:05PM -0400, Jerome Glisse wrote:
> > > No this patch does not duplicate it. Current user of mmu_notifier
> > > rely on file close code path to call mmu_notifier_unregister. New
> > > code like AMD IOMMUv2 or HMM can not rely on that. Thus they need a
> > > way to call the mmu_notifer_unregister (which can not be done from
> > > inside the the release call back).
> >
> > No, when the mm is destroyed the .release function is called from
> > exit_mmap() which calls mmu_notifier_release() right at the beginning.
> > In this case you don't need to call mmu_notifer_unregister yourself
> > (you can still call it, but it will be a nop).
> >
>=20
> We do intend to tear down all secondary mapping inside the relase callbac=
k but
> still we can not cleanup all the resources associated with it.
>=20
> > > If you look at current code the release callback is use to kill
> > > secondary translation but not to free associated resources. All the
> > > associated resources are free later on after the release callback
> > > (well it depends if the file is close before the process is kill).
> >
> > In exit_mmap the .release function is called when all mappings are
> > still present. Thats the perfect point in time to unbind all those
> > resources from your device so that it can not use it anymore when the
> > mappings get destroyed.
> >
> > > So this patch aims to provide a callback to code outside of the
> > > mmu_notifier realms, a place where it is safe to cleanup the
> > > mmu_notifier and associated resources.
> >
> > Still, this is a duplication of mmu_notifier release call-back, so
> > still NACK.
> >
>=20
> It is not, mmu_notifier_register take increase mm_count and only
> mmu_notifier_unregister decrease the mm_count which is different from the
> mm_users count (the latter being the one that trigger an mmu notifier
> release).
>=20
> As said from the release call back you can not call mmu_notifier_unregist=
er
> and thus you can not fully cleanup things. Only way to achieve so is to d=
o it
> ouside mmu_notifier callback. As pointed out current user do not have thi=
s
> issue because they rely on file close callback to perform the cleanup ope=
ration.
> New user will not necessarily have such things to rely on. Hence factoriz=
ing
> various mm_struct destruction callback with an callback chain.
>=20
> If you know any other way to call mmu_notifier_unregister before the end =
of
> mmput function than i am all ear. I am not adding this call back just for=
 the fun
> of it i spend serious time trying to find a way to do thing without it. I=
 might have
> miss a way so if i did please show it to me.
>=20

Joerg, please consider that the amd_iommu_v2 driver already breaks the rule=
s for what can be done from the release callback. In particular, it frees t=
he pasid_state structure containing the struct mmu_notifier. (mn_release, u=
nbind_pasid, put_pasid_state_wait, free_pasid_state). Since this contains t=
he next pointer for the mmu_notifier list, __mmu_notifier_release will cras=
h. Modifying the MMU notifier list isn't allowed because the notifier code =
is holding an RCU read lock. In general the problem is that RCU read locks =
are very constraining and things that you'd like to do from release can't b=
e done. It could be done from the mmput callback, or perhaps mmu_notifier_r=
elease could call release from call_srcu instead.

As an aside we found another small issue: amd_iommu_bind_pasid calls get_ta=
sk_mm. This bumps the mm_struct use count and it will never be released. Th=
is would prevent the buggy code path described above from ever running in t=
he first place.

Thanks.
Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

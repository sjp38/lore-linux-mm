Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 53D396B0038
	for <linux-mm@kvack.org>; Sun, 25 Oct 2015 06:01:13 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so80095382wic.0
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 03:01:12 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0085.outbound.protection.outlook.com. [157.56.112.85])
        by mx.google.com with ESMTPS id qt4si16152601wic.99.2015.10.25.03.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 25 Oct 2015 03:01:11 -0700 (PDT)
Subject: Re: [PATCH v11 00/15] HMM (Heterogeneous Memory Management)
References: <1445461210-2605-1-git-send-email-jglisse@redhat.com>
From: Haggai Eran <haggaie@mellanox.com>
Message-ID: <562CA843.1040804@mellanox.com>
Date: Sun, 25 Oct 2015 12:00:35 +0200
MIME-Version: 1.0
In-Reply-To: <1445461210-2605-1-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel
 Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes
 Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van
 Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind
 Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John
 Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jeff Law <law@redhat.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On 21/10/2015 23:59, JA(C)rA'me Glisse wrote:
> HMM (HMM (Heterogeneous Memory Management) is an helper layer
> for device driver, its main features are :
>    - Shadow CPU page table of a process into a device specific
>      format page table and keep both page table synchronize.
>    - Handle DMA mapping of system ram page on behalf of device
>      (for shadowed page table entry).
>    - Migrate private anonymous memory to private device memory
>      and handle CPU page fault (which triggers a migration back
>      to system memory so CPU can access it).
> 
> Benefits of HMM :
>    - Avoid current model where device driver have to pin page
>      which blocks several kernel features (KSM, migration, ...).
>    - No impact on existing workload that do not use HMM (it only
>      adds couple more if() to common code path).
>    - Intended as common infrastructure for several different
>      hardware, as of today Mellanox and NVidia.
>    - Allow userspace API to move away from explicit copy code
>      path where application programmer has to manage manually
>      memcpy to and from device memory.
>    - Transparent to userspace, for instance allowing library to
>      use GPU without involving application linked against it.
> 
> I expect other hardware company to express interest in HMM and
> eventualy start using it with their new hardware. I give a more
> in depth motivation after the change log.

The RDMA stack had IO paging support since kernel v4.0, using the
mmu_notifier APIs to interface with the mm subsystem. As one may expect,
it allows RDMA applications to decrease the amount of memory that needs
to be pinned, and allows the kernel to better allocate physical memory.
HMM looks like a better API than mmu_notifiers for that purpose, as it
allows sharing more code. It handles internally things that any similar
driver or subsystem would need to do, such as synchronization between
page fault events and invalidations, and DMA-mapping pages for device
use. It looks like it can be extended to also assist in device peer to
peer memory mapping, to allow capable devices to transfer data directly
without CPU intervention.

Regards,
Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9D72A6B0005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 18:58:32 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id zm5so24977866pac.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 15:58:32 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id z12si1475827pas.77.2016.03.29.15.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 15:58:31 -0700 (PDT)
Date: Tue, 29 Mar 2016 15:58:30 -0700
From: John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v12 07/29] HMM: add per mirror page table v4.
In-Reply-To: <1457469802-11850-8-git-send-email-jglisse@redhat.com>
Message-ID: <alpine.LNX.2.20.1603291549230.27602@blueforge.nvidia.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com> <1457469802-11850-8-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="296541600-260365134-1459292310=:27602"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Jatin Kumar <jakumar@nvidia.com>

--296541600-260365134-1459292310=:27602
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT

On Tue, 8 Mar 2016, JA(C)rA'me Glisse wrote:

> This patch add the per mirror page table. It also propagate CPU page
> table update to this per mirror page table using mmu_notifier callback.
> All update are contextualized with an HMM event structure that convey
> all information needed by device driver to take proper actions (update
> its own mmu to reflect changes and schedule proper flushing).
> 
> Core HMM is responsible for updating the per mirror page table once
> the device driver is done with its update. Most importantly HMM will
> properly propagate HMM page table dirty bit to underlying page.
> 
> Changed since v1:
>   - Removed unused fence code to defer it to latter patches.
> 
> Changed since v2:
>   - Use new bit flag helper for mirror page table manipulation.
>   - Differentiate fork event with HMM_FORK from other events.
> 
> Changed since v3:
>   - Get rid of HMM_ISDIRTY and rely on write protect instead.
>   - Adapt to HMM page table changes
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
> ---
>  include/linux/hmm.h |  83 ++++++++++++++++++++
>  mm/hmm.c            | 221 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 304 insertions(+)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index b559c0b..5488fa9 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -46,6 +46,7 @@
>  #include <linux/mmu_notifier.h>
>  #include <linux/workqueue.h>
>  #include <linux/mman.h>
> +#include <linux/hmm_pt.h>
>  
>  
>  struct hmm_device;
> @@ -53,6 +54,38 @@ struct hmm_mirror;
>  struct hmm;
>  
>  
> +/*
> + * hmm_event - each event is described by a type associated with a struct.
> + */
> +enum hmm_etype {
> +	HMM_NONE = 0,
> +	HMM_FORK,
> +	HMM_MIGRATE,
> +	HMM_MUNMAP,
> +	HMM_DEVICE_RFAULT,
> +	HMM_DEVICE_WFAULT,

Hi Jerome,

Just a tiny thing I noticed, while connecting HMM to NVIDIA's upcoming 
device driver: the last two enum items above should probably be named 
like this:

	HMM_DEVICE_READ_FAULT,
	HMM_DEVICE_WRITE_FAULT,

instead of _WFAULT / _RFAULT. (Earlier code reviewers asked for more 
clarity on these types of names.)

thanks,
John Hubbard

> +	HMM_WRITE_PROTECT,
> +};
> +
--296541600-260365134-1459292310=:27602--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

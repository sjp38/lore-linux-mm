Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 911E86B53D2
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 19:11:55 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d22-v6so5593064pfn.3
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 16:11:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j16-v6sor2278739pga.230.2018.08.30.16.11.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 16:11:54 -0700 (PDT)
Date: Fri, 31 Aug 2018 09:11:48 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 5/7] mm/hmm: use a structure for update callback
 parameters
Message-ID: <20180830231148.GC28695@350D>
References: <20180824192549.30844-1-jglisse@redhat.com>
 <20180824192549.30844-6-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180824192549.30844-6-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Fri, Aug 24, 2018 at 03:25:47PM -0400, jglisse@redhat.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> Use a structure to gather all the parameters for the update callback.
> This make it easier when adding new parameters by avoiding having to
> update all callback function signature.
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/hmm.h | 25 +++++++++++++++++--------
>  mm/hmm.c            | 27 ++++++++++++++-------------
>  2 files changed, 31 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 1ff4bae7ada7..a7f7600b6bb0 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -274,13 +274,26 @@ static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
>  struct hmm_mirror;
>  
>  /*
> - * enum hmm_update_type - type of update
> + * enum hmm_update_event - type of update
>   * @HMM_UPDATE_INVALIDATE: invalidate range (no indication as to why)
>   */
> -enum hmm_update_type {
> +enum hmm_update_event {
>  	HMM_UPDATE_INVALIDATE,
>  };
>  
> +/*
> + * struct hmm_update - HMM update informations for callback
> + *
> + * @start: virtual start address of the range to update
> + * @end: virtual end address of the range to update
> + * @event: event triggering the update (what is happening)
> + */
> +struct hmm_update {
> +	unsigned long start;
> +	unsigned long end;
> +	enum hmm_update_event event;
> +};
> +

I wonder if you want to add further information about the range,
like page_size, I guess the other side does not care about the
size. Do we care about sending multiple discontig ranges in
hmm_update? Should it be an array?

Balbir Singh

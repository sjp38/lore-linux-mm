Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5708E00C8
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 09:32:33 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e17so3752652edr.7
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 06:32:33 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3-v6si11790758ejm.182.2019.01.25.06.32.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 06:32:31 -0800 (PST)
Date: Fri, 25 Jan 2019 15:32:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 3/3] mm: Maintain randomization of page free lists
Message-ID: <20190125143230.GP3560@dhcp22.suse.cz>
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154690328135.676627.5979130839159447106.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154690328135.676627.5979130839159447106.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, keith.busch@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de

On Mon 07-01-19 15:21:21, Dan Williams wrote:
> When freeing a page with an order >= shuffle_page_order randomly select
> the front or back of the list for insertion.
> 
> While the mm tries to defragment physical pages into huge pages this can
> tend to make the page allocator more predictable over time. Inject the
> front-back randomness to preserve the initial randomness established by
> shuffle_free_memory() when the kernel was booted.
> 
> The overhead of this manipulation is constrained by only being applied
> for MAX_ORDER sized pages by default.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/mmzone.h  |   10 ++++++++++
>  include/linux/shuffle.h |   12 ++++++++++++
>  mm/page_alloc.c         |   11 +++++++++--
>  mm/shuffle.c            |   16 ++++++++++++++++
>  4 files changed, 47 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index b78a45e0b11c..c15f7f703be0 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -98,6 +98,8 @@ extern int page_group_by_mobility_disabled;
>  struct free_area {
>  	struct list_head	free_list[MIGRATE_TYPES];
>  	unsigned long		nr_free;
> +	u64			rand;
> +	u8			rand_bits;
>  };

Do we really need per order randomness? Why a global one is not
sufficient?
-- 
Michal Hocko
SUSE Labs

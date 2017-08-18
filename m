Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 297046B02F3
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 20:42:28 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y190so143436890pgb.3
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 17:42:28 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p19si2685563pgk.10.2017.08.17.17.42.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 17:42:26 -0700 (PDT)
Date: Fri, 18 Aug 2017 08:43:11 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2] swap: choose swap device according to numa node
Message-ID: <20170818004311.GB1996@intel.com>
References: <20170814053130.GD2369@aaronlu.sh.intel.com>
 <20170814163337.92c9f07666645366af82aba2@linux-foundation.org>
 <20170815054944.GF2369@aaronlu.sh.intel.com>
 <20170815150947.9b7ccea78c5ea28ae88ba87f@linux-foundation.org>
 <20170816024439.GA10925@aaronlu.sh.intel.com>
 <20170817154408.66c37d2d84eccdb102b9e04c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170817154408.66c37d2d84eccdb102b9e04c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Huang Ying <ying.huang@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>

On Thu, Aug 17, 2017 at 03:44:08PM -0700, Andrew Morton wrote:
> On Wed, 16 Aug 2017 10:44:40 +0800 Aaron Lu <aaron.lu@intel.com> wrote:
> > ...
> >
> > +static int __init swapfile_init(void)
> > +{
> > +	int nid;
> > +
> > +	swap_avail_heads = kmalloc(nr_node_ids * sizeof(struct plist_head), GFP_KERNEL);
> 
> I suppose we should use kmalloc_array(), as someone wrote it for us.
> 
> --- a/mm/swapfile.c~swap-choose-swap-device-according-to-numa-node-v2-fix
> +++ a/mm/swapfile.c
> @@ -3700,7 +3700,8 @@ static int __init swapfile_init(void)
>  {
>  	int nid;
>  
> -	swap_avail_heads = kmalloc(nr_node_ids * sizeof(struct plist_head), GFP_KERNEL);
> +	swap_avail_heads = kmalloc_array(nr_node_ids, sizeof(struct plist_head),
> +					 GFP_KERNEL);
>  	if (!swap_avail_heads) {
>  		pr_emerg("Not enough memory for swap heads, swap is disabled\n");
>  		return -ENOMEM;
> 
> > +	if (!swap_avail_heads) {
> > +		pr_emerg("Not enough memory for swap heads, swap is disabled\n");
> 
> checkpatch tells us that the "Not enough memory" is a bit redundant, as
> the memory allocator would have already warned.  So it's sufficient to
> additionally say only "swap is disabled" here.  But it's hardly worth
> changing.

Thanks Andrew for taking care of this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

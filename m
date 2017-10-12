Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D646C6B0069
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 08:41:09 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s78so3056276wmd.14
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 05:41:09 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id w43si2253283edb.141.2017.10.12.05.41.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 05:41:08 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 56C751C1E12
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 13:41:08 +0100 (IST)
Date: Thu, 12 Oct 2017 13:41:07 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/8] mm, truncate: Do not check mapping for every page
 being truncated
Message-ID: <20171012124107.fk63gk656jhzgodh@techsingularity.net>
References: <20171012093103.13412-1-mgorman@techsingularity.net>
 <20171012093103.13412-3-mgorman@techsingularity.net>
 <20171012121527.GA29293@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171012121527.GA29293@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On Thu, Oct 12, 2017 at 02:15:27PM +0200, Jan Kara wrote:
> > diff --git a/mm/workingset.c b/mm/workingset.c
> > index 7119cd745ace..a80d52387734 100644
> > --- a/mm/workingset.c
> > +++ b/mm/workingset.c
> > @@ -341,12 +341,6 @@ static struct list_lru shadow_nodes;
> >  
> >  void workingset_update_node(struct radix_tree_node *node, void *private)
> >  {
> > -	struct address_space *mapping = private;
> > -
> > -	/* Only regular page cache has shadow entries */
> > -	if (dax_mapping(mapping) || shmem_mapping(mapping))
> > -		return;
> > -
> 
> Hum, we don't need to pass 'mapping' from call sites then? Either pass NULL
> or just remove the argument completely since nobody needs it anymore...
> Otherwise the patch looks good.
> 

You're right. Initially, I was preserving the signature as it's defined
by radix_tree_update_node_t but the only user is workingset_update_node
so it can be changed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

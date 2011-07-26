Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BCE3E6B016B
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 20:52:18 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p6Q0qDwd019621
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 17:52:13 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by wpaz37.hot.corp.google.com with ESMTP id p6Q0qB5q024997
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 17:52:11 -0700
Received: by pzk33 with SMTP id 33so8047358pzk.8
        for <linux-mm@kvack.org>; Mon, 25 Jul 2011 17:52:11 -0700 (PDT)
Date: Mon, 25 Jul 2011 17:52:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Declare hugetlb_sysfs_add_hstate __meminit
In-Reply-To: <1311635968-10107-1-git-send-email-trenn@suse.de>
Message-ID: <alpine.DEB.2.00.1107251744530.27999@chino.kir.corp.google.com>
References: <1311635968-10107-1-git-send-email-trenn@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Renninger <trenn@suse.de>
Cc: linux-mm@kvack.org, mgorman@novell.com, majordomo@kvack.org

On Tue, 26 Jul 2011, Thomas Renninger wrote:

> Initially found by Mel, I just put this into a patch.
> 
> Signed-off-by: Thomas Renninger <trenn@suse.de>
> Reviewed-by: Mel Gorman <mgorman@novell.com>
> CC: majordomo@kvack.org

Not sure where majordomo@kvack.org comes into this :)

>  mm/hugetlb.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index bfcf153..2c59a0a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1543,9 +1543,10 @@ static struct attribute_group hstate_attr_group = {
>  	.attrs = hstate_attrs,
>  };
>  
> -static int hugetlb_sysfs_add_hstate(struct hstate *h, struct kobject *parent,
> -				    struct kobject **hstate_kobjs,
> -				    struct attribute_group *hstate_attr_group)
> +static int
> +__meminit hugetlb_sysfs_add_hstate(struct hstate *h, struct kobject *parent,
> +				   struct kobject **hstate_kobjs,
> +				   struct attribute_group *hstate_attr_group)
>  {
>  	int retval;
>  	int hi = h - hstates;

I'm looking at this based on the latest git; if this was intended only as 
a fix for -mm, please add that tag to the subject line.

That would be right if hugetlb_register_node() didn't use it or it was 
moved to meminit.text as well, and that would require that register_node() 
was in the same section.

It's a bit tricky to see since hugetlb_register_node() in 
drivers/base/node.c is really calling into hugetlb_register_node() from 
mm/hugetlb.c.

 [ And the drivers/base/node.c function has bool type for CONFIG_HUGETLBFS
   and void for !CONFIG_HUGETLBFS.  It can probably be changed to just be
   void everywhere. ]

So, unless this is a fix for -mm, I don't think this is right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

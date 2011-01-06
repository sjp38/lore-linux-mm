Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0B56B0092
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 15:39:38 -0500 (EST)
Date: Thu, 6 Jan 2011 12:38:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: PATCH: hugetlb: handle NODEMASK_ALLOC failure correctly
Message-Id: <20110106123858.8a585f77.akpm@linux-foundation.org>
In-Reply-To: <20110106100439.GA5774@tiehlicka.suse.cz>
References: <20110104105214.GA10759@tiehlicka.suse.cz>
	<907929848.134962.1294203162923.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
	<20110105084357.GA21349@tiehlicka.suse.cz>
	<20110105125959.c6e3d90a.akpm@linux-foundation.org>
	<20110106100439.GA5774@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: CAI Qian <caiqian@redhat.com>, linux-mm <linux-mm@kvack.org>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Jan 2011 11:04:39 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> NODEMASK_ALLOC can use kmalloc if nodemask_t > 256 bytes so it might
> fail with NULL as a result. Let's check the resulting variable and
> fail with -ENOMEM if NODEMASK_ALLOC failed.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/hugetlb.c |   18 +++++++++++++++---
>  1 files changed, 15 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 4c0606c..21f31b2 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1439,14 +1439,19 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
>  	struct hstate *h;
>  	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
>  
> +	if (!nodes_allowed) {
> +		err = -ENOMEM;
> +		goto out;
> +	}

Looks good to me.  I was going to complain that it adds extra unneeded
instructions in the case where the nodemasks are allocated on the
stack.  But it appears that gcc assumes that stack-based variables
cannot have address zero, so if gcc sees this:

	{
		nodemask_t foo;

		if (!&foo) {
			stuff
		}
	}

if just removes it all for us.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

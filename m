Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 10D8C6B005D
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 20:03:01 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 20 Aug 2012 18:02:59 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 73E993E4003D
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 18:02:49 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7L02WPm113076
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 18:02:33 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7L02Wi5015507
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 18:02:32 -0600
Date: Mon, 20 Aug 2012 17:02:31 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] kmemleak: replace list_for_each_continue_rcu with
 new interface
Message-ID: <20120821000230.GO2435@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <502CB92F.2010700@linux.vnet.ibm.com>
 <502DC99E.4060408@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502DC99E.4060408@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, catalin.marinas@arm.com

On Fri, Aug 17, 2012 at 12:33:34PM +0800, Michael Wang wrote:
> From: Michael Wang <wangyun@linux.vnet.ibm.com>
> 
> This patch replaces list_for_each_continue_rcu() with
> list_for_each_entry_continue_rcu() to save a few lines
> of code and allow removing list_for_each_continue_rcu().
> 
> Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> ---
>  mm/kmemleak.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 45eb621..0de83b4 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -1483,13 +1483,11 @@ static void *kmemleak_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  {
>  	struct kmemleak_object *prev_obj = v;
>  	struct kmemleak_object *next_obj = NULL;
> -	struct list_head *n = &prev_obj->object_list;
> +	struct kmemleak_object *obj = prev_obj;
> 
>  	++(*pos);
> 
> -	list_for_each_continue_rcu(n, &object_list) {
> -		struct kmemleak_object *obj =
> -			list_entry(n, struct kmemleak_object, object_list);
> +	list_for_each_entry_continue_rcu(obj, &object_list, object_list) {
>  		if (get_object(obj)) {
>  			next_obj = obj;
>  			break;
> -- 
> 1.7.4.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 961B56B005D
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 20:53:11 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <wangyun@linux.vnet.ibm.com>;
	Fri, 24 Aug 2012 10:52:41 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7O0qqLC24576114
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 10:52:57 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7O0qq3d011675
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 10:52:52 +1000
Message-ID: <5036D062.7070003@linux.vnet.ibm.com>
Date: Fri, 24 Aug 2012 08:52:50 +0800
From: Michael Wang <wangyun@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] kmemleak: replace list_for_each_continue_rcu with
 new interface
References: <502CB92F.2010700@linux.vnet.ibm.com> <502DC99E.4060408@linux.vnet.ibm.com>
In-Reply-To: <502DC99E.4060408@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: catalin.marinas@arm.com, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>

On 08/17/2012 12:33 PM, Michael Wang wrote:
> From: Michael Wang <wangyun@linux.vnet.ibm.com>
> 
> This patch replaces list_for_each_continue_rcu() with
> list_for_each_entry_continue_rcu() to save a few lines
> of code and allow removing list_for_each_continue_rcu().

Hi, Catalin

Could I get some comments on this patch?

Regards,
Michael Wang

> 
> Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

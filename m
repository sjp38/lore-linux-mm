Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id BD4896B006C
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 12:50:12 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 19 Jun 2012 12:50:09 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 397B038C806F
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 12:49:26 -0400 (EDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5JGnO8G162606
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 12:49:24 -0400
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5JGnI9R026167
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 10:49:18 -0600
Message-ID: <4FE0AD89.6000001@linux.vnet.ibm.com>
Date: Tue, 19 Jun 2012 11:49:13 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/10] cleanup the code between tmem_obj_init and tmem_obj_find
References: <4FE0392E.3090300@linux.vnet.ibm.com> <4FE03A55.7070503@linux.vnet.ibm.com>
In-Reply-To: <4FE03A55.7070503@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

This patch causes a crash, details below.

On 06/19/2012 03:37 AM, Xiao Guangrong wrote:

> tmem_obj_find and insertion tmem-obj have the some logic, we can integrate
> the code
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/tmem.c |   58 +++++++++++++++++++++-------------------
>  1 files changed, 30 insertions(+), 28 deletions(-)
> 
> diff --git a/drivers/staging/zcache/tmem.c b/drivers/staging/zcache/tmem.c
> index 1ca66ea..cdf2d3c 100644
> --- a/drivers/staging/zcache/tmem.c
> +++ b/drivers/staging/zcache/tmem.c
> @@ -72,33 +72,48 @@ void tmem_register_pamops(struct tmem_pamops *m)
>   * the hashbucket lock must be held.
>   */
> 
> -/* searches for object==oid in pool, returns locked object if found */
> -static struct tmem_obj *tmem_obj_find(struct tmem_hashbucket *hb,
> -					struct tmem_oid *oidp)
> +static struct tmem_obj
> +*__tmem_obj_find(struct tmem_hashbucket*hb, struct tmem_oid *oidp,
> +		 struct rb_node *parent, struct rb_node **link)
>  {
> -	struct rb_node *rbnode;
> +	struct rb_node **rbnode;
>  	struct tmem_obj *obj;
> 
> -	rbnode = hb->obj_rb_root.rb_node;
> -	while (rbnode) {
> -		BUG_ON(RB_EMPTY_NODE(rbnode));
> -		obj = rb_entry(rbnode, struct tmem_obj, rb_tree_node);
> +	rbnode = &hb->obj_rb_root.rb_node;
> +	while (*rbnode) {
> +		BUG_ON(RB_EMPTY_NODE(*rbnode));
> +		obj = rb_entry(*rbnode, struct tmem_obj,
> +			       rb_tree_node);
>  		switch (tmem_oid_compare(oidp, &obj->oid)) {
>  		case 0: /* equal */
>  			goto out;
>  		case -1:
> -			rbnode = rbnode->rb_left;
> +			rbnode = &(*rbnode)->rb_left;
>  			break;
>  		case 1:
> -			rbnode = rbnode->rb_right;
> +			rbnode = &(*rbnode)->rb_right;
>  			break;
>  		}
>  	}
> +
> +	if (parent)
> +		parent = &obj->rb_tree_node;
> +	if (link)
> +		link = rbnode;
> +
>  	obj = NULL;
>  out:
>  	return obj;
>  }
> 
> +
> +/* searches for object==oid in pool, returns locked object if found */
> +static struct tmem_obj *tmem_obj_find(struct tmem_hashbucket *hb,
> +					struct tmem_oid *oidp)
> +{
> +	return __tmem_obj_find(hb, oidp, NULL, NULL);
> +}
> +
>  static void tmem_pampd_destroy_all_in_obj(struct tmem_obj *);
> 
>  /* free an object that has no more pampds in it */
> @@ -131,8 +146,7 @@ static void tmem_obj_init(struct tmem_obj *obj, struct tmem_hashbucket *hb,
>  					struct tmem_oid *oidp)
>  {
>  	struct rb_root *root = &hb->obj_rb_root;
> -	struct rb_node **new = &(root->rb_node), *parent = NULL;
> -	struct tmem_obj *this;
> +	struct rb_node **new = NULL, *parent = NULL;
> 
>  	BUG_ON(pool == NULL);
>  	atomic_inc(&pool->obj_count);
> @@ -144,22 +158,10 @@ static void tmem_obj_init(struct tmem_obj *obj, struct tmem_hashbucket *hb,
>  	obj->pampd_count = 0;
>  	(*tmem_pamops.new_obj)(obj);
>  	SET_SENTINEL(obj, OBJ);
> -	while (*new) {
> -		BUG_ON(RB_EMPTY_NODE(*new));
> -		this = rb_entry(*new, struct tmem_obj, rb_tree_node);
> -		parent = *new;
> -		switch (tmem_oid_compare(oidp, &this->oid)) {
> -		case 0:
> -			BUG(); /* already present; should never happen! */
> -			break;
> -		case -1:
> -			new = &(*new)->rb_left;
> -			break;
> -		case 1:
> -			new = &(*new)->rb_right;
> -			break;
> -		}
> -	}
> +
> +	if (__tmem_obj_find(hb, oidp, parent, new))
> +		BUG();
> +
>  	rb_link_node(&obj->rb_tree_node, parent, new);


Getting a NULL deref crash here because new is NULL

[   56.422031] BUG: unable to handle kernel NULL pointer dereference at           (null)
[   56.423008] IP: [<ffffffff812b8ba4>] tmem_put+0x3a4/0x3d0

static inline void rb_link_node(struct rb_node * node, struct rb_node * parent,
				struct rb_node ** rb_link)
{
...
	*rb_link = node;
ffffffff812b8ba4:	48 89 38             	mov    %rdi,(%rax) <--- here
ffffffff812b8ba7:	e8 00 00 00 00       	callq  ffffffff812b8bac <tmem_put+0x3ac>

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

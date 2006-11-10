Message-ID: <45544240.80609@openvz.org>
Date: Fri, 10 Nov 2006 12:11:28 +0300
From: Pavel Emelianov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 6/8] RSS controller shares allocation
References: <20061109193523.21437.86224.sendpatchset@balbir.in.ibm.com> <20061109193619.21437.84173.sendpatchset@balbir.in.ibm.com>
In-Reply-To: <20061109193619.21437.84173.sendpatchset@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@in.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, dev@openvz.org, ckrm-tech@lists.sourceforge.net, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, haveblue@us.ibm.com, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Support shares assignment and propagation.
> 
> Signed-off-by: Balbir Singh <balbir@in.ibm.com>
> ---
> 
>  kernel/res_group/memctlr.c |   59 ++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 58 insertions(+), 1 deletion(-)

[snip]

> +static void recalc_and_propagate(struct memctlr *res, struct memctlr *parres)
> +{
> +	struct resource_group *child = NULL;
> +	int child_divisor;
> +	u64 numerator;
> +	struct memctlr *child_res;
> +
> +	if (parres) {
> +		if (res->shares.max_shares == SHARE_DONT_CARE ||
> +			parres->shares.max_shares == SHARE_DONT_CARE)
> +			return;
> +
> +		child_divisor = parres->shares.child_shares_divisor;
> +		if (child_divisor == 0)
> +			return;
> +
> +		numerator = (u64)(parres->shares.unused_min_shares *
> +				res->shares.max_shares);
> +		do_div(numerator, child_divisor);
> +		numerator = (u64)(parres->nr_pages * numerator);
> +		do_div(numerator, SHARE_DEFAULT_DIVISOR);
> +		res->nr_pages = numerator;
> +	}
> +
> +	for_each_child(child, res->rgroup) {
> +		child_res = get_memctlr(child);
> +		BUG_ON(!child_res);
> +		recalc_and_propagate(child_res, res);

Recursion? Won't it eat all the stack in case of a deep tree?

> +	}
> +
> +}
> +
> +static void memctlr_shares_changed(struct res_shares *shares)
> +{
> +	struct memctlr *res, *parres;
> +
> +	res = get_memctlr_from_shares(shares);
> +	if (!res)
> +		return;
> +
> +	if (is_res_group_root(res->rgroup))
> +		parres = NULL;
> +	else
> +		parres = get_memctlr((struct container *)res->rgroup->parent);
> +
> +	recalc_and_propagate(res, parres);
> +}
> +
>  struct res_controller memctlr_rg = {
>  	.name = res_ctlr_name,
>  	.ctlr_id = NO_RES_ID,
>  	.alloc_shares_struct = memctlr_alloc_instance,
>  	.free_shares_struct = memctlr_free_instance,
>  	.move_task = memctlr_move_task,
> -	.shares_changed = NULL,
> +	.shares_changed = memctlr_shares_changed,

I didn't find where in this patches this callback is called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

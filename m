Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id B18716B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 02:35:11 -0400 (EDT)
Message-ID: <519B1641.1020906@cn.fujitsu.com>
Date: Tue, 21 May 2013 14:37:53 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2 v2, RFC] Driver core: Introduce offline/online callbacks
 for memory blocks
References: <1576321.HU0tZ4cGWk@vostro.rjw.lan> <1583356.7oqZ7gBy2q@vostro.rjw.lan> <2376818.CRj1BTLk0Y@vostro.rjw.lan> <19540491.PRsM4lKIYM@vostro.rjw.lan>
In-Reply-To: <19540491.PRsM4lKIYM@vostro.rjw.lan>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Toshi Kani <toshi.kani@hp.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, isimatu.yasuaki@jp.fujitsu.com, vasilis.liaskovitis@profitbricks.com, Len Brown <lenb@kernel.org>, linux-mm@kvack.org

Hi Rafael,

Please see below.

On 05/04/2013 07:21 PM, Rafael J. Wysocki wrote:
......
>   static BLOCKING_NOTIFIER_HEAD(memory_chain);
> @@ -278,33 +283,64 @@ static int __memory_block_change_state(s
>   {
>   	int ret = 0;
>
> -	if (mem->state != from_state_req) {
> -		ret = -EINVAL;
> -		goto out;
> -	}
> +	if (mem->state != from_state_req)
> +		return -EINVAL;
>
>   	if (to_state == MEM_OFFLINE)
>   		mem->state = MEM_GOING_OFFLINE;
>
>   	ret = memory_block_action(mem->start_section_nr, to_state, online_type);
> -
>   	if (ret) {
>   		mem->state = from_state_req;
> -		goto out;
> +	} else {
> +		mem->state = to_state;
> +		if (to_state == MEM_ONLINE)
> +			mem->last_online = online_type;

Why do we need to remember last online type ?

And as far as I know, we can obtain which zone a page was in last time it
was onlined by check page->flags, just like online_pages() does. If we
use online_kernel or online_movable, the zone boundary will be 
recalculated.
So we don't need to remember the last online type.

Seeing from your patch, I guess memory_subsys_online() can only handle
online and offline. So mem->last_online is used to remember what user has
done through the original way to trigger memory hot-remove, right ? And 
when
user does it in this new way, it just does the same thing as user does last
time.

But I still think we don't need to remember it because if finally you call
online_pages(), it just does the same thing as last time by default.

online_pages()
{
	......
	if (online_type == ONLINE_KERNEL ......

	if (online_type == ONLINE_MOVABLE......

	zone = page_zone(pfn_to_page(pfn));

	/* Here, the page will be put into the zone which it belong to last 
time. */

	......
}

I just thought of it. Maybe I missed something in your design. Please tell
me if I'm wrong.

Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>

Thanks. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

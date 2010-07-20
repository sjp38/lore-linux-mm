Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 49AD26B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 03:06:16 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6K76CwN019312
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Jul 2010 16:06:13 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C71A45DE4F
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:06:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 18E9545DE51
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:06:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CC4781DB803B
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:06:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BF9E1DB8040
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:06:11 +0900 (JST)
Date: Tue, 20 Jul 2010 16:01:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/8] v3 Add section count to memory_block
Message-Id: <20100720160131.7cc8c0a2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4C451DD6.3080005@austin.ibm.com>
References: <4C451BF5.50304@austin.ibm.com>
	<4C451DD6.3080005@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, greg@kroah.com
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jul 2010 22:53:58 -0500
Nathan Fontenot <nfont@austin.ibm.com> wrote:

> Add a section count property to the memory_block struct to track the number
> of memory sections that have been added/removed from a emory block.
> 
> Signed-off-by: Nathan Fontenot <nfont@asutin.ibm.com>
> ---
>  drivers/base/memory.c  |   19 ++++++++++++-------
>  include/linux/memory.h |    2 ++
>  2 files changed, 14 insertions(+), 7 deletions(-)
> 
> Index: linux-2.6/drivers/base/memory.c
> ===================================================================
> --- linux-2.6.orig/drivers/base/memory.c	2010-07-19 20:43:49.000000000 -0500
> +++ linux-2.6/drivers/base/memory.c	2010-07-19 20:44:01.000000000 -0500
> @@ -487,6 +487,7 @@ static int add_memory_block(int nid, str
>  
>  	mem->start_phys_index = __section_nr(section);
>  	mem->state = state;
> +	atomic_inc(&mem->section_count);
>  	mutex_init(&mem->state_mutex);
>  	start_pfn = section_nr_to_pfn(mem->start_phys_index);
>  	mem->phys_device = arch_get_memory_phys_device(start_pfn);
> @@ -516,13 +517,17 @@ int remove_memory_block(unsigned long no
>  	struct memory_block *mem;
>  
>  	mem = find_memory_block(section);
> -	unregister_mem_sect_under_nodes(mem);
> -	mem_remove_simple_file(mem, start_phys_index);
> -	mem_remove_simple_file(mem, end_phys_index);
> -	mem_remove_simple_file(mem, state);
> -	mem_remove_simple_file(mem, phys_device);
> -	mem_remove_simple_file(mem, removable);
> -	unregister_memory(mem, section);
> +	atomic_dec(&mem->section_count);
> +
> +	if (atomic_read(&mem->section_count) == 0) {

We use atomic_dec_and_test() in usual.

Otherwise, I don't see other problems in other part. Please fix this nitpick.

Regards,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

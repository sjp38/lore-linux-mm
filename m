Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD296B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 15:17:56 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6KJHAcx004703
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 15:17:10 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6KJI4Yi277870
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 15:18:04 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6KJI3pF000653
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 15:18:04 -0400
Subject: Re: [PATCH 4/8] v3 Allow memory_block to span multiple memory
 sections
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C451E1C.8070907@austin.ibm.com>
References: <4C451BF5.50304@austin.ibm.com>
	 <4C451E1C.8070907@austin.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 20 Jul 2010 12:18:01 -0700
Message-ID: <1279653481.9785.4.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, greg@kroah.com
List-ID: <linux-mm.kvack.org>

On Mon, 2010-07-19 at 22:55 -0500, Nathan Fontenot wrote:
> +static int add_memory_section(int nid, struct mem_section *section,
> +                       unsigned long state, enum mem_add_context context)
> +{
> +       struct memory_block *mem;
> +       int ret = 0;
> +
> +       mem = find_memory_block(section);
> +       if (mem) {
> +               atomic_inc(&mem->section_count);
> +               kobject_put(&mem->sysdev.kobj);
> +       } else
> +               ret = init_memory_block(&mem, section, state);
> +
>         if (!ret) {
> -               if (context == HOTPLUG)
> +               if (context == HOTPLUG &&
> +                   atomic_read(&mem->section_count) == sections_per_block)
>                         ret = register_mem_sect_under_node(mem, nid);
>         } 

I think the atomic_inc() can race with the atomic_dec_and_test() in
remove_memory_block().

Thread 1 does:

	mem = find_memory_block(section);

Thread 2 does 

	atomic_dec_and_test(&mem->section_count);

and destroys the memory block,  Thread 1 runs again:
	
       if (mem) {
               atomic_inc(&mem->section_count);
               kobject_put(&mem->sysdev.kobj);
       } else

but now mem got destroyed by Thread 2.  You probably need to change
find_memory_block() to itself take a reference, and to use
atomic_inc_unless().

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

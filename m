Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 5637F6B015F
	for <linux-mm@kvack.org>; Wed, 29 May 2013 14:45:13 -0400 (EDT)
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id r4TIj79D016532
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 May 2013 20:45:08 +0200
Received: from mail2.itwm.fhg.de ([131.246.191.79]:59990)
	by itwm2.itwm.fhg.de with esmtps (TLSv1:DES-CBC3-SHA:168)
	(/C=DE/ST=Rheinland-Pfalz/L=Kaiserslautern/O=Fraunhofer ITWM/OU=SLG/CN=mail2.itwm.fhg.de)(verified=1)
	 (Exim 4.74 #1)
	id 1UhlMx-0004yM-1B
	for linux-mm@kvack.org; Wed, 29 May 2013 20:45:07 +0200
Message-ID: <51A64CB2.9070503@itwm.fraunhofer.de>
Date: Wed, 29 May 2013 20:45:06 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
Subject: spin_lock contention in shrink_inactive_list
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi all,

we got a report about a system where fhgfs has a rather high latency 
(fhgfs is running on top of xfs) and while investigating the system I 
noticed that the system was rather cpu bound.
I'm not sure, but somehow CPU usage went down after disabling swap.
Is the lock contention a known issue?

kernel version: 3.8.2


> spin_lock

> # Overhead          Command                                                                                  Shared Object                                                                                                                          Symbol
> # ........  ...............  .............................................................................................  ..............................................................................................................................
> #
>     63.93%  fhgfs-storage/M  [kernel.kallsyms]                                                                              0xffffffff815d31bd k [k] _raw_spin_lock_irq
>             |
>             --- _raw_spin_lock_irq
>                |
>                |--99.44%-- shrink_inactive_list
>                |          shrink_lruvec
>                |          shrink_zone
>                |          shrink_zones
>                |          do_try_to_free_pages
>                |          try_to_free_pages
>                |          __alloc_pages_slowpath
>                |          __alloc_pages_nodemask
>                |          |
>                |          |--99.98%-- alloc_pages_current
>                |          |          |
>                |          |          |--100.00%-- __page_cache_alloc
>                |          |          |          |
>                |          |          |          |--100.00%-- grab_cache_page_write_begin
>                |          |          |          |          xfs_vm_write_begin
>                |          |          |          |          generic_perform_write
>                |          |          |          |          generic_file_buffered_write
>                |          |          |          |          xfs_file_buffered_aio_write
>                |          |          |          |          xfs_file_aio_write
>                |          |          |          |          do_sync_write
>                |          |          |          |          vfs_write
>                |          |          |          |          sys_write
>                |          |          |          |          system_call_fastpath
>                |          |          |          |          0x2aaaaba8f4ed
>                |          |          |           --0.00%-- [...]
>                |          |           --0.00%-- [...]
>                |           --0.02%-- [...]
>                 --0.56%-- [...]
>
>      3.73%  fhgfs-storage/M  [kernel.kallsyms]                                                                              0xffffffff815d3533 k [k] _raw_spin_lock_irqsave
>             |
>             --- _raw_spin_lock_irqsave
>                |
>                |--97.82%-- pagevec_lru_move_fn
>                |          |
>                |          |--91.28%-- __pagevec_lru_add
>                |          |          |
>                |          |          |--86.17%-- __lru_cache_add
>                |          |          |          add_to_page_cache_lru
>                |          |          |          grab_cache_page_write_begin
>                |          |          |          xfs_vm_write_begin
>                |          |          |          generic_perform_write
>                |          |          |          generic_file_buffered_write
>                |          |          |          xfs_file_buffered_aio_write
>                |          |          |          xfs_file_aio_write
>                |          |          |          do_sync_write
>                |          |          |          vfs_write


Thanks,
Bernd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

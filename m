Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8318D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 17:19:03 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p3KLJ0AL021613
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 14:19:00 -0700
Received: from pvg11 (pvg11.prod.google.com [10.241.210.139])
	by kpbe20.cbf.corp.google.com with ESMTP id p3KLIuu3008011
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 14:18:58 -0700
Received: by pvg11 with SMTP id 11so864072pvg.27
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 14:18:56 -0700 (PDT)
Date: Wed, 20 Apr 2011 14:18:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <1303317178.2587.30.camel@mulgrave.site>
Message-ID: <alpine.DEB.2.00.1104201410350.31768@chino.kir.corp.google.com>
References: <20110420161615.462D.A69D9226@jp.fujitsu.com> <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com> <20110420174027.4631.A69D9226@jp.fujitsu.com> <1303317178.2587.30.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

On Wed, 20 Apr 2011, James Bottomley wrote:

> [    0.200000] Backtrace:
> [    0.200000]  [<000000004021c938>] add_partial+0x28/0x98
> [    0.200000]  [<000000004021faa0>] __slab_free+0x1d0/0x1d8
> [    0.200000]  [<000000004021fd04>] kmem_cache_free+0xc4/0x128
> [    0.200000]  [<000000004033bf9c>] ida_get_new_above+0x21c/0x2c0
> [    0.200000]  [<00000000402a8980>] sysfs_new_dirent+0xd0/0x238
> [    0.200000]  [<00000000402a974c>] create_dir+0x5c/0x168
> [    0.200000]  [<00000000402a9ab0>] sysfs_create_dir+0x98/0x128
> [    0.200000]  [<000000004033d6c4>] kobject_add_internal+0x114/0x258
> [    0.200000]  [<000000004033d9ac>] kobject_add_varg+0x7c/0xa0
> [    0.200000]  [<000000004033df20>] kobject_add+0x50/0x90
> [    0.200000]  [<000000004033dfb4>] kobject_create_and_add+0x54/0xc8
> [    0.200000]  [<00000000407862a0>] cgroup_init+0x138/0x1f0
> [    0.200000]  [<000000004077ce50>] start_kernel+0x5a0/0x840
> [    0.200000]  [<000000004011fa3c>] start_parisc+0xa4/0xb8
> [    0.200000]  [<00000000404bb034>] packet_ioctl+0x16c/0x208
> [    0.200000]  [<000000004049ac30>] ip_mroute_setsockopt+0x260/0xf20
> [    0.200000] 

This is probably because the parisc's DISCONTIGMEM memory ranges don't 
have bits set in N_NORMAL_MEMORY.

diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -266,8 +266,10 @@ static void __init setup_bootmem(void)
 	}
 	memset(pfnnid_map, 0xff, sizeof(pfnnid_map));
 
-	for (i = 0; i < npmem_ranges; i++)
+	for (i = 0; i < npmem_ranges; i++) {
+		node_set_state(i, N_NORMAL_MEMORY);
 		node_set_online(i);
+	}
 #endif
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

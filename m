Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 64A656B0012
	for <linux-mm@kvack.org>; Wed, 18 May 2011 14:25:59 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p4IIPplM017696
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:25:51 -0700
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by hpaq3.eem.corp.google.com with ESMTP id p4IIPmJW025620
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:25:49 -0700
Received: by pvc21 with SMTP id 21so1202664pvc.11
        for <linux-mm@kvack.org>; Wed, 18 May 2011 11:25:47 -0700 (PDT)
Date: Wed, 18 May 2011 11:25:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH mmotm] add the pagefault count into memcg stats: shmem
 fix
In-Reply-To: <20110518144349.a44ae926.nishimura@mxp.nes.nec.co.jp>
Message-ID: <alpine.LSU.2.00.1105181102050.4087@sister.anvils>
References: <alpine.LSU.2.00.1105171120220.29593@sister.anvils> <20110518144349.a44ae926.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org

On Wed, 18 May 2011, Daisuke Nishimura wrote:
> On Tue, 17 May 2011 11:24:40 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > mem_cgroup_count_vm_event() should update the PGMAJFAULT count for the
> > target mm, not for current mm (but of course they're usually the same).
> > 
> hmm, why ?
> In shmem_getpage(), we charge the page to the memcg where current mm belongs to,

(In the case when it's this fault which is creating the page.
Just as when filemap_fault() reads in the page, add_to_page_cache
will charge it to the current->mm's memcg, yes.  Arguably correct.)

> so I think counting vm events of the memcg is right.

It should be consistent with which task gets the maj_flt++, and
it should be consistent with filemap_fault(), and it should be a
subset of what's counted by mem_cgroup_count_vm_event(mm, PGFAULT).

In each case, those work on target mm rather than current->mm.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

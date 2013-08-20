Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 64EB66B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 19:29:06 -0400 (EDT)
Date: Tue, 20 Aug 2013 16:29:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/backing-dev.c: check user buffer length before copy
 data to the related user buffer.
Message-Id: <20130820162903.d5caeda1a6f119a5967a13a2@linux-foundation.org>
In-Reply-To: <5212E12C.5010005@asianux.com>
References: <5212E12C.5010005@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, jmoyer@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org

On Tue, 20 Aug 2013 11:23:24 +0800 Chen Gang <gang.chen@asianux.com> wrote:

> '*lenp' may be less than "sizeof(kbuf)", need check it before the next
> copy_to_user().
> 
> pdflush_proc_obsolete() is called by sysctl which 'procname' is
> "nr_pdflush_threads", if the user passes buffer length less than
> "sizeof(kbuf)", it will cause issue.
> 
> ...
>
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -649,7 +649,7 @@ int pdflush_proc_obsolete(struct ctl_table *table, int write,
>  {
>  	char kbuf[] = "0\n";
>  
> -	if (*ppos) {
> +	if (*ppos || *lenp < sizeof(kbuf)) {
>  		*lenp = 0;
>  		return 0;
>  	}

Well sort-of.  If userspace opens /proc/sys/vm/nr_pdflush_threads and
then does a series of one-byte reads, the kernel should return "0" on the
first read, "\n" on the second and then EOF.

However this usually doesn't work in /proc anyway :(

akpm3:/tmp> cat /proc/sys/vm/max_map_count         
65530
akpm3:/tmp> dd if=/proc/sys/vm/max_map_count of=foo bs=1
1+0 records in
1+0 records out
1 byte (1 B) copied, 0.00011963 s, 8.4 kB/s
akpm3:/tmp> wc foo
0 1 1 foo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

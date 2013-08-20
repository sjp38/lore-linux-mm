Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 9F28C6B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 11:28:21 -0400 (EDT)
Date: Tue, 20 Aug 2013 17:28:09 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm/backing-dev.c: check user buffer length before copy
 data to the related user buffer.
Message-ID: <20130820152809.GB2862@quack.suse.cz>
References: <5212E12C.5010005@asianux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5212E12C.5010005@asianux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, jmoyer@redhat.com, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue 20-08-13 11:23:24, Chen Gang wrote:
> '*lenp' may be less than "sizeof(kbuf)", need check it before the next
> copy_to_user().
> 
> pdflush_proc_obsolete() is called by sysctl which 'procname' is
> "nr_pdflush_threads", if the user passes buffer length less than
> "sizeof(kbuf)", it will cause issue.
> 
  Good catch. The patch looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  mm/backing-dev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index e04454c..2674671 100644
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
> -- 
> 1.7.7.6
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

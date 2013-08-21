Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 3D4716B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 23:46:04 -0400 (EDT)
Date: Tue, 20 Aug 2013 20:45:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/backing-dev.c: check user buffer length before copy
 data to the related user buffer.
Message-Id: <20130820204550.356e13b5.akpm@linux-foundation.org>
In-Reply-To: <52143568.30708@asianux.com>
References: <5212E12C.5010005@asianux.com>
	<20130820162903.d5caeda1a6f119a5967a13a2@linux-foundation.org>
	<52143568.30708@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, jmoyer@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org

On Wed, 21 Aug 2013 11:35:04 +0800 Chen Gang <gang.chen@asianux.com> wrote:

> On 08/21/2013 07:29 AM, Andrew Morton wrote:
> > On Tue, 20 Aug 2013 11:23:24 +0800 Chen Gang <gang.chen@asianux.com> wrote:
> > 
> >> '*lenp' may be less than "sizeof(kbuf)", need check it before the next
> >> copy_to_user().
> >>
> >> pdflush_proc_obsolete() is called by sysctl which 'procname' is
> >> "nr_pdflush_threads", if the user passes buffer length less than
> >> "sizeof(kbuf)", it will cause issue.
> >>
> >> ...
> >>
> >> --- a/mm/backing-dev.c
> >> +++ b/mm/backing-dev.c
> >> @@ -649,7 +649,7 @@ int pdflush_proc_obsolete(struct ctl_table *table, int write,
> >>  {
> >>  	char kbuf[] = "0\n";
> >>  
> >> -	if (*ppos) {
> >> +	if (*ppos || *lenp < sizeof(kbuf)) {
> >>  		*lenp = 0;
> >>  		return 0;
> >>  	}
> > 
> > Well sort-of.  If userspace opens /proc/sys/vm/nr_pdflush_threads and
> > then does a series of one-byte reads, the kernel should return "0" on the
> > first read, "\n" on the second and then EOF.
> > 
> 
> Excuse me for my English, I guess your meaning is
> 
>   "this patch is OK, but can be improvement"
> 
> Is it correct ?

Not really.  I was pointing out that the patched code doesn't correctly
implement read(1) behavior.  But that is true of many other procfs
files, so I suggest we not attempt to address the problem for this
procfs file.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

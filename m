Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 6A51D6B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 12:05:01 -0400 (EDT)
Date: Tue, 10 Apr 2012 18:04:57 +0200
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: [PATCH] mm: sync rss-counters at the end of exit_mm()
Message-ID: <20120410160457.GA346@x4>
References: <20120409200336.8368.63793.stgit@zurg>
 <CAHGf_=oWj-hz-E5ht8-hUbQKdsZ1bzP80n987kGYnFm8BpXBVQ@mail.gmail.com>
 <alpine.LSU.2.00.1204091433380.1859@eggly.anvils>
 <4F83D470.6010207@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F83D470.6010207@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 2012.04.10 at 10:34 +0400, Konstantin Khlebnikov wrote:
> Hugh Dickins wrote:
> > On Mon, 9 Apr 2012, KOSAKI Motohiro wrote:
> >> On Mon, Apr 9, 2012 at 4:03 PM, Konstantin Khlebnikov
> >> <khlebnikov@openvz.org>  wrote:
> >>> On task's exit do_exit() calls sync_mm_rss() but this is not enough,
> >>> there can be page-faults after this point, for example exit_mm() ->
> >>> mm_release() ->  put_user() (for processing tsk->clear_child_tid).
> >>> Thus there may be some rss-counters delta in current->rss_stat.
> >>
> >> Seems reasonable.
> >
> > Yes, I think Konstantin has probably caught it;
> > but I'd like to hear confirmation from Markus.
> 
> There is another bug in exec_mmap()
> 
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -823,8 +823,8 @@ static int exec_mmap(struct mm_struct *mm)
>          /* Notify parent that we're no longer interested in the old VM */
>          tsk = current;
>          old_mm = current->mm;
> -       sync_mm_rss(old_mm);
>          mm_release(tsk, old_mm);
> +       sync_mm_rss(old_mm);
> 
>          if (old_mm) {
>                  /*

FWIW with both patches applied I cannot reproduce the issue anymore.

Thanks.

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

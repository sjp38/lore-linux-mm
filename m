Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 3B3866B004A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 20:35:54 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 67B883EE0BD
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:35:52 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FE2045DEA6
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:35:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3531E45DEB2
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:35:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 297F61DB8038
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:35:52 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D8C2D1DB8040
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:35:51 +0900 (JST)
Message-ID: <4F837FE2.7010805@jp.fujitsu.com>
Date: Tue, 10 Apr 2012 09:33:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: sync rss-counters at the end of exit_mm()
References: <20120409200336.8368.63793.stgit@zurg> <CAHGf_=oWj-hz-E5ht8-hUbQKdsZ1bzP80n987kGYnFm8BpXBVQ@mail.gmail.com> <alpine.LSU.2.00.1204091433380.1859@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1204091433380.1859@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Markus Trippelsdorf <markus@trippelsdorf.de>

(2012/04/10 7:03), Hugh Dickins wrote:

> On Mon, 9 Apr 2012, KOSAKI Motohiro wrote:
>> On Mon, Apr 9, 2012 at 4:03 PM, Konstantin Khlebnikov
>> <khlebnikov@openvz.org> wrote:
>>> On task's exit do_exit() calls sync_mm_rss() but this is not enough,
>>> there can be page-faults after this point, for example exit_mm() ->
>>> mm_release() -> put_user() (for processing tsk->clear_child_tid).
>>> Thus there may be some rss-counters delta in current->rss_stat.
>>
>> Seems reasonable.
> 
> Yes, I think Konstantin has probably caught it;
> but I'd like to hear confirmation from Markus.
> 
>> but I have another question. Do we have any reason to
>> keep sync_mm_rss() in do_exit()? I havn't seen any reason that thread exiting
>> makes rss consistency.
> 
> IIRC it's all about the hiwater_rss/maxrss stuff: we want to sync the
> maximum rss into mm->hiwater_rss before it's transferred to signal->maxrss,
> and later made visible to the user though getrusage(RUSAGE_CHILDREN,) -
> does your reading confirm that?
> 


IIRC, sync_mm_rss() in do_exit() is for synchronizing rsscounter for taskacct.
mm->maxrss is sent to listener by xacct_add_tsk(). It's needed to be
synchronized before taskstat_exit()..

Hm, but, exit_mm() is placed after taskstat_exit().

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

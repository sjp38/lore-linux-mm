Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id EDF829000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:58:24 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7BC773EE0C5
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:58:21 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6181B45DE9E
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:58:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 31F1B45DEAD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:58:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 272811DB8037
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:58:21 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E5CB01DB8038
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:58:20 +0900 (JST)
Message-ID: <4E8271C5.3080500@jp.fujitsu.com>
Date: Wed, 28 Sep 2011 10:00:53 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: remove sysctl to manually rescue unevictable pages
References: <1316948380-1879-1-git-send-email-consul.kautuk@gmail.com> <20110926112944.GC14333@redhat.com>
In-Reply-To: <20110926112944.GC14333@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jweiner@redhat.com
Cc: consul.kautuk@gmail.com, akpm@linux-foundation.org, mel@csn.ul.ie, minchan.kim@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com

(2011/09/26 20:29), Johannes Weiner wrote:
> On Sun, Sep 25, 2011 at 04:29:40PM +0530, Kautuk Consul wrote:
>> write_scan_unavictable_node checks the value req returned by
>> strict_strtoul and returns 1 if req is 0.
>>
>> However, when strict_strtoul returns 0, it means successful conversion
>> of buf to unsigned long.
>>
>> Due to this, the function was not proceeding to scan the zones for
>> unevictable pages even though we write a valid value to the 
>> scan_unevictable_pages sys file.
> 
> Given that there is not a real reason for this knob (anymore) and that
> it apparently never really worked since the day it was introduced, how
> about we just drop all that code instead?
> 
> 	Hannes
> 
> ---
> From: Johannes Weiner <jweiner@redhat.com>
> Subject: mm: remove sysctl to manually rescue unevictable pages
> 
> At one point, anonymous pages were supposed to go on the unevictable
> list when no swap space was configured, and the idea was to manually
> rescue those pages after adding swap and making them evictable again.
> But nowadays, swap-backed pages on the anon LRU list are not scanned
> without available swap space anyway, so there is no point in moving
> them to a separate list anymore.
> 
> The manual rescue could also be used in case pages were stranded on
> the unevictable list due to race conditions.  But the code has been
> around for a while now and newly discovered bugs should be properly
> reported and dealt with instead of relying on such a manual fixup.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

About three years ago when we introduced unevictable pages feature,
we were worry about there are mlock, shmmem-lock abuse in the real
world and we broke such assumption. And we expected this knob help
to dig unevictable pages bug report. Briefly says, If this knob works
meangfully, our unevictable handling code or their driver code are buggy.

Fortunately, Such bug report was never happen. So, this knob finished
the role.

    Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

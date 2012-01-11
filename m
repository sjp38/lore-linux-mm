Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 2FA6A6B005C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 03:42:47 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 485483EE0BB
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 17:42:45 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EB1745DE55
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 17:42:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BD4B45DE4E
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 17:42:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F0DB51DB8041
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 17:42:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A9AFF1DB803E
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 17:42:44 +0900 (JST)
Date: Wed, 11 Jan 2012 17:41:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm: adjust rss counters for migration entiries
Message-Id: <20120111174126.f35e708a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F0D46EF.4060705@openvz.org>
References: <20120106173827.11700.74305.stgit@zurg>
	<20120106173856.11700.98858.stgit@zurg>
	<20120111144125.0c61f35f.kamezawa.hiroyu@jp.fujitsu.com>
	<4F0D46EF.4060705@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 11 Jan 2012 12:23:11 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Fri, 06 Jan 2012 21:38:56 +0400
> > Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
> >
> >> Memory migration fill pte with migration entry and it didn't update rss counters.
> >> Then it replace migration entry with new page (or old one if migration was failed).
> >> But between this two passes this pte can be unmaped, or task can fork child and
> >> it will get copy of this migration entry. Nobody account this into rss counters.
> >>
> >> This patch properly adjust rss counters for migration entries in zap_pte_range()
> >> and copy_one_pte(). Thus we avoid extra atomic operations on migration fast-path.
> >>
> >> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> >
> > It's better to show wheter this is a bug-fix or not in changelog.
> >
> > IIUC, the bug-fix is the 1st harf of this patch + patch [2/3].
> > Your new bug-check code is in patch[1/3] and 2nd half of this patch.
> >
> 
> No, there only one new bug-check in 1st patch, this is non-fatal warning.
> I didn't hide this check under CONFIG_VM_DEBUG because it rather small and
> rss counters covers whole page-table management, this is very good invariant.
> Currently I can trigger this warning only on this rare race -- extremely loaded
> memory compaction catches this every several seconds.
> 
> 1/3 bug-check
> 2/3 fix preparation
> 3/3 bugfix in two places:
>      do rss++ in copy_one_pte()
>      do rss-- in zap_pte_range()
> 

Hmm, ok, I read wrong.

So, I think you should post the patch with [BUGFIX] and
report 'what happens' and 'what is the bug' , 'what you fixed' explicitly.

As...
==
  This patch series fixes per-mm rss counter accounting bug. When pages are
  heavily migrated, the rss counters will go wrong by fork() and unmap()
  because they ignores migration_pte_entries.
  This rarelly happens but will make rss counter incorrect.

  This seires of patches will fix the issue by adding proper accounting of
  migration_pte_entries in unmap() and fork(). This series includes
  bug check code, too.
==

If [BUGFIX], people will have more interests.

Anyway, thank you for bugfix.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

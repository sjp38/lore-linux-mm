Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 364356B005C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 03:23:16 -0500 (EST)
Received: by bkuw5 with SMTP id w5so451663bku.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 00:23:14 -0800 (PST)
Message-ID: <4F0D46EF.4060705@openvz.org>
Date: Wed, 11 Jan 2012 12:23:11 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: adjust rss counters for migration entiries
References: <20120106173827.11700.74305.stgit@zurg>	<20120106173856.11700.98858.stgit@zurg> <20120111144125.0c61f35f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120111144125.0c61f35f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 06 Jan 2012 21:38:56 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> Memory migration fill pte with migration entry and it didn't update rss counters.
>> Then it replace migration entry with new page (or old one if migration was failed).
>> But between this two passes this pte can be unmaped, or task can fork child and
>> it will get copy of this migration entry. Nobody account this into rss counters.
>>
>> This patch properly adjust rss counters for migration entries in zap_pte_range()
>> and copy_one_pte(). Thus we avoid extra atomic operations on migration fast-path.
>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>
> It's better to show wheter this is a bug-fix or not in changelog.
>
> IIUC, the bug-fix is the 1st harf of this patch + patch [2/3].
> Your new bug-check code is in patch[1/3] and 2nd half of this patch.
>

No, there only one new bug-check in 1st patch, this is non-fatal warning.
I didn't hide this check under CONFIG_VM_DEBUG because it rather small and
rss counters covers whole page-table management, this is very good invariant.
Currently I can trigger this warning only on this rare race -- extremely loaded
memory compaction catches this every several seconds.

1/3 bug-check
2/3 fix preparation
3/3 bugfix in two places:
     do rss++ in copy_one_pte()
     do rss-- in zap_pte_range()

> I think it's better to do bug-fix 1st and add bug-check later.
>
> So, could you reorder patches to bug-fix and new-bug-check ?

Patches didn't share any context, so they can be applied in any order.

>
> To the logic itself,
> Acked-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Please CC when you repost.
>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

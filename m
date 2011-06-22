Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1143F90016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 07:08:03 -0400 (EDT)
Message-ID: <4E01CCED.5050609@redhat.com>
Date: Wed, 22 Jun 2011 19:07:25 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/4] mm: make the threshold of enabling THP configurable
References: <1308643849-3325-1-git-send-email-amwang@redhat.com> <1308643849-3325-2-git-send-email-amwang@redhat.com> <alpine.DEB.2.00.1106211817340.5205@chino.kir.corp.google.com> <4E015C36.2050005@redhat.com> <alpine.DEB.2.00.1106212024210.8712@chino.kir.corp.google.com> <4E018060.3050607@redhat.com> <alpine.DEB.2.00.1106212325400.14693@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1106212325400.14693@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, dave@linux.vnet.ibm.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??22ae?JPY 14:32, David Rientjes a??e??:
> On Wed, 22 Jun 2011, Cong Wang wrote:
>
>>> Either way, this patch isn't needed since it has no benefit over doing it
>>> through an init script.
>>
>> If you were right, CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not needed,
>> you can do it through an init script.
>>
>
> They are really two different things: config options like
> CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS and CONFIG_SLUB_DEBUG_ON are shortcuts
> for command line options when you want the _default_ behavior to be
> specified.  They could easily be done on the command line just as they can
> be done in the config.  They typically have far reaching consequences
> depending on whether they are enabled or disabled and warrant the entry in
> the config file.
>
> This patch, however, is not making the heuristic any easier to work with;
> in fact, if the default were ever changed or the value is changed on your
> kernel, then certain kernels will have THP enabled by default and others
> will not.  That's why I suggested an override command line option like
> transparent_hugepage=force to ignore any disabling heursitics either
> present or future.

Actually, if we move this out of kernel, to user-space, everything
you worried will be solved by just changing the user-space code.
Just add the following pseudo code into your init script,

if [ $total_memory -lt 512 ]
then
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi

BTW, "=force" makes people confused with "=always", like "=never"
actually means "=disabled".

>
>> If you were right, the 512M limit is not needed neither, you have
>> transparent_hugepage=never boot parameter and do the check of
>> 512M later in an init script. (Actually, moving the 512M check to
>> user-space is really more sane to me.)
>>
>
> It's quite obvious that the default behavior intended by the author is
> that it is defaulted off for systems with less than 512M of memory.
> Obfuscating that probably isn't a very good idea, but I'm always in favor
> of command lines that allow users to override settings when they really do
> know better.

The better way to express this is to add one line in Kconfig help said
"Please set CONFIG_THP_NEVER=y when you have less than 512M memory",
rather than enforcing a decision in code.

 From either aspect, I don't think the current 512M check code in kernel
is a good thing.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

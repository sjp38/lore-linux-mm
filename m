Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE116B0011
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 11:07:50 -0400 (EDT)
Received: by vxk20 with SMTP id 20so5906468vxk.14
        for <linux-mm@kvack.org>; Wed, 01 Jun 2011 08:07:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com>
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com>
	<BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com>
Date: Wed, 1 Jun 2011 19:07:48 +0400
Message-ID: <BANLkTikrRRzGLbMD47_xJz+xpgftCm1C2A@mail.gmail.com>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 6/1/11, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 2011/6/1 Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>:
>> Please be more polite to other people. After a197b59ae6 all allocations
>> with GFP_DMA set on nodes without ZONE_DMA fail nearly silently (only
>> one warning during bootup is emited, no matter how many things fail).
>> This is a very crude change on behaviour. To be more civil, instead of
>> failing emit noisy warnings each time smbd. tries to allocate a GFP_DMA
>> memory on non-ZONE_DMA node.
>>
>> This change should be reverted after one or two major releases, but
>> we should be more accurate rather than hoping for the best.
>>
>> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>
> Instaed of, shouldn't we revert a197b59ae6? Some arch don't have
> DMA_ZONE at all.
> and a197b59ae6 only care x86 embedded case. If we accept your patch, I
> can imagine
> other people will claim warn foold is a bug. ;)

I think that argument from a197b59ae6 is correct. Allocating with GFP_DMA
should fail if there is no ZONE_DMA. On the other hand linux/gfp.h clearly
specifies: "...Ignored on some platforms, used as appropriate on others".

So it's up to mm gurus to decide which way is correct. I'd be happy as long
as we don't have such nasty change of behaviour.

> However, I think, you should explain which platform and drivers hit
> this breakage.
> Otherwise developers can't learn which platform should care.

I've hit this with IrDA driver on PXA. Also I've seen the report regarding
other ARM platform (ep-something). Thus I've included Russell in the cc.

-- 
With best wishes
Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 716926B0096
	for <linux-mm@kvack.org>; Wed,  6 May 2009 10:03:31 -0400 (EDT)
Message-ID: <4A01987A.6070002@redhat.com>
Date: Wed, 06 May 2009 17:02:34 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] ksm: dont allow overlap memory addresses registrations.
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <4A00DD4F.8010101@redhat.com> <4A015C69.7010600@redhat.com> <4A0181EA.3070600@redhat.com> <20090506131735.GW16078@random.random> <Pine.LNX.4.64.0905061424480.19190@blonde.anvils>
In-Reply-To: <Pine.LNX.4.64.0905061424480.19190@blonde.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 6 May 2009, Andrea Arcangeli wrote:
>   
>> For example for the swapping of KSM pages we've been thinking of using
>> external rmap hooks to avoid the VM to know anything specific to KSM
>> pages but to still allow their unmapping and swap.
>>     
>
> There may prove to be various reasons why it wouldn't work out in practice;
> but when thinking of swapping them, it is worth considering if those KSM
> pages can just be assigned to a tmpfs file, then leave the swapping to that.
>
> Hugh
>   

The problem here (as i see it) is reverse mapping for this vmas that 
point into the shared page.
Right now linux use the ->index to find this pages and then unpresent 
them...
But even if we move into allocating them inside tmpfs, who will know how 
to unpresent the virtual addresses when we want to swap the page?

I had old patch that did that extrnal rmap thing, it added few callbacks 
inside rmap.c (you had AnonPage FilePage and ExtRmapPage) and if any 
driver wanted to mangae the reverse mapping by itself it would just 
marked the pages as ExtRmapPages and will then tell the 
try_to_unmap_one() the virtual address it need to unmap...

As far as i remember it required some small changes into memory.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

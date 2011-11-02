Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 59C966B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 11:45:08 -0400 (EDT)
Message-ID: <4EB16572.70209@redhat.com>
Date: Wed, 02 Nov 2011 17:44:50 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>  <75efb251-7a5e-4aca-91e2-f85627090363@default>  <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>  <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>  <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>  <20111031181651.GF3466@redhat.com> <1320142590.7701.64.camel@dabdike>
In-Reply-To: <1320142590.7701.64.camel@dabdike>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On 11/01/2011 12:16 PM, James Bottomley wrote:
> Actually, I think there's an unexpressed fifth requirement:
>
> 5. The optimised use case should be for non-paging situations.
>
> The problem here is that almost every data centre person tries very hard
> to make sure their systems never tip into the swap zone.  A lot of
> hosting datacentres use tons of cgroup controllers for this and
> deliberately never configure swap which makes transcendent memory
> useless to them under the current API.  I'm not sure this is fixable,
> but it's the reason why a large swathe of users would never be
> interested in the patches, because they by design never operate in the
> region transcended memory is currently looking to address.
>
> This isn't an inherent design flaw, but it does ask the question "is
> your design scope too narrow?"

If you look at cleancache, then it addresses this concern - it extends
pagecache through host memory.  When dropping a page from the tail of
the LRU it first goes into tmem, and when reading in a page from disk
you first try to read it from tmem.  However in many workloads,
cleancache is actually detrimental.  If you have a lot of cache misses,
then every one of them causes a pointless vmexit; considering that
servers today can chew hundreds of megabytes per second, this adds up. 
On the other side, if you have a use-once workload, then every page that
falls of the tail of the LRU causes a vmexit and a pointless page copy.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

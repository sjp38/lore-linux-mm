Received: by pproxy.gmail.com with SMTP id z74so551918pyg
        for <linux-mm@kvack.org>; Sat, 11 Mar 2006 03:52:53 -0800 (PST)
Message-ID: <aec7e5c30603110352u4a18825ai1aaa6c5eac04685d@mail.gmail.com>
Date: Sat, 11 Mar 2006 20:52:53 +0900
From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [PATCH 00/03] Unmapped: Separate unmapped and mapped pages
In-Reply-To: <1141999506.2876.45.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060310034412.8340.90939.sendpatchset@cherry.local>
	 <1141977139.2876.15.camel@laptopd505.fenrus.org>
	 <aec7e5c30603100519l5a68aec3ub838ac69a734a46b@mail.gmail.com>
	 <1141999506.2876.45.camel@laptopd505.fenrus.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Magnus Damm <magnus@valinux.co.jp>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/10/06, Arjan van de Ven <arjan@infradead.org> wrote:
> On Fri, 2006-03-10 at 14:19 +0100, Magnus Damm wrote:
> > My current code just extends this idea which basically means that
> > there is currently no relation between how many pages that sit in each
> > LRU. The LRU with the largest amount of pages will be shrunk/rotated
> > first. And on top of that is the guarantee logic and the
> > reclaim_mapped threshold, ie the unmapped LRU will be shrunk first by
> > default.
>
> that sounds wrong, you lose history this way. There is NO reason to
> shrink only the unmapped LRU and not the mapped one. At minimum you
> always need to pressure both. How you pressure (absolute versus
> percentage) is an interesting question, but to me there is no doubt that
> you always need to pressure both, and "equally" to some measure of equal

Regarding if shrinking the unmapped LRU only is bad or not: In the
vanilla version of refill_inactive_zone(), if reclaim_mapped is false
then mapped pages are rotated on the active list without the
young-bits are getting cleared in the PTE:s. I would say this is very
similar to leaving the pages on the mapped active list alone as long
as reclaim_mapped is false in the dual LRU case. Do you agree?

Also, losing history, do you mean that the order of the pages are not
kept? If so, then I think my refill_inactive_zone() rant above shows
that the order of the pages are not kept today. But yes, keeping the
order is probaly a good idea.

It would be interesting to hear what you mean by "pressure", do you
mean that both the active list and inactive list are scanned?

Many thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

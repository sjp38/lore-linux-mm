Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B13D26B01B2
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 21:37:51 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5S1bnHc001072
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 28 Jun 2010 10:37:49 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ED29745DE7A
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:37:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CAEFF45DE6E
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:37:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ACACA1DB803A
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:37:48 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C6011DB8040
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 10:37:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: zone_reclaim don't call disable_swap_token()
In-Reply-To: <AANLkTikm9fXmGoE1phY7vgQcMsS9_FVAvPHgtt1hnvTV@mail.gmail.com>
References: <20100625173002.8052.A69D9226@jp.fujitsu.com> <AANLkTikm9fXmGoE1phY7vgQcMsS9_FVAvPHgtt1hnvTV@mail.gmail.com>
Message-Id: <20100628103508.3870.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon, 28 Jun 2010 10:37:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Fri, Jun 25, 2010 at 5:31 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > Swap token don't works when zone reclaim is enabled since it was born.
> > Because __zone_reclaim() always call disable_swap_token()
> > unconditionally.
> >
> > This kill swap token feature completely. As far as I know, nobody want
> > to that. Remove it.
> >
> 
> In f7b7fd8f3ebbb, Rik added disable_swap_token.
> At that time, sc.priority in zone_reclaim is zero so it does make sense.
> But in a92f71263a, Christoph changed the priority to begin from
> ZONE_RECLAIM_PRIORITY with remained disable_swap_token. It doesn't
> make sense.
> 
> So doesn't we add disable_swap_token following as than removing?

f7b7fd8f3ebbb says disable_swap_token was introduced to prevent OOM.
but zone reclaim failure don't make OOM. instead, fallback to try_to_free_pages().

If the system have really heavy pressure, do_try_to_free_pages()
will call disable_swap_token().

So, What benefit is there?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

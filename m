Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AB0FE6B005A
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 23:48:32 -0400 (EDT)
Received: by iwn34 with SMTP id 34so2498856iwn.12
        for <linux-mm@kvack.org>; Tue, 06 Oct 2009 20:48:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <604427e00910061559v34590d49x4cdd01b16df6fb1e@mail.gmail.com>
References: <20091006112803.5FA5.A69D9226@jp.fujitsu.com>
	 <20091006114052.5FAA.A69D9226@jp.fujitsu.com>
	 <604427e00910061559v34590d49x4cdd01b16df6fb1e@mail.gmail.com>
Date: Wed, 7 Oct 2009 12:48:31 +0900
Message-ID: <2f11576a0910062048j1967de28ve33a134df6d4ab9c@mail.gmail.com>
Subject: Re: [PATCH 2/2] mlock use lru_add_drain_all_async()
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Oleg Nesterov <oleg@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

> Hello=A0KOSAKI-san,
>
> Few questions on the lru_add_drain_all_async(). If i understand
> correctly, the reason that we have lru_add_drain_all() in the mlock()
> call is to isolate mlocked pages into the separate LRU in case they
> are sitting in pagevec.
>
> And I also understand the RT use cases you put in the patch
> description, now my questions is that do we have race after applying
> the patch? For example that if the RT task not giving up the cpu by
> the time mlock returns, you have pages left in the pagevec which not
> being drained back to the lru list. Do we have problem with that?

This patch don't introduce new race. current code has following race.

1. call mlock
2. lru_add_drain_all()
3. another cpu grab the page into its pagevec
4. actual PG_mlocked processing

I'd like to explain why this code works. linux has VM_LOCKED in vma
and PG_mlocked in page.  if we failed to turn on PG_mlocked, we can
recover it at vmscan phase by VM_LOCKED.

Then, this patch effect are
  - increase race possibility a bit
  - decrease RT-task problem risk

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

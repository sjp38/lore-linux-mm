Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C04A76B004F
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 11:39:02 -0400 (EDT)
Received: by vws6 with SMTP id 6so702076vws.12
        for <linux-mm@kvack.org>; Wed, 09 Sep 2009 08:39:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090909131945.0CF5.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.1.10.0909081110450.30203@V090114053VZO-1>
	 <alpine.DEB.1.10.0909081124240.30203@V090114053VZO-1>
	 <20090909131945.0CF5.A69D9226@jp.fujitsu.com>
Date: Thu, 10 Sep 2009 00:39:02 +0900
Message-ID: <28c262360909090839j626ff818of930cf13a6185123@mail.gmail.com>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 9, 2009 at 1:27 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> The usefulness of a scheme like this requires:
>>
>> 1. There are cpus that continually execute user space code
>> =A0 =A0without system interaction.
>>
>> 2. There are repeated VM activities that require page isolation /
>> =A0 =A0migration.
>>
>> The first page isolation activity will then clear the lru caches of the
>> processes doing number crunching in user space (and therefore the first
>> isolation will still interrupt). The second and following isolation will
>> then no longer interrupt the processes.
>>
>> 2. is rare. So the question is if the additional code in the LRU handlin=
g
>> can be justified. If lru handling is not time sensitive then yes.
>
> Christoph, I'd like to discuss a bit related (and almost unrelated) thing=
.
> I think page migration don't need lru_add_drain_all() as synchronous, bec=
ause
> page migration have 10 times retry.
>
> Then asynchronous lru_add_drain_all() cause
>
> =A0- if system isn't under heavy pressure, retry succussfull.
> =A0- if system is under heavy pressure or RT-thread work busy busy loop, =
retry failure.
>
> I don't think this is problematic bahavior. Also, mlock can use asynchrou=
nous lru drain.

I think, more exactly, we don't have to drain lru pages for mlocking.
Mlocked pages will go into unevictable lru due to
try_to_unmap when shrink of lru happens.
How about removing draining in case of mlock?

>
> What do you think?
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

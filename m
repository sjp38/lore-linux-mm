Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F38536B00BC
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 09:48:31 -0400 (EDT)
Received: by pzk30 with SMTP id 30so1025543pzk.12
        for <linux-mm@kvack.org>; Mon, 15 Mar 2010 06:48:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100315160919.c46fcc5a.kamezawa.hiroyu@jp.fujitsu.com>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	 <1268412087-13536-3-git-send-email-mel@csn.ul.ie>
	 <28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com>
	 <20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262361003142328w610f0478sbc17880ffa454fe8@mail.gmail.com>
	 <20100315154459.c665f68d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100315160919.c46fcc5a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 15 Mar 2010 22:48:25 +0900
Message-ID: <28c262361003150648v59baf43cx829248c33b4ce607@mail.gmail.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 4:09 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 15 Mar 2010 15:44:59 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> On Mon, 15 Mar 2010 15:28:15 +0900
>> Minchan Kim <minchan.kim@gmail.com> wrote:
>>
>> > On Mon, Mar 15, 2010 at 2:34 PM, KAMEZAWA Hiroyuki
>> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > > On Mon, 15 Mar 2010 09:28:08 +0900
>> > > Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> > I think above scenario make error "use-after-free", again.
>> > What prevent above scenario?
>> >
>> I think this patch is not complete.
>> I guess this patch in [1/11] is trigger for the race.
>> =3D=3D
>> +
>> + =C2=A0 =C2=A0 /* Drop an anon_vma reference if we took one */
>> + =C2=A0 =C2=A0 if (anon_vma && atomic_dec_and_lock(&anon_vma->migrate_r=
efcount, &anon_vma->lock)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int empty =3D list_empty(&an=
on_vma->head);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&anon_vma->lock)=
;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (empty)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
anon_vma_free(anon_vma);
>> + =C2=A0 =C2=A0 }
>> =3D=3D
>> If my understainding in above is correct, this "modify" freed anon_vma.
>> Then, use-after-free happens. (In old implementation, there are no refcn=
t,
>> so, there is no use-after-free ops.)
>>
> Sorry, about above, my understanding was wrong. anon_vma->lock is modifed=
 even
> in old code. Sorry for noise.

Nope.  Such your kindness always helps and cheer up others people.
In addition, give others good time to consider seriously something.

Thanks, Kame.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

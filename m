Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 135F86B01F5
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 06:07:58 -0400 (EDT)
Received: by pwi10 with SMTP id 10so2231972pwi.14
        for <linux-mm@kvack.org>; Mon, 26 Apr 2010 03:07:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100426184908.3c277568.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100423095922.GJ30306@csn.ul.ie> <20100423155801.GA14351@csn.ul.ie>
	 <20100424110200.b491ec5f.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100424104324.GD14351@csn.ul.ie>
	 <20100426084901.15c09a29.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100426182838.2cab9844.kamezawa.hiroyu@jp.fujitsu.com>
	 <r2o28c262361004260248s62729484g14a720d37d5916f7@mail.gmail.com>
	 <20100426184908.3c277568.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 26 Apr 2010 19:07:56 +0900
Message-ID: <z2y28c262361004260307m22f38d23y95c5615072b8f3a7@mail.gmail.com>
Subject: Re: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 26, 2010 at 6:49 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 26 Apr 2010 18:48:42 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Mon, Apr 26, 2010 at 6:28 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Mon, 26 Apr 2010 08:49:01 +0900
>> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >
>> >> On Sat, 24 Apr 2010 11:43:24 +0100
>> >> Mel Gorman <mel@csn.ul.ie> wrote:
>> >
>> >> > It looks nice but it still broke after 28 hours of running. The
>> >> > seq-counter is still insufficient to catch all changes that are mad=
e to
>> >> > the list. I'm beginning to wonder if a) this really can be fully sa=
fely
>> >> > locked with the anon_vma changes and b) if it has to be a spinlock =
to
>> >> > catch the majority of cases but still a lazy cleanup if there happe=
ns to
>> >> > be a race. It's unsatisfactory and I'm expecting I'll either have s=
ome
>> >> > insight to the new anon_vma changes that allow it to be locked or R=
ik
>> >> > knows how to restore the original behaviour which as Andrea pointed=
 out
>> >> > was safe.
>> >> >
>> >> Ouch.
>> >
>> > Ok, reproduced. Here is status in my test + printk().
>> >
>> > =C2=A0* A race doesn't seem to happen if swap=3Doff.
>> > =C2=A0 =C2=A0I need to swapon to cause the bug
>>
>> FYI,
>>
>> Do you have a swapon/off bomb test?
>
> No. Just running test under swapoff, and running the same test after swap=
on.
>
>
>> When I saw your mail, I feel it might be culprit.
>>
>> http://lkml.org/lkml/2010/4/22/762.
>>
>> It is just guessing. I don't have a time to look into, now.
>>
> Hmm. BTW.
>
> =3D=3D
> static int expand_downwards(struct vm_area_struct *vma,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long address)
> {
> =C2=A0 ....
> =C2=A0 =C2=A0 =C2=A0 /* Somebody else might have raced and expanded it al=
ready */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (address < vma->vm_start) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long size=
, grow;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0size =3D vma->vm_e=
nd - address;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0grow =3D (vma->vm_=
start - address) >> PAGE_SHIFT;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D acct_sta=
ck_growth(vma, size, grow);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!error) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0vma->vm_start =3D address;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0vma->vm_pgoff -=3D grow;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =3D=3D
>
> I feel this part needs care. No ?

Yes. Andrea pointed it out.
I didn't followed the thread whole yet but It seems Mel and Andrea
want to restore anon_vma's atomicity like old than one by one healing.



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

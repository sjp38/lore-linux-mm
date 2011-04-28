Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CA53B6B002C
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:53:01 -0400 (EDT)
Date: Thu, 28 Apr 2011 11:52:57 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <1304008533.3360.88.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1104281152110.18213@router.home>
References: <20110427102034.GE31015@htj.dyndns.org>  <1303961284.3981.318.camel@sli10-conroe>  <20110428100938.GA10721@htj.dyndns.org>  <alpine.DEB.2.00.1104280904240.15775@router.home>  <20110428142331.GA16552@htj.dyndns.org>  <alpine.DEB.2.00.1104280935460.16323@router.home>
  <20110428144446.GC16552@htj.dyndns.org>  <alpine.DEB.2.00.1104280951480.16323@router.home>  <20110428145657.GD16552@htj.dyndns.org>  <alpine.DEB.2.00.1104281003000.16323@router.home>  <20110428151203.GE16552@htj.dyndns.org>  <alpine.DEB.2.00.1104281017240.16323@router.home>
  <1304005726.3360.69.camel@edumazet-laptop>  <1304006345.3360.72.camel@edumazet-laptop>  <alpine.DEB.2.00.1104281116270.18213@router.home> <1304008533.3360.88.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1505610529-1304009578=:18213"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Shaohua Li <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1505610529-1304009578=:18213
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE


On Thu, 28 Apr 2011, Eric Dumazet wrote:

> Le jeudi 28 avril 2011 =C3=A0 11:17 -0500, Christoph Lameter a =C3=A9crit=
 :
> > On Thu, 28 Apr 2011, Eric Dumazet wrote:
> >
> > > > If _sum() notices seqcount was changed too much, restart the loop.
> >
> > This does not address the issue of cpus adding batch -1 while the
> > loop is going on.
>
>
> Yes, it does, I left the needed changes to write side as an exercice ;)
>
>
> For example, based on current linux-2.6 code
>
>
> void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 bat=
ch)
> {
>         s64 count;
>
>         preempt_disable();
>         count =3D __this_cpu_read(*fbc->counters) + amount;
>         if (count >=3D batch || count <=3D -batch) {
>                 spin_lock(&fbc->lock);
> =09=09fbc->seqcount++;
>                 fbc->count +=3D count;
>                 __this_cpu_write(*fbc->counters, 0);
>                 spin_unlock(&fbc->lock);
>         } else {
>                 __this_cpu_write(*fbc->counters, count);
>         }
>         preempt_enable();
> }

I can still add (batch - 1) without causing the seqcount to be
incremented.

---1463811839-1505610529-1304009578=:18213--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

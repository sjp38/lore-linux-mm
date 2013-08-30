Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 26CF76B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 12:31:42 -0400 (EDT)
Received: by mail-qe0-f51.google.com with SMTP id cy11so1070586qeb.24
        for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:31:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALE5RAvaa4bb-9xAnBe07Yp2n+Nn4uGEgqpLrKMuOE8hhZv00Q@mail.gmail.com>
References: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
	<CA+icZUVbUD1tUa_ORtn_ZZebpp3gXXHGAcNe0NdYPXPMPoABuA@mail.gmail.com>
	<1372192414.1888.8.camel@buesod1.americas.hpqcorp.net>
	<CA+icZUXgOd=URJBH5MGAZKdvdkMpFt+5mRxtzuDzq_vFHpoc2A@mail.gmail.com>
	<1372202983.1888.22.camel@buesod1.americas.hpqcorp.net>
	<521DE5D7.4040305@synopsys.com>
	<CA+icZUUrZG8pYqKcHY3DcYAuuw=vbdUvs6ZXDq5meBMjj6suFg@mail.gmail.com>
	<C2D7FE5348E1B147BCA15975FBA23075140FA3@IN01WEMBXA.internal.synopsys.com>
	<CA+icZUUn-r8iq6TVMAKmgJpQm4FhOE4b4QN_Yy=1L=0Up=rkBA@mail.gmail.com>
	<52205597.3090609@synopsys.com>
	<CA+icZUW=YXMC_2Qt=cYYz6w_fVW8TS4=Pvbx7BGtzjGt+31rLQ@mail.gmail.com>
	<C2D7FE5348E1B147BCA15975FBA230751411CB@IN01WEMBXA.internal.synopsys.com>
	<CALE5RAvaa4bb-9xAnBe07Yp2n+Nn4uGEgqpLrKMuOE8hhZv00Q@mail.gmail.com>
Date: Fri, 30 Aug 2013 13:31:41 -0300
Message-ID: <CAMJEocr1SgxQw0bEzB3Ti9bvRY74TE5y9e+PLUsAL1mJbK=-ew@mail.gmail.com>
Subject: Re: ipc-msg broken again on 3.11-rc7?
From: Davidlohr Bueso <dave.bueso@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>, sedat.dilek@gmail.com, linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Manfred Spraul <manfred@colorfullife.com>, Jonathan Gonzalez <jgonzalez@linets.cl>

> From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
> Date: Fri, Aug 30, 2013 at 4:46 AM
> Subject: Re: ipc-msg broken again on 3.11-rc7?
> To: "sedat.dilek@gmail.com" <sedat.dilek@gmail.com>
> Cc: linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <davi=
dlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-k=
ernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Mor=
ton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen =
<andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Manfred Spraul <manf=
red@colorfullife.com>, Jonathan Gonzalez <jgonzalez@linets.cl>
>
>
> On 08/30/2013 01:57 PM, Sedat Dilek wrote:
> > On Fri, Aug 30, 2013 at 10:19 AM, Vineet Gupta <vineetg76@gmail.com> wr=
ote:
> >> Ping ?
> >>
> >> It seems 3.11 is pretty close to releasing but we stil have LTP msgctl=
08 causing a
> >> hang (atleast on ARC) for both linux-next 20130829 as well as Linus tr=
ee.
> >>
> >> So far, I haven't seemed to have drawn attention of people involved.
> >>

I apologize for the delay, I am on vacations and wasnt interrupting my
days at the beach by checking email.

You mention that the msgctl08 test case just hangs, nothing
interesting in dmesg appart from "msgmni has been set to 479" (which
is a standard initialization message anyways)?

After a quick glance, I suspect that the problem might be because we
are calling security_msg_queue_msgsnd() without taking the lock. This
is similar to the issue Sedat reported in the original thread with
find_msg() concerning msgrcv. The rest of the code looks otherwise
standard. Unfortunately I dont have a computer available to write/test
such a fix. I think we can move calls to security_msg_queue_msgsnd()
to be done right before ss_add(), which would simplify the code
changes, something like:

...

/* queue full, wait: */
if (msgflg & IPC_NOWAIT) {
     err =3D -EAGAIN;
     goto out_unlock1;
}

ipc_lock_object(&msq->q_perm);
err =3D security_msg_queue_msgsnd(msq, msg, msgflg);
if (err)
    goto out_unlock0;

ss_add(msq, &s);

...


Thanks,
Davidlohr


> >
> > Hi Vineet,
> >
> > I remember fakeroot was an another good test-case for me to test this
> > IPC breakage.
> > Attached is my build-script for Linux-next (tested with Debian/Ubuntu).
> > ( Cannot say if you can play with it in your environment. )
>
> Hi Sedat,
>
> I have a simpler buildroot based rootfs (initramfs based) and LTP is run =
off of
> NFS, although running of a local storage doesn't make a difference.
>
> For me msgctl08 standalone (w/o hassle of running full LTP) is enough to =
trigger
> it consistently.
>
> P.S. sorry my sender address kept flipping - mailer was broken !
>
> -Vineet
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

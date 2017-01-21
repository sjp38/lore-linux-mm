Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7ADA86B0038
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 19:11:54 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id c7so18301910wjb.7
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 16:11:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z38si9743585wrc.101.2017.01.20.16.11.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 16:11:53 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Sat, 21 Jan 2017 11:11:41 +1100
Subject: Re: [ATTEND] many topics
In-Reply-To: <20170119121135.GR30786@dhcp22.suse.cz>
References: <20170118054945.GD18349@bombadil.infradead.org> <20170118133243.GB7021@dhcp22.suse.cz> <20170119110513.GA22816@bombadil.infradead.org> <20170119113317.GO30786@dhcp22.suse.cz> <20170119115243.GB22816@bombadil.infradead.org> <20170119121135.GR30786@dhcp22.suse.cz>
Message-ID: <878tq5ff0i.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, willy@bombadil.infradead.org
Cc: willy@infradead.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 19 2017, Michal Hocko wrote:

> On Thu 19-01-17 03:52:43, willy@bombadil.infradead.org wrote:
>> On Thu, Jan 19, 2017 at 12:33:17PM +0100, Michal Hocko wrote:
>> > On Thu 19-01-17 03:05:13, willy@infradead.org wrote:
>> > > Let me rephrase the topic ... Under what conditions should somebody =
use
>> > > the GFP_TEMPORARY gfp_t?
>> >=20
>> > Most users of slab (kmalloc) do not really have to care. Slab will add
>> > __GFP_RECLAIMABLE to all reclaimable caches automagically AFAIR. The
>> > remaining would have to implement some kind of shrinker to allow the
>> > reclaim.
>>=20
>> I seem to be not making myself clear.  Picture me writing a device drive=
r.
>> When should I use GFP_TEMPORARY?
>
> I guess the original intention was to use this flag for allocations
> which will be either freed shortly or they are reclaimable.

I would really like to see GFP_TEMPORARY described as a contract, rather
than in terms of implementation details.
What are the benefits of using it, and what are the costs?

For example, with GFP_NOFS, we know that the benefits are "no recursion
into the filesystem for reclaim" and hence no deadlocks.  The costs are
that failure is more likely.  So it is easy to know when to use it, and
it is easy to see if either side breaks the contract.

What are the benefits of GFP_TEMPORARY?  Presumably it doesn't guarantee
success any more than GFP_KERNEL does, but maybe it is slightly less
likely to fail, and somewhat less likely to block for a long time??  But
without some sort of promise, I wonder why anyone would use the
flag.  Is there a promise?  Or is it just "you can be nice to the MM
layer by setting this flag sometimes". ???

And what, exactly, are the costs?  How soon is "shortly".  Below you say
"not forever" which very very different to "shortly", at least it is on
my calendar=20

I would like to suggest:

  GFP_TEMPORARY should be used when the memory allocated will either be
  freed, or will be placed in a reclaimable cache, before the process
  which allocated it enters an TASK_INTERRUPTIBLE sleep or returns to
  user-space.  It allows access to memory which is usually reserved for
  XXX and so can be expected to succeed more quickly during times of
  high memory pressure.

Using GFP_TEMPORARY would then help make the code self-documenting and
might improve behaviour under memory pressure in some cases.  It would
also be clear whether a particular was not correct, if a change in
behaviour of the MM would be consistent.

The rules given here might be more strict that necessary with the current
implementation, but they are clear and measurable.  This gives room for
code to change in the future without breaking things.

NeilBrown




>=20=20
>> > > Example usages that I have questions about:
>> > >=20
>> > > 1. Is it permissible to call kmalloc(GFP_TEMPORARY), or is it only
>> > > for alloc_pages?
>> >=20
>> > kmalloc will use it internally as mentioned above.  I am not even sure
>> > whether direct using of kmalloc(GFP_TEMPORARY) is ok.  I would have to
>> > check the code but I guess it would be just wrong unless you know your
>> > cache is reclaimable.
>>=20
>> You're not using words that have any meaning to a device driver writer.
>> Here's my code:
>>=20
>> int foo_ioctl(..)
>> {
>> 	struct foo *foo =3D kmalloc(sizeof(*foo), GFP_TEMPORARY);
>> }
>>=20
>> Does this work?  If not, should it?  Or should slab be checking for
>> this and calling WARN()?
>
> I would have to check the code but I believe that this shouldn't be
> harmful other than increase the fragmentation.
>
>> > > I ask because if the slab allocator is unaware of
>> > > GFP_TEMPORARY, then a non-GFP_TEMPORARY allocation may be placed in a
>> > > page allocated with GFP_TEMPORARY and we've just made it meaningless.
>> > >=20
>> > > 2. Is it permissible to sleep while holding a GFP_TEMPORARY allocati=
on?
>> > > eg, take a mutex, or wait_for_completion()?
>> >=20
>> > Yes, GFP_TEMPORARY has ___GFP_DIRECT_RECLAIM set so this is by
>> > definition sleepable allocation request.
>>=20
>> Again, we're talking past each other.  Can foo_ioctl() sleep before
>> releasing its GFP_TEMPORARY allocation, or will that make the memory
>> allocator unhappy?
>
> I do not think it would make the allocator unhappy as long as the sleep
> is not for ever...
>
>> > > 3. Can I make one GFP_TEMPORARY allocation, and then another one?
>> >=20
>> > Not sure I understand. WHy would be a problem?
>>=20
>> As you say above, GFP_TEMPORARY may sleep, so this is a variation on the=
 "can I sleep while holding a GFP_TEMPORARY allocation" question.
>>=20
>> > > 4. Should I disable preemption while holding a GFP_TEMPORARY allocat=
ion,
>> > > or are we OK with a task being preempted?
>> >=20
>> > no, it can sleep.
>> >=20
>> > > 5. What about something even longer duration like allocating a kiocb?
>> > > That might take an arbitrary length of time to be freed, but eventua=
lly
>> > > the command will be timed out (eg 30 seconds for something that ends=
 up
>> > > going through SCSI).
>> >=20
>> > I do not understand. The reclaimability of the object is in hands of t=
he
>> > respective shrinker...
>>=20
>> There is no shrinker here.  This is about the object being "temporary",
>> for some value of temporary.  I want to nail down what the MM is willing
>> to tolerate in terms of length of time an object is allocated for.
>
> From my understanding MM will use the information for optimizing objects
> placing and the longer the user will use that memory the worse this
> optimization works. I do not think the (ab)use would be fatal...
>=20=20
>> > > 6. Or shorter duration like doing a GFP_TEMPORARY allocation, then t=
aking
>> > > a spinlock, which *probably* isn't contended, but you never know.
>> > >=20
>> > > 7. I can see it includes __GFP_WAIT so it's not suitable for using f=
rom
>> > > interrupt context, but interrupt context might be the place which can
>> > > benefit from it the most.  Or does GFP_ATOMIC's __GFP_HIGH also allo=
w for
>> > > allocation from the movable zone?  Should we have a GFP_TEMPORARY_AT=
OMIC?
>> >=20
>> > This is where __GFP_RECLAIMABLE should be used as this is the core of
>> > the functionality.
>>=20
>> This response also doesn't make sense to me.
>
> I meant to say that such an allocation can use __GFP_RECLAIMABLE | __GFP_=
NOWAIT.
>
>
> --=20
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliCpz0ACgkQOeye3VZi
gbmkoA//dBq2JSshDSz/t0MugytzW2cqrc7RCc4NPnxpx7I00RcpVzReyPJFX8ke
TJ2xAOOKiaW4kmkBn1QnQtYxspOi5I9mDecCo7bbGaeriTQzpi7PmWmittU93aTU
8AfnaeyhDHzvyp0ol3AYarfp0It5sRFMUcGbMK2g2YeKrs7BFDWGzBgNCl3Ft5FT
UqD89qvJ9ziw1duoF3WNN4ouivNT7TdG/Rr17MOtBYI96xr7w6Cv0udCbznIFOF7
wxPGG14TLEKPvHTblPaCze4M1zyhRX3/gD5PPBcnySYaFuBjGZMj1yLtuc6De4xv
McPC/f30T44MvaSDAN53BKpUyTyAeLmn3VRbXc2ZpQhTEfAMXau+X0YGGr7do3ce
pPlswfwyLijmLbpVjGj8X0XLizQWUTlEcUUh6IcKNDz9tG5RXT9yDB59mpi+QsXc
kbjy8iv+9NdJNul40tFtqltO6JzyvYvTbWc+HvmysDDJabWuwW+Egnm2sA9oNng5
06y4CXsGDkOX2RBwuaafoFuhsZMouBtmjXD9+X3vowqs5QR6bAMGq8rXh5S9UMM1
VRgoyAsA3k3d+fkWz+pG4Ybyh6BEUKseP4AtG3hZ+fISKsvryRwgCphY8OugviwT
fmbrsx5OXvZk5Sx0+WU+adGunriSSeiGdv17QOuObpCR1efYWIM=
=OvbD
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

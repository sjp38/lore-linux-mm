Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 499516B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 15:01:38 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id n2so15875400pgs.0
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 12:01:38 -0800 (PST)
Received: from anholt.net (anholt.net. [50.246.234.109])
        by mx.google.com with ESMTP id w14si6482725pgv.95.2018.01.18.12.01.36
        for <linux-mm@kvack.org>;
        Thu, 18 Jan 2018 12:01:36 -0800 (PST)
From: Eric Anholt <eric@anholt.net>
Subject: Re: [RFC] Per file OOM badness
In-Reply-To: <20180118171355.GH6584@dhcp22.suse.cz>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com> <20180118170006.GG6584@dhcp22.suse.cz> <20180118171355.GH6584@dhcp22.suse.cz>
Date: Thu, 18 Jan 2018 12:01:32 -0800
Message-ID: <87k1wfgcmb.fsf@anholt.net>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrey Grodzovsky <andrey.grodzovsky@amd.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org, Christian.Koenig@amd.com

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Michal Hocko <mhocko@kernel.org> writes:

> On Thu 18-01-18 18:00:06, Michal Hocko wrote:
>> On Thu 18-01-18 11:47:48, Andrey Grodzovsky wrote:
>> > Hi, this series is a revised version of an RFC sent by Christian K=C3=
=B6nig
>> > a few years ago. The original RFC can be found at=20
>> > https://lists.freedesktop.org/archives/dri-devel/2015-September/089778=
.html
>> >=20
>> > This is the same idea and I've just adressed his concern from the orig=
inal RFC=20
>> > and switched to a callback into file_ops instead of a new member in st=
ruct file.
>>=20
>> Please add the full description to the cover letter and do not make
>> people hunt links.
>>=20
>> Here is the origin cover letter text
>> : I'm currently working on the issue that when device drivers allocate m=
emory on
>> : behalf of an application the OOM killer usually doesn't knew about tha=
t unless
>> : the application also get this memory mapped into their address space.
>> :=20
>> : This is especially annoying for graphics drivers where a lot of the VR=
AM
>> : usually isn't CPU accessible and so doesn't make sense to map into the
>> : address space of the process using it.
>> :=20
>> : The problem now is that when an application starts to use a lot of VRA=
M those
>> : buffers objects sooner or later get swapped out to system memory, but =
when we
>> : now run into an out of memory situation the OOM killer obviously doesn=
't knew
>> : anything about that memory and so usually kills the wrong process.
>
> OK, but how do you attribute that memory to a particular OOM killable
> entity? And how do you actually enforce that those resources get freed
> on the oom killer action?
>
>> : The following set of patches tries to address this problem by introduc=
ing a per
>> : file OOM badness score, which device drivers can use to give the OOM k=
iller a
>> : hint how many resources are bound to a file descriptor so that it can =
make
>> : better decisions which process to kill.
>
> But files are not killable, they can be shared... In other words this
> doesn't help the oom killer to make an educated guess at all.

Maybe some more context would help the discussion?

The struct file in patch 3 is the DRM fd.  That's effectively "my
process's interface to talking to the GPU" not "a single GPU resource".
Once that file is closed, all of the process's private, idle GPU buffers
will be immediately freed (this will be most of their allocations), and
some will be freed once the GPU completes some work (this will be most
of the rest of their allocations).

Some GEM BOs won't be freed just by closing the fd, if they've been
shared between processes.  Those are usually about 8-24MB total in a
process, rather than the GBs that modern apps use (or that our testcases
like to allocate and thus trigger oomkilling of the test harness instead
of the offending testcase...)

Even if we just had the private+idle buffers being accounted in OOM
badness, that would be a huge step forward in system reliability.

>> : So question at every one: What do you think about this approach?
>
> I thing is just just wrong semantically. Non-reclaimable memory is a
> pain, especially when there is way too much of it. If you can free that
> memory somehow then you can hook into slab shrinker API and react on the
> memory pressure. If you can account such a memory to a particular
> process and make sure that the consumption is bound by the process life
> time then we can think of an accounting that oom_badness can consider
> when selecting a victim.

For graphics, we can't free most of our memory without also effectively
killing the process.  i915 and vc4 have "purgeable" interfaces for
userspace (on i915 this is exposed all the way to GL applications and is
hooked into shrinker, and on vc4 this is so far just used for
userspace-internal buffer caches to be purged when a CMA allocation
fails).  However, those purgeable pools are expected to be a tiny
fraction of the GPU allocations by the process.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE/JuuFDWp9/ZkuCBXtdYpNtH8nugFAlpg/RwACgkQtdYpNtH8
nuiPLRAAnjetiPTPfCfkxSyNF2jHTmCmFPkrVUNwJLy+oF2LOSmpBe6ufK+fF0c9
Fe+guvaRPZ4QNQMdM7DIYO7QO1o+CcpmvTwAAQVPxDN7w/3jo+Unm0pE5/3Hpws7
sRQADYSUhzbXm3XZ8bbpKxObPg04ebYdYR4BtPbSnE59PC0c7tqj7vx+P8WROV8y
4fPnY9xcCxnSjb9O6q8CagL5G5wgKA6YP4RLMv1KQhmiCKwQ7j4DDtbcMT6tmyqu
FykbVX09F++jUCRfmA9FJmWNYeYEqyS4eSQd336pI+2AT2XkmQcyLsJuML5Or7Bp
pGwjK4mC1n8b8HkHnGIihVKKG/CSG5pHgG5d1KcT3Vd6Kkz1eIbO7LRdAXp/hkw8
senGxs86ejxNDnQ75rylk+grpVzHy9zWJ5ltnqKHtvYhhBCamOsBwMAC7ZH7cvSK
7MEQJduOJobRrhBRS/Fdq5YXAlWXPytcIGP5IcjMql77+X2vEGAp1UhjA6xN2Uki
9TzyyIVsVmo9EnCH9xnTgCp1iHj+/faJVf8AHoiVizki2kvV3jRw5aTnVQ0B/f4y
/12R2xMaNGWW9VH1y1JZXVLVl8HFU9irvCdjm8HZn94IA03Mkhhnv4rjWBXif3P0
k/Gm1+aB2x8TWOKL99Fkv4GlagIM26uC3YBqkq0tHca2DQdncuA=
=zfLa
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
